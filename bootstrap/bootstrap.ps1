[CmdletBinding()]
param (

    [parameter (Mandatory=$true)]
    [ValidatePattern("^https://dev.azure.com/*")]
    [string]$targetOrg,

    [parameter (Mandatory=$false)]
    [boolean]$envApproveEnable = $false,

    [parameter (Mandatory=$false)]
    [string]$securityGroupName = "",

    [parameter (Mandatory=$false)]
    [string]$envApproveTimeout = "172800",

    [parameter (Mandatory=$false)]
    [string]$artifactPath = "./bootstrap-artifact",

    [parameter (Mandatory=$false)]
    [string]$workflow = "trunk",

    [parameter (Mandatory=$false)]
    [string]$wikibranch = "main",

    [parameter (Mandatory=$false)]
    [string]$configFile = "./configuration.yaml"
)

############################# Function to bootstrap a single project #############################
function Bootstrap-AzDoProject {

    param (
        [string]$targetOrg,
        [string]$project,
        [boolean]$envApproveEnable,
        [string]$securityGroupName,
        [string]$envApproveTimeout,
        [string]$filesPath,
        [string]$workflow,
        [string]$wikibranch,
        [hashtable]$authHeader,
        [string]$gitAuthHeader
    )

    ### Parse branch configuration
    if ($workflow -eq "trunk") {
        $branch = "main"
        $longLivingBranchesPolicies = @()
    }
    elseif ($workflow -eq "gitflow") {
        $branch = "develop"
        $longLivingBranchesPolicies = @("main", "release/")
    }
    else {
        Write-Error "Please choose correct workflow. There are 'trunk' and 'gitflow' avaliable."
    }

    ### Collect snapshot resourcess to bootstrap
    $snapshotConfig = Get-Content "$filesPath/snapshot.json" | ConvertFrom-Json


    ############################# Project #############################
    $projects = Get-AzDoProjects -org $targetOrg -authHeader $authHeader
    Write-Output ("Creating Azure DevOps project...")
    if ($projects.name -notcontains $project) {
        $newProject = New-AzDoProject -name $project -org $targetOrg -authHeader $authHeader
        if ($null -ne $newProject.id) { Write-Output ("ADO project '{0}' with ID '{1}' successfully created" -f $project, $newProject.id) }
        else { throw ("Can not create ADO project '{0}' in organization '{1}'. Check the PAT." -f $project, $targetOrg) }

        Write-Output ("Waiting to finalyze project setup...")

        $projects = Get-AzDoProjects -org $targetOrg -authHeader $authHeader
        $attempt = 0
        while (($projects.name -notcontains $project) -and ($attempt -le 100)) {
            Start-Sleep 1
            $attempt ++
            $projects = Get-AzDoProjects -org $targetOrg -authHeader $authHeader
        }
    }
    else { Write-Output ("ADO project '{0}' already exists" -f $project) }


    ############################# Security Group #############################
    if ($securityGroupName -ne "") {
        Write-Output ("Creating Azure DevOps security groups...")
        $securityGroups = Get-AzDoSecurityGroups -org $targetOrg -project $project -authHeader $authHeader

        if ($securityGroups.displayName -notcontains $securityGroupName) {
            $securityGroup = New-AzDoSecurityGroups -name $securityGroupName -org $targetOrg -project $project -authHeader $authHeader
            if ($null -ne $securityGroup) { Write-Output ("ADO security group '{0}' successfully created" -f $securityGroup.displayName) }
            else { Throw ("Can not create Azure DevOps security group with name '{0}' in project '{1}'" -f $securityGroupName, $project) }
        }
        else { Write-Output ("Azure DevOps security group '{0} already exists" -f $project) }
    }
    else {Write-Output "There is no configuration for Azure DevOps security group. Nothing to do."}


    ############################# Environments #############################
    if ($snapshotConfig.environments -ne "[]") {
        Write-Output ("Creating Azure DevOps environments...")
        $groupId = $securityGroup.originId

        $snapshotConfig.environments | ForEach-Object {
            $envName = $_
            $envId = (Get-AzDoEnvList -org $targetOrg -project $project -authHeader $authHeader | Where-Object {$_.name -eq $envName}).id
            if ($null -eq $envId) {
                $envId = (Add-AzDoEnv -org $targetOrg -project $project -name $_ -authHeader $authHeader).id
                if ($null -ne $envId) { Write-Output ("ADO environment '{0}' successfully created" -f $_) }
                else { Throw ("Can not create ADO environment with name '{0}' in project '{1}'" -f $_, $project) }
            }
            else { Write-Output ("ADO environment '{0}' already exists" -f $_) }

            if ($envApproveEnable -eq $true) {
                $approval = Get-AzDoEnvApproval -envId $envId -org $targetOrg -project $project -authHeader $authHeader
                if ($null -eq $approval.type.name) {
                    $arguments = @{
                        org = $targetOrg
                        project = $project
                        authHeader = $authHeader
                        envName = $_
                        envId =$envId
                        groupId = $groupId
                        approveTimeout = $envApproveTimeout
                    }
                    $approval = Add-AzDoEnvApproval @arguments

                    if ($null -ne $approval) { Write-Output ("ADO approval for environment '{0}' successfully configured" -f $approval.resource.name) }
                    else { Throw ("Can not create ADO approval for environment '{0}' in project '{1}'" -f $_, $project) }
                }
                else { Write-Output ("ADO approval for environment '{0}' already exists" -f $_)}
            }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps environments. Nothing to do."}


    ############################# Variable groups #############################
    if ($snapshotConfig.var_groups -ne "[]") {
        Write-Output ("Creating Azure DevOps variable groups...")
        $varGroups = (Get-AzDoVarGroups -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.var_groups | ForEach-Object {
            $varGroupName = $_.name

            if ($varGroups.name -notcontains $varGroupName) {
                $varGroup = New-AzDoVarGroup -name $_.name -description $_.description -variables $_.variables -org $targetOrg -project $project -authHeader $authHeader
                if ($null -ne $varGroup) { Write-Output ("ADO variable group '{0}' successfully created" -f $varGroup.name) }
                else { Throw ("Can not create ADO variable group '{0}' in project '{1}'" -f $_, $project) }

                $permission = (Set-AzDoVarGroupPipelinesPermisson -id $varGroup.id -allow $true -org $targetOrg -project $project -authHeader $authHeader).value
                if ($null -ne ($permission | Where-Object {$_.id -eq $varGroup.id})) { Write-Output ("ADO variable group '{0}' pipeline permissions successfully set" -f $varGroup.name) }
                else { Throw ("Can not set pipeline permission for ADO variable group '{0}' in project '{1}'" -f $_, $project) }
            }
            else { Write-Output ("ADO variable group '{0}' already exists" -f $varGroupName) }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps variable groups. Nothing to do."}


    ############################# Create temp repo / remove default repo #############################
    $tempRepoName = "{0}-temp-repo" -f $project
    $repos = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value

    if ($repos.name -notcontains $tempRepoName) {
        $repo = New-AzDoRepo -org $targetOrg -project $project -name $tempRepoName -authHeader $authHeader
        if ($null -ne $repo) { Write-Output ("ADO temporary repository '{0}' for replacing default repository successfully created" -f $repo.name) }
        else { Throw ("Can not create ADO temporary repository '{0}' in project '{1}'" -f $tempRepoName, $project) }
    }
    else {
        Write-Output ("ADO temporary repository '{0}' already exists." -f $tempRepoName)
    }
    ### Remove default repository
    if ($repos.name -contains $project) {
        Remove-AzDoRepo -org $targetOrg -project $project -name $project -authHeader $authHeader | Out-Null
        Write-Output ("Project default repository '{0}' removed" -f $project)
    }
    else {
        Write-Output ("Project default repository '{0}' does not exist. No action taken." -f $project)
    }


    ############################# Repositories #############################
    ### Bootstrap repositories
    if ($snapshotConfig.repositories -ne "[]") {
        Write-Output ("Creating Azure DevOps repositories...")
        $repos = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.repositories | ForEach-Object {
            $repoName = $_.name

            ### Create repo
            if ($repos.name -notcontains $repoName) {
                $repo = New-AzDoRepo -org $targetOrg -project $project -name $repoName -authHeader $authHeader
                if ($null -ne $repo) { Write-Output ("ADO repository '{0}' successfully created" -f $repo.name) }
                else { Throw ("Can not create ADO repository '{0}' in project '{1}'" -f $_, $project) }
            }
            else {
                Write-Output ("ADO repository '{0}' already exists" -f $repoName)
                Remove-AzDoRepo -org $targetOrg -project $project -name $repoName -authHeader $authHeader | Out-Null
                Write-Output ("ADO repository '{0}' removed" -f $repoName)
                $repo = New-AzDoRepo -org $targetOrg -project $project -name $repoName -authHeader $authHeader
                if ($null -ne $repo) { Write-Output ("ADO repository '{0}' successfully created" -f $repo.name) }
                else { Throw ("Can not create ADO repository '{0}' in project '{1}'" -f $_, $project) }
            }

            ### Push files
            class PushFileChanges {
                [string]$changeType = "add"
                [hashtable]$item = @{ path = "" }
                [hashtable]$newContent = @{ content = ""; contentType = "base64encoded" }
            }

            $repoPath = "$filesPath/repo_$repoName"

            $fileList = Get-ChildItem -Path $repoPath -Recurse -File -Force
            $replaceExpression = $repoPath -replace ".*\\" -replace ".*/"

            $changes = @()

            $fileList | ForEach-Object {

                ### Upload files
                $content = [System.IO.File]::ReadAllBytes($_.FullName)
                $uploadFile = [PushFileChanges]::new()
                $uploadFile.item.path = ($_.PSPath -replace ".*$replaceExpression" -replace "\\", "/")
                $uploadFile.newContent.content = [Convert]::ToBase64String($content)

                $changes += $uploadFile
            }

            $pushArguments = @{
                org = $targetOrg
                project = $project
                repoName = $repoName
                branch = $branch
                authHeader = $authHeader
            }
            $commit = Push-AdoRepoInitCommit @pusharguments -changes $changes
            if ($null -ne $commit) { Write-Output ("Initial commit to repository '{0}' for branch '{1}' successfully pushed" -f $repoName, $branch) }
            else { Throw ("Can not push Initial commit to repository '{0}' for branch '{1}' in project '{2}'" -f $repoName, $branch, $project) }

            ### Create policies
            $repoId = $repo.id
            foreach ($policyType in @('reviewers','workItemLinking','comment', 'mergeStrategy')) {
                $policyArguments = @{
                    org = $targetOrg
                    project = $project
                    repoId  = $repoId
                    policyType = $policyType
                    branches = @($branch) + $longLivingBranchesPolicies
                    authHeader = $authHeader
                }
                $policy = Set-AzDoPolicy @policyArguments
                if ($null -ne $policy) { Write-Output ("ADO branch policy for repository '{0}' successfully created" -f $repoName) }
                else { Throw ("Can not create ADO branch policy for repository '{0}' in project '{1}'" -f $repoName, $project) }
            }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps repositories. Nothing to do."}


    ############################# ReposRaw including commit history and tags #############################
    if ($snapshotConfig.reposRaw -ne "[]") {
        Write-Output ("Creating Azure DevOps repositories with full history...")
        $repos = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.reposRaw | ForEach-Object {
            $repoName = $_.name

            ### Create repo
            if ($repos.name -notcontains $repoName) {
                $repo = New-AzDoRepo -org $targetOrg -project $project -name $repoName -authHeader $authHeader
                if ($null -ne $repo) { Write-Output ("ADO repository '{0}' successfully created" -f $repo.name) }
                else { Throw ("Can not create ADO repository '{0}' in project '{1}'" -f $_, $project) }
            }
            else {
                Write-Output ("ADO repository '{0}' already exists" -f $repoName)

                ### Check policies and remove them if exist
                $repoId = ($repos | Where-Object {$_.name -eq $repoName}).id
                $policies = (Get-AzDoPolicies -org $targetOrg -project $project -authHeader $authHeader).value
                $currentbranchPolicies = $policies | Where-Object {$_.settings.scope.repositoryId -eq $repoId}

                foreach ($branchPolicy in $currentbranchPolicies) {
                    Write-Output ("ADO branch policy for repository '{0}' already exists" -f $repoName)
                    Remove-AzDoPolicy -org $targetOrg -project $project -policyId $branchPolicy.id -authHeader $authHeader | Out-Null
                    Write-Output ("ADO branch policy for repository '{0}' removed" -f $repoName)
                }
            }

            $repoPath = "$filesPath/reporaw_$repoName"

            ### Push files including commit history and tags
            $currentLocation = Get-location
            Set-Location $repoPath

            $gitRemoteUrl = "https://{0}@dev.azure.com/{0}/{1}/_git/{2}" -f $orgName, $project, $repoName -replace " ", "%20"
            git remote set-url origin $gitRemoteUrl

            git add .
            git commit -m "Replaced tokens"

            git -c http.extraHeader="$gitAuthHeader" push --force
            git -c http.extraHeader="$gitAuthHeader" push --tags

            Set-Location $currentLocation.path

            ### Create policies
            $repoId = ((Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value | Where-Object {$_.name -eq $repoName}).id

            foreach ($policyType in @('reviewers','workItemLinking','comment', 'mergeStrategy')) {
                $policyArguments = @{
                    org = $targetOrg
                    project = $project
                    repoId  = $repoId
                    policyType = $policyType
                    branches = $_.branchListToSetPolicies
                    authHeader = $authHeader
                }
                $policy = Set-AzDoPolicy @policyArguments
                if ($null -ne $policy) { Write-Output ("ADO branch policy for repository '{0}' successfully created" -f $repoName) }
                else { Throw ("Can not create ADO branch policy for repository '{0}' in project '{1}'" -f $repoName, $project) }
            }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps repositories with full history. Nothing to do."}


    ############################# Pipelines #############################
    if ($snapshotConfig.pipelines -ne "[]") {
        Write-Output ("Creating Azure DevOps pipelines...")
        $pipelines = (Get-AzDoBuildDefenition -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.pipelines | ForEach-Object {
            if ($pipelines.name -notcontains $_.name) {
                $pipeArguments = @{
                    org = $targetOrg
                    project = $project
                    name = $_.name
                    path = $_.path
                    repoName = $_.repo_id
                    yamlPath = $_.yml_path
                    authHeader = $authHeader
                }
                $pipe = New-AzDoBuildDefenition @pipeArguments
                if ($null -ne $pipe) { Write-Output ("ADO pipeline '{0}' successfully created" -f $pipe.name) }
                else { Throw ("Can not create ADO pipeline '{0}' in project '{1}'" -f $_.name, $project) }
            }
            else {
                Write-Output ("ADO pipeline '{0}' already exists" -f $_.name)
            }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps pipelines. Nothing to do."}


    ############################# Wiki #############################
    if ($snapshotConfig.wikis -ne "[]") {
        $wikis = (Get-AzDoWiki -org $targetOrg -project $project -authHeader $authHeader).value | Where-Object {$_.type -eq "codeWiki"}
        $repos = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value

        foreach ($snapshotWiki in $snapshotConfig.wikis) {
            $wikiName = $snapshotWiki.name
            $wikiType = $snapshotWiki.type
            $wikiMappedPath = $snapshotWiki.mappedPath
            $repoName = $snapshotWiki.wikiRepoName

            ### Create repo
            if ($repos.name -notcontains $repoName) {
                $repo = New-AzDoRepo -org $targetOrg -project $project -name $repoName -authHeader $authHeader
                if ($null -ne $repo) { Write-Output ("ADO wiki repository '{0}' successfully created" -f $repo.name) }
                else { Throw ("Can not create ADO wiki repository '{0}' in project '{1}'" -f $repoName, $project) }
            }
            else {
                Write-Output ("ADO wiki repository '{0}' already exists" -f $repoName)
            }


            ### Push files including commit history and tags
            $repoPath = "$filesPath/wiki_$wikiName"
            $currentLocation = Get-location
            Set-Location $repoPath

            $gitRemoteUrl = "https://{0}@dev.azure.com/{0}/{1}/_git/{2}" -f $orgName, $project, $repoName -replace " ", "%20"

            if (Test-Path ".git") {
                Remove-Item ".git" -Recurse -Force
            }
            git init -b "main"
            git remote add origin $gitRemoteUrl
            git remote set-url origin $gitRemoteUrl
            git add .
            git commit -m "Initial commit"
            git branch ($wikibranch -replace " ", "%20")
            git checkout ($wikibranch -replace " ", "%20")

            git -c http.extraHeader="$gitAuthHeader" push origin ($wikibranch -replace " ", "%20") --force

            Set-Location $currentLocation.path

            if ($wikis.name -notcontains $wikiName) {
                $repo = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value | Where-Object {$_.name -eq $repoName}

                $wikiArguments = @{
                    org = $targetOrg
                    project =  $project
                    name = $wikiName
                    repositoryId = $repo.id
                    type = $wikiType
                    mappedPath = $wikiMappedPath
                    branch = $wikibranch
                    authHeader = $authHeader
                }
                $wiki = New-AzDoWiki @wikiArguments
                if ($null -ne $wiki) { Write-Output ("ADO Wiki '{0}' successfully created" -f $wiki.name) }
                else { Throw ("Can not create ADO Wiki '{0}' in project '{1}'" -f $wikiName, $project) }
            }
            else {
                Write-Output ("ADO Wiki '{0}' already exists" -f $wikiName)
            }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps Wiki. Nothing to do."}


    ################## Repository build validation policies ##################
    if ($snapshotConfig.reposBuildPolicies -ne "[]") {
        Write-host "==============================="
        Write-Output ("Creating Azure DevOps build validation policies for repos...")
        $policies = (Get-AzDoPolicies -org $targetOrg -project $project -authHeader $authHeader).value
        $pipelines = (Get-AzDoBuildDefenition -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.reposBuildPolicies | ForEach-Object {
            $repoName = $_.repoName
            $repoId = ((Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value | Where-Object {$_.name -eq $repoName}).id
            $pipelineNameRef = $_.pipelineNameRef
            $pipelineId = ($pipelines | Where-Object {$_.name -eq $pipelineNameRef}).id
            Write-host "$repoName : $repoId"
            Write-host "$pipelineNameRef : $pipelineId"

            $currentBuildPolicies = $policies | Where-Object {$_.type.id -eq "0609b952-1397-4640-95ec-e00a01b2c241"} | Where-Object {$_.settings.scope.repositoryId -eq $repoId}
            Write-host "`$currentBuildPolicies:"
            $currentBuildPolicies | ConvertTo-Json -Depth 10
            if ($null -ne $currentBuildPolicies) {
                foreach ($buildPolicy in $currentBuildPolicies) {
                    Write-Output ("ADO build validation policy for repository '{0}' already exists and will be re-created" -f $repoName)
                    Remove-AzDoPolicy -org $targetOrg -project $project -policyId $buildPolicy.id -authHeader $authHeader | Out-Null
                    Write-Output ("ADO build validation policy for repository '{0}' removed" -f $repoName)
                }
            }
            
            $policyConfig = @{
                isEnterpriseManaged = $_.isEnterpriseManaged
                isEnabled = $_.isEnabled
                isBlocking = $_.isBlocking
                type = @{
                    id = "0609b952-1397-4640-95ec-e00a01b2c241"
                }
                settings = @{
                    buildDefinitionId = $pipelineId
                    queueOnSourceUpdateOnly = $_.settings.queueOnSourceUpdateOnly
                    manualQueueOnly = $_.settings.manualQueueOnly
                    displayName = $_.settings.displayName
                    validDuration = $_.settings.validDuration
                    scope = $_.settings.scope
                }
            }
            $policyConfig.settings.scope[0].repositoryId = $repoId

            $policyArguments = @{
                org = $targetOrg
                project = $project
                authHeader = $authHeader
                policyConfig = $policyConfig
            }

            Write-host "`$policyArguments:"
            $policyArguments | ConvertTo-Json -Depth 10
            $policy = Set-AzDoBuildValidationPolicy @policyArguments
            if ($null -ne $policy) { Write-Output ("ADO build validation policy {0} for repository '{1}' successfully created" -f $_.settings.displayName,  $repoName) }
            else { Throw ("Can not create ADO build validation policy for repository '{0}' in project '{1}'" -f $repoName, $project) }
            Write-host "==============================="
        }
    }
    else {Write-Output "There is no 'reposBuildPolicies' in the configuration. ADO build validation policy won't be applied to repos."}


    ####################### Repository raw build validation policies #######################
    if ($snapshotConfig.reposRaw -ne "[]") {
        Write-Output ("Creating Azure DevOps build validation policies for reposRaw...")
        $policies = (Get-AzDoPolicies -org $targetOrg -project $project -authHeader $authHeader).value
        $pipelines = (Get-AzDoBuildDefenition -org $targetOrg -project $project -authHeader $authHeader).value

        $snapshotConfig.reposRaw | ForEach-Object {
            $repoName = $_.name
            $repoId = ((Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value | Where-Object {$_.name -eq $repoName}).id
            $pipelineId = ($pipelines | Where-Object {$_.name -eq $repoName}).id

            $currentBuildPolicies = $policies | Where-Object {$_.type.id -eq "0609b952-1397-4640-95ec-e00a01b2c241"} | Where-Object {$_.settings.scope.repositoryId -eq $repoId}
            foreach ($buildPolicy in $currentBuildPolicies) {
                Write-Output ("ADO build validation  policy for repository '{0}' already exists" -f $repoName)
                Remove-AzDoPolicy -org $targetOrg -project $project -policyId $buildPolicy.id -authHeader $authHeader | Out-Null
                Write-Output ("ADO build validation policy for repository '{0}' removed" -f $repoName)
            }

            $policyArguments = @{
                org = $targetOrg
                project = $project
                repoId  = $repoId
                policyType = "buildValidation"
                buildDefinitionId = $pipelineId
                branches = $_.branchListToSetPolicies
                authHeader = $authHeader
            }
            $policy = Set-AzDoPolicy @policyArguments
            if ($null -ne $policy) { Write-Output ("ADO build validation policy for repository '{0}' successfully created" -f $repoName) }
            else { Throw ("Can not create ADO build validation policy for repository '{0}' in project '{1}'" -f $repoName, $project) }
        }
    }
    else {Write-Output "There is no reposRaw configuration. ADO build validation policy won't be applied to reposRaw."}    


    ############################# Allow Contributor access for project's build service user to all repos within project  #############################
    if ($snapshotConfig.reposRaw -ne "[]") {
        Write-Output ("Allowing Contributor access for project's build service user to all repos...")
        $aceessPermission = Set-AzDoBuildUserReposPermission -org $targetOrg -project $project -allowBit 4 -authHeader $authHeader
        if ($null -ne $aceessPermission) { Write-Output ("ADO Repos Contributor permission for Build service user successfully granted.") }
        else { Throw ("Can not grant ADO Repos Contributor permission for Build service user in project '{0}'" -f $project) }
    }
    else {Write-Output "There is no reposRaw configuration. Contributor access for build service user to all repos within project won't be applied."}


    ############################# Azure DevOps Dashboards #############################
    if ($snapshotConfig.dashboards -ne "[]") {
        Write-Output ("Creating Azure DevOps Dashboards...")
        $dashboardsList = (List-AzDashboards -org $targetOrg -project $project -authHeader $authHeader).value
        $snapshotConfig.dashboards | ForEach-Object {
            $dashboardName = $_.name
            $dashboardWidgets = $($_.widgets | ConvertTo-Json -Depth 20)
            if ($dashboardsList.name -notcontains $dashboardName) {
                $dashboard = Create-AzDashboard -name "$($_.name)" -description "$($_.description)" -widgets $dashboardWidgets -org $targetOrg -project $project -refreshInterval "$($_.refreshInterval)" -authHeader $authHeader
                if ($null -ne $dashboard) { Write-Output ("Dashboard '{0}' successfully created" -f $dashboard.name) }
                else { Throw ("Can not create ADO dashboard '{0}' in project '{1}'" -f $_, $project) }
            }
            else { Write-Output ("Dashboard '{0}' already exists" -f $dashboardName) }
        }
    }
    else {Write-Output "There is no configuration for Azure DevOps dashboards."}


    ############################# Remove temporary repo #############################
    $tempRepoName = "{0}-temp-repo" -f $project
    $repos = (Get-AzDoRepos -org $targetOrg -project $project -authHeader $authHeader).value
    if ($repos.name -contains $tempRepoName) {
        ### Remove temporary repository
        Remove-AzDoRepo -org $targetOrg -project $project -name $tempRepoName -authHeader $authHeader | Out-Null
        Write-Output ("Project temporary repository '{0}' removed" -f $tempRepoName)
    }

    Write-Output ("Process completed.`n")
}



############################# Script body #############################
### Validate variables
$targetOrg = $targetOrg -replace "/$"
$orgName = $targetOrg -replace "https://dev.azure.com/"

### Get a ADO PAT token value
$PAT = Read-Host "Enter a Azure DevOps PAT token" -MaskInput

### Set default script error action
$ErrorActionPreference = 'Stop'

### Check if Git installed
$git = git version
if ($git -notmatch "^git version *") { throw ("Looks like Git is not installed. Please Install and try again.") }

Import-Module "$PSScriptRoot/bootstrap-module.psm1"
Import-Module "$PSScriptRoot/replace_string.psm1"
if ((Get-InstalledModule).name -notcontains "powershell-yaml") {
    Install-Module powershell-yaml -Force
}
if ((Get-Module).name -notcontains "powershell-yaml") {
    Import-Module powershell-yaml
}

$config = Get-Content $configFile | ConvertFrom-Yaml

### Configure authorization headers for Azure DevOps REST API and Git
$authHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)"))}

$gitAuthHeader = "Authorization: Basic {0}" -f $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")))


$projectList = (Get-ChildItem $artifactPath -Directory).Name

$projectList | ForEach-Object {
    $arguments = @{
        targetOrg = $targetOrg
        project = $_
        envApproveEnable = $envApproveEnable
        securityGroupName = $securityGroupName
        envApproveTimeout = $envApproveTimeout
        filesPath = "{0}/{1}" -f $artifactPath, $_
        workflow = $workflow
        wikibranch = $wikibranch
        authHeader = $authHeader
        gitAuthHeader = $gitAuthHeader
    }
    
### Replace content in the files
    Write-Output ("Replace tokens'{0}'...`n" -f $_)
    $performing_project = $_
    $project_config = $($config | where-object {($_.project -match $performing_project)}).replaceContent
    $dir = "{0}/{1}" -f $artifactPath, $_
    
    $project_config | ForEach-Object {
        if (($_.pattern.oldValue -cmatch "#{org_name}#") -and ($null -eq $_.pattern.newValue)) {
            $output_string = $($targetOrg.Split("/")[-1])
        }
        elseif (($_.pattern.oldValue -cmatch "#{project_name}#") -and ($null -eq $_.pattern.newValue)) {
            $output_string = $performing_project
        }
        else {
            $output_string = $_.pattern.newValue
        }
        $targetDir = "{0}/{1}" -f $dir, $_.pattern.filePath
        Format-Text -dir $targetDir -input_string $_.pattern.oldValue -output_string  $output_string -fileMask $_.pattern.fileMask
    }

    Write-Output ("Bootstrapping project '{0}'...`n" -f $_)
    Bootstrap-AzDoProject @arguments
}
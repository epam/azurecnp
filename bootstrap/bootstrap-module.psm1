### Get AzDO projects
function Get-AzDoProjects {
    param (
        [string]$org,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/_apis/projects?api-version={1}" -f $org, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result.value)
}


### Create AzDO projects
function New-AzDoProject {
    param (
        [string]$org,
        [string]$name,
        [string]$procesType = "Agile",
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )
    $ErrorActionPreference = 'Stop'

    $body = @{
        name = $name
        description = ""
        capabilities = @{
            versioncontrol = @{
                sourceControlType = "Git"
            }
            processTemplate = @{
                templateTypeId = "adcc42ab-9882-485e-a3ed-7678f01f66bc" # Agile
            }
        }
    }

    if ($procesType -eq "Agile") { $body.capabilities.processTemplate.templateTypeId = "adcc42ab-9882-485e-a3ed-7678f01f66bc" }
    elseif ($procesType -eq "Scrum") { $body.capabilities.processTemplate.templateTypeId = "6b724908-ef14-45cf-84f8-768b5384da45" }
    elseif ($procesType -eq "Basic") { $body.capabilities.processTemplate.templateTypeId = "b8a3a935-7e91-48b8-a94c-606d37c3e9f2" }
    else { Throw ("Process type can be one of the 'Agile', 'Scrum', 'Basic'") }

    $body = $body | ConvertTo-Json

    $uri = "{0}/_apis/projects?api-version={1}" -f $org, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get AzDO project Security Groups
function Get-AzDoSecurityGroups {
    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $projectData = Get-AzDoProjects -org $org -authHeader $authHeader | Where-Object {$_.name -eq $project}

    $uri = "{0}/_apis/graph/descriptors/{1}?api-version={2}" -f $org, $projectData.id, $apiVersion -replace "dev.azure.com", "vssps.dev.azure.com" -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $descriptor = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    $uri = "{0}/_apis/graph/groups?scopeDescriptor={1}&api-version={2}" -f $org, $descriptor.value, $apiVersion -replace "dev.azure.com","vssps.dev.azure.com" -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try {$result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result.value)
}


### Create AzDO project Security Groups
function New-AzDoSecurityGroups {
    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $projectData = Get-AzDoProjects -org $org -authHeader $authHeader | Where-Object {$_.name -eq $project}

    $uri = "{0}/_apis/graph/descriptors/{1}?api-version={2}" -f $org, $projectData.id, $apiVersion -replace "dev.azure.com","vssps.dev.azure.com" -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $descriptor = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    $uri = "{0}/_apis/graph/groups?scopeDescriptor={1}&api-version={2}" -f $org, $descriptor.value, $apiVersion -replace "dev.azure.com","vssps.dev.azure.com" -replace " ", "%20"

    $body = @{
        displayName = $name
    } | ConvertTo-Json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get environment list from AzDO project
function Get-AzDoEnvList {
    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/distributedtask/environments?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result.value)
}


### Add new environment.
function Add-AzDoEnv {
    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/distributedtask/environments?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        name = $name -replace " ", "%20"
        description = ""
    } | ConvertTo-Json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Gets environment approval in AzDO project.
function Get-AzDoEnvApproval {
    param (
        [string]$org,
        [string]$project,
        [string]$envId,
        [hashtable]$authHeader,
        [string]$apiVersion = "7.1-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/pipelines/checks/configurations?resourceType=environment&resourceId={2}&api-version={3}" -f $org, $project, $envId, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result.value)
}


### Create environment approval in AzDO project.
function Add-AzDoEnvApproval {

    param (
        [string]$org,
        [string]$project,
        [string]$envName,
        [string]$envId,
        [string]$groupId,
        [string]$approveTimeout,
        [hashtable]$authHeader,
        [string]$apiVersion = "7.1-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/pipelines/checks/configurations?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        type = @{
            id = "8C6F20A7-A545-4486-9777-F762FAFE0D4D"
            name = "Approval"
            }
        settings = @{
            approvers = @( @{
                id = $groupId
                } )
                executionOrder = "1"
                instructions = ""
                blockedApprovers = "[]"
                minRequiredApprovers = "0"
                requesterCannotBeApprover = "false"
            }
        resource = @{
            type = "environment"
            id = $envId
            name = $envName -replace " ", "%20"
        }
    timeout = $approveTimeout
    } | ConvertTo-Json -Depth 10

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get varible groups from AzDO project.
function Get-AzDoVarGroups {

    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0-preview.2"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/distributedtask/variablegroups?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Create varible group in AzDO project.
function New-AzDoVarGroup {

    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [string]$description,
        $variables,
        [hashtable]$authHeader,
        [string]$apiVersion = "5.1-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/distributedtask/variablegroups?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        description = $description
        name = $name
        type = "Vsts"
        variables = $variables
    } | ConvertTo-Json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method POST -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    return ($result)
}


### Create varible group in AzDO project.
function Set-AzDoVarGroupPipelinesPermisson {

    param (
        [string]$org,
        [string]$project,
        [string]$id,
        [boolean]$allow = $true,
        [hashtable]$authHeader,
        [string]$apiVersion = "7.1-preview.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/build/authorizedresources?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        authorized = $allow
        id = $id
        type = "variablegroup"
    } | ConvertTo-Json
    $body = "[$body]"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Patch -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    return ($result)
}


### Push changes to AzDO repo
function Push-AdoRepoInitCommit {
    param (
        [string]$org,
        [string]$project,
        [string]$repoName,
        [hashtable]$authHeader,
        [string]$branch,
        [array]$changes,
        [string]$apiVersion = "6.0"
    )
    $ErrorActionPreference = 'Stop'

    class PushBody {
        [array]$refUpdates = @(@{ name = $("refs/heads/{0}" -f $branch); oldObjectId = "0000000000000000000000000000000000000000" })
        [array]$commits = @(@{ comment = "Initial files upload"; changes = $null })
    }

    $uri = "{0}/{1}/_apis/git/repositories/{2}/pushes?api-version={3}" `
            -f $org, $project, $repoName, $apiVersion -replace " ", "%20"

    $body = [PushBody]::new()
    $body.commits[0].changes = $changes

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $($body | ConvertTo-Json -Depth 10) -ContentType "application/json"  -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Creates new AzDO repository
function New-AzDoRepo {

    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [hashtable]$authHeader,
        [string]$apiVersion = "5.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/git/repositories?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        name = $name -replace " ", "%20"
    } | ConvertTo-Json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get AzDO repositories
function Get-AzDoRepos {

    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [string]$apiVersion = "5.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/git/repositories?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Remove repository.
function Remove-AzDoRepo {
    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [hashtable]$authHeader,
        [string]$apiVersion = "5.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/git/repositories/{2}?api-version={3}" -f $org, $project, $name, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $repoId = (Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ErrorAction Stop -ErrorVariable restError ).id }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    $uri = "{0}/{1}/_apis/git/repositories/{2}?api-version={3}" -f $org, $project, $repoId, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Delete -Headers $authHeader -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Create pipeline.
function New-AzDoBuildDefenition {

    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [string]$path,
        [string]$repoName,
        [string]$yamlPath,
        [string]$defaultBranch,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )

    $uri = "{0}/{1}/_apis/build/definitions?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        name = $name
        type = "build"
        path = $path -replace " ", "%20"
        repository = @{
            name = $repoName -replace " ", "%20"
            type = "TfsGit"
            defaultBranch = $defaultBranch -replace " ", "%20"
        }
        process = @{
            yamlFilename = $yamlPath -replace " ", "%20"
        }
        queue = @{
            pool = @{
                name = "Azure Pipelines"
                isHosted = "true"
            }
        }
    } | ConvertTo-Json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get pipelines from AzDO project.
function Get-AzDoBuildDefenition {

    param (
        [string]$org,
        [string]$project,
        [string]$id,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )

    if ($null -eq $id) {
        $uri = "{0}/{1}/_apis/build/definitions?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"
    }
    else {
        $uri = "{0}/{1}/_apis/build/definitions/{3}?api-version={2}" -f $org, $project, $apiVersion, $id -replace " ", "%20"
    }

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get pipelines from AzDO project.
function Get-AzDoPolicies {

    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )

    $uri = "{0}/{1}/_apis/policy/configurations?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}

### Set build validation policy for repository in AzDO project
function Set-AzDoBuildValidationPolicy {
    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader,
        [hashtable]$policyConfig,
        [string]$apiVersion = "5.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/policy/configurations?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = $policyConfig

    $body = $body | ConvertTo-Json -Depth 10
    
    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Set policy for repository in AzDO project
function Set-AzDoPolicy {
    param (
        [string]$org,
        [string]$project,
        [string]$repoId,
        [ValidateSet('reviewers','workItemLinking','comment', 'mergeStrategy', 'buildValidation')][string]$policyType,
        [string]$buildDefinitionId = $null,
        [string]$buildPolicyName = $null,
        [hashtable]$authHeader,
        [array]$branches,
        [string]$apiVersion = "5.1"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/policy/configurations?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        isEnabled = $true
        isBlocking = $true
        type = @{
            id = ""
        }
        settings = @{
            scope = @()
        }
    }

    if ($policyType -eq "reviewers") {
        $body.type.id = "fa4e907d-c16b-4a4c-9dfa-4906e5d171dd"
        $body.settings.Add("minimumApproverCount", "1")
        $body.settings.Add("creatorVoteCounts", "true")
        $body.settings.Add("resetOnSourcePush", "true")
    }
    elseif ($policyType -eq "workItemLinking") {
        $body.type.id = "40e92b44-2fe1-4dd6-b3d8-74a9c21d0c6e"
    }
    elseif ($policyType -eq "comment") {
        $body.type.id = "c6a1889d-b943-4856-b76f-9e46bb6b0df2"
    }
    elseif ($policyType -eq "mergeStrategy") {
        $body.type.id = "fa4e907d-c16b-4a4c-9dfa-4916e5d171ab"
        $body.settings.Add("allowSquash", "true")
    }
    elseif ($policyType -eq "buildValidation") {
        $body.type.id = "0609b952-1397-4640-95ec-e00a01b2c241"
        $body.settings.Add("displayName", "Code validation")
        $body.settings.Add("buildDefinitionId", $buildDefinitionId)
    }
    
    $branches | ForEach-Object {

        if ($_[$_.length-1] -eq "/") {$matchKind = "prefix"}
        else {$matchKind = "exact"}

        $body.settings.scope += @{
            repositoryId = $repoId
            matchKind = $matchKind
            refName = $_ -replace "^","refs/heads/" -replace "/$"
        }
    }

    $body = $body | ConvertTo-Json -Depth 10

    
    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Delete pipelines from AzDO project.
function Remove-AzDoPolicy {

    param (
        [string]$org,
        [string]$project,
        [string]$policyId,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )

    $uri = "{0}/{1}/_apis/policy/configurations/{2}?api-version={3}" -f $org, $project, $policyId, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Delete -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Creates new AzDo project wiki
function New-AzDoWiki {

    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [string]$repositoryId,
        [string]$mappedPath,
        [string]$branch,
        [hashtable]$authHeader,
        [string]$type = "projectWiki",
        [string]$apiVersion = "6.0"
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/_apis/projects/{1}?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $projectId = (Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError).id }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    $uri = "{0}/{1}/_apis/wiki/wikis?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"

    $body = @{
        type = $type
        name = $name 
        projectId = $projectId
        repositoryId = $repositoryId
        mappedPath = $mappedPath 
        version = @{
            version = $branch
        }
    } | ConvertTo-json

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Get wiki from AzDO project.
function Get-AzDoWiki {

    param (
        [string]$org,
        [string]$project,
        [string]$wikiId,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )

    if ($null -eq $wikiId) {
        $uri = "{0}/{1}/_apis/wiki/wikis?api-version={2}" -f $org, $project, $apiVersion -replace " ", "%20"
    }
    else {
        $uri = "{0}/{1}/_apis/wiki/wikis/{2}?api-version={3}" -f $org, $project, $wikiId, $apiVersion -replace " ", "%20"
    }

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}


### Set Repos permission on a project level scope for project Build user
function Set-AzDoBuildUserReposPermission {

    param (
        [string]$org,
        [string]$project,
        [int]$allowBit,
        [hashtable]$authHeader,
        [string]$apiVersion = "6.0"
    )
    $ErrorActionPreference = 'Stop'
    $gitReposNamespaceId = "2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87"


    $uri = "{0}/_apis/projects/{1}?api-version=6.0" -f $org, $project, $apiVersion -replace " ", "%20"
    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $projectId = (Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError).id }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    $uri = "{0}/_apis/graph/users?subjectTypes=svc&api-version=6.0-preview.1" -f $org -replace "dev.azure.com", "vssps.dev.azure.com" -replace " ","%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $buildUser = (Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError).value | Where-Object {$_.principalName -eq $projectId} }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    if ($null -eq $buildUser.descriptor) { throw("Can't assign repo contributor permission to project's Build service user. User's principalName doesn't match ProjectID.") }
    $uri = "{0}/_apis/identities?subjectDescriptors={1}&api-version=6.0-preview.1" -f $org, $buildUser.descriptor -replace "dev.azure.com", "vssps.dev.azure.com" -replace " ", "%20"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $identity = (Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError).value }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    $uri = "{0}/_apis/accesscontrolentries/{1}?subjectTypes=svc&api-version={2}" -f $org, $gitReposNamespaceId, $apiVersion -replace " ", "%20"

    $body = @{
        token = "repoV2/{0}" -f $projectId
        merge = $true
        accessControlEntries = @(@{
            descriptor = $identity.descriptor
            allow = 4
            deny = 0
            extendedinfo = $null
        })
    } | ConvertTo-Json
    $body = $body -replace "null", "{}"

    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Post -Body $body -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }


    return ($result.value)
}


### Create Azure DevOps dashboards
function Create-AzDashboard {

    param (
        [string]$org,
        [string]$project,
        [string]$name,
        [string]$description,
        [string]$refreshInterval,
        [string]$widgets,
        [hashtable]$authHeader
    )
    $ErrorActionPreference = 'Stop'

    $uri = "{0}/{1}/_apis/dashboard/dashboards?api-version=7.0-preview.3" -f $org, $project -replace " ","%20"
    # We need to add [] brackets if variable consist of one element.
    if ($widgets[0] -eq '{') {
        $widgets = "[$widgets]"
    }

$body = @"
{
    "description": "$description",
    "name": "$name",
    "refreshInterval": "$refreshInterval",
    "widgets": $widgets
    }
"@
    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method POST -Headers $authHeader -Body $body -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }
    return ($result)
}


### List Dashboards from AzDO project.
function List-AzDashboards {

    param (
        [string]$org,
        [string]$project,
        [hashtable]$authHeader
    )

    $uri = "{0}/{1}/_apis/dashboard/dashboards?api-version=7.0-preview.3" -f $org, $project -replace " ", "%20"
    $attempt = 0
    do {
        $attempt ++
        $errorDetected = $null
        try { $result = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader -ContentType "application/json" -ErrorAction Stop -ErrorVariable restError }
        catch { $errorDetected = $true; Start-Sleep -Seconds 1 }
    }
    while (($null -ne $errorDetected) -and ($attempt -lt 4))
    if ($null -ne $errorDetected) { throw($restError.ErrorRecord) }

    return ($result)
}
# Importing demo app to Azure DevOps organization
For importing demo app to your organization:
1. Download bootstrap folder from the repository.
2. Configure Azure DevOps Personal Access Token (PAT) with full access within your organization. Refer to [MS documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) to create PAT.
3. Unblock downloaded PowerShell files:
```
Unblock-File .\bootstrap-module.psm1
Unblock-File .\replace_string.psm1
Unblock-File .\bootstrap.ps1
```
4. If you need to replace content in the downloaded files to your custom values could be done some code manipulations like:
- Renaming projects. For this need to rename both folders in the bootstrap-artifact folder and update configuration.yaml file with new projects' names (Update replace pattern too).
- Renaming repositories. For this need to rename repo_<repo_name> folders in each project folder (do not lose "repo_" prefix) and update snapshot.json files with new repositories names. As well for renaming wiki repositories, no need to update folders name, just need to update in snapshot.json "wikiRepoName" field. Update replace pattern in configuration.yaml too.
- This should be done **before** ./bootstrap.ps1 script running, because values in all files will be replaced. 
5. Set execution policy to allow script run if required:
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope <scope>
```
6. Considering potential issues related to maximum length of git file name, run PowerSell as administrator and adjust the following option:
```
git config --system core.longpaths true
```
7. Run bootstrap script:
```
./bootstrap.ps1 -targetOrg "https://dev.azure.com/<org_name>" -workflow "gitflow"
                     [-envApproveEnable]
                     [-securityGroupName]
                     [-envApproveTimeout]
                     [-artifactPath]
                     [-configFile]
                     [-wikibranch]
```
Required Parameters
```
-targetOrg - target DevOps organization in format "https://dev.azure.com/<org_name>"
-workflow - determines default branch(s) name(s) for creating repositories and assigning policies, possible values are "trunk", "gitflow". "trunk" includes ["main"] branches, "gitflow" includes ["develop", "release/", "main"] branches. Default value: "trunk"
```
- Generally "workflow" is an optional parameter, but in this solution pipelines works with **develop** branches. So, better to use this parameter with "gitflow" value or manually create develop branches after bootstrapping.

Optional Parameters
```
-envApproveEnable - boolean value, configure or not Azure DevOps security group as an environment approval group for the all environments. Default value: $false
-securityGroupName - security group name to be created (used as environment approval security group if envApproveEnable equal $true). Default value: ""
-envApproveTimeout - timeout for environment approval. Default value: "172800"
-artifactPath - path to folder with snapshot data. Default value: "./bootstrap-artifact"
-configFile - the path of the configuration file for content replacement. Default value is "./configuration.yaml"
-wikibranch - wiki branch name where the wiki content will be stored. Default value: "main"
```
When you ran the script you will see the suggestion to enter the value of the Azure PAT token, you should enter the PAT value which was generated in the second step of this guide

# Initial set up
After bootstraping to the organization it is need to do initial configuration.

**Prerequisites**

- Azure DevOps (ADO) organization;
- Azure Cloud subscription;
- Azure Cloud service principal (with at least "Сontributor" and "User Access Administrator" or "Owner" rights on the subscription level) [Create an Azure AD app and service principal in the portal - Microsoft Entra | Microsoft Learn ](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli).

**Extensions**

Additional post deployment actions are required to install Azure DevOps extensions into your organization:
  - [Replace Tokens](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens);
  - [Azure Pipelines Terraform](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks);
  - [SonarQube](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) (Optional only if will use Sonar Qube Analyze)

**Agent requirements**

You do not need to set up additional components in case you plan to use [microsoft-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml). But if you want to use [self-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install) - there are some requirements for them:

- Linux only agents supported (based on Ubuntu);
- PowerShell must be installed;
- yamllint must be installed;
- Docker must be installed;
- Zip must be installed;
- unzip must be installed;
- Terraform optional to use in case you plan to use Terraform IaC templates for infrastructure provisioning.

#Deployment steps

Several essential things must be done before get started:
<ol>
<li>Create ADO PAT tokens and insert secret data into variable groups (variables in <strong> .sys.global </strong>VG):
<table>
<tbody>
<tr>
<td>PAT token name</td>
<td>Scope</td>
<td>Description</td>
</tr>
<tr>
<td>SYS_OPS_RW_PAT</td>
<td>Build (Read & execute); Environment (Read & manage); Service Connections (Read, query, & manage); Variable Groups (Read, create, & manage)</td>
<td>Token used for operations inside of CNP project</td>
</tr>
<tr>
<td>SYS_CODE_READ_PAT</td>
<td>Code (Read)</td>
<td>Used as a token to access the code</td>
</tr>
</tbody>
</table>
</li>
<li>Create <strong>Azure Repos/Team Foundation Server</strong> service connection in "application project" named <strong>tfs_cnpdevopsproject</strong> to the Azure DevOps organization that contains "DevOps project". As a PAT token use the token which was generated in the previous step for `SYS_CODE_READ_PAT`.</li>
<li>Create <a href="https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#azure-resource-manager-service-connection">Azure Resource Manager service connection</a> to your Azure Cloud subscription.</li>
<li>Update at least these variable groups (VG) and variables:<br><br>

Update common environment variables (variables in <strong>*.com.env.* </strong>VG)<br>
ENV_APP_ALERTS_RECEIVERS_EMAIL - update with your own email addresses;<br>
ENV_CERT_MANAGER_ISSUER_EMAIL - update with your own email addresses;<br>
ENV_AZURE_CLIENT_ID – update with your Azure Cloud SP client ID;<br>
ENV_AZURE_CLIENT_SECRET – update with your Azure Cloud SP client secret;<br>
ENV_AZURE_SUBSCRIPTION_ID – update with your Azure Cloud subscription ID;<br>
ENV_AZURE_TENANT_ID – update with your Azure Cloud tenant ID;<br>
ENV_SERVICE_CONNECTION_NAME – update with Azure Cloud service connection name that was created on the previous step;<br>
ENV_TF_STATE_STORAGE_ACCOUNT_NAME – update with desired Azure Cloud storage account name to store terraform state files (should be of 3-24 characters long and globally unique.);<br>
ENV_TF_STATE_SUBSCRIPTION_ID – update with your Azure Cloud subscription ID;<br>
ENV_TF_STATE_FOLDER – optionally to change.<br>

Update environment specific variables (variables in <strong>*.dev.env.*, *.qa.env.* </strong>… VGs):<br>
ENV_INFRA_NAME_PREFIX – change value to some unique string (use letters and numbers);<br>
ENV_INFRA_SO_NAME – optionally to change;<br>
ENV_TF_STATE_FOLDER – optionally to change.
</li>
<li>Create branches and assign branch policies to organize CI/CD strategy please check CI/CD concepts overview.</li>
</ol>

At the end, you are able to deploy infrastructure and application components using "application project" pipelines.

**Optional steps to configure company's naming convention**
1. Update VG names according to your naming convention.
2. Update Terraform configuration files (.tfvars files) in "application project" according VG names. File name must be the same as variable group name. For example:<br>
<span>&#9888;</span> Let's assume that we need to deploy infrastructure components for environment called <strong>test</strong>. So we have a variable group called <strong>company.test.env.myazuresubscription</strong>. Terraform configuration file must be named <strong>company.test.env.myazuresubscription.tfvars</strong>.
3. Update all pipeline files in "application project":<br>
- Update VG names and environment configuration;<br>
- Update project name in all pipelines in case it was migrated with name different from source;<br>
- Update pool name in all pipeline files in "application project" (in case if you don't plan to use microsoft-hosted agents). Example:<br>
```
pool:
  vmImage: self-hosted-agent-name
```
4. Update terraform modules links in "DevOps project" with new organization and project names (in case it was migrated with name different from source).
5. Configure approvals for <strong>dev, qa</strong> and <strong>prod</strong> environments (use ADO groups for it).
6. Rename infrastructure based ADO environments with the same names as infrastructure based variable groups, but '.' symbols must be changed to '_' symbol. For example:<br>
For infrastructure based variable group called <strong>company.test.env.myazuresubscription</strong> we must create ADO environment with name <strong>company_test_env_myazuresubscription</strong>. This is because of ADO environment's naming restrictions.
7. Set up appropriate properties in application pipelines befor run
- `name`,
- `endpoint`, 
- `ref`,
- `variables.group`

```
resources:
  repositories:
  - repository: templates
    type: git
    name: yourcompanyname.cnp.devops/yourcompanyname.cnp.devops
    endpoint: "tfs_cnpdevopsproject"
    ref: 'refs/heads/develop'

variables:
- group: epam.com.env.epamaodpsshared01
```

# Known issues
**01-infra-cd.yml**

The pipeline may fail during Terraform apply step throwing multiple errors:
```
│ Error: creating or updating Monitor Metric Alert (Subscription: "a03def49-d9de-4a49-a38f-3a2dcfcf84a1"
│ Resource Group Name: "almaltd-rg-noeu-d-prfxmonitor-01"
│ Metric Alert Name: "Completed job count"): metricalerts.MetricAlertsClient#CreateOrUpdate: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="BadRequest" Message="The metric completedJobsCount specifies a dimension controllerName which was not found.The metric completedJobsCount specifies a dimension kubernetes namespace which was not found. Activity ID: 2f22fde5-8980-4be0-91a0-fe69f77c3442."
│ 
│   with module.alerts["aks_alert_recievers_dev"].azurerm_monitor_metric_alert.metric_alert["Completed job count"],
│   on .terraform/modules/alerts/iac/terraform/terraform.azurerm.alerts/main.tf line 13, in resource "azurerm_monitor_metric_alert" "metric_alert":
│   13: resource "azurerm_monitor_metric_alert" "metric_alert" {
```
Resolution: re run all jobs within the stage.

License

Copyright (C) 2023 EPAM Systems Inc.

 

The LICENSE file in the root of this project applies unless otherwise indicated.
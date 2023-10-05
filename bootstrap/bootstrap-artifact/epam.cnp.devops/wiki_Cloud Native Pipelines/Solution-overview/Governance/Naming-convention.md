[[_TOC_]]

## About

A naming convention is a vital part of any solution design. It is used to have a standardized approach to repositories, item naming, and resource naming and is a significant part of the IaC approach. A good naming convention allows finding and identifying resources quickly, generating nested resource naming, and having naming scalability.

As a best practice, it is a good to have inherited naming for a child's resources when the child resource takes its parent resource name as a prefix and adds its name as a suffix: **{parent_name}.{child_name}.{nested_resource_suffix}**

## Project naming

Project name must only contain alphanumeric characters and dots. Here is the pattern for Azure DevOps projects naming: **{Organization}.{Unit}.{Application/Stream}.[ApplicationType].[Version]**

| Parameter name| Mandatory | Description |
|--|--|--|
| Organization | yes | An abbreviation for the organization's name |
| Unit  | yes | An abbreviation for the organization's name |
| Application/Stream | yes | An abbreviation for the application's name or for the general stream's name |
| ApplicationType | no | Optional: suffix for the application type like: api, fnc, app etc. |
| Version | no | Optional: version of the project for the application |

Example:<br>
epam.cnp.demoapp<br>
epam.cnp.demoapp.api.v1<br>
#{project_name}#<br>
epam.cnp.webapp.app.v1

## Repositories naming

Following the proposed naming convention the repositories appear as child resources for the Azure DevOps projects. Repository name must only contain alphanumeric characters and dashes. Here is the pattern for Azure DevOps GIT repositories naming:<br> **{Customer/Organization}.{ProjectSuffix}.[RepositorySuffix]**

| Name| Mandatory | Description |
|--|--|--|
| Customer/Organization | yes | A customer or Azure DevOps organization name |
| ProjectSuffix| yes | A project Suffix name within Azure DevOps organization or project Suffix provided by the customer |
| RepositoryName | no |The name of the repository within Azure DevOps project |

Example:<br>
epam.cnp.demoapp<br>
#{project_name}#<br>
epam.cnp.terraform

## Branch naming

The branch naming convention should meet the requirements of the branching workflow chosen for the project.

## Environment naming

Initially, the environment naming depends on the development lifecycle. Environment name must only contain alphanumeric characters. Here it is the most common environment names that are used in the software development:

| Environment name | Environment code |
|--|--|
| Development | dev |
| Test | test  |
| User Acceptance Testing | uat |
| Staging | stg |  
| Production | prod |

## Variable groups naming

Variable group name must only contain alphanumeric characters, dashes, underscores and dots. Variable groups name pattern: **[Temporary].{Owner}.{Environment}.{Type}.{Name}**

**Temporary** - optional parameter, should be set if VG is temporary;<br>
**Owner** - describes who is an instance owner, managed by this VG, could be a company name, department, even or system;<br>
**Environment** - defines variables environment scope dev/qa/prod, etc.;<br>
**Type** - defines variables tool/system belonging or variables purpose;<br>
**Name** - additional suffix to split variable groups with the same scope and kind but for different applications.<br>

<table border="1">
  <tbody>
    <tr>
      <td><p> Part of name</p></td>
      <td><p>Mandatory</p></td>
      <td><p>Possible values</p></td>
      <td><p>Description</p></td>
    </tr>
    <tr>
      <td><p>Temporary</p></td>
      <td><p align="center">no</p></td>
      <td><p>tmp</p></td>
      <td><p>Should be set if VG is temporary</p></td>
    </tr>
    <tr>
      <td rowspan="3"><p>Owner</p></td>
      <td rowspan="3"><p align="center">yes</p></td>
      <td><p>com </p></td>
      <td><p>Should be set if VG describes a common instance</p></td>
    </tr>
    <tr>
      <td><p>epam</p></td>
      <td><p>Should be set if VG describes an instance deployed/used in the EPAM environment</p></td>
    </tr>
    <tr>
      <td><p>any_name</p></td>
      <td><p>Should be set if VG describes an instance deployed/used in other environments owned by another customer/owner</p></td>
    </tr>
    <tr>
      <td rowspan="5"><p>Environment</p></td>
      <td rowspan="5"><p align="center">yes</p></td>
      <td><p>com </p></td>
      <td><p>Should be set if VG describes a common instance</p></td>
    </tr>
    <tr>
      <td><p>dev</p></td>
      <td><p>Dev environment variable groups</p></td>
    </tr>
    <tr>
      <td><p>qa</p></td>
      <td><p>QA environment variable groups</p></td>
    </tr>
    <tr>
      <td><p>prod</p></td>
      <td><p>Prod environment variable groups</p></td>
    </tr>
    <tr>
      <td><p>any_name</p></td>
      <td><p>Should be the name of the environment where the instance exists, like test, stage, uat, etc.</p></td>
    </tr>
    <tr>
      <td rowspan="4"><p>Type</p></td>
      <td rowspan="4"><p align="center">yes</p></td>
      <td><p>app</p></td>
      <td><p>Should be set if VG describes the application</p></td>
    </tr>
    <tr>
      <td><p>env</p></td>
      <td><p>Should be set if VG contains environment-specific data</p></td>
    </tr>
    <tr>
      <td><p>tool</p></td>
      <td><p>Should be set if VG contains tool-specific data</p></td>
    </tr>
    <tr>
      <td><p>sys</p></td>
      <td><p>Should be set if VG describes system values</p></td>
    </tr>
    <tr>
      <td><p>Name</p></td>
      <td><p align="center">yes</p></td>
      <td><p>any_name</p></td>
      <td><p>Should be the name of the instance</p></td>
    </tr>
  </tbody>
</table>

In case of multiple “com” values at the beginning (only) of the VG name – it can be omitted.
Example: Full VG name com.com.sys.ado, short VG name sys.ado

Example:<br>
Example of an application VG: app.myapp1<br>
Example of an environment VG: epam.dev.env.dev<br>
Example of Terraform tool VG: tool.terraform<br>
Example of env-specific VG for tool: epam.dev.tool.terraform<br>
Example of Kubernetes cluster VG: tool.kubernetes<br>
Example of env-specific VG for Kubernetes: epam.uat.tool.kubernetes<br>
Example of tool-specific VG: epam.com.tool.infrastructure<br>
Example of the VG that contains system Azure Devops variables: sys.ado<br>

## Variables naming

Azure DevOps variables that are used by YAML pipelines could be specified right into the YAML pipeline file code or configured in variable groups. Their names must be clear to understand, as short as possible, and have exactly the same name pattern. In most cases, it is better to use variable **type** meaning as a very first part for the variable name. Variable **type** must describe purpose or define variable tool/system belonging. After the variable type, we may use any number of meaning **Words** describing what this variable really is. Variable name must only contain alphanumeric characters and dashes. The pattern for the Azure DevOps variables naming: <strong>{Type}\_{Word1}\_{Word2}\_{WordN}</strong><br>
Here it is the most common variable types that are used in the software development:

| Variable type | Description |
|--|--|
| ENV | Must be used if variable used for environment-specific data |
| APP | Must be used if variable used for application-specific data |
| SOL | Must be used if variable used for solution-specific data |
| TOOL | Must be used if variable used for tool-specific data |  
| SYS | Must be used if variable used for system-specific data |
| PIPE | Must be used if variable used at pipeline run time (dynamically) and it mustn't be configured/used outside of pipeline run. Usually used to exchange variables between pipeline steps, jobs, stages... |

Example:<br>
Example of an application variable: APP_NAME<br>
Example of an environment variable: ENV_INFRA_LOCATION<br>
Example of Terraform tool variable: TOOL_TERRAFORM_VERSION<br>
Example of the variable that is used as system variable all around the Azure DevOps project: 
SYS_PROJECT_CODE<br>
Example of the dynamic pipeline run time variable: PIPE_RELEASE_ARTIFACTNAME<br>

## Service connection naming

You can create a connection from Azure Pipelines to external and remote services for executing tasks in a job. The service connection pattern is<br> **[Temporary]\_{SC Type}\_{Endpoint Name}\_[Postfix]**.<br> Each block should contain alphanumeric characters only, and underscores are used as block delimiter.

**Temporary** - an optional parameter, should be set if service connection is temporary;<br>
**SC Type** - the service connection type;<br>
**Endpoint Name** - the name of the connection endpoint: azure subscription name, gitHub project name, Docker Hub name, etc.;<br>
**Postfix** - an optional parameter which could contain numeric index, short description, owner name, specific resource name, etc.;

<table border="1">
  <tbody>
    <tr>
      <td><p> Part of name</p></td>
      <td><p>Mandatory</p></td>
      <td><p>Possible values</p></td>
      <td><p>Description</p></td>
    </tr>
    <tr>
      <td><p>Temporary</p></td>
      <td><p align="center">no</p></td>
      <td><p>tmp</p></td>
      <td><p>Should be set if Service Connection is temporary</p></td>
    </tr>
    <tr>
      <td rowspan="30"><p>SC Type</p></td>
      <td rowspan="30"><p align="center">yes</p></td>
      <td><p>awstf </p></td>
      <td><p>Should be set if SC type is AWS for Terraform</p></td>
    </tr>
    <tr>
      <td><p>azcls</p></td>
      <td><p>Should be set if SC type is Azure Classic</p></td>
    </tr>
    <tr>
      <td><p>tfs</p></td>
      <td><p>Should be set if SC type is Azure Repos/Team Foundation Server</p></td>
    </tr>
    <tr>
      <td><p>arm</p></td>
      <td><p>Should be set if SC type is Azure Resource Manager</p></td>
    </tr>
    <tr>
      <td><p>asb</p></td>
      <td><p>Should be set if SC type is Azure Service Bus</p></td>
    </tr>
    <tr>
      <td><p>bbc</p></td>
      <td><p>Should be set if SC type is Bitbucket Cloud</p></td>
    </tr>
    <tr>
      <td><p>crg</p></td>
      <td><p>Should be set if SC type is Cargo</p></td>
    </tr>
    <tr>
      <td><p>chf</p></td>
      <td><p>Should be set if SC type is Chef</p></td>
    </tr>
    <tr>
      <td><p>dh</p></td>
      <td><p>Should be set if SC type is Docker Host</p></td>
    </tr>
    <tr>
      <td><p>dr</p></td>
      <td><p>Should be set if SC type is Docker Registry</p></td>
    </tr>
    <tr>
      <td><p>gcptf</p></td>
      <td><p>Should be set if SC type is GCP for Terraform</p></td>
    </tr>
    <tr>
      <td><p>gnc</p></td>
      <td><p>Should be set if SC type is Generic</p></td>
    </tr>
    <tr>
      <td><p>gth</p></td>
      <td><p>Should be set if SC type is GitHub</p></td>
    </tr>
    <tr>
      <td><p>gts</p></td>
      <td><p>Should be set if SC type is GitHub Enterprise Server</p></td>
    </tr>
    <tr>
      <td><p>wh</p></td>
      <td><p>Should be set if SC type is Incoming WebHook</p></td>
    </tr>
    <tr>
      <td><p>jnks</p></td>
      <td><p>Should be set if SC type is Jenkins</p></td>
    </tr>
    <tr>
      <td><p>jra</p></td>
      <td><p>Should be set if SC type is Jira</p></td>
    </tr>
    <tr>
      <td><p>k8s</p></td>
      <td><p>Should be set if SC type is Kubernetes</p></td>
    </tr>
    <tr>
      <td><p>mvn</p></td>
      <td><p>Should be set if SC type is Maven</p></td>
    </tr>
    <tr>
      <td><p>ngt</p></td>
      <td><p>Should be set if SC type is NuGet</p></td>
    </tr>
    <tr>
      <td><p>otg</p></td>
      <td><p>Should be set if SC type is Other Git</p></td>
    </tr>
    <tr>
      <td><p>pypd</p></td>
      <td><p>Should be set if SC type is Python package download</p></td>
    </tr>
    <tr>
      <td><p>pypu</p></td>
      <td><p>Should be set if SC type is Python package upload</p></td>
    </tr>
    <tr>
      <td><p>ssh</p></td>
      <td><p>Should be set if SC type is SSH</p></td>
    </tr>
    <tr>
      <td><p>svcfbk</p></td>
      <td><p>Should be set if SC type is Service Fabric</p></td>
    </tr>
    <tr>
      <td><p>snrc</p></td>
      <td><p>Should be set if SC type is SonarCloud</p></td>
    </tr>
    <tr>
      <td><p>snrq</p></td>
      <td><p>Should be set if SC type is SonarQube</p></td>
    </tr>
    <tr>
      <td><p>sbver</p></td>
      <td><p>Should be set if SC type is Subversion</p></td>
    </tr>
    <tr>
      <td><p>vsc</p></td>
      <td><p>Should be set if SC type is Visual Studio App Center</p></td>
    </tr>
    <tr>
      <td><p>npm</p></td>
      <td><p>Should be set if SC type is npm</p></td>
    </tr>
    <tr>
      <td><p>Endpoint Name</p></td>
      <td><p align="center">yes</p></td>
      <td><p>any_name</p></td>
      <td><p>Should be the name of the endpoint</p></td>
    </tr>
    <tr>
      <td><p>Postfix</p></td>
      <td><p align="center">no</p></td>
      <td><p>any_value</p></td>
      <td><p>Could be the numeric index, short description, owner name, specific resource name, etc.</p></td>
    </tr>
  </tbody>
</table>

Example:<br>
Service Connection to the Azure Subscription: arm_examplesub_01<br>
Temporary Service connection to the Docker Registry: tmp_dr_mydr<br>
SSH Service Connection: ssh_myserver_jsmith<br>

## Azure Cloud naming

Azure Cloud resources naming convention based on EPAM Azure Landing Zone accelerator. Azure Naming Convention is available [here](https://dev.azure.com/#{org_name}#/AzureLandingZone/_wiki/wikis/Azure%20Landing%20Zone/1012/Azure-Naming-Convention).
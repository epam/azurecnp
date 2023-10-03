[[_TOC_]]

# Overview

Variable groups are used as an entry configuration point for both infrastructure and application management tasks. Also, it allows reusing variables in different operational tasks. It should be mentioned that variables and variable groups naming is very important. Correct naming helps to quickly understand the purpose of variables, even after project size will grow up multiple times. 

**Please read carefully the naming convention** described in [here](/Solution-overview/Governance/Naming-convention).

# Project variable group description

By default, we are using three variable group types:
- system variable group;
- application specific variable group;
- environment specific variable groups.

| Variable group name | Description |
|--|--|
| sys.global | Global variable group contains system variables |
| epam.com.env.epamaodpsshared01 | Contains common environment configuration variables |
| epam.dev.env.epamaodpsshared01 | Contains DEV environment configuration variables |
| epam.qa.env.epamaodpsshared01 | Contains QA environment configuration variables |
| epam.shift.env.epamaodpsshared01 | Contains environment configuration variables for the shift-left testing |
| epam.prod.env.epamaodpsshared01 | Contains PROD environment configuration variables |
| epam.com.app.todoapp | Contains common application specific variables |

In some cases may be useful to have common variables with different values in global and environment specific groups.

# Variables description

System specific variable names start from `SYS` prefix that helps is to easily understand variable meaning scope.

| Variable name | Description |
|--|--|
| SYS_CODE_READ_PAT         | ADO personal access token. Please check PAT generation [steps](/Demonstration-concepts/#{project_name}#.app.v1/Initial-project-configuration). |
| SYS_HELM_DEPLOY_TIMEOUT   | [Helm](https://helm.sh/) deployment timeout.  |
| SYS_HELM_VERSION          | [Helm](https://helm.sh/) version to use.  |
| SYS_KUBECTL_VERSION       | Kubectl utility version to use.  |
| SYS_OPS_RW_PAT            | ADO personal access token. Please check PAT generation [steps](/Demonstration-concepts/#{project_name}#.app.v1/Initial-project-configuration).  |
| SYS_PROJECT_CODE          | Application project code. Used for dynamic resource naming.  |

Application specific variable names start from `APP` prefix that helps is to easily understand variable meaning scope.

| Variable name | Description |
|--|--|
|APP_BUILD_CONFIGURATION        | Defines the dotnet build configuration. The default for most projects is Debug, but you can override the build configuration settings in your project.  |
|APP_DOCKER_IMAGE_STABLE_TAG    | Stable docker image tag.  |
|APP_K8S_CPU_LIMITS             | Kubernetes application POD CPU limits.  |
|APP_K8S_CPU_REQUESTS           | Kubernetes application POD CPU request.  |
|APP_K8S_MEMORY_LIMITS          | Kubernetes application POD memory limits.  |
|APP_K8S_MEMORY_REQUESTS        | Kubernetes application POD memory request.  |
|APP_NAME                       | Application name.  |
|APP_PROJECT_NAME               | .NET project name.  |
|APP_REPLICA_COUNT              | Kubernetes application POD replica count.  |
|APP_SONAR_PROJECT              | Sonar project name.  |
|APP_TRAFFIC_PERCENTAGE_CANARY  | Canary traffic percentage. Used by canary deployment to switch traffic right to the new application version.  |

Environment specific variable names start from `ENV` prefix that helps is to easily understand variable meaning scope.

| Variable name | Description |
|--|--|
| ENV_ACR_NAME                      | Azure container registry name.  |
| ENV_APP_ALERTS_RECEIVERS_EMAIL    | Application alerts receivers email address(-es).  |
| ENV_AZURE_CLIENT_ID               | Azure Cloud Service Principal client ID. Used for infrastructure management. |
| ENV_AZURE_CLIENT_SECRET           | Azure Cloud Service Principal secret. Used for infrastructure management. |
| ENV_AZURE_ENVIRONMENT             | Azure Cloud environment [type](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#environment).  |
| ENV_AZURE_SUBSCRIPTION_ID         | Azure Cloud subscription ID.  |
| ENV_AZURE_TENANT_ID               | Azure Cloud tenant ID. |
| ENV_CERT_MANAGER_ISSUER_EMAIL     | Email address that used by [cert-manager](https://cert-manager.io/) to register certificates.  |
| ENV_CERT_MANAGER_ISSUER_SERVER    | [Cert-manager](https://cert-manager.io/) issuer server.  |
| ENV_HELM_CHART_CERT               | [Cert-manager](https://cert-manager.io/) helm chart name. Used as chart name to deploy to Kubernetes and as part of the path where helm chart is located (helm chart folder name).  |
| ENV_HELM_CHART_INGR               | Kubernetes ingress controller helm chart name. Used as chart name to deploy to Kubernetes and as part of the path where helm chart is located (helm chart folder name).  |
| ENV_SERVICE_CONNECTION_NAME       | Azure Cloud ADO service connection name.  |
| ENV_TF_STATE_CONTAINER_NAME       | Azure Cloud storage account container name. Used to store Terraform .tfstate files.  |
| ENV_TF_STATE_FOLDER               | Folder name inside of Azure Cloud storage account container. Used to store Terraform .tfstate files.  |
| ENV_TF_STATE_LOCATION             | Azure Cloud storage account location. Used to store Terraform .tfstate files.  |
| ENV_TF_STATE_RESOURCE_GROUP_NAME  | Azure Cloud storage account resource group name. Used to store Terraform .tfstate files.  |
| ENV_TF_STATE_STORAGE_ACCOUNT_NAME | Azure Cloud storage account name. Used to store Terraform .tfstate files.  |
| ENV_TF_STATE_SUBSCRIPTION_ID      | Azure Cloud storage account subscription ID. Used to store Terraform .tfstate files.  |
| ENV_ACR_RG_NAME                   | Azure container registry resource group.  |
| ENV_AKS_NAME                      | Azure Kubernetes Service name.  |
| ENV_AKS_RG                        | Azure Kubernetes Service resource group.  |
| ENV_APPINS_NAME                   | Azure Cloud application insights name.  |
| ENV_INFRA_LOCATION                | Azure Cloud resources location. Example: westeurope |
| ENV_INFRA_LOCATION_SHORT          | Azure Cloud resources location (short naming). Used as a part of Azure Cloud resource names. Example (for westeurope): weeu |
| ENV_INFRA_NAME_PREFIX             | Azure Cloud resource name prefix. Used as a part of Azure Cloud resource names. |
| ENV_INFRA_SO_NAME                 | Infrastructure system owner. Used as a part of Azure Cloud resource names.  |
| ENV_INFRA_TYPE                    | Infrastructure type. Used as a part of Azure Cloud resource names. Please check available option in resource naming convention. |
| ENV_KUBERNETES_NAMESPACE          | Kubernetes namespace.  |
| ENV_MONITOR_RG                    | Azure Cloud resource group that is used for monitoring resources.  |
| ENV_NAME                          | Development environment name. Used in CI/CD processes, for configuring Kubernetes components and environments.  |

# Storing secrets

There are two ways for storing secrets in the project:
1. As Azure DevOps secret values.<br>
2. As linked Azure key vault secrets.

<span>&#9888;</span> Initially, the deployed project provides storing secrets in Azure DevOps groups. It's useful and enough for storing secrets that used by pipelines. However, since many of the tools are able to directly use the secrets stored in Azure key vaults, or when you have a necessity to view values of some secrets, combining of both approaches is the best way. Therefore, after initial infrastructure deployment, Azure key vault with copy of project secrets will be created, and you may use it when appropriate necessity will appear.


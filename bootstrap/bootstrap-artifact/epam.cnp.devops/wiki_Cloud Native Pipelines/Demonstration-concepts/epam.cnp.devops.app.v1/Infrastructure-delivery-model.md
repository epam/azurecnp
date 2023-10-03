[[_TOC_]]

# CI/CD process

Azure cloud infrastructure components is designed to be deployed using Terraform IaC tool, on the basis of Azure Landing Zone IaC governance procedures. IaC templates organized in modular manner and could be easily modified and reused, even using different Terraform configuration files. Terraform modules available [here](https://dev.azure.com/#{org_name}#/_git/#{repo_name}#?path=/iac/terraform). We are using dedicated Terraform .tfvars configuration files and variable groups to set up specific environment with help of Terraform modules. 

While Terraform and Helm are used to describe the infrastructure IaC templates, Azure pipelines automate infrastructure deployment, deletion and update. At the same time, we are using ARM templates for the very first deployment step - Terraform prerequisites deployment stage.

## IaC components

### Terraform modules

If you are not familiar with Terraform, all the necessary information can be found [here](https://www.terraform.io/intro/index.html). Terraform module structure represented below:

**main.tf** - file contains Terraform code which call other Terraform modules.<br>
**variables.tf** - file contains declarations of input variables.<br>
**variables.tfvars** - file contains Terraform code variables configuration with its' own values.<br>
**output.tf** - file contains declarations of outputs.


There are the following Terraform modules are used to deploy all infrastructure components:
- Base infrastructure [module](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/iac/terraform/epam.alz.terraform/_solutions/cnp_demo_aks);
- Application monitoring [module](https://dev.azure.com/#{org_name}#/_git/#{repo_name}#?path=/iac/terraform/epam.alz.terraform/_modules/070_appmonitoring).

But at the same time, each Terraform module uses a number of different Terraform 'child' modules and additional functions.

### ARM templates

[ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview) are native Azure Cloud IaC solution.  We are using ARM templates for initial Terraform prerequisites deployment. As a result, we will have Azure Cloud resource group with storage account inside. Azure Cloud storage account is used as shared storage for the Terraform tfstate files.

### Helm charts

Helm helps us to manage infrastructure components (such as nginx ingress controller or cert-manager) right inside Kubernetes cluster. We are using dedicated Helm chart values files and variable groups as a best practice approach to set up specific Kubernetes resources. The following [Helm charts](https://dev.azure.com/#{org_name}#/_git/#{repo_name}#?path=/containers/infrastructure/helm-charts/ingress-nginx) are used to deploy infrastructure components:
- [Cert-manager](https://cert-manager.io/) - cloud native certificate management solution allows us to generate HTTPS TLS certificates.
- [Ingress NGINX Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) - ingress-nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.
- [cert-manager-config](https://dev.azure.com/#{org_name}#/_git/#{repo_name}#?path=/containers/infrastructure/helm-charts/cert-manager-config) - used to properly configure Cert-manager solution.

# Pipelines

- To make possible to store Terraform tfstate file in dedicated shared storage, we are using Azure storage account. It deploys as an initial deployment step with help of ARM templates. Resources could be created and deleted with help of dedicated pipeline.
- To deploy Azure Cloud resources with help of Terraform utility, a separate YAML template file exists. Pipeline supports the full resources' life cycle.
- To deploy infrastructure Kubernetes resources, the separate YAML template file also exists. It supports shared and environment specific resources' creation options.

Please check [pipelines](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Pipelines) description page to get more information.

# Deployment strategies

The possibility how to deploy infrastructure components really depends on the tool\technology that is used for the specific deployment. By default, Terraform supports **Recreate** deployment strategy if the resource cannot be updated in-place due to remote API limitations, Terraform will instead destroy the existing object and then create a new replacement object with the new configured arguments. But deployment behavior could be modified a bit using `lifecycle` [meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle) and `create_before_destroy = true` option specifically. In this case, it will be some kind of **Blue/Green** deployment strategy. In fact, this is not a 100% true because there is no any testing/approval action in the middle of the process before switching the instance from version A to version B. So, the olny one option available for us - **Recreate** deployment strategy, it is used when we must recreate resource. If update the infrastructure resource configuration is available without recreation - it will just updated.

Terraform shared storage is deployed by ARM templates and the default deployment mode is "incremental", specifying that the resources deployed to the target Resource Group are incremental changes or additions to the Resource Group. It works exactly the same as for Terraform in sense of deployment strategy. This is still **Recreate** option, only if the resource cannot be updated partially without recreation action.

While we are speaking about Kubernetes infrastructure components - default rolling update deployment strategy is used. But at the same time, Kubernetes deployment enables us to use different deployment [strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy).

The diagram below shows the pipelines and their stages with main infrastructure deployment tools:

![CNP_AKS.jpg](/.attachments/CICD_Infrastructure_app_v1.png)

[CICD_Infrastructure_app_v1.xml](/.attachments/CICD_Infrastructure_app_v1.xml)
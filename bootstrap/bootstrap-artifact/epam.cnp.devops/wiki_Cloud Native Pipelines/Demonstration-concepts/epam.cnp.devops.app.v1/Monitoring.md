[[_TOC_]]

## Overview

Both application and infrastructure parts are covered by monitoring solution. As a monitoring tools Azure services used, such as Azure Log Analytics, Application insights, Container Insights solution with configured thresholds, alerts and availability tests.

## Governance

Azure monitoring solutions configuration presented as a number of Terraform modules and Terraform configuration for them. Infrastructure and application monitoring automation separated from each other to make possible to manage both of them different. To deploy all monitoring components, we are using the same Terraform deployment approach and [pipeline](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/pipelines/infrastructure/terraform-deployment-pipeline.yml), but with different Terraform modules:
- Infrastructure monitoring configuration is a part of infrastructure Terraform [module](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/iac/terraform/epam.alz.terraform/_solutions/cnp_demo_aks);
- Application monitoring configuration could be found [here](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/iac/terraform/epam.alz.terraform/_modules/070_appmonitoring).

<span>&#9888;</span> To avoid false-positive alerts execution it is recommended to apply application monitoring configuration after an application deployment.
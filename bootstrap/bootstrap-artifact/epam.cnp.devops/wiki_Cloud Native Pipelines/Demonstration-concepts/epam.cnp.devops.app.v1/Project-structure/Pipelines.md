[[_TOC_]]

# Overview

Base project pipelines are conventionally divided into next categories:
- **Operations** - allow us to perform different operational tasks.
- **Infrastructure** - organize infrastructure components CI/CD process.
- **Application** - organize application CI/CD process.

Project contains following pipelines:

| Pipeline | Class  | Triggers | Description |
|--|--|--|--|
| 00-infra-prerequisites-cd | Infrastructure  | none | Initial pipeline used to deploy resource group and Azure storage account to store Terraform tfstate files. [ARM templates](https://dev.azure.com/#{org_name}#/#{project_name}#.app.v1/_git/epam.cnp.todoapp?path=/pipelines/_configuration/_prerequsites) and environment variable groups used to configure initial components. |
| 01-infra-cd | Infrastructure | none | The pipeline used to deploy Azure Cloud infrastructure components. Terraform .tfvars configuration [files](https://dev.azure.com/#{org_name}#/#{project_name}#.app.v1/_git/epam.cnp.todoapp?path=/pipelines/_configuration) and environment variable groups used to configure infrastructure components. |
| 02-infra-k8s-environment-cd | Infrastructure | none | The pipeline used to deploy Kubernetes environment components (like ingress controllers and cert-manager). Configuration is done mainly through Helm chart value files configuration (in the "DevOps project") and variables in variable groups.|
| 03-app-cicd-canary | Application | trigger from feature; hotfix; release; develop; branches for src/*, todo.tests/* folders and Dockerfile | Main application CI/CD pipeline. Application variable groups used to configure application. Support canary deployment strategy for production deployment. |
| 04-infra-appmonitoring-cd | Infrastructure | none | The pipeline used to deploy application monitoring components. Terraform .tfvars configuration [files](https://dev.azure.com/#{org_name}#/#{project_name}#.app.v1/_git/epam.cnp.todoapp?path=/pipelines/_configuration) and environment variable groups used to configure infrastructure components. |
| 05-app-cicd-shift-left | Application | trigger from shift/* branch for src/*, todo.tests/* folders and Dockerfile | Application CI/CD pipeline that is used for shift-left testing. |
| 06-app-cicd | Application | none | Application CI/CD pipeline. Application variable groups used to configure application. Support rolling update deployment strategy for all Kubernetes environment deployments. |
| 07-app-cicd-tbd | Application | none | Application CI/CD pipeline. Application variable groups used to configure application. Support rolling update deployment strategy for production deployment and based on scaled trunk-based development. |
| 08-app-cicd-shift-left-cleanup | Application | trigger from develop branch for src/, todo.tests/ folders and Dockerfile | Application CI/CD pipeline that is used for shift-left dynamic environment removal step, checking if dynamic environment for the completed Pull Request for the shift-left branch exist. |
| service-connections-deploy | Operations | none | Allows us to manage Azure DevOps service connections. |

# Pipeline concept

Pipelines divided by several parts:
- pipeline main files;
- pipeline template file which contains all logic;
- reusable template files with task(s) or\and job(s).

**Pipeline main file** contains only mandatory part of the pipeline and link to pipeline template with stages, which located in "DevOps project" repository. It allows to avoid storing of complex pipeline code in application and infrastructure repositories. Besides, exclude possibility of changing pipeline logic by developers.

**Pipeline template files** contains all stages for all environment and refers to reusable templates with task(s) or job(s).

<span>&#9888;</span> Pipelines main file is advisable in cases with separate repositories containing any code and when developers have access there. Thereby, pipelines from "DevOps project" combines Pipeline main file and Pipeline template with stages logic in one file (multi-tier approache).

**Reusable templates** with task(s) or job(s) located in "DevOps project" and can be used by multiple projects.

# New pipeline creation

Basically to create a new pipeline you need to do the following:
1. Create pipeline template file with stages logic in "application project" repository that will link to reusable templates.
2. Find appropriate reusable template(s) in the "DevOps project" or develop new if its don't meet the requirements.
3. Add stages to pipeline template file with stages logic linked to chosen (developed) reusable templates.
4. Create main pipeline file which calls pipeline template file with stages logic in repository where auto triggering required.

<span>&#9888;</span> Pay attention that most of templates have parameters, some of them are mandatory! Developing new template try to anticipate what parameters might be useful regarded to template reusability.
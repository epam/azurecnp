[[_TOC_]]

## Project overview

The "DevOps project" that is called as "#{project_name}#" is intended for the DevOps team. It is used to store and develop universal reusable pipeline templates, scripts, terraform modules, Helm charts, and other automation assets that pipelines from different projects can call. The approach to store templates independently allows one to rapidly create a new Application project or multiple projects CI/CD pipelines by reusing universal templates. On these terms, the "#{project_name}#" project used as a **library** for the different processes.

## Repositories

There are the following repositories in the "DevOps project":

|Name    | Description    | 
|--      |--              |
| devops | Contains automation assets for CI/CD and operation tasks |
| wiki   | Wiki as a code |


### Folders structure within repositories

The "devops" repository folders:

| Name | Description |
|--|--|
| pipelines | Contains automation pipelines. |
| scripts | Contains automation scripts. |
| containers | Stores content for containerization environments. |
| iac | Contains infrastructure as a code templates, like ARM and Terraform. |

The wiki repository content generates automatically during documentation process, or could be configured manually if it needs for documentation purposes.

## Pipelines 

The "#{project_name}#" project contains pipelines that allow us to validate the code and do operational tasks:

| Pipeline  |Applicability | Triggers | Description |
|--|--|--|--|
| yaml-validation | YAML templates  | Auto<br/> (Pushing changes to the repository) | The pipeline is purposed to run static code analysis for multistage YAML pipeline's templates |
| terraform-validation | Terraform code files | Auto<br/> (Pushing changes to the repository) | The pipeline checks Terraform modules syntax and does basic security tests (https://github.com/tfsec/tfsec) |
| terraform-code-synchronization | Terraform code synchronization | None | [Terraform code synchronization](/Solution-overview/Operational-processes/Terraform-code-synchronization) from ALZ to CNP project |

## Variable groups

Variable groups and variables allow us to dynamically configure Azure DevOps pipelines without code changes. It is a very useful option on the stage of initial project configuration in the new Azure DevOps organization.
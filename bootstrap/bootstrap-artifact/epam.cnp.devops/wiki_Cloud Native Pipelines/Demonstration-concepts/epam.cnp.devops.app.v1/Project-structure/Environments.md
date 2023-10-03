[[_TOC_]]

# Default environment configuration

By default, project uses `dev`, `qa`, and `prod` environments that are used for appropriate application instance deployment. And dynamic environments (that must be created during infrastructure deployment) like `company_dev_env_example` for the variable group called `company.dev.env.example` that describes infrastructure components for environment with name `dev`.

# Environment approvals

One of the most useful environment function in Azure DevOps is 'approvals'. It allows to request permissions before the deployment.

We recommend to create a user group in your Azure DevOps organization for each environments and set appropriate approvals from members of that groups required.

# How to add new environment

1. Create new environment from `Pipelines` / `Environments` menu.
2. Add a user group in your Azure DevOps organization for created environment and set appropriate approval.
3. Add environment specific variable group to Library.
4. Edit YAML templates with stage logic for pipelines which will be use new environment (see pipelines structure description [here](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Pipelines):
   - copy environment specific stage
   - modify environment, stage, job names
   - modify connected variable group
   - modify `condition` and `dependsOn` blocks that triggers current stage (optionally)
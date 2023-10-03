[[_TOC_]]

##  Overview

In addition to the CNP solution, there is a process created to support the ability to pack all solutions into artifacts for further distribution. In fact, this is the way how the project supplied automatically and set upped into another Azure DevOps organization. Also, this functionality could be used for demonstration purposes.

That means all repositories within the "DevOps project" and "application projects", including documentation, will be placed into a unique ZIP archive. So, using this archive, it is possible to recreate the CNP projects structure within any Azure DevOps organization. This will provide examples of multi-tier YAML CI/CD pipelines, Terraform modules, scripts and other processes that could be reused or refactored according to project needs.

The deployed projects will be ready to be used, and it is possible to run pipelines to deploy infrastructure, build code and deploy code.

Here is the diagram that shows the CNP distribution overview:

![CNP_distribution_overview.png](/.attachments/CNP_distribution_overview.png)

[CNP_distribution_overview.xml](/.attachments/CNP_distribution_overview.xml)

##  DevOps project requirements

### Project bootstrap

To be able to supply and set up CNP solution "DevOps project" for the different Azure DevOps organization you have to have some components:
- Azure DevOps organization;
- Azure DevOps Personal Access Token (PAT) with full access within your organization in case you are using automatic supply approach. Refer to [MS documentation](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) to create PAT.

### Extensions

Additional post deployment actions are required to install Azure DevOps extensions into your organization:
  - [Replace Tokens](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens);
  - [Azure Pipelines Terraform Tasks](https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform) in case you plan to use Terraform IaC templates for infrastructure provisioning;
  - [SonarCloud](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarcloud&targetId=501105ea-146a-4ef7-8f0e-54de940c1f3c&utm_source=vstsproduct&utm_medium=ExtHubManageList) in case you plan to use SonarCloud static code analyze tool.

### Agent requirements

You do not need to set up additional components in case you plan to use [microsoft-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml). But if you want to use [self-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install) - there are some requirements for them:

- Linux only agents supported (based on Ubuntu);
- PowerShell must be installed;
- yamllint must be installed;
- Docker must be installed;
- Terraform optional to use in case you plan to use Terraform IaC templates for infrastructure provisioning.

##  Application project requirements

Every CNP solution "application projects" has its' own set of requirements, for this, please refer to the appropriate page for the specific "application projects".
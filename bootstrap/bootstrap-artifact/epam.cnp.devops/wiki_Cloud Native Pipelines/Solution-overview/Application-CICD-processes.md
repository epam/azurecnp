## Overview

To manage application CI/CD processes, Azure DevOps multistage YAML pipelines are used.

The pipelines designed in a modular three-tier approach:

- **Tier 1**: The "Main" application CI/CD pipeline links triggers and applications variables  and then calls the "Stages" template.
- **Tier 2**: The "Stages" template describes CI/CD stages like build, deploy, and integration tests. The "Stages" template calls small "Jobs" templates to execute particular tasks for CI/CD process
- **Tier 3**: The "Jobs" templates that describe specific Azure DevOps tasks.

The tiers are shown on the diagram below:

![CICD_architecture-Page-1.png](/.attachments/CICD_architecture-Page-1.png)
[CICD_architecture.xml](/.attachments/CICD_architecture.xml)

The modular approach provides an ability to manage CI/CD pipeline structure and logic by independent processes because the pipeline "Main" sequence and "Stages" with "Jobs" are stored in a different repositories. So, if it's required to update the pipeline for a particular application, it could be done without affecting the Application source code repository. Additionally, the provided model is centralized and has good maintainability and scalability.

The "Stages" and "Jobs" are stored as templates in the "DevOps project" and aligned by their own SDLC and branching strategy. It allows us to be flexible, supporting multiple branching strategies for the application software development lifecycle and for the automation assets development process.







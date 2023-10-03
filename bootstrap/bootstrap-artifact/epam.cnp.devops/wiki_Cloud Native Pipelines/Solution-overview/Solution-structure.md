[[_TOC_]]

## Overview

The CNP accelerator solution is based on separating logic for the application, infrastructure, operational processes by the splitting automation assets into few groups:
- pipelines;
- scripts;
- containerization assets;
- IaC templates;
- variable groups.

Configuring, triggers, variables and policies we are able to design and develop obfuscated CI/CD pipelines in a specific Azure DevOps project (or repository), but trigger their runs and pass different parameters from another Azure DevOps project (or repository). Here is the diagram that shows the relationship between those two projects within Azure DevOps Services:

![Terraform CI_CD repos relationship.png](/.attachments/CNP_project_repos_relationship.png)

[CNP_project_repos_relationship.xml](/.attachments/CNP_project_repos_relationship.xml)

The CNP accelerator, in some sense, it is a library, library of code, library of documentation and processes that could and must be reused by different projects, teams, applications. So the core project that is represented as a library is "DevOps project". The project that is based on core project assets and simply reuse its' assets - the project that is called "Application project".

The "DevOps project" which hosts the definitions of the CI/CD process templates, IaC templates, scripts and etc. purposed to be managed and updated by the team responsible for the process establishment. The "Application project" hosts application code, "stub" pipelines, and variables. These "stub" pipelines are purposed to call pipeline templates from the "DevOps project" and pass variables to them.

This approach provides good scalability and maintainability, as any "Application projects" could be linked to the central "DevOps project". Furthermore, this centralization makes it easy to control all CI/CD and IaC processes from one place. In addition to these advantages, the approach also allows for building a standard SDLC for the application CI/CD, infrastructure and operational tasks.

On the diagram above, it is shown that pipelines from the "Application project" rely on "YAML pipelines templates" in the "DevOps project". Likewise, infrastructure and operational tasks relies on the code in the "DevOps project".
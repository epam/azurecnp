[[_TOC_]]

# Overview

**Service connections (endpoints)** intended to allow interaction for project pipelines with other services. Initially project created with 2 service connections:
- Azure Resource Manager
- Azure Repos

**Azure Resource Manager** connects Azure DevOps project to Azure Cloud subscription.

**Azure Repos** permit project pipelines access to templates from "DevOps project".

Basically it's enough to start develop the application, however you can additionally create connection to SonarCloud and enable appropriate unit test in pipeline configuration.

Some pipelines could create additional endpoints by itself.

<span>&#9888;</span> Please keep in mind in case you change connection names, you also need to change appropriate variable values in [variable groups](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Variable-groups).

# Service connection management

You can manually manage connections from `Project Settings` / `Service connections` menu.

To create new or manage existed connection automatically, you can use [automation pipeline](https://dev.azure.com/#{org_name}#/#{project_name}#.app.v1/_build?definitionId=526).

## Sonar Qube endpoint

1. Go to `Project Settings` / `Service connections` - `New service connection` and select type `SonarCloud`.

2. Insert `SonarQube token` and `Service connection name` then press `Verify and safe`.

Pass your endpoint name to `SYS_SONAR_ENDPOINT` variable value in `sys.global` group.
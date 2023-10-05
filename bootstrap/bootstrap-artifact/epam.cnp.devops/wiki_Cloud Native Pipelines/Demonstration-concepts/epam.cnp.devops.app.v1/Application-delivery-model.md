[[_TOC_]]

# CI/CD process

Azure DevOps services allow is to organize any CI/CD process, that consist of different stages, approval gates, testing, branching and deployment strategies. We are using next Azure DevOps features to construct target CI/CD process:
- operators and conditions in YAML template files enables us to reconfigure pipeline stages in very flexible manner;
- trigger enable us automatically run the pipeline from the specific branch or/and folder;
- Azure DevOps environment used for approval stages for the specific environment;
- branch policy and build validation option specifically enable us to execute additional check during CI/CD process.

By default, demonstration concept configured to use:
- Gitflow branching strategy;
- Rolling update deployment strategy for the Kubernetes compute resources;
- Canary deployment strategy for the production environment on the Ingress NGINX Controller level.

## Gitflow

Current application Software Delivery Model is based on Gitflow model, which uses "classic" three tier environment DEV (Development environment); QA (Quality Assurance environment); PROD (Production environment). In case using Kubernetes cluster as a resource that holds out application, each software development environment exists as a Kubernetes namespace. In high-level:

- At the CI stage an application is building, after that docker image is prepared to deploy an app into DEV and QA environments one by one. 
- It is possible to deploy an application to DEV environment only from _develop_ git branch.
- PROD deployment is possible only by cutting off _develop_ branch on _release/_ Git branch.

The diagram below shows the CI/CD based on Git flow Development:

![development-worflows-diagrams-GitFlow.png](/.attachments/development-worflows-diagrams-GitFlow.png)  

[development-worflows-diagrams.drawio.xml](/.attachments/development-worflows-diagrams.drawio.xml)

### Development Stage

The `develop` branch is basic for application development. The `develop` branch  is maintained throughout the development process, and contains pre-production code with newly developed features that are in the process of being tested. Newly-created features should be based off the develop branch, and then merged back in when ready for testing.

The following tests are executed during the <u>development stage</u>:

* **[DEV and QA]:** Deployment verification tests
* **[DEV]:** Integration tests
* **[QA]:** Low-priority risk-based tests
* **[QA]:** Exploratory testing
* **[QA]:** High-priority risk-based tests

![Tests-envs-DEV.png.png](/.attachments/Tests-envs-DEV.png)

[Tests-envs-DEV.xml](/.attachments/Tests-envs-DEV.xml)

Branch policy for `develop`:  

* Pull Request flow is mandatory
* minimum 1 reviewer
* linked appropriate work item is required
* comment resolution check is mandatory
* build validation is mandatory

#### Feature Flow

The feature development starts with cutting off a `feature/*` branch from the `develop` branch. When feature development is done and recent code is pushed to `feature/*` branch, automatic build is triggered to complete unit tests execution, image build verification. Pull request conditions are met and changes can be merged to the `develop` branch. 

### Release Stage

Cutting off a `release` branch from the `develop` branch and triggers a build and running tests in the QA environment. After getting positive Release-verification it can be deployed to the PROD environment.

:warning: The release deployment pipeline only starts by triggers automatically if pull request in release brunch, otherwise the deployment pipeline can be started manually.

The following tests are executed during the <u>release stage<u>:

* **[QA and PROD]:** Deployment verification tests
* **[QA]:** Low-priority risk-based tests
* **[QA]:** Exploratory testing
* **[QA]:** Non-functional testing

![Tests-envs-release.png.png](/.attachments/Tests-envs-release.png)

[Tests-envs-release.xml](/.attachments/Tests-envs-release.xml)
Branch policy for `release/` branches:

* Pull Request flow is mandatory
* minimum 1 reviewer
* linked appropriate work item is required
* comment resolution check is mandatory
* build validation is mandatory

#### Bugfix flow

If some bugs were found during *Release confirmation*, the work starts over from `develop` branch again to fix the bug.

### Main Branch

`Main` branch contains stable code of recently released application. After sucessfull deployment on PROD environment, `release/` branch must be merged to `main`. 

#### Hotfix flow

In Gitflow, the `hotfix` branch is used to quickly address necessary changes in the `Main` branch.

The base of the hotfix branch should be `main` branch and should be merged back into both the `release` and `develop` branches. Merging the changes from your `hotfix` branch back into the `develop` branch is critical to ensure the fix persists the next time the `main` branch is released.

## Scaled Trunk-Based Development

At the same time, demonstration concept offers another Software Delivery Model that is based on "Trunk Based Development" and "Scaled Trunk-Based Development" specifically. Application CI/CD process in this case organized on the basis of short-lived feature branches: one person over a couple of days and flowing through Continuous Integration pipelines before merging changes into the `main` branch. 

We are using a "classic" three-tier environment DEV (Development environment), QA (Quality Assurance environment), and PROD (Production environment). In case using Kubernetes cluster as a resource that holds out the application, each software development environment exists as a Kubernetes namespace.  

### Feature flow

The feature development starts with creating a branch from the `main` branch. After completing tests, image build verification, and pull request conditions you can merge the changes. 

### Main flow

Merging changes to the `main` branch triggers the pipeline that runs unit tests and image build verification, then publishes artifacts. Approval is required for deploying the artifacts to DEV and QA environments for running the following tests:
* **[DEV and QA]** Deployment verification tests
* **[DEV]** Integration tests
* **[QA]** Feature and high-priority risk-based tests

### Release flow

Creating a release branch from the `main` branch triggers a build and running tests in the QA environment. After getting approval you can deploy it to the PROD environment.  

The following tests will be run on the release flow:
* **[QA and PROD]** Deployment verification tests
* **[QA**] Low-priority risk-based tests
* **[QA]** Exploratory testing
* **[QA]** Non-functional testing

The diagram below shows the CI/CD based on Scaled Trunk Based Development:

![development-worflows-diagrams-Trunk-Based-Development.png](/.attachments/development-worflows-diagrams-Trunk-Based-Development.png)

[development-worflows-diagrams.drawio.xml](/.attachments/development-worflows-diagrams.drawio.xml)

- The very first pipeline after merging changes to the `main` branch is building an application, after that, we are able to deploy an artifact (docker image) into DEV and QA environments one by one. Application deployed into DEV and QA environments using the default Kubernetes deployment strategy - **rolling update** (see [Deployments Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment)). It is possible to deploy an application to DEV and QA environments only from the `main` git branch.

# Pipelines

CI/CD YAML templates files could be found [here](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/pipelines/application). There are few "root" pipelines that allow us to manage the whole application CI/CD process. More information about pipelines could be found [here](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Pipelines).

# Deployment strategies

Application deployment is done by Helm, because it is easier to manage the instance that consist of multiple Kubernetes manifests. Also, Helm allow us to use additional tool logic, to make application package that is called Helm chart to be flexible and well reusable. A Kubernetes deployment enables us to use different deployment strategies. And the default Kubernetes deployment strategy is - [rolling update](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy). This strategy is used by the current application update flow on the level of Kubernetes **Deployments**. The diagram below shows the deployment flow for the current implementation through the all AKS environments without taking into consideration release management flow:

![AKS_CosmosDB_APP_deployment_flow.png](/.attachments/AKS_CosmosDB_APP_deployment_flow.png)

[Diagrams.net XML source code for  AKS CosmosDB application deployment flow](/.attachments/AKS_CosmosDB_APP_deployment_flow.xml)

## Canary deployment flow

But what if you have to use another deployment strategy like canary? The wide variety of tools and technologies that are used in the containerized environment allow us to realize any deployment strategy in a flexible manner. By default, canary deployment is not available out of the box for the Kubernetes. That is why we are using additional instruments, such as Helm and Ingress NGINX Controller for Kubernetes. Keeping in mind that Helm already used in deployment flow, while Ingress NGINX Controller implemented in current infrastructure.

Canary deployment implemented on the basis of Ingress NGINX Controller possibilities and `nginx.ingress.kubernetes.io/canary*` annotations specifically. It allows us to redirect requests to the appropriate ingress resource. That is mean that we have to use at least two different ingress resource with equal path and, additional dedicated ingress object (direct) with different path that routes traffic right to the news version of application.

Using two or three ingress resource force us to use the same number of Kubernetes service resources, that will be route traffic to the both application versions (current and new).

Finally, we must have two different application versions. The diagram below shows the traffic flow to the current PODs and to the new PODs:

![AKS Canary deployment requests flow.png](/.attachments/AKS_CosmosDB_traffic_flow.png)

[Diagrams.net XML source code for AKS Canary deployment requests flow](/.attachments/AKS_CosmosDB_traffic_flow.xml)

### Canary deployment configuration

#### NGINX Controller configuration

Ingress NGINX Controller uses the following annotations to enable canary deployments:
```
nginx.ingress.kubernetes.io/canary
nginx.ingress.kubernetes.io/canary-weight
nginx.ingress.kubernetes.io/canary-by-header
nginx.ingress.kubernetes.io/canary-by-header-value
nginx.ingress.kubernetes.io/canary-by-header-pattern
nginx.ingress.kubernetes.io/canary-by-cookie
```
We are using `nginx.ingress.kubernetes.io/canary, nginx.ingress.kubernetes.io/canary-weight` annotations to route a percent of traffic. Ingress NGINX annotations configured right in the application Helm chart.

#### Application configuration

Application deployment flow is fully managed by Helm and its' [Helm chart](https://dev.azure.com/#{org_name}#/#{project_name}#/_git/#{repo_name}#?path=/containers/application/helm-charts/todo-app-canary). Where we have two Kubernetes Deployment manifest (for the current application version and for the new one) as an output of Helm chart, multiple Kubernetes services and ingress resources and a number of conditions to support canary deployment flow.

#### Pipeline configuration

Canary deployment flow is not a one time update action as it could be done for Blue/Green deployment flow. Canary deployment approach could be implemented at least with next active phases:
- deploy new application version and redirect part of users to the new application version;
- swap 100% traffic to the new application version;
- mark new application version as current, changing the code for the current version and removing additional replicas for the new application version.

Considering that - Azure DevOps CD pipeline also supports canary deployment flow, at least 3 stages with approval procedure insight based on Azure DevOps environments and just only for production deployment.

The diagram below shows the flow for canary deployment into the PROD environment:

![AKS_CosmosDB_Canary_deployment.png](/.attachments/AKS_CosmosDB_Canary_deployment.png)

[Diagrams.net XML source code for  AKS CosmosDB Canary deployment](/.attachments/AKS_CosmosDB_Canary_deployment.xml)

The application CI/CD pipeline contains the following stages for the canary deployment:

1. Build the application.
2. Determine the canary PODs' replicas count based on `PIPE_APP_TRAFFIC_PERCENTAGE_CANARY` and `APP_REPLICA_COUNT` and update Kubernetes deployment with its value. `PIPE_RELEASE_ARTIFACTNAME` docker image tag is used as image tag for the new production deployment. Redirecting the traffic to the new application version by NGINX Controller annotations on the basis of `APP_TRAFFIC_PERCENTAGE_CANARY` value.
3. Updating Kubernetes deployment, swapping 100% traffic from current to new deployment. Scaling the number of current application replicas to 1, and the number of replicas for the new deployment equal to `APP_REPLICA_COUNT`.
4. Tagging the new image version as `stable` and replacing the current application image version with new `stable` version. Scaling the number of current application replicas to `APP_REPLICA_COUNT`, and the number of replicas for the new deployment equal to `0`. Redirecting 100% of the traffic to the new `stable` application version.

# Shift-left testing

Shift-left testing is a strategy to move tasks and tests to an earlier stage in the development process, so that potential problems can be identified and fixed earlier before they become bigger and more expensive. This is done by post-deployment tests in the pipeline that allow us to detect if the web application is up and running after deployment is done. At the same time, we are creating the temporary, isolated, self-contained environment for the new shift-left testing approach handling, each time when it needs us.

## Automated tests

To detect if the web application is up and running after deployment is done the pipeline do some verification steps:

- [Helm test](https://helm.sh/docs/topics/chart_tests/) that validates that our chart works as expected when it is installed.  Helm test templates lives under the templates/ Helm chart directory.
- The "Deployment verification test" checks web service availability from the Azure DevOps agent to ensure that the application is responding with the HTTP 200 code.

## Shift-left process

At the start of the process, we need to create a shift-left branch (`shift`) and configure [variable group](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Variable-groups). The key difference between shift-left variable group configuration and variable groups that are used for the DEV or QA environments configuration - the value for the `ENV_KUBERNETES_NAMESPACE` and `ENV_KUBERNETES_NAMESPACE` that are equal to the `$(Build.SourceBranchName)` system variable. This 'hook' used for the dynamic environment naming.

<span>&#9888;</span> In case if branch will be called `shift/123-example`, environment name will be `123-example`. Environment name also used as a part of the DNS name. Try to use as short branch name as possible. We are using cert-manager with Let's Encrypt provider for the certificate generation option. There is the domain name limitation exist when using AutoSSL with Let's Encrypt. The error occurs when attempting to request an SSL certificate from Let's Encrypt for a domain name longer than 64 characters. When this domain name is used as the Common Name (CN) for the SSL certificate, the request fails.

[Pipeline](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Pipelines) will be triggered each time when we make a commit into `shift` branch and deploys dynamic environment with all necessary infrastructure components right in the same Azure Cloud resources that is used for DEV environment. But it could be configured by the specific variable group. When the dynamic environment created, the pipeline starts to deploy the application. Tests execution happens right after application deployment. If the specific feature was developed and tested correctly, we are approving the changes and making a PR into the "main" branch. Depending on the branching strategy that is used in current development flow, main branches naming differs. For the Gitflow it could be "develop" but for the TBD - "main". When the new feature is ready and merged into the "main" development branch, an additional pipeline will be triggered by the commit into the main branch which found the branch name for the latest completed PR and checks if the environment (in our case Kubernetes namespace) with such name still exist. If the answer is yes - it will delete the entire namespace with all components.

The diagram below shows the CI/CD process in terms of shift-left testing approach with a part of TBD flow:
![shift-left-testing.png](/.attachments/shift-left-testing.png)

[shift-left-testing.xml](/.attachments/shift-left-testing.xml)
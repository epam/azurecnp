[[_TOC_]]

## Overview

SonarQube is a widely adopted open-source platform that continuously inspects source code quality and detects bugs, vulnerabilities, and code smell in more than 20 languages. It is free for Community Edition version to prerair your SonarQube server and supports all major programming languages, including C#, VB .Net, JavaScript, TypeScript, C/C++, and many more.

SonarQube explains all coding issues in detail, allowing you to fix your code before even merging and deploying while learning best practices along the way. At the project level, you'll also get a dedicated widget that tracks the overall health of your application.

As well if you don't want to prepaire self-managed SonarQube server, you can use SonarCloud. SonarCloud offers a paid plan to run private analyses if your code is a closed source. 

Azure DevOps SonarQube extension provides build tasks that you can add to your build definition. In addition, you will benefit from the automated detection of bugs and vulnerabilities across all branches and Pull Requests. 

## Installation 

To use SonarQube code analysis in the project, you need to follow these steps:

- Install [SonarQube extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) from Visual Studio Marketplace
- Create a SonarQube account on self or other side hosted SonarQube server (ex. SonarCloud)
- Create a new project in the account and generate token
- Create Azure Devops service connection for SonarQube

## How to use

To set up SonarQube validation, you need to use three build tasks in your YAML pipeline file:

- Prepare Analysis Configuration task, to configure all the required settings before executing the build. This task is mandatory. In case of .NET solutions or Java projects, this tasks helps to integrate seamlessly with MSBuild, Maven and Gradle tasks.

```
Code example
- task: SonarQubePrepare@5
  enabled: ${{ parameters.enableSonarQubeAnalyze }}
  inputs:
    SonarQube: '$(SYS_SONAR_ENDPOINT)'
    scannerMode: 'MSBuild'
    projectKey: '$(APP_SONAR_PROJECT)'
    extraProperties: |
      sonar.cs.opencover.reportsPaths="${{ parameters.sourceRepoPath }}/TestResults/coverage/**.xml"
      sonar.cs.vstest.reportsPaths="${{ parameters.sourceRepoPath }}/TestResults/*.trx"
```

- Run Code Analysis task, to actually execute the analysis of the source code. Not required for Maven or Gradle projects.

```
Code example
- task: SonarQubeAnalyze@5
  enabled: ${{ parameters.enableSonarQubeAnalyze }}
  env: {BROWSERSLIST_IGNORE_OLD_DATA: true} # to ignore server side error if sonar version under 9.4
```
- Publish Quality Gate Result task, to display the quality gate status in the build summary. This tasks is optional, as it can increase the overall build time.
```
- task: SonarQubePublish@5
  enabled: ${{ parameters.enableSonarQubeAnalyze }}
  inputs:
    pollingTimeoutSec: '300'
```
- Configure the following variables in variable groups:
  - SYS_SONAR_ENDPOINT - the name of configured Azure DevOps service connection
  - APP_SONAR_PROJECT - the name of the project in SonarQube server
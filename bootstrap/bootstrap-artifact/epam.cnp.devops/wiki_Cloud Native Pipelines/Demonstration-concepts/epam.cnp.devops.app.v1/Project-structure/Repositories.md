[[_TOC_]]

# Overview

Project contains 2 repositories:
- epam.cnp.todoapp
- epam.cnp.wiki

Repository `epam.cnp.todoapp` intended for developers team. It contains .NET application source code, Docker file to build a docker image from source code, pipeline files and necessary infrastructure configuration.

Repository `epam.cnp.wiki` contains project documentation.

**Pipeline files** contain only mandatory part of the pipeline and link to pipeline template with stages, which located in "DevOps project" repository with all automation assets that are needed. More information on [pipelines page](/Demonstration-concepts/#{project_name}#.app.v1/Project-structure/Pipelines).

# Branch strategy

**Gitflow** is taken as a basis for the branching strategy, please learn more about Gitflow and it's modifications from deployed "DevOps project" wiki or on [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) page. 


##Branch naming pattern
- **develop**
   Active development is happening in the develop branch usually. Reflects a state with the latest delivered development changes for the next release.
- **release/***
  The key moment to branch off a new release branch from develop is when develop (almost) reflects the desired state of the new release. At least all features that are targeted for the release-to-be-built must be merged in to develop at the point in time. All features targeted at future releases may not - they must wait until after the release branch is branched off. Semipermanent lifetime means that release branch can leave forever if artifacts are not created from this version.
- **feature/***
   Feature branches are used to develop new features for the upcoming or a distant future release. The essence of a task branch is that it exists if the story/task (feature) is in development but will eventually be merged back into develop (to add the new feature to the upcoming release) or discarded (in case the business goals have been changed).
- **hotfix/***
  Hotfix branches are like bugfix branches, but created from release branches and intended to fix issues in them once the release that is already used by dependent project.
- **master**
  Usually this branch reflects a production-ready state. After code has been validated in a release branch and pushed to production, the code is merged to the master branch and marked with appropriate release tag.

<span>&#9888;</span> Initially all repositories created with one 'develop' branch.

## Branch policy

According to Gitflow workflow following branch policy set to protect some branches:
![release_branch_policy.png](/.attachments/release_branch_policy.png)

You can ***specify your own policy*** from `Project Settings` / `Repositories` menu.


# Application repository content

Application repository `epam.cnp.todoapp` constructed with next file structure:

**src** - folder contains developed application source code.<br>
**pipelines** - folder contains Azure DevOps pipelines with configuration files for infrastructure deployments and operational tasks.<br>
**Dockerfile** - contains configuration for docker container image that will be created by pipeline.<br>

# Multiple applications

There are two approaches to scale the number of application using common infrastructure for several applications:
1. Multi-repo approach. In this case, you need to add application repositories and respective variable groups for each new application instance. 
2. Monorepo. In this case, you need to add application folders inside of application repository and respective variable groups for each new application instance. 
In all cases, you need to modify existing pipeline files to set up CI/CD process that you need to implement.
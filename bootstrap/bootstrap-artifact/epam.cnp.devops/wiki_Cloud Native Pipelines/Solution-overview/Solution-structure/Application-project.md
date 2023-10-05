[[_TOC_]]

## Project overview

The application project is the project purposed for delivery team activity. It has repositories, variable groups, and pipelines for the application CI/CD process and infrastructure deployment. It relies on the "DevOps project" and generally makes calls of shared templated from that "DevOps project". Application project supplied with the CNP accelerator contain the number of infrastructure, application, documentation samples that shows us the possibilities of the CNP accelerator. At the same, application project used not only as the demonstration samples, but it is a very good start point for initial project configuration for the specific task. More information is [available here](/Demonstration-concepts).

## Repositories

Repositories structure also as folders structure and their content fully dependent on the type of project, its requirements, implemented logic and environment that is used. All these assets are covered in [this](/Demonstration-concepts) section for each of application samples examples.

## Pipelines

The general approach for pipelines definition within the project is to create "stub" pipelines to only call jobs from the "DevOps project". Each application or solution project could have a different number of pipelines, but the general approach is to have a dedicated pipeline for a specific process.

## Variable groups

Variable groups and variables allow us to dynamically configure Azure DevOps pipelines without code changes. It is a very useful option on the stage of initial project configuration in the new Azure DevOps organization. Each application project has its variable groups or YAML-file variables. These variables are required for the application, infrastructure deployment and the whole CI/CD processe.

Variable group naming is described in the "Governance" section in the "Naming convention" article. Variable groups description for a specific [project](/Demonstration-concepts) is described in the appropriate project documentation.
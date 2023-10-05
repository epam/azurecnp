[[_TOC_]]

## Overview

We suggest to use infrastructure as code (IaC) process of managing infrastructure with automated methods. It improves consistency, security, eliminate configuration drift and allow us to tack the changes (versioning). Infrastructure as code approach, already implemented in CNP for managing infrastructure components in the Azure Cloud.

By default, we are using Terraform IaC development approach that is used in [Azure Landing Zone](https://dev.azure.com/#{org_name}#/AzureLandingZone/_wiki/wikis/Azure%20Landing%20Zone/1756/Terraform-code-development) project.

The CNP project contains a lot of CI/CD YAML pipelines to provide IaC automated deployment process. YAML pipelines are also aligned with the modular approach and could be easily combined and reused.

In the diagram below, "terraform.yml" represents the Root template and "jobs.yml" represents the Child template:

![Infrastructure provisioning and configuration.png](/.attachments/Infrastructure%20provisioning%20and%20configuration.png)
[Infrastructure provisioning and configuration.xml](/.attachments/Infrastructure%20provisioning%20and%20configuration.xml)
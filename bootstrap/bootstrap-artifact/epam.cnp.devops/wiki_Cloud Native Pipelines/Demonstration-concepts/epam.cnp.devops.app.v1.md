[[_TOC_]]

## Overview

The solution represents a basic reference model for infrastructure management and application CI/CD processes in case of using Azure Kubernetes Services (AKS) in combination with Azure Cosmos DB.

It relies on Azure DevOps services as an orchestrator for CI/CD and infrastructure deployment and configuration.

Terraform used as IaC tool. Application and infrastructure components inside AKS cluster are managed by Helm. It allows us to control full application and infrastructure life cycle starting from creation phase, its' update and deletion phases.

## Architecture

Initial architecture based on [Microservices architecture on Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-microservices/aks-microservices) but the key difference is - how we use IaC approach. Azure Cloud infrastructure components managed by Terraform and uses [Azure Landing Zone concepts](https://dev.azure.com/#{org_name}#/AzureLandingZone). Azure pipelines as a part of Azure DevOps Services uses for automated builds, tests, and deployments.

Here is a diagram that shows the solution architecture:

![CNP_AKS.jpg](/.attachments/CNP_AKS.jpg)

[CNP_AKS.vsdx](/.attachments/CNP_AKS.vsdx)

The whole solution is divided into two independent parts - development and production environments. Each environment consist of next Azure Cloud components:

- Azure Kubernetes Service (AKS) - AKS is an Azure service that deploys a managed Kubernetes cluster. AKS is responsible for deploying the Kubernetes cluster and managing the Kubernetes API server. You only manage the agent nodes.

- Azure virtual network - By default, AKS creates a virtual network to deploy the agent nodes. For more advanced scenarios, you can create the virtual network first, which lets you control how the subnets are configured, on-premises connectivity, and IP addressing.

- Ingress - Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource. "Ingress NGINX Controller" used in current implementation, but it could be [any](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

- Azure Load Balancer - An Azure Load Balancer is created when the "Ingress NGINX Controller" is deployed. The load balancer routes internet traffic to the ingress.

- External data stores - Microservices are typically stateless and write state to external data stores, such as Azure SQL Database or Cosmos DB. In current case Azure Cosmos DB stores application data.

- Private endpoint - provide a privately accessible IP address for the specific resource (Azure Cosmos DB).

- Azure Container Registry - Azure Container Registry (ACR) used to store Docker images and make it possible to deploy them to the kubernetes cluster. AKS can authenticate with ACR using its Azure AD identity. Note that AKS does not require ACR. You can use other container registries, such as Docker Hub.

- Azure Monitor - Azure Monitor collects and stores metrics and logs, including platform metrics for the Azure services in the solution and application telemetry. Use this data to monitor the application, set up alerts and dashboards, and perform root cause analysis of failures. Moreover, Azure Monitor integrates with AKS to collect metrics from controllers, nodes, and containers, as well as container and node logs.

- Azure Log Analytics - used for analyze and alerts in case of infrastructure and application disasters. Also used by container insights to monitor the performance of Kubernetes instances. 

- Application Insights - uses for application performance monitoring and availability test specifically.

- Resource groups - uses to logically split Azure Cloud resources for an Azure solution.
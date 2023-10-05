# Introduction 
Simple ASP.NET [web application](https://github.com/Azure-Samples/cosmos-dotnet-core-todo-app).
Application sample shows you how to use the Microsoft Azure Cosmos DB service to store and access data from an ASP.NET Core MVC application hosted on Azure Kubernetes Service.
Automation pipelines and IaC configuration allows you to manage all infrastructure components ands CI/CD processes that are needed for development process.

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

# Changes
[02.22.2023]

Added "todo.Tests" with empty test for demonstration of unit testing 

App changes to resolve SonarQube warnings:
* renamed "queryString" to "query" in CosmosDbService.cs
* added "readonly" property for "_container" in CosmosDbService.cs
* added "static" property for Program class in Program.cs
* added to ignor warning for an indentical method "DeleteAsync" in ItemController.cs

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)
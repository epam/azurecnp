location = "#{ENV_INFRA_LOCATION}#"

aks = [
  {
    cluster_name                      = "#{ENV_AKS_NAME}#"
    aks_private_cluster_enabled       = false
    rg_name                           = "#{ENV_AKS_RG}#"

    ### Identity
    identity_type                     = "SystemAssigned"
    identity_ids                      = []
    
    default_node_pool = {
      name                   = "default"
      node_count             = 2
      vm_size                = "Standard_DS2_v2"
      os_disk_size_gb        = 100
      zones                  = []
      enable_node_public_ip  = true
      enable_auto_scaling    = false
      enable_host_encryption = false
      max_count              = 3
      min_count              = 1
      max_pods               = 60
    }

    ### Auto scaler profile
    balance_similar_node_groups       = false
    max_graceful_termination_sec      = "600"
    scale_down_delay_after_add        = "10m"
    scale_down_delay_after_failure    = "3m"
    scan_interval                     = "10s"
    scale_down_unneeded               = "10m"
    scale_down_unready                = "20m"
    scale_down_utilization_threshold  = "0.5"

    ### Network configuration
    network_plugin                    = "azure"
    network_policy                    = null
    pod_cidr                          = null
    service_cidr                      = null
    dns_service_ip                    = null
    docker_bridge_cidr                = null
    
    tags = {
      environment         = "dev"
      businessCriticality = "high"
      businessUnit        = "DA"
      businessOwner       = "SO"
      platfromSupport     = "1"
      functionalSupport   = "0"
      reviewedOn          = "22.08.2023"
    }
  }
]

vnet = {
  vnet_name                          = "#{ENV_INFRA_SO_NAME}#-vnet-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#core-01"
  rg_name                            = "#{ENV_INFRA_SO_NAME}#-rg-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#network-01"
  address_space = [
    "10.10.0.0/16"
  ]
  subnets = [
    { 
      name                = "#{ENV_INFRA_SO_NAME}#-sub-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#-01"
      address_prefixes    = ["10.10.0.0/22"]
      service_endpoints   = [
      "Microsoft.AzureActiveDirectory",
      "Microsoft.KeyVault",
      "Microsoft.Storage",
      "Microsoft.AzureCosmosDB"
      ]
    },
    {
      name                = "#{ENV_INFRA_SO_NAME}#-sub-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-appgtw-01"
      address_prefixes    = ["10.10.4.0/24"]
      service_endpoints   = [
      "Microsoft.KeyVault",
      "Microsoft.Storage"
      ]
    },
    {
      name                = "#{ENV_INFRA_SO_NAME}#-sub-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-prend-01"
      address_prefixes    = ["10.10.5.0/24"]
      service_endpoints   = [
      "Microsoft.AzureActiveDirectory",
      "Microsoft.KeyVault",
      "Microsoft.Storage",
      "Microsoft.AzureCosmosDB"
      ]
    }
  ]
  tags = {
    environment         = "dev"
    businessCriticality = "high"
    businessUnit        = "DA"
    businessOwner       = "SO"
    platfromSupport     = "1"
    functionalSupport   = "0"
    reviewedOn          = "22.08.2023"
  }
}

acr = {
  name = "#{ENV_ACR_NAME}#"
  rg_name = "#{ENV_ACR_RG_NAME}#"
  sku = "Basic"
  admin_enabled = true
}
log_analytics = {
  name                                  = "#{ENV_INFRA_SO_NAME}#-la-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#-01"
  rg_name                               = "#{ENV_MONITOR_RG}#"
  pricing_tier                          = "PerGB2018"
  retention_in_days                     = 60
  la_solutions = [
    {
      la_sln_name      = "ContainerInsights"
      la_sln_publisher = "Microsoft"
      la_sln_product   = "OMSGallery/ContainerInsights"
    }
  ]
  tags = {
    environment         = "dev"
    businessCriticality = "high"
    businessUnit        = "DA"
    businessOwner       = "SO"
    platfromSupport     = "1"
    functionalSupport   = "0"
    reviewedOn          = "22.08.2023"
  }
}
cosmosdb_account = {
  rg_name                   = "#{ENV_ACR_RG_NAME}#"
  cosmosdb_account_name     = "#{ENV_INFRA_SO_NAME}#-cosdb-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#-01"
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location = [
    {
      location          = "northeurope"
      failover_priority = 0
    }
  ]
  allowed_subnets = [
    {
      vnet_name                            = "#{ENV_INFRA_SO_NAME}#-vnet-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#core-01"
      vnet_rg_name                         = "#{ENV_INFRA_SO_NAME}#-rg-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#network-01"
      subnet_name                          = "#{ENV_INFRA_SO_NAME}#-sub-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#-01"
      ignore_missing_vnet_service_endpoint = true
    }
  ]
  prend_subnet_name = "#{ENV_INFRA_SO_NAME}#-sub-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-prend-01"
}
app_insights = {
  appinsights_name    = "#{ENV_APPINS_NAME}#"
  rg_name             = "#{ENV_MONITOR_RG}#"
  application_type    = "web"
}

monitor_action_groups = [
  {
    action_group_name       = "aks_alert_recievers_#{ENV_NAME}#"
    action_group_short_name = "aks_#{ENV_NAME}#"
    rg_name                 = "#{ENV_MONITOR_RG}#"
    enabled                 = true

    email_receiver = [
      {
        name                    = "notify_#{ENV_APP_ALERTS_RECEIVERS_EMAIL}#"
        email_address           = "#{ENV_APP_ALERTS_RECEIVERS_EMAIL}#"
        use_common_alert_schema = true
      }
    ]
  }
]

alerts = [
    {
        action_group_rg_name       = "#{ENV_MONITOR_RG}#"
        action_group_name          = "aks_alert_recievers_#{ENV_NAME}#"

        metric_alert = [
          {
            name                = "Container CPU percentage"
            description         = "Calculates average CPU used per container"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/containers"
                metric_name            = "cpuExceededPercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "95"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetes namespace"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "controllerName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Container working set memory percentage"
            description         = "Calculates average working set memory used per container"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/containers"
                metric_name            = "memoryWorkingSetExceededPercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "95"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetes namespace"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "controllerName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Node CPU percentage"
            description         = "Calculates average CPU used per node"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/nodes"
                metric_name            = "cpuUsagePercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "80"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "host"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Node disk usage percentage"
            description         = "Calculates average disk usage for a node"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/nodes"
                metric_name            = "DiskUsedPercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "80"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "host"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "device"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Node NotReady status"
            description         = "Calculates if any node is in NotReady state"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/nodes"
                metric_name            = "nodesCount"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "0"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "status"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Node working set memory"
            description         = "Calculates average Working set memory for a node"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/nodes"
                metric_name            = "memoryWorkingSetPercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "80"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "host"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "OOM Killed Containers"
            description         = "Calculates number of OOM killed containers"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/pods"
                metric_name            = "oomKilledContainerCount"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "0"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetes namespace"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "controllerName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Persistent volume usage percentage"
            description         = "Calculates average PV usage per pod"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/persistentvolumes"
                metric_name            = "pvUsageExceededPercentage"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "80"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetesNamespace"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "podName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Pods ready percentage"
            description         = "Calculates the average ready state of pods"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/pods"
                metric_name            = "PodReadyPercentage"
                aggregation            = "Average"
                operator               = "LessThan"
                threshold              = "80"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetes namespace"
                    operator = "Include"
                    values   = [ "*" ]
                  },
                  {
                    name     = "controllerName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Failed pod counts"
            description         = "Calculates if any pod in failed state"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/pods"
                metric_name            = "podCount"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "0"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "phase"
                    operator = "Include"
                    values   = [ "Failed" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Restarting container count"
            description         = "Calculates number of restarting containers"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/pods"
                metric_name            = "restartingContainerCount"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "0"
                skip_metric_validation = true
                dimension              = [
                  {
                    name     = "kubernetes namespace"
                    operator = "Include"
                    values    = [ "*" ]
                  },
                  {
                    name     = "controllerName"
                    operator = "Include"
                    values   = [ "*" ]
                  }
                ]
              }
            ]
          },
          {
            name                = "Completed job count"
            description         = "Calculates number of jobs completed more than six hours ago"
            metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
            frequency           = "PT1M"
            severity            = "3"
            window_size         = "PT5M"
            criteria            = [
              {
                metric_namespace       = "Insights.Container/pods"
                metric_name            = "completedJobsCount"
                aggregation            = "Average"
                operator               = "GreaterThan"
                threshold              = "0"
                skip_metric_validation = true
                dimension              = [
                  {
                    name = "kubernetes namespace"
                    operator = "Include"
                    values = [ "*" ]
                  },
                  {
                    name = "controllerName"
                    operator = "Include"
                    values = [ "*" ]
                  }
                ]
              }
            ]
          }
        ]                    
    }
] 
app_monitoring = {
    appinsightactions     = [
        {
            rg_name          = "#{ENV_MONITOR_RG}#"
            appinsights_name = "#{ENV_INFRA_SO_NAME}#-appins-#{ENV_INFRA_LOCATION_SHORT}#-#{ENV_INFRA_TYPE}#-#{ENV_INFRA_NAME_PREFIX}#-01"
            web_tests        = [
                {
                    name                    = "todoapp-availability-#{ENV_NAME}#"
                    kind                    = "ping"
                    description             = "Application availability test"
                    geo_locations           = ["us-il-ch1-azr","apac-jp-kaw-edge","emea-ch-zrh-edge","us-fl-mia-edge","latam-br-gru-edge"]
                    frequency               = 300
                    url                     = "https://#{SYS_PROJECT_CODE}#-#{ENV_INFRA_NAME_PREFIX}#-#{ENV_NAME}#.#{ENV_INFRA_LOCATION}#.cloudapp.azure.com/"
                    timeout                 = 60
                    enabled                 = true
                    expected_status_code    = 200
                    configuration           = <<XML
                                              <WebTest Name="test" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
                                              <Items>
                                                  <Request Method="GET" Version="1.1" Url="https://#{SYS_PROJECT_CODE}#-#{ENV_INFRA_NAME_PREFIX}#-#{ENV_NAME}#.#{ENV_INFRA_LOCATION}#.cloudapp.azure.com/" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
                                              </Items>
                                              </WebTest>
                                              XML
                }
            ]
        }
    ]
    monitor_action_groups = [
        {
            action_group_name       = "app_alert_recievers_#{ENV_NAME}#"
            action_group_short_name = "appsql#{ENV_NAME}#"
            rg_name                 = "#{ENV_MONITOR_RG}#"
            email_receiver          = [
                {
                    name                    = "notify_#{ENV_APP_ALERTS_RECEIVERS_EMAIL}#"
                    email_address           = "#{ENV_APP_ALERTS_RECEIVERS_EMAIL}#"
                    use_common_alert_schema = true
                }
            ]
        }
    ]
    alerts   = [
        {
            action_group_rg_name = "#{ENV_MONITOR_RG}#"
            action_group_name    = "app_alert_recievers_#{ENV_NAME}#"
            metric_alert         = [
                {
                    name                = "app-avaliability_#{ENV_NAME}#"
                    metric_alert_scopes = ["/subscriptions/#{ENV_AZURE_SUBSCRIPTION_ID}#/resourceGroups/#{ENV_MONITOR_RG}#/providers/Microsoft.Insights/components/#{ENV_APPINS_NAME}#"]
                    description         = "Alerts when application is unavalible"
                    frequency           = "PT1M"
                    severity            = 1
                    window_size         = "PT5M"
                    criteria            = [
                        {
                            metric_namespace = "microsoft.insights/components"
                            metric_name      = "availabilityResults/availabilityPercentage"
                            aggregation      = "Average"
                            operator         = "LessThan"
                            threshold        = "100"
                            dimension        = [
                                {
                                    name     = "availabilityResult/name"
                                    operator = "Include"
                                    values   = [ "*" ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
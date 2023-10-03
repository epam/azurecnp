terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2" # use the version it was last implemented or last tested with
    }
  }

  required_version = ">= 1.1.7" # only changes if a module requires something specific from a specific minor/patch version, e.g: 1.1.2
}
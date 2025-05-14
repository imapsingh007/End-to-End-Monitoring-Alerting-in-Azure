terraform {
  required_version = ">= 1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Optional: remote state, e.g. a storage account you already have.
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod000001"
    container_name       = "tfstate"
    key                  = "monitoring.tfstate"
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    # Replace these placeholders or supply values at `terraform init` with -backend-config
    resource_group_name  = "RG-Mahbub-Rahman"
    storage_account_name = "mahbubtfstatefiles"
    container_name       = "statefiles"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "9c87ae58-f043-4631-94a6-9e8f9519132a"
}
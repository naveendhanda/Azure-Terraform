// More information on the Azure Terraform provider is available in the below link
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id = "f300f5aa-36bf-454c-866b-41cfa2d8f15b"
  client_secret = "kdc8Q~RZd~oGAmYvERMLgpJkMeEFBGDTL5WVpdco"
  tenant_id = "38dbefc3-d57f-4955-b62c-1406e16a4ea8"
  subscription_id = "387407e5-94af-45e7-b378-4d37af61c732"
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "North Europe"
}
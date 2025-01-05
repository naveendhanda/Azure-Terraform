terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
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

locals {
  resource_location="North Europe"
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "websubnet01"
    address_prefixes = ["10.0.0.0/24"]
  }

  subnet {
    name             = "appsubnet01"
    address_prefixes = ["10.0.1.0/24"]
  }
 
}


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


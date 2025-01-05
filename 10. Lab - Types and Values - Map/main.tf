resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_virtual_network" "app_network" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = local.virtual_network.address_prefixes

  subnet {
    name             = "websubnet01"
    address_prefixes = [local.subnet_address_prefix[0]]
  }

  subnet {
    name             = "appsubnet01"
    address_prefixes = [local.subnet_address_prefix[1]]
  }
 
}


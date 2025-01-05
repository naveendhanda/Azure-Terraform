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
    name             = local.subnets[0].name
    address_prefixes = local.subnets[0].address_prefixes
  }

  subnet {
    name             = local.subnets[1].name
    address_prefixes = local.subnets[1].address_prefixes
  }
 
}


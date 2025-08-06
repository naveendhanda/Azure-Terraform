# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Create Virtual Networks for each region
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-${var.region1}"
  address_space       = ["10.0.0.0/16"]
  location            = var.region1
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-${var.region2}"
  address_space       = ["10.1.0.0/16"]
  location            = var.region2
  resource_group_name = azurerm_resource_group.main.name
}

# Create Subnets for Application Gateways
resource "azurerm_subnet" "appgw_subnet1" {
  name                 = "appgw-subnet-${var.region1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "appgw_subnet2" {
  name                 = "appgw-subnet-${var.region2}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Create Public IPs for Application Gateways
resource "azurerm_public_ip" "appgw_pip1" {
  name                = "appgw-pip-${var.region1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.region1
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "appgw-${var.region1}-${random_string.suffix.result}"
}

resource "azurerm_public_ip" "appgw_pip2" {
  name                = "appgw-pip-${var.region2}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.region2
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "appgw-${var.region2}-${random_string.suffix.result}"
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Application Gateway 1
resource "azurerm_application_gateway" "appgw1" {
  name                = "appgw-${var.region1}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.region1

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.appgw_subnet1.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw_pip1.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }
}

# Application Gateway 2
resource "azurerm_application_gateway" "appgw2" {
  name                = "appgw-${var.region2}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.region2

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.appgw_subnet2.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw_pip2.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }
}

# Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "main" {
  name                   = var.traffic_manager_name
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = var.traffic_routing_method

  dns_config {
    relative_name = var.traffic_manager_dns_name
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

# Traffic Manager Endpoints for Application Gateways
resource "azurerm_traffic_manager_azure_endpoint" "appgw1_endpoint" {
  name               = "appgw-endpoint-${var.region1}"
  profile_id         = azurerm_traffic_manager_profile.main.id
  weight             = 100
  target_resource_id = azurerm_public_ip.appgw_pip1.id
}

resource "azurerm_traffic_manager_azure_endpoint" "appgw2_endpoint" {
  name               = "appgw-endpoint-${var.region2}"
  profile_id         = azurerm_traffic_manager_profile.main.id
  weight             = 100
  target_resource_id = azurerm_public_ip.appgw_pip2.id
}
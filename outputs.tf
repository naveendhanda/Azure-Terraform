output "traffic_manager_fqdn" {
  description = "Fully qualified domain name of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.fqdn
}

output "traffic_manager_profile_id" {
  description = "ID of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.id
}

output "application_gateway_1_fqdn" {
  description = "FQDN of Application Gateway 1"
  value       = azurerm_public_ip.appgw_pip1.fqdn
}

output "application_gateway_2_fqdn" {
  description = "FQDN of Application Gateway 2"
  value       = azurerm_public_ip.appgw_pip2.fqdn
}

output "application_gateway_1_ip" {
  description = "Public IP address of Application Gateway 1"
  value       = azurerm_public_ip.appgw_pip1.ip_address
}

output "application_gateway_2_ip" {
  description = "Public IP address of Application Gateway 2"
  value       = azurerm_public_ip.appgw_pip2.ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "application_gateway_1_id" {
  description = "ID of Application Gateway 1"
  value       = azurerm_application_gateway.appgw1.id
}

output "application_gateway_2_id" {
  description = "ID of Application Gateway 2"
  value       = azurerm_application_gateway.appgw2.id
}
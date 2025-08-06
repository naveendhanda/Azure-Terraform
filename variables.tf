variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-traffic-manager-demo"
}

variable "location" {
  description = "Primary Azure region for the resource group"
  type        = string
  default     = "East US"
}

variable "region1" {
  description = "First Azure region for Application Gateway deployment"
  type        = string
  default     = "East US"
}

variable "region2" {
  description = "Second Azure region for Application Gateway deployment"
  type        = string
  default     = "West US"
}

variable "traffic_manager_name" {
  description = "Name of the Traffic Manager profile"
  type        = string
  default     = "tm-appgw-demo"
}

variable "traffic_manager_dns_name" {
  description = "DNS name for the Traffic Manager profile"
  type        = string
  default     = "tm-appgw-demo"
}

variable "traffic_routing_method" {
  description = "Traffic routing method for Traffic Manager"
  type        = string
  default     = "Performance"
  validation {
    condition = contains(["Performance", "Weighted", "Priority", "Geographic", "MultiValue", "Subnet"], var.traffic_routing_method)
    error_message = "Traffic routing method must be one of: Performance, Weighted, Priority, Geographic, MultiValue, Subnet."
  }
}
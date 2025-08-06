# Log Analytics Workspace for centralized logging
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${azurerm_resource_group.appgrp.name}"
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    Environment = "Development"
    Project     = "Terraform-Labs"
    CreatedBy   = "Terraform"
  }
}

# VM Insights for performance monitoring
resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  name                       = "vm-diagnostics"
  target_resource_id         = azurerm_windows_virtual_machine.webvm01.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Security"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Network Security Group Flow Logs for network monitoring
resource "azurerm_network_watcher_flow_log" "nsg_flow_log" {
  network_watcher_name = "NetworkWatcher_${local.resource_location}"
  resource_group_name  = "NetworkWatcherRG"  # Default RG created by Azure
  
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  storage_account_id        = azurerm_storage_account.monitoring.id
  enabled                   = true
  
  retention_policy {
    enabled = true
    days    = 7
  }
  
  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.main.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.main.location
    workspace_resource_id = azurerm_log_analytics_workspace.main.id
    interval_in_minutes   = 10
  }
}

# Storage account for diagnostics and flow logs
resource "azurerm_storage_account" "monitoring" {
  name                     = "monitoring${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    Environment = "Development"
    Project     = "Terraform-Labs"
    CreatedBy   = "Terraform"
    Purpose     = "Monitoring"
  }
}

# Random string for unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "terraform-labs-alerts"
  resource_group_name = azurerm_resource_group.appgrp.name
  short_name          = "tflabs"
  
  # Add email notification (replace with actual email)
  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

# CPU Alert Rule
resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "high-cpu-usage"
  resource_group_name = azurerm_resource_group.appgrp.name
  scopes              = [azurerm_windows_virtual_machine.webvm01.id]
  description         = "Alert when CPU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Memory Alert Rule (requires VM insights extension)
resource "azurerm_monitor_metric_alert" "high_memory" {
  name                = "high-memory-usage"
  resource_group_name = azurerm_resource_group.appgrp.name
  scopes              = [azurerm_windows_virtual_machine.webvm01.id]
  description         = "Alert when memory usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1073741824  # 1GB in bytes
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Disk Performance Alert
resource "azurerm_monitor_metric_alert" "high_disk_usage" {
  name                = "high-disk-usage"
  resource_group_name = azurerm_resource_group.appgrp.name
  scopes              = [azurerm_windows_virtual_machine.webvm01.id]
  description         = "Alert when disk usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Queue Depth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 32
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
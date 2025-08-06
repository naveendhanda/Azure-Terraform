terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.5"  # Allow patch updates for security fixes
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  
  # Enable parallel resource creation for faster deployments
  required_version = ">= 1.5"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
  
  # Use environment variables instead of hardcoded credentials
  # Set ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
  skip_provider_registration = true  # Speed up provider initialization
}
###
# Terraform implementation example
###
terraform {
  backend "azurerm" {}
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.78.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.SUBSCRIPTIONID
  tenant_id       = var.tenant_id

  features {}
}

###
# Variables
###

variable "tenant_id" {
  type    = string
  default = ""
}

variable "SUBSCRIPTIONID" {
  type    = string
  default = ""
}
variable "ENVIRONMENT" {
  type = string
}

variable "APPLICATION" {
  type = string
}


variable "extra_ip_rules" {
  type        = list(string)
  description = "A list of additional IP rules to allow/deny for the storage account firewall. Each IP rule is specified as a CIDR notation string.Provide a default value if there are any additional IP rules."
  default     = []
}

variable "extra_subnet_ids" {
  type        = list(string)
  description = "A list of additional subnet IDs to grant access to the storage account. This allows resources in the specified subnets to access the storage account.Provide a default value if there are any additional subnet IDs."
  default     = []
}


###
## Data 
###

#data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "keyvault" {
  name                = "keyvaulttest"
  resource_group_name = "RG-KEY-VAULT-WE"
}

data "azurerm_log_analytics_workspace" "log" {
  name                = "testlogs"
  resource_group_name = "RG-WORKSPACE-WE"
}

###
## Resources
###
resource "azurerm_resource_group" "rg" {
  name     = "RG-ST-NPD"
  location = "westeurope"

  lifecycle {
    // ignoring subscription inherited tags
    ignore_changes = [
      tags,
    ]
  }
}

module "storage_account" {
  source              = "git::source" # Source for the storage account module                                                                                                  
  resource_group_name = azurerm_resource_group.rg.name                                                                                                                        # Name of the Azure resource group
  environment = {                                                                                                                                                             # Configuration for the environment
    env      = "dev"                                                                                                                                                          # Environment name
    app_code = "app"                                                                                                                                                    # Application code
  }
  access_tier                         = "Hot"                # Storage account access tier (Hot or Cool)
  account_kind                        = "StorageV2"          # Storage account kind (StorageV2, BlobStorage, etc.)
  account_replication_type            = "ZRS"                # Replication type (LRS, GRS, etc.)
  account_tier                        = "Standard"           # Storage account performance tier (Standard or Premium)
  extra_ip_rules                      = var.extra_ip_rules   # List of extra IP rules for storage firewall
  extra_subnet_ids                    = var.extra_subnet_ids # List of extra subnet IDs for storage firewall
  is_hns_enabled                      = false                # Is Hierarchical Namespace enabled
  is_large_file_share_enabled         = false                # Is Large File Share enabled
  is_sftp_enabled                     = false                # Is SFTP (SSH) enabled
  days_for_blob_retention_policy      = "30"                 # Number of days for blob retention policy
  days_for_blob_restore_policy        = "7"                  # Number of days for blob restore policy
  days_for_container_retention_policy = "30"                 # Number of days for container retention policy
  tags = {
    TERRAFORM = "true"
  }

  depends_on = [azurerm_resource_group.rg]

  #variables for the diagnostic settings
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log.id

  #variables for encryption
  key_vault_id = data.azurerm_key_vault.keyvault.id
  computerDscr = "Computer Account object for Azure storage account."
}

# Define the blob container module with relevant configuration.
module "container" {
  source               = "git::source" # Source for the blob container module
  container_name       = "containertest"                                                                                                             # Name of the blob container                                                                                                 # Access type for the blob container (private, blob, container)
  storage_account_name = module.storage_account.azure_storage_account_name                                                                           # Name of the associated storage account
}

# Define the table module for configuring Azure Storage Tables.
module "table" {
  source               = "git::source"  # Source for the table module
  table_name           = "tabletestnpd"                                                                                                          # Name of the Azure Storage Table
  storage_account_name = module.storage_account.azure_storage_account_name                                                                              # Name of the associated storage account
}

# Define the queue module for configuring Azure Storage Queues.
module "queue" {
  source               = "git::source"  # Source for the queue module
  queue_name           = "queuetest"                                                                                                                    # Name of the Azure Storage Queue
  storage_account_name = module.storage_account.azure_storage_account_name                                                                              # Name of the associated storage account
}

# Define the queue module for configuring Azure Storage Fileshares.
module "fileshare" {
  source               = "git::source"  Source for the fileshare module                                                                                                                  
  environment = {                                                                                                                                                             # Configuration for the environment
    env      = "dev                                                                                                                                                          # Environment name
    app_code = "app"                                                                                                                                                    # Application code
  }
  file_share_quota     = "100"                                             # Quota size for the File Share  
  file_share_tier      = "Hot"                                             # Performance tier for the File Share (Standard, Premium, etc.)
  storage_account_name = module.storage_account.azure_storage_account_name # Name of the associated storage account
}

##
# outputs
##

# Output the Azure Storage Account ID.
output "azure_storage_account_id" {
  description = "The storage account ID"
  value       = module.storage_account.azure_storage_account_id
}

# Output the Azure Storage Account name.
output "azure_storage_account_name" {
  description = "The storage account name"
  value       = module.storage_account.azure_storage_account_name
}

# Output the Key Vault Key name & ID

output "azure_key_vault_key_id" {
  description = "The key id"
  value       = module.storage_account.azure_key_vault_key_id
}

output "azure_key_vault_key_name" {
  description = "The key name"
  value       = module.storage_account.azure_key_vault_key_name
}

# Output the Key Vault access policy ID

output "azure_key_vault_access_policy_id" {
  description = "The key vault access policy id"
  value       = module.storage_account.azure_key_vault_access_policy_id
}

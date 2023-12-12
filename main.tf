###
# Terraform
###

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.78.0"
    }
  }
  required_version = ">= 1.5"
}


###
# locals
###

locals {
  default_ip_rules = []
  default_allowed_subnet_ids = []
}

###
# Naming
###
#In this section we call the naming convention module in order to name the storage account.
module "nc_storage_account" {
  source       = "git::source"
  type         = "AzureStorageAccount"
  environment  = var.environment
  custom_field = var.custom_field
}

###
# Data
###

data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

###
# Ressources
###

#In this section, we define the storage account resource block, given the following parameters:
# Define a resource block for creating an Azure Storage Account
# The soft delete configuration for objects is temporary configuration until the backup is set 
resource "azurerm_storage_account" "azure_storage_account" {

  name                             = module.nc_storage_account.name                                  # Set the name of the Storage Account using the value from a separate module
  resource_group_name              = data.azurerm_resource_group.rg.name                             # Specify the name of the resource group in which the Storage Account will be created
  location                         = coalesce(var.location, data.azurerm_resource_group.rg.location) # Specify the Azure region where the Storage Account should be located
  account_tier                     = var.account_tier                                                # Specify the performance tier of the Storage Account (e.g., Standard, Premium)
  account_kind                     = var.account_kind                                                # Specify the kind of Storage Account (e.g., StorageV2, BlobStorage)
  access_tier                      = var.access_tier                                                 # Specify the access tier for blob storage (e.g., Hot, Cool, Archive)
  account_replication_type         = var.account_replication_type                                    # Specify the type of replication for the Storage Account (e.g., LRS, GRS)
  min_tls_version                  = "TLS1_2"                                                        # Set the minimum required TLS version for secure connections
  cross_tenant_replication_enabled = false                                                           # Disable cross-tenant replication for added security
  allow_nested_items_to_be_public  = false                                                           # Restrict access to nested items within containers to be non-public
  is_hns_enabled                   = var.is_hns_enabled                                              # Enable or disable Hierarchical Namespace (HNS)
  enable_https_traffic_only        = true                                                            # Allow only HTTPS traffic to the Storage Account for security
  sftp_enabled                     = var.is_sftp_enabled                                             # Enable or disable SFTP (SSH File Transfer Protocol) for the Storage Account. To enable SFTP, HNS must be enabled
  large_file_share_enabled         = var.is_large_file_share_enabled                                 # Enable or disable large file share support for the Storage Account
  default_to_oauth_authentication  = false                                                           # Disable the Azure Active Directory authorization in the Azure portal when accessing the Storage Account.
  allowed_copy_scope               = var.allowed_copy_scope                                          # Define the allowed copy scope to and from the storage accounts
  nfsv3_enabled                    = false                                                           # Disable NFS support
  shared_access_key_enabled        = var.shared_access_key_enabled                                   # Enable or disable shared access keys for the storage account


  blob_properties {
    delete_retention_policy {
      days = var.days_for_blob_retention_policy #30days
    }
    restore_policy {                          # This must be used together with delete_retention_policy set, versioning_enabled and change_feed_enabled set to true.
      days = var.days_for_blob_restore_policy # must be less than the days in delete_retention_policy
    }
    container_delete_retention_policy {
      days = var.days_for_container_retention_policy
    }
    versioning_enabled  = var.versioning_enabled # This field cannot be configured when kind is set to Storage (V1)
    change_feed_enabled = true
  }

  # Configure the network rules for the Storage Account
  network_rules {

    default_action             = "Deny"                                                         # Set the default action for incoming traffic (e.g., Deny, Allow)
    ip_rules                   = concat(local.default_ip_rules, var.extra_ip_rules)             # Define the IP rules for incoming traffic, combining default and additional rules
    virtual_network_subnet_ids = concat(local.default_allowed_subnet_ids, var.extra_subnet_ids) # Define the IDs of virtual network subnets allowed to access the Storage Account

  }

  # Configure the routing settings for the Storage account
  routing {

    choice                      = "MicrosoftRouting" # The choice of routing mechanism is set to "MicrosoftRouting" by default.
    publish_internet_endpoints  = false              # Internet endpoints are not being published by this configuration.
    publish_microsoft_endpoints = false              # Microsoft endpoints are also not being published by this configuration.
  }

  dynamic "identity" {
    for_each = var.encryption_enabled == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
  lifecycle {
    // ignoring subscription inherited tags
    ignore_changes = [
      tags,
    ]
  }
  share_properties {
    dynamic "smb" {
      for_each = var.joinAD_enabled == true ? [1] : [0]
      content {
        authentication_types            = var.authentication_types            # Specify the allowed authentication types for SMB (e.g., NTLMv2, Kerberos)
        channel_encryption_type         = var.channel_encryption_type         # Specify the type of channel encryption used for SMB (e.g., required, preferred)
        kerberos_ticket_encryption_type = var.kerberos_ticket_encryption_type # Specify the encryption type for Kerberos tickets (e.g., none, krb5)
        multichannel_enabled            = var.multichannel_enabled            # Enable or disable multichannel support for SMB
        versions                        = var.versions                        # Specify the supported SMB protocol versions (e.g., SMB2, SMB3)
      }
    }

  }

  # Dynamic block for defining Azure Files authentication settings.
  dynamic "azure_files_authentication" {
    for_each = var.joinAD_enabled == true ? [1] : [0]
    content {
      directory_type = var.directory_type # Type of directory for Azure Files authentication.

      active_directory {
        # Domain-specific configurations.
        domain_name         = var.domain_name
        domain_guid         = var.domain_guid
        domain_sid          = var.domain_sid
        storage_sid         = module.join-share["enabled"].sid
        netbios_domain_name = var.netbios_domain_name
        forest_name         = var.forest_name
      }
    }
  }

  depends_on = [module.join-share]

}


# This module declaration creates an instance of the "register_share".
module "join-share" {
  for_each     = toset(var.joinAD_enabled ? ["enabled"] : [])
  source       = "./modules/register_share"
  computerName = replace(module.nc_storage_account.name, "st", "fs") # Pass the name of computer object
  computerDscr = var.computerDscr                                    # Pass the description of the computer 
}


### Encryption configuration
# Configure access policy for the Azure Key Vault to grant necessary permissions to the storage account.
resource "azurerm_key_vault_access_policy" "keyvault_access_policy_terraform_storage" {
  count        = var.encryption_enabled == true ? 1 : 0
  key_vault_id = var.key_vault_id                                                       # Specify the Azure Key Vault ID.
  tenant_id    = data.azurerm_client_config.current.tenant_id                           # Specify the Azure AD tenant ID.
  object_id    = azurerm_storage_account.azure_storage_account.identity[0].principal_id # Use the principal ID of the identity associated with the storage account.

  secret_permissions = ["Get"]                         # Define permissions for secrets (in this case, Get permission).
  key_permissions    = ["Get", "WrapKey", "UnwrapKey"] # Specify the operations that are allowed on the key within the Key Vault for the st managed identity.
}

# Create an RSA-HSM key in the Azure Key Vault to be used as the customer-managed key for the storage account.
resource "azurerm_key_vault_key" "terraform_storage_key" {
  count        = var.encryption_enabled == true ? 1 : 0
  name         = "${module.nc_storage_account.name}-encryption-key" # Specify the name for the key.
  key_vault_id = var.key_vault_id                                   # Specify the Azure Key Vault ID.
  key_type     = "RSA-HSM"                                          # Specify the key type (RSA-HSM in this case).
  key_size     = 2048                                               # Specify the key size (2048 bits in this case).
  # Specify key options for various operations.
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  lifecycle {
    ignore_changes = [
      key_vault_id # Ignore changes to the key_vault_id to prevent unnecessary updates.
    ]
  }
}

# Associate the customer-managed key from the Azure Key Vault with the storage account.
resource "azurerm_storage_account_customer_managed_key" "st-customer-managed-key" {
  count              = var.encryption_enabled == true ? 1 : 0
  storage_account_id = azurerm_storage_account.azure_storage_account.id    # Specify the Azure Storage Account ID.
  key_vault_id       = var.key_vault_id                                    # Specify the Azure Key Vault ID.
  key_name           = azurerm_key_vault_key.terraform_storage_key[0].name # Use the name of the key created in the Azure Key Vault.
}



#IMPORTANT: The 'target_resource_id' parameter within the diagnostic settings resource block expects a string data type 
#and does not accept a list. Therefore, a separate diagnostic setting resource block must be created for each individual object,
#ensuring that the 'target_resource_id' is specified as a string for each instance.

# Diagnostic settings for storage account
resource "azurerm_monitor_diagnostic_setting" "st_dg" {
  for_each                   = toset(var.enable_diagnostic_settings_st ? ["enabled"] : [])
  name                       = "fr-dg-${module.nc_storage_account.name}"
  target_resource_id         = azurerm_storage_account.azure_storage_account.id # Specify the target resource ID for the storage account.
  log_analytics_workspace_id = var.log_analytics_workspace_id                   # Specify the Log Analytics workspace ID in which you want to send the logs.

  # Enable metrics collection for the storage account
  metric {
    category = "Transaction"
  }
}

# Diagnostic settings for blob
resource "azurerm_monitor_diagnostic_setting" "blob_dg" {
  for_each                   = toset(var.enable_diagnostic_settings_blob ? ["enabled"] : [])
  name                       = "fr-dg-${module.nc_storage_account.name}-blob"
  target_resource_id         = "${azurerm_storage_account.azure_storage_account.id}/blobServices/default/" # Specify the target resource ID for blob storage
  log_analytics_workspace_id = var.log_analytics_workspace_id                                              # Specify the Log Analytics workspace ID in which you want to send the logs.

  # Enable audit logs for the blob storage
  enabled_log {
    category_group = "audit"
  }

  # Enable all logs for the blob storage
  enabled_log {
    category_group = "allLogs"
  }
}

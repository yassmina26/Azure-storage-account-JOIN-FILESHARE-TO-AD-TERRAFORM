###
# Variables
###
############################# Naming convention variables ######################################

variable "custom_field" {
  type        = string
  default     = ""
  description = "(Optional) custom field for naming convention"
}

variable "environment" {
  type = object({
    country_code = optional(string, "fr")
    env          = string
    region       = optional(string, "we")
    app_code     = string
  })
  description = "(Required) Environment details (for naming convention)."
}

############################# Storage Account Variables ######################################

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created"
}

variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the storage account will exist. Changing this forces a new resource to be created."
  default     = ""
}

variable "account_kind" {
  type        = string
  description = "Defines the kind of storage account."
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Valid values BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "(Required) Defines the access tier for BlobStorage, FileStorage and StorageV2."

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Valid values are Hot, Cool."
  }
}

variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "(Required) Defines the Tier to use for this storage account."

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Valid values are Standard, Premium."
  }
}

variable "account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "(Required) Defines the type of replication to use for this storage account."

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAZGRS"], var.account_replication_type)
    error_message = "Valid values are LRS, GRS, RAGRS, ZRS, GZRS, RAZGRS."
  }
}

variable "is_hns_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Defines if hierachical namespace feature is enabled."
}

variable "is_large_file_share_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enables the storage account for file share spanning up to 100 TiB."
}

variable "is_sftp_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enables the storage account for SFTP to transfer files securely to and from Azure storage."
}

variable "allowed_copy_scope" {
  type        = string
  default     = "AAD"
  description = " (Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet."
  validation {
    condition     = contains(["AAD", "PrivateLink"], var.allowed_copy_scope)
    error_message = "Valid values are AAD and PrivateLink."
  }
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD)."
}

variable "days_for_blob_retention_policy" {
  type        = string
  default     = "30"
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days. Defaults to 7."
}

variable "days_for_blob_restore_policy" {
  type        = string
  default     = "7"
  description = "(Required) Specifies the number of days that the blob can be restored, between 1 and 365 days. This must be less than the days specified for delete_retention_policy"
}

variable "days_for_container_retention_policy" {
  type        = string
  default     = "30"
  description = "(Optional) Specifies the number of days that the container should be retained, between 1 and 365 days. Defaults to 7."
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Tags that will be merged with the common mandatory tags."
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "(Optional) value of versioning "
}
############################# Diagnostic Settings Variables ##########################
variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
  description = " (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent. "
}
variable "enable_diagnostic_settings_blob" {
  type        = bool
  default     = true
  description = "(Required) Enable the diagnostic settings for the storage account blob"
}
variable "enable_diagnostic_settings_st" {
  type        = bool
  default     = true
  description = "(Required) Enable the diagnostic settings for the storage account"
}
############################# Network Varialbles######################################

variable "extra_ip_rules" {
  type        = list(string)
  default     = []
  description = "Extra IPv4 addresses or IP ranges (CIDR format) to allow."
}

variable "extra_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Extra subnet resource ids to allow."
}

######################### Share File variables ##########################
variable "authentication_types" {
  type        = set(string)
  default     = ["Kerberos"]
  description = "(Optional) A set of SMB authentication methods."
}

variable "channel_encryption_type" {
  type        = set(string)
  default     = ["AES-256-GCM"]
  description = "(Optional) A set of SMB channel encryption."
}

variable "kerberos_ticket_encryption_type" {
  type        = set(string)
  default     = ["AES-256"]
  description = "(Optional) A set of Kerberos ticket encryption."
}


variable "multichannel_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Indicates whether multichannel is enabled. Defaults to `false`. This is only supported on Premium storage accounts."
}

variable "versions" {
  type        = set(string)
  default     = ["SMB3.1.1"]
  description = "(Optional) A set of SMB protocol versions."
}

############################ Join Fileshare to AD parameters ##########################
variable "directory_type" {
  type        = string
  default     = "AD"
  description = "(Required) Specifies the directory service used. Possible values are AADDS, AD and AADKERB."
}

variable "domain_name" {
  type        = string
  default     = "fr.deloitte.com"
  description = "(Required) Specifies the primary domain that the AD DNS server is authoritative for."
}

variable "domain_guid" {
  type        = string
  default     = "41284b6e-4631-482e-aaa4-8b267319777a"
  description = "(Required) Specifies the domain GUID."
}

variable "domain_sid" {
  type        = string
  default     = "S-1-5-21-2139493591-172588965-2079600828"
  description = "(Optional) Specifies the security identifier (SID). This is required when directory_type is set to AD"
}

# variable "storage_sid" {
#   type        = string
#   default     = "S-1-5-21-2139493591-172588965-2079600828-357141"
#   description = "(Optional) Specifies the security identifier (SID) for Azure Storage. This is required when directory_type is set to AD."
# }

variable "forest_name" {
  type        = string
  default     = "deloitte.com"
  description = "(Optional) Specifies the Active Directory forest. This is required when directory_type is set to AD."
}

variable "netbios_domain_name" {
  type        = string
  default     = "NEUILLY"
  description = "(Optional) Specifies the NetBIOS domain name. This is required when directory_type is set to AD."
}

variable "joinAD_enabled" {
  type        = bool
  default     = true
  description = "(Required) the flag to activate or desactivate the fileshare registration to AD."
}

variable "computerDscr" {
  description = "(Required) Computer Description"
  type        = string
  validation {
    condition     = length(var.computerDscr) < 100
    error_message = "Computer Description must be less than 100 characters."
  }
}
############################# Encryption variables ####################################
variable "encryption_enabled" {
  type        = bool
  default     = true
  description = "(Required) the flag to activate or desactivate encryption for the storage account"
}
variable "key_vault_id" {
  type        = string
  default     = ""
  description = "(Required) Specifies the id of the Key Vault resource. Changing this forces a new resource to be created."
}

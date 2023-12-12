############################# Naming convention variables ######################################

variable "custom_field" {
  type        = string
  default     = ""
  description = "(Optional) custom field for naming convention"
}

variable "environment" {
  type = object({
    country_code = optional(string, "en")
    env          = string
    region       = optional(string, "we")
    app_code     = string
  })
  description = "(Required) Environment details (for naming convention)."
}
###########################" Fileshare variables ###############################################

variable "storage_account_name" {
  type        = string
  default     = ""
  description = "(Required) Specifies the storage account in which to create the storage container. Changing this forces a new resource to be created."
}

variable "file_share_quota" {
  type        = string
  default     = "15360"
  description = "(Required) The maximum size of the share, in gigabytes."
}

variable "file_share_tier" {
  type        = string
  default     = "Cool"
  description = "(Optional) The access tier of the File Share."
  validation {
    condition     = contains(["Hot", "Cool", "TransactionOptimized", "Premium"], var.file_share_tier)
    error_message = "Valid values are Hot, Cool and TransactionOptimized, Premium."
  }
}

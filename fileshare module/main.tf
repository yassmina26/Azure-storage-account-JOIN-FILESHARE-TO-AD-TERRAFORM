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
# Naming
###
module "nc_fileshare" {
  source       = "git::source"
  type         = "AzureStorageFileShare"
  environment  = var.environment
  custom_field = var.custom_field
}

###
# Resources
###

resource "azurerm_storage_share" "fileshare" {
  name                 = module.nc_fileshare.name
  storage_account_name = var.storage_account_name
  quota                = var.file_share_quota
  access_tier          = var.file_share_tier
}

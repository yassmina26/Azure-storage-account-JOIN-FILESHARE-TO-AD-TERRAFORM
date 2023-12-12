################# Storage Account Outputs ##############################
output "azure_storage_account_id" {
  description = "The storage account ID"
  value       = azurerm_storage_account.azure_storage_account.id
}

output "azure_storage_account_name" {
  description = "The storage account name"
  value       = azurerm_storage_account.azure_storage_account.name
}

################ Key Vault Access Policy Outputs #######################
output "azure_key_vault_access_policy_id" {
  description = "The key vault access policy id"
  value       = azurerm_key_vault_access_policy.keyvault_access_policy_terraform_storage[0].id
}

################ Key Vault Key Outputs #################################
output "azure_key_vault_key_id" {
  description = "The key id"
  value       = azurerm_key_vault_key.terraform_storage_key[0].id
}

output "azure_key_vault_key_name" {
  description = "The key name"
  value       = azurerm_key_vault_key.terraform_storage_key[0].name
}

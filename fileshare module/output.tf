output "file_share_name" {
  value       = azurerm_storage_share.fileshare.name
  description = "The name of the File Share resource"
}

output "file_share_id" {
  value       = azurerm_storage_share.fileshare.id
  description = "The id of the File Share resource"
}

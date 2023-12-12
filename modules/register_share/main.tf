###
# Terraform
####

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
# Locales
###

locals {
  # AD server information
  adUser       = sensitive("")
  server_ip_AD = sensitive("")
}

# This block retrieves a secret named "joindom-password" from an Azure Key Vault to use as user password to connect to the AD.
data "azurerm_key_vault_secret" "joindom_password" {
  name         = "joindom-password"
  key_vault_id = var.kv_id
}

# This block executes an external program (a PowerShell script) to create a Computer Object in the AD for the storage account.
data "external" "execute_matricage2" {
  program = ["powershell.exe", "${path.module}/CreateComputerObject.ps1", "-server_ip_AD", "'${local.server_ip_AD}'", "-adUser", "'${local.adUser}'",
  "-adPwd", "'${data.azurerm_key_vault_secret.joindom_password.value}'", "-computerName", "'${var.computerName}'", "-computerDscr", "'${var.computerDscr}'"]
}

# This output exposes the "sid" (Security Identifier) of the created object from the result of the external program execution.
output "sid" {
  value      = data.external.execute_matricage2.result.sid
  depends_on = [data.external.execute_matricage2]
}

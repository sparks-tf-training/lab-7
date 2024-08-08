# main.tf

# Provider configuration
provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

locals {
  location = data.azurerm_resource_group.rg.location
}

variable "name" {
  description = "The name of the resources."
  default     = "example"
}


resource "random_string" "vault" {
  length  = 8
  special = false

}

resource "azurerm_key_vault" "vault" {
  name                = "vault${random_string.vault.result}"
  location            = local.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Update",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
  ]
}

output "vault_id" {
  value = azurerm_key_vault.vault.id
}
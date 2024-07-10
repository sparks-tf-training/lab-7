# main.tf

# Provider configuration
provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
}

variable "vnet" {
  description = "The name of the virtual network."
}

variable "subnet" {
  description = "The name of the subnet."
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group_name
}

locals {
  location = data.azurerm_resource_group.rg.location
}

variable "name" {
  description = "The name of the resources."
  default     = "example"
}

# Public IP address
resource "azurerm_public_ip" "example" {
  name                = "${var.name}-public-ip"
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Network interface
resource "azurerm_network_interface" "example" {
  name                = "${var.name}-nic"
  location            = local.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = "${var.name}-vm"
  resource_group_name   = var.resource_group_name
  location              = local.location
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1ls"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.name}-vm"
    admin_username = "adminuser"
    admin_password = random_password.password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.example.ip_address
    user     = "adminuser"
    password = random_password.password.result
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    ]
  }
}

output "public_ip" {
  value = azurerm_public_ip.example.ip_address
}

output "vm_name" {
  value = azurerm_virtual_machine.example.name
}

output "vm_id" {
  value = azurerm_virtual_machine.example.id
}

output "identity_id" {
  value = azurerm_user_assigned_identity.example.principal_id
}

output "password" {
  value     = random_password.password.result
  sensitive = true

}

variable "key_vault_id" {
  description = "The ID of the key vault."
}

# Managed Identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = local.location
}

# Assign Managed Identity to Key Vault
resource "azurerm_key_vault_access_policy" "example_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = azurerm_user_assigned_identity.example.principal_id

  certificate_permissions = []
  key_permissions         = []
  secret_permissions      = ["Get"]
  storage_permissions     = []
}
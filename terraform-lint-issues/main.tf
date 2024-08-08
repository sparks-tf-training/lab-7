variable "config" {
  type    = object({ instance_type = string })
  default = null
}

resource "azurerm_virtual_machine" "example" {
  name                  = "example-machine"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  vm_size               = var.config.instance_type
  network_interface_ids = [azurerm_network_interface.example.id]

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
}
data "azurerm_resource_group" "RG" {
  name = var.resource_group_name
}



data "azurerm_subnet" "Subnet" {
    name                 = data.azurerm_virtual_network.Vnet.subnets[count.index]
    virtual_network_name = data.azurerm_virtual_network.Vnet.name
    resource_group_name  = data.azurerm_virtual_network.Vnet.resource_group_name
    count                = length(data.azurerm_virtual_network.Vnet.subnets)
}


output "subnets_id" {
  value = data.azurerm_subnet.Subnet.*.id
}






resource "azurerm_network_interface" "NIC" {
  name                = var.name_nic
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_virtual_network.vnet.subnet.*.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM_windows_2019" {
  name                = var.name_vm_windows_2019
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.version
  }
}


resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "nix-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1S"
  instances           = 1
  custom_data         = filebase64("web.conf")
  health_probe_id = azurerm_lb_probe.lbProbe.id


  computer_name_prefix = "helloworld"

  ##Login info
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = "false"


  automatic_instance_repair {
    enabled = true

  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "vmssInt"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.backNSG.id

    ip_configuration {
      name                                   = "vmss"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lbBackPool.id]


    }
  }
}


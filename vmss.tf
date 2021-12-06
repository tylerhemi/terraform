# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}


resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "nix-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1S"
  instances           = 2
  custom_data         = filebase64("web.conf")
  health_probe_id = azurerm_lb_probe.lbProbe.id
  zones = ["1","2","3"]
  computer_name_prefix = "helloworld"

  ##Login info
  admin_username                  = "hemiadmin"
  disable_password_authentication = "true"

  admin_ssh_key {
    username = "hemiadmin"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }



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


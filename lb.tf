resource "azurerm_public_ip" "pubIP" {
  name                = "lbPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"


}
resource "azurerm_lb" "lb" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"





  frontend_ip_configuration {
    name                 = "PublicIpAddress"
    public_ip_address_id = azurerm_public_ip.pubIP.id
  }

}

resource "azurerm_lb_backend_address_pool" "lbBackPool" {
  name            = "loadBalancerBackPool"
  loadbalancer_id = azurerm_lb.lb.id

}
/*
resource "azurerm_lb_backend_address_pool_address" "lbBackPoolIP" {
  name                    = "loadBalancerBackPoolIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbBackPool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address              = "10.0.0.10"

}
*/


resource "azurerm_lb_probe" "lbProbe" {
  name                = "loadBalancerProbe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = "80"
  protocol            = "HTTP"
  request_path        = "/"
}

resource "azurerm_lb_rule" "lbRule" {
  name                           = "http"
  protocol                       = "TCP"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_port                  = "80"
  backend_port                   = "80"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lbBackPool.id]
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lbProbe.id
}


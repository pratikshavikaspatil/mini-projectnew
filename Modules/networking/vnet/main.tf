# Virtual Network
resource "azurerm_virtual_network" "prati_network" {
  for_each = {for network in var.virtual_network_details:network.virtual_network_name=>network}
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space    = [each.value.virtual_network_address_space]
  

}
resource "azurerm_subnet" "app_network_subnets" {
  for_each = {for subnet in var.subnet_details:subnet.subnet_name=>subnet}
  name                 = "${each.key}subnet"
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = [each.value.subnet_address_prefix]
}

#Network Security Group
resource "azurerm_network_security_group" "app_nsg" {
  for_each = {for subnet in var.subnet_details: subnet.subnet_name => subnet if length(lookup(subnet, "network_security_group_rules", [])) != 0}

  name                = "${each.key}_nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic security_rule {
    for_each = each.value.network_security_group_rules
    content{
    name                       = "${security_rule.value.access}-${security_rule.value.protocol}"
    priority                   = security_rule.value.priority
    direction                  = "Inbound"
    access                     = security_rule.value.access
    protocol                   = security_rule.value.protocol
    source_port_range          = security_rule.source_port_range
    destination_port_range     = security_rule.value.destination_port_range
    source_address_prefix      = security_rule.source_address_prefix
    destination_address_prefix = security_rule.destination_address_prefix
  }
}
}
  resource "azurerm_subnet_network_security_group_association" "subnet_appnsg" {
   for_each = {for subnet in var.subnet_details: subnet.subnet_name => subnet if length(lookup(subnet, "network_security_group_rules", [])) != 0}

  subnet_id                 = azurerm_subnet.app_network_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.app_nsg[each.key].id
}   
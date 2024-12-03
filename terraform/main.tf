
terraform {
  required_version = ">=1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }

  # backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "core"
  subscription_id                 = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  tenant_id = var.tenant_id
}


provider "azuread" {}

data "azurerm_subscription" "current" {}

// create resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-ape-networking"
  location = "Sweden Central"
}

// create vwan
resource "azurerm_virtual_wan" "vwan" {
  name                           = "vwan-ape-swedencentral-001"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  allow_branch_to_branch_traffic = true
  disable_vpn_encryption         = true
  type                           = "Standard"
}

// create vwan hub
resource "azurerm_virtual_hub" "hub" {
  name                = "hub-ape-swedencentral-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.227.254.0/23"
  sku                 = "Standard"
}

// create azure firewall in vwan hub
resource "azurerm_firewall" "firewall" {
  name                = "firewall-ape-swedencentral-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.hub.id

  }
  zones              = ["1", "2", "3"]
  sku_name           = "AZFW_Hub"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.policy.id
}

// create empty firewall policy
resource "azurerm_firewall_policy" "policy" {
  name                = "policy-ape-swedencentral-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  dns {
    proxy_enabled = true
    servers       = [azurerm_private_dns_resolver_inbound_endpoint.inbound.ip_configurations[0].private_ip_address]
  }
}

// create virtual network
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-ape-swedencentral-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.227.250.0/24"]
}

// create subnets dns inbound and outbound in virtual network
resource "azurerm_subnet" "dns_inbound" {
  name                 = "subnet-dns-inbound"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.227.250.0/26"]
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "dns_outbound" {
  name                 = "subnet-dns-outbound"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.227.250.64/26"]
  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

// create private dns zones and link to virtual network
resource "azurerm_private_dns_zone" "privatelink" {
  for_each            = var.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each              = var.private_dns_zones
  name                  = each.value
  private_dns_zone_name = each.value
  registration_enabled  = false
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

// create private dsn resolver
resource "azurerm_private_dns_resolver" "resolver" {
  name                = "resolver-ape-swedencentral-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_network_id  = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound" {
  name                    = "inbound-ape-swedencentral-001"
  location                = azurerm_resource_group.rg.location
  private_dns_resolver_id = azurerm_private_dns_resolver.resolver.id
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_inbound.id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "outbound" {
  name                    = "outbound-ape-swedencentral-001"
  location                = azurerm_resource_group.rg.location
  private_dns_resolver_id = azurerm_private_dns_resolver.resolver.id
  subnet_id               = azurerm_subnet.dns_outbound.id
}

// create virtual network peering to vhub
resource "azurerm_virtual_hub_connection" "hub" {
  name                      = "hub-ape-swedencentral-001"
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  internet_security_enabled = true
}

// create virtual hub routing intent
resource "azurerm_virtual_hub_routing_intent" "hub" {
  name           = "hub-ape-swedencentral-001"
  virtual_hub_id = azurerm_virtual_hub.hub.id
  routing_policy {
    name         = "Internet"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.firewall.id
  }
  routing_policy {
    name         = "PrivateTraffic"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.firewall.id
  }
}

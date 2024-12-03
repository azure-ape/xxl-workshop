using 'main.bicep'

param parVnetResourceId = '/subscriptions/c8a730a9-2944-407f-8504-f1250e228bde/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-privatedns-westeurope-001'
param parDnsResolverInboundSubnetResourceId = '/subscriptions/c8a730a9-2944-407f-8504-f1250e228bde/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-privatedns-westeurope-001/subnets/sn-dnsresolver-inbound'
param parDnsRsolverOutboundSubnetResourceId = '/subscriptions/c8a730a9-2944-407f-8504-f1250e228bde/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-privatedns-westeurope-001/subnets/sn-dnsresolver-outbound'

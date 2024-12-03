using 'main.bicep'

param parKeyVaultName = 'kv-demo01-prod-westeurope-01'
param parSubnetResourceId = '/subscriptions/8dad2223-2f35-4813-89fd-e54f87dc3934/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-demo02/subnets/sn-pe'
param parPrivateDnsZoneResourceIds = [
  '/subscriptions/c8a730a9-2944-407f-8504-f1250e228bde/resourceGroups/rg-dns-prod/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
]

param parLocation string = resourceGroup().location

module avmPublicIp 'br/public:avm/res/network/public-ip-address:0.5.1' = {
  name: 'pip-bastion-prod-westeurope-001'
  params: {
    name: 'pip-bastion-prod-westeurope-001'
    location: parLocation
    enableTelemetry: false
  }
}

resource resBastion 'Microsoft.Network/bastionHosts@2024-01-01' = {
  name: 'bastionDeployment'
  location: parLocation
  sku: {
    name: 'Developer'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          publicIPAddress: {
            id: avmPublicIp.outputs.resourceId
          }
          subnet: {
            id: '/subscriptions/3b48ca78-ffc3-4882-b52c-466b8db0e0a9/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-cloudgrip-prod-westeurope-001/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
}

metadata Name = 'Create VHub to Virtual Network Connection'
metadata Author = 'CA8 - CloudGrip'

@description('The VHub Name')
param parVirtualHubName string = 'vhub-${parLocation}-001'

@description('The location of the resources to deploy to.')
param parLocation string = resourceGroup().location

@description('The list of peered vnets.')
param parPeeredVnets peeredVnet[] = []

resource resVhub 'Microsoft.Network/virtualHubs@2023-11-01' existing = {
  name: parVirtualHubName
}

resource hubVirtualNetworkConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = [
  for vnet in parPeeredVnets: {
    name: '${resVhub.name}-${vnet.RemoteVirtualNetworkName}'
    parent: resVhub
    properties: {
      enableInternetSecurity: false
      remoteVirtualNetwork: {
        id: resourceId(
          vnet.RemoteVirtualNetworkSubscriptionId,
          vnet.RemoteVirtualNetworkResourceGroupName,
          'Microsoft.Network/virtualNetworks',
          vnet.RemoteVirtualNetworkName
        )
      }
    }
  }
]

type peeredVnet = {
  RemoteVirtualNetworkName: string
  RemoteVirtualNetworkResourceGroupName: string
  RemoteVirtualNetworkSubscriptionId: string
}

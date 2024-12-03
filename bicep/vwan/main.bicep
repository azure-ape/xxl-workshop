metadata Name = 'Create a Virtual WAN and Virtual Hub'
metadata Author = 'CA8 - CloudGrip'

@description('The VWan Name')
param parVirtualWanName string = 'vwan-${parLocation}-001'

@description('The VHub Name')
param parVirtualHubName string = 'vhub-${parLocation}-001'

@description('The location of the resources to deploy to.')
param parLocation string = resourceGroup().location

@description('The address prefix for the Virtual Hub')
param parAddressPrefix string = '10.0.252.0/22'

@description('The name of the firewall.')
param parFirewallName string = 'afw-${resourceGroup().location}-001'

@description('The name of the firewall policy.')
param parFirewallPolicyName string = 'afwp-${resourceGroup().location}-001'

module avmVirtualWan 'br/public:avm/res/network/virtual-wan:0.1.1' = {
  name: parVirtualWanName
  params: {
    name: parVirtualWanName
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    type: 'Standard'
    location: parLocation
    enableTelemetry: false
  }
}

module avmVirtualHub 'br/public:avm/res/network/virtual-hub:0.1.1' = {
  name: parVirtualHubName
  params: {
    addressPrefix: parAddressPrefix
    name: parVirtualHubName
    virtualWanId: avmVirtualWan.outputs.resourceId
    location: parLocation
    enableTelemetry: false
    allowBranchToBranchTraffic: true
  }
}

module avmFirewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.2' = {
  name: parFirewallPolicyName
  params: {
    name: parFirewallPolicyName
    location: parLocation
    enableTelemetry: false
    autoLearnPrivateRanges: 'Enabled'
    allowSqlRedirect: false
    ruleCollectionGroups: [
      {
        name: 'DefaultDnatRuleCollectionGroup'
        priority: 100
        ruleCollections: []
      }
      {
        name: 'DefaultNetworkRuleCollectionGroup'
        priority: 100
        ruleCollections: []
      }
      {
        name: 'DefaultApplicationRuleCollectionGroup'
        priority: 100
        ruleCollections: []
      }
    ]
  }
}

module avmFirewall 'br/public:avm/res/network/azure-firewall:0.2.0' = {
  name: parFirewallName
  params: {
    name: parFirewallName
    location: parLocation
    virtualHubId: avmVirtualHub.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    firewallPolicyId: avmFirewallPolicy.outputs.resourceId
    enableTelemetry: false
  }
}

resource resVhub 'Microsoft.Network/virtualHubs@2023-11-01' existing = {
  name: avmVirtualHub.name
}

resource resRoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2023-11-01' = {
  dependsOn: [avmVirtualHub]
  parent: resVhub
  name: '${avmVirtualHub.name}-routingIntent'
  properties: {
    routingPolicies: [
      {
        name: 'PublicTraffic'
        destinations: ['Internet']
        nextHop: avmFirewall.outputs.resourceId
      }
    ]
  }
}

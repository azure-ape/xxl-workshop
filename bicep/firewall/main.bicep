metadata Name = 'Create Firewall resources'
metadata Author = 'CA8 - CloudGrip'

@description('Whether to use a public IP prefix or not.')
param parUseIpPrefix bool = true

@description('The name of the public IP prefix.')
param parIpPrefixName string = 'ippre-afw-${resourceGroup().location}-001'

@description('The name of the public IP.')
param parPublicIpName string = 'pip-afw-${resourceGroup().location}-001'

@description('The name of the firewall.')
param parFirewallName string = 'afw-${resourceGroup().location}-001'

@description('The name of the firewall policy.')
param parFirewallPolicyName string = 'afwp-${resourceGroup().location}-001'

@description('The location of the resource.')
param parLocation string = resourceGroup().location

module avmPublicIpPrefix 'br/public:avm/res/network/public-ip-prefix:0.3.0' = if (parUseIpPrefix) {
  name: 'publiciprefix-deployment'
  params: {
    name: parIpPrefixName
    prefixLength: 28
    location: parLocation
    enableTelemetry: false
  }
}

module avmPublicIp 'br/public:avm/res/network/public-ip-address:0.4.0' = {
  name: 'publicip-deployment'
  params: {
    name: parPublicIpName
    publicIpPrefixResourceId: parUseIpPrefix ? avmPublicIpPrefix.outputs.resourceId : null
    location: parLocation
    enableTelemetry: false
  }
}

module avmFirewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.2' = {
  name: 'firewall-policy-deployment'
  params: {
    name: parFirewallPolicyName
    location: parLocation
    enableTelemetry: false
    autoLearnPrivateRanges: 'Enabled'
    allowSqlRedirect: false
    ruleCollectionGroups: []
  }
}

module avmFirewall 'br/public:avm/res/network/azure-firewall:0.2.0' = {
  name: 'firewall-deployment'
  params: {
    name: parFirewallName
    location: parLocation
    publicIPResourceID: avmPublicIp.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    firewallPolicyId: avmFirewallPolicy.outputs.resourceId
    enableTelemetry: false
  }
}

metadata Name = 'Create Firewall Policy'
metadata Author = 'CA8 - CloudGrip'

@description('The name of the firewall policy.')
param parFirewallPolicyName string = 'afwp-${resourceGroup().location}-001'

@description('The location of the resource.')
param parLocation string = resourceGroup().location

@description('The DNS servers to use for the firewall policy.')
param parDnsServer array = []

@description('The NAT rules to use for the firewall policy.')
param parNatRules array = []

@description('The network rules to use for the firewall policy.')
param parNetworkRules array = []

@description('The application rules to use for the firewall policy.')
param parApplicationRules array = []

module avmFirewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.2' = {
  name: 'firewall-policy-deployment'
  params: {
    name: parFirewallPolicyName
    autoLearnPrivateRanges: 'Enabled'
    allowSqlRedirect: false
    ruleCollectionGroups: [
      {
        name: 'DefaultDnatRuleCollectionGroup'
        priority: 100
        ruleCollections: [
          {
            name: 'DefaultDnatRuleCollection'
            priority: 100
            action: {
              type: 'Dnat'
            }
            ruleCollectionType: 'FirewallPolicyNatRuleCollection'
            rules: parNatRules
          }
        ]
      }
      {
        name: 'DefaultNetworkRuleCollectionGroup'
        priority: 100
        ruleCollections: [
          {
            name: 'DefaultFirewallRuleCollection'
            priority: 100
            action: {
              type: 'Allow'
            }
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            rules: parNetworkRules
          }
        ]
      }
      {
        name: 'DefaultApplicationRuleCollectionGroup'
        priority: 100
        ruleCollections: [
          {
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            name: 'AllowAllHttpHttps'
            priority: 100
            action: {
              type: 'Allow'
            }
            rules: parApplicationRules
          }
        ]
      }
    ]
    enableProxy: true
    servers: parDnsServer
    location: parLocation
    enableTelemetry: false
  }
}

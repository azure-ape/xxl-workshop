using 'main.bicep'

param parDnsServer = [
  '10.31.250.4'
]

param parNatRules = [
  {
    name: 'rdp-vm-demo01'
    ruleType: 'NatRule'
    ipProtocols: ['TCP']
    destinationAddresses: ['20.4.31.10']
    destinationPorts: ['3389']
    sourceAddresses: ['*']
    translatedAddress: '10.31.10.4'
    translatedPort: '3389'
  }
  {
    name: 'rdp-vm-demo02'
    ruleType: 'NatRule'
    ipProtocols: ['TCP']
    destinationAddresses: ['20.4.31.10']
    destinationPorts: ['3390']
    sourceAddresses: ['*']
    translatedAddress: '10.31.14.4'
    translatedPort: '3389'
  }
]

param parNetworkRules = [
  {
    name: 'AllowDns'
    ruleType: 'NetworkRule'
    ipProtocols: ['Any']
    sourceAddresses: ['*']
    destinationAddresses: ['*']
    destinationPorts: ['53']
  }
  {
    name: 'AllowNTP'
    ruleType: 'NetworkRule'
    ipProtocols: ['UDP']
    sourceAddresses: ['*']
    destinationAddresses: ['time.windows.com']
    destinationPorts: ['123']
  }
  {
    name: 'AllowFtp'
    ruleType: 'NetworkRule'
    ipProtocols: ['TCP']
    sourceAddresses: ['*']
    destinationAddresses: ['*']
    destinationPorts: ['21']
  }
]

param parApplicationRules = [
  {
    ruleType: 'ApplicationRule'
    name: 'AllowAllHttpHttps'
    sourceAddresses: ['*']
    protocols: [
      {
        port: 80
        protocolType: 'Http'
      }
      {
        port: 443
        protocolType: 'Https'
      }
    ]
    targetFqdns: ['*']
  }
]

metadata Name = 'Create a KeyVault'
metadata Author = 'CA8 - CloudGrip'

@description('Key Vault Name')
param parKeyVaultName string = 'kv-prod-${resourceGroup().location}-001'

@description('Subnet Resource Id')
param parSubnetResourceId string = ''

@description('Private DNS Zone Resource Ids')
param parPrivateDnsZoneResourceIds array = []

@description('Key Vault Location')
param parLocation string = resourceGroup().location

module avmKeyVault 'br/public:avm/res/key-vault/vault:0.5.1' = {
  name: 'keyvault-deployment'
  params: {
    name: parKeyVaultName
    enableRbacAuthorization: true
    enablePurgeProtection: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    publicNetworkAccess: !empty(parSubnetResourceId) ? 'Disabled' : 'Enabled'
    privateEndpoints: !empty(parSubnetResourceId)
      ? [
          {
            subnetResourceId: parSubnetResourceId
            service: 'vault'
            privateDnsZoneResourceIds: parPrivateDnsZoneResourceIds
          }
        ]
      : null
    location: parLocation
    enableTelemetry: false
  }
}

// https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/storage/storage-account
param storageAccountName string

module sa 'br/public:avm/res/storage/storage-account:0.8.2' = {
  name: 'StorageAccountDeployment'
  params: {
    name: storageAccountName
    allowBlobPublicAccess: false
    enableTelemetry: false
  }
}

output storageAccountName string = sa.outputs.resourceId

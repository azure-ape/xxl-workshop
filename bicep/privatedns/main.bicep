metadata Name = 'Create Private DNS Zones'
metadata Author = 'CA8 - CloudGrip'

@description('Auto merge Azure Backup DNS Zone')
param parPrivateDnsZoneAutoMergeAzureBackupZone bool = true

@description('Private DNS Zones to create')
param parPrivateDnsZones array = [
  'privatelink.${toLower(parLocation)}.azmk8s.io'
  'privatelink.${toLower(parLocation)}.batch.azure.com'
  'privatelink.${toLower(parLocation)}.kusto.windows.net'
  'privatelink.adf.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.analysis.windows.net'
  'privatelink.api.azureml.ms'
  'privatelink.azconfig.io'
  'privatelink.azure-api.net'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azure-devices.net'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.azuredatabricks.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.azurestaticapps.net'
  'privatelink.azuresynapse.net'
  'privatelink.azurewebsites.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.directline.botframework.com'
  'privatelink.documents.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.file.core.windows.net'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.kubernetesconfiguration.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.mariadb.database.azure.com'
  'privatelink.media.azure.net'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.notebooks.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.postgres.database.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.servicebus.windows.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.token.botframework.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.webpubsub.azure.com'
]

@description('Resource ID of the VNet to link the Private DNS Zones to')
param parVnetResourceId string

@description('Deploy DNS Resolver')
param parDeployDnsResolver bool = true

param parDnsResolverName string = 'dnspr-${resourceGroup().location}-001'

@description('Resource ID of the DNS Resolver Inbound Subnet')
param parDnsResolverInboundSubnetResourceId string = ''

@description('Resource ID of the DNS Resolver Outbound Subnet')
param parDnsRsolverOutboundSubnetResourceId string = ''

@description('Location of the DNS Zone deployments')
param parLocation string = resourceGroup().location

@description('Azure Backup Geo Codes')
var varAzBackupGeoCodes = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  brazilsoutheast: 'bse'
  centraluseuap: 'ccy'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralus: 'cus'
  eastasia: 'ea'
  eastus2euap: 'ecy'
  eastus: 'eus'
  eastus2: 'eus2'
  francecentral: 'frc'
  francesouth: 'frs'
  germanycentral: 'gec'
  germanynorth: 'gn'
  germanynortheast: 'gne'
  germanywestcentral: 'gwc'
  israelcentral: 'ilc'
  italynorth: 'itn'
  centralindia: 'inc'
  southindia: 'ins'
  westindia: 'inw'
  japaneast: 'jpe'
  japanwest: 'jpw'
  jioindiacentral: 'jic'
  jioindiawest: 'jiw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  polandcentral: 'plc'
  qatarcentral: 'qac'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  southeastasia: 'sea'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  usnateast: 'exe'
  usnatwest: 'exw'
  usseceast: 'rxe'
  ussecwest: 'rxw'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinanorth3: 'bjb3'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  chinaeast3: 'sha3'
}

@description('Private DNS Zones to create after filtering.')
var varPrivateDnsZonesMerge = parPrivateDnsZoneAutoMergeAzureBackupZone && contains(varAzBackupGeoCodes, parLocation)
  ? union(parPrivateDnsZones, ['privatelink.${varAzBackupGeoCodes[toLower(parLocation)]}.backup.windowsazure.com'])
  : parPrivateDnsZones

module avmPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.5' = [
  for privateDnsZoneName in varPrivateDnsZonesMerge: {
    name: 'deployment-${privateDnsZoneName}'
    params: {
      name: privateDnsZoneName
      location: 'global'
      enableTelemetry: false
      virtualNetworkLinks: [
        {
          registrationEnabled: false
          virtualNetworkResourceId: parVnetResourceId
        }
      ]
    }
  }
]

module avmPrivateDnsResolver 'br/public:avm/res/network/dns-resolver:0.3.0' = if (parDeployDnsResolver) {
  name: 'deployment-dns-resolver'
  params: {
    name: parDnsResolverName
    virtualNetworkResourceId: parVnetResourceId
    inboundEndpoints: [
      {
        name: 'inbound'
        subnetResourceId: parDnsResolverInboundSubnetResourceId
      }
    ]
    outboundEndpoints: [
      {
        name: 'outbound'
        subnetResourceId: parDnsRsolverOutboundSubnetResourceId
      }
    ]
    location: parLocation
    enableTelemetry: false
  }
}

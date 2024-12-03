metadata Name = 'Create Automation Account'
metadata Author = 'CA8 - CloudGrip'

@description('Automation Account Name')
param parAutomationAccountName string = toLower('aa-management-prod-${parLocation}-01')

param parLocation string = resourceGroup().location

module avmAutomationAccount 'br/public:avm/res/automation/automation-account:0.4.1' = {
  name: 'automationccount-deployment'
  params: {
    name: parAutomationAccountName
    skuName: 'Basic'
    disableLocalAuth: true
    gallerySolutions: [
      {
        name: 'Updates'
      }
    ]
    modules: [
      {
        name: 'PSWindowsUpdate'
        uri: 'https://www.powershellgallery.com/api/v2/package'
        version: 'latest'
      }
    ]
    managedIdentities: {
      systemAssigned: true
    }
    location: parLocation
    enableTelemetry: false
  }
}

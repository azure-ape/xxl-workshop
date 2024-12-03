metadata Name = 'Create Log Analytics Workspace'
metadata Author = 'CA8 - CloudGrip'

@description('Name of the Log Analytics Workspace')
param parWorkspaceName string = toLower('log-management-prod-${(resourceGroup().location)}-01')

@description('Name of the Automation Account')
param parAutomationAccountName string = toLower('aa-management-prod-${(resourceGroup().location)}-01')

@description('Location of the resource deployment')
param parLocation string = resourceGroup().location

resource resAutomationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: parAutomationAccountName
}

module avmWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.4' = {
  name: 'workspace-deployment'
  params: {
    name: parWorkspaceName
    skuName: 'PerGB2018'
    dataRetention: 90
    gallerySolutions: [
      {
        name: 'AgentHealthAssessment'
      }
      {
        name: 'AntiMalware'
      }
      {
        name: 'ChangeTracking'
      }
      {
        name: 'Security'
      }
      {
        name: 'SecurityInsights'
      }
      {
        name: 'SQLAdvancedThreatProtection'
      }
      {
        name: 'SQLVulnerabilityAssessment'
      }
      {
        name: 'SQLAssessment'
      }
      {
        name: 'Updates'
      }
      {
        name: 'VMInsights'
      }
    ]
    linkedServices: [
      {
        name: 'Automation'
        resourceId: resAutomationAccount.id
      }
    ]
    useResourcePermissions: true
    location: parLocation
    enableTelemetry: false
  }
}

output outWorkspaceId string = avmWorkspace.outputs.resourceId

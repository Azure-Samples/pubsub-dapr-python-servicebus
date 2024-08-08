param name string
param location string = resourceGroup().location
param tags object = {}
param daprEnabled bool = false
param logAnalyticsWorkspaceName string
param applicationInsightsName string = ''
param vnetInternal bool = true

@description('Name of the Vnet')
param vnetName string


resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIInstrumentationKey: daprEnabled && !empty(applicationInsightsName) ? applicationInsights.properties.InstrumentationKey : ''
    vnetConfiguration: {
      infrastructureSubnetId: vnet.properties.subnets[0].id
      internal: vnetInternal
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (daprEnabled && !empty(applicationInsightsName)){
  name: applicationInsightsName
}

output defaultDomain string = containerAppsEnvironment.properties.defaultDomain
output name string = containerAppsEnvironment.name

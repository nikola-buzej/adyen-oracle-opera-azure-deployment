targetScope = 'resourceGroup'

//Params
@description('The location of the resources')
param location string = resourceGroup().location

@description('Optional tags to be assigned')
param tags object = {}

@description('The name of the log analytics workspace. If set, it overrides the name generated by the template.')
param logAnalyticsWorkspaceName string 

@description('The name of the container apps environment')
param containerAppsEvnironmentName string

@description('The name of the Application Insights')
param applicationInsightName string

//Resources

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties:any({
    features: {
      searchVersion: 1 
    }
    sku: {
      name: 'PerGB2018'
    }
    retentionDays: 30
  })
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightName
  location:location
  tags:tags
  kind: 'web'
  properties:{
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name:containerAppsEvnironmentName
  location:location
  tags:tags
  properties:{
    appLogsConfiguration:{
      destination:'log-analytics'
      logAnalyticsConfiguration:{
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
  
}

//Outputs
@description('The name of the application insights')
output applicationInsightName string = applicationInsights.name


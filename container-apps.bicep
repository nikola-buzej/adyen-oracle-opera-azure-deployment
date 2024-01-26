targetScope = 'resourceGroup'
@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the container apps environment.')
param containerAppsEnvironmentName string
@description('the db')
param dbName string 
// Services

@description('The image for the backend api service.')
param backendApiServiceImage string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppsEnvironmentName
}

module backendApiService 'backend-api-service.bicep' = {
  name:'backend-api-service-test'
  params: {
    location: location
    backendApiServiceImage: backendApiServiceImage
    containerAppsEnvironmentId: containerAppsEnvironment.id
    tags:tags
    dbName: dbName
  }
}

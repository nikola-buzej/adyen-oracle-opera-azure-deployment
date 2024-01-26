targetScope = 'resourceGroup'

//parameters
@description('The location where the resources will be created.')
param location string = resourceGroup().location

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The resource Id of the container apps environment.')
param containerAppsEnvironmentId string

@description('The image for the backend api service.')
param backendApiServiceImage string


@description('The db name.')
param dbName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: 'database-vnet'
}

resource backendApiAppService 'Microsoft.App/containerApps@2023-05-01' = {
  location: location
  tags: tags
  name: 'backend-api-service'
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
      }
    secrets: [
      {name: 'connection-string', value: dbName}
    ]
    }
    template: {
      containers:[
        {
          name: 'backend-service-api'
          image: backendApiServiceImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'Logging__LogLevel__Default'
              value: 'Information'
            }
            {
                name: 'Logging__LogLevel__Microsoft.AspNetCore'
                value: 'Warning'
            }
            {
                name: 'ConnectionStrings__Database'
                value: dbName
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas:1 
      }
    }
  }
}

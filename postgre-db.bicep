targetScope = 'resourceGroup'

//Parameters
@secure()
param administratorLoginPassword string
param location string
param serverName string

// resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
//   name: 'database-vnet'
//   location: location
//   properties: {
//       addressSpace: {
//       addressPrefixes: [
//           '10.0.0.0/16'
//       ]
//       }
//   }
//   resource databaseSubnet 'subnets' = {
//     name: 'database-subnet'
//     properties: {
//         addressPrefix: '10.0.0.0/24'
//         delegations: [
//         {
//             name: '$database-subnet-delegation'
//             properties: {
//             serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
//             }
//         }]
//     }
//   }
//   resource webappSubnet 'subnets' = {
//     name: 'webapp-subnet'
//     properties: {
//         addressPrefix: '10.0.1.0/24'
//         delegations: [
//         {
//             name: 'database-subnet-delegation-web'
//             properties: {
//             serviceName: 'Microsoft.App/containerApps'
//             }
//         }]
//     }
// }
// }
// resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: 'test.private.postgres.database.azure.com'
//   location: 'global'
//   resource vNetLink 'virtualNetworkLinks' = {
//       name: 'test-link'
//       location: 'global'
//       properties: {
//           registrationEnabled: false
//           virtualNetwork: { id: virtualNetwork.id }
//       }
//   }
// }

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: location
  sku: {
      name: 'Standard_B1ms'
      tier: 'Burstable'
  }
  resource allowedIps 'firewallRules@2022-12-01' = {
    name: 'AllowAllWindowsAzureIps'
    properties:{
      endIpAddress: '255.255.255.255'
      startIpAddress: '0.0.0.0'
    }
  }
  resource database 'databases' = {
    name: 'test'
  }
  properties: {
      administratorLogin: 'adyen'
      administratorLoginPassword: administratorLoginPassword
      createMode: 'Create'
      
      // network: {
      //   delegatedSubnetResourceId: virtualNetwork::databaseSubnet.id
      //   privateDnsZoneArmResourceId: privateDnsZone.id
      // }
      version: '14'
      storage: {
      storageSizeGB: 32
      }
  }
}

// resource serverName_resource 'Microsoft.DBforPostgreSQL/serverGroupsv2@2022-11-08' = {
//   name: clusterName
//   location: location
//   tags: {}
//   properties: {
//           administratorLoginPassword: administratorLoginPassword
//           coordinatorServerEdition: coordinatorServerEdition
//           coordinatorVCores: coordinatorVCores
//           coordinatorStorageQuotaInMb: coordinatorStorageQuotaInMb
//           enableShardsOnCoordinator: enableShardsOnCoordinator
//           nodeCount: nodeCount
//           nodeServerEdition: nodeServerEdition
//           nodeVCores: nodeVCores
//           nodeStorageQuotaInMb: nodeStorageQuotaInMb
//           enableHa: enableHa
//           coordinatorEnablePublicIpAccess: coordinatorEnablePublicIpAccess
//           nodeEnablePublicIpAccess: nodeEnablePublicIpAccess
//           citusVersion: citusVersion
//           postgresqlVersion: postgresqlVersion
//           preferredPrimaryZone: availabilityZone
//           }
//           resource db_server 'servers' existing = {
//             name: server.name
//           }
//         }

@description('Id of the postgres database server')
output dbServerId string = 'Host=${server.properties.fullyQualifiedDomainName};Database=test;Username=adyen;Password=${administratorLoginPassword}'

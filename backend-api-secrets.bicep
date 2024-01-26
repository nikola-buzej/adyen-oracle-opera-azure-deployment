targetScope = 'resourceGroup'

//Parameters

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the Key Vault.')
param KEYVAULT_NAME string = 'KeyVault'

@description('The principal ID of the Backend Api Service.')
param backendServicePrincipalId string

//Resources 
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: KEYVAULT_NAME
}

var keyVaultSecretUserRoleGuid = 'c4a4cd9a-6873-4979-ac55-9a44cb003d18'

resource defaultLogLevelSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'defaultLogLevelSecret'
  tags:tags
  properties:{
    value: 'Information'
  }
}
resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, keyVault.id, backendServicePrincipalId, keyVaultSecretUserRoleGuid) 
  scope: keyVault
  properties: {
    principalId: backendServicePrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretUserRoleGuid)
    principalType: 'ServicePrincipal'
  }
}

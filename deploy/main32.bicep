// RESOURCES

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

// VARIABLES

var storageAccountName = 'rvvstor${resourceNameSuffix}'

var appServicePlanName = 'rvv-website-plan-${resourceNameSuffix}'

var appServiceAppName = 'rvv-website-${resourceNameSuffix}'

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

var environmentConfigurationMap = {
  nonprod: {
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
      kind: 'StorageV2'
    }
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    appServiceApp: {
      alwaysOn: false
    }
  }
  prod: {
    storageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    appServiceApp: {
      alwaysOn: true
    }
  }
}

// RESOURCES

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
  properties: {}
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: environmentConfigurationMap[environmentType].appServiceApp.alwaysOn
      appSettings: [
        {
          name: 'storageAccountConnectionString'
          value: storageAccountConnectionString
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
  kind: environmentConfigurationMap[environmentType].storageAccount.kind
}

// OUTPUTS


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'rvvappsvc001'
  location: 'westeurope'
  sku: {
    name: 'F1'
  }
  properties: {}
}

@allowed([
  'DEV'
  'PROD'
])
param environment string = 'DEV'
param webAppName string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${webAppName}-${environment}-AppPlan'
  location: resourceGroup().location
  sku: {
    name: environment == 'DEV' ? 'F1' : 'S1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: take('${webAppName}-${environment}-${uniqueString(resourceGroup().id)}', 20)
  location: resourceGroup().location
    properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'ThisIsAnAppSetting'
          value: 'demo'
        }
      ]
    }
  }
}

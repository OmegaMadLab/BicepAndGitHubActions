@allowed([
  'DEV'
  'PROD'
])
param environment string = 'DEV'
param webAppName string

module appPlan 'br:acr55899.azurecr.io/bicep/modules/appserviceplan:v1' = {
  name: appPlan
  param: {
    environment: environment
    appPlanName: webAppName
  } 
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: take('${webAppName}-${environment}-${uniqueString(resourceGroup().id)}', 20)
  location: resourceGroup().location
    properties: {
    serverFarmId: appPlan.outputs.serverFarmId
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

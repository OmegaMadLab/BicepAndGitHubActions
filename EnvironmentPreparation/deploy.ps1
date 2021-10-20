# Create RGs for DEV and PROD env
$devRg = New-AzResourceGroup -Name 'BicepAndGitHub-DEV-RG' -location 'westeurope'
$prodRg = New-AzResourceGroup -Name 'BicepAndGitHub-PROD-RG' -location 'westeurope'

# Create a service principal and grant it access on the DEV rg
$azureContext = Get-AzContext
$servicePrincipal = New-AzADServicePrincipal `
    -DisplayName "BicepAndGitHub-DEV" `
    -Role "Contributor" `
    -Scope $devRg.ResourceId

$output = @{
   clientId = $($servicePrincipal.ApplicationId)
   clientSecret = $([System.Net.NetworkCredential]::new('', $servicePrincipal.Secret).Password)
   subscriptionId = $($azureContext.Subscription.Id)
   tenantId = $($azureContext.Tenant.Id)
}

$output | ConvertTo-Json
$output | ConvertTo-Json | Set-Clipboard
# Paste the content of the clipboard in a new GitHub secret called AzCred_DEV

# Create a service principal and grant it access on the PROD rg
$servicePrincipal = New-AzADServicePrincipal `
    -DisplayName "BicepAndGitHub-PROD" `
    -Role "Contributor" `
    -Scope $prodRg.ResourceId

$output = @{
   clientId = $($servicePrincipal.ApplicationId)
   clientSecret = $([System.Net.NetworkCredential]::new('', $servicePrincipal.Secret).Password)
   subscriptionId = $($azureContext.Subscription.Id)
   tenantId = $($azureContext.Tenant.Id)
}

$output | ConvertTo-Json
$output | ConvertTo-Json | Set-Clipboard
# Paste the content of the clipboard in a new GitHub secret called AzCreds_DEV

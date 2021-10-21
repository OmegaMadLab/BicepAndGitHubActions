# Create RGs for DEV and PROD env
$devRg = New-AzResourceGroup -Name 'BicepAndGitHub-DEV-RG' -location 'westeurope'
$prodRg = New-AzResourceGroup -Name 'BicepAndGitHub-PROD-RG' -location 'westeurope'

# Create a role for validating ARM deployment
$role = Get-AzRoleDefinition | select -First 1

$role.Id = $null
$role.Name = "Deployment validator"
$role.Description = "Can validate an ARM deployment."
$role.Actions.RemoveRange(0,$role.Actions.Count)
$role.Actions.Add("Microsoft.Resources/deployments/validate/action")
$role.NotActions.RemoveRange(0,$role.NotActions.Count)
$role.AssignableScopes.Add("/subscriptions/$((Get-AzContext).Subscription.Id)")

New-AzRoleDefinition -Role $role

# Create a service principal and grant it contributor access on the DEV rg
$azureContext = Get-AzContext
$servicePrincipal = New-AzADServicePrincipal `
    -DisplayName "BicepAndGitHub-DEV" `
    -Role "Contributor" `
    -Scope $devRg.ResourceId

# Assign also the Deployment validator role on PROD RG
New-AzRoleAssignment -ApplicationId $servicePrincipal.ApplicationId `
    -ResourceGroupName $prodRg.ResourceGroupName `
    -RoleDefinitionName "Deployment validator"

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

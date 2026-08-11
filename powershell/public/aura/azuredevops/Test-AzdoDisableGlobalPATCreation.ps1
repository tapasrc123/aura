<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks if global Personal Access Token creation is restricted.

    Requires Azure DevOps organization backed by a Microsoft Entra tenant and
    Azure DevOps Administrator permissions.

    https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#restrict-creation-of-global-pats-tenant-policy


.EXAMPLE
    ```
    Test-AzdoDisableGlobalPATCreation
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoDisableGlobalPATCreation
#>

function Test-AzdoDisableGlobalPATCreation {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoDisableGlobalPATCreation"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $Policy = Get-ADOPSTenantPolicy -PolicyCategory RestrictGlobalPersonalAccessToken -Force

    if ($null -eq $Policy) {
        $Message = "Tenant Policy for RestrictGlobalPersonalAccessToken not found. This may be due to insufficient permissions or the Azure DevOps Organization is not backed by an Entra ID tenant.
        Please see [Manage Tenant Policies](https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#prerequisites)"
        Write-Verbose $Message
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason $Message
    }
    else {
        $result = [bool]$Policy.value
        if ($result) {
            $resultMarkdown = "Your tenant has Global Personal Access Token creation disabled."
        }
        else {
            $resultMarkdown = "Your tenant does not have Global Personal Access Token creation disabled."
        }

        Add-AuTestResultDetail -Result $resultMarkdown
        return $result
    }

}

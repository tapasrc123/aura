<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks if Personal Access Token full scope restrictions are configured.

    https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#restrict-full-scope-personal-access-tokens


.EXAMPLE
    ```
    Test-AzdoRestrictFullScopePersonalAccessToken
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoRestrictFullScopePersonalAccessToken
#>

function Test-AzdoRestrictFullScopePersonalAccessToken {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoRestrictFullScopePersonalAccessToken"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $Policy = Get-ADOPSTenantPolicy -PolicyCategory RestrictFullScopePersonalAccessToken -Force
    if ($null -eq $Policy) {
        $Message = "Tenant Policy for RestrictFullScopePersonalAccessToken not found. This may be due to insufficient permissions or the Azure DevOps Organization is not backed by an Entra ID tenant.
        Please see [Manage Tenant Policies](https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#prerequisites)"
        Write-Verbose $Message
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason $Message
    }
    else {
        $result = [bool]$Policy.value
        if ($result) {
            $resultMarkdown = "Your tenant has Personal Access Token full scope restrictions enabled."
        }
        else {
            $resultMarkdown = "Your tenant does not have Personal Access Token full scope restrictions enabled."
        }

        Add-AuTestResultDetail -Result $resultMarkdown

        return $result
    }
}

<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks if leaked Personal Access Token auto-revocation is enabled.

    Requires Azure DevOps organization backed by a Microsoft Entra tenant and
    Azure DevOps Administrator permissions.

    https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#automatic-revocation-of-leaked-tokens


.EXAMPLE
    ```
    Test-AzdoEnableLeakedPersonalAccessTokenAutoRevocation
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoEnableLeakedPersonalAccessTokenAutoRevocation
#>

function Test-AzdoEnableLeakedPersonalAccessTokenAutoRevocation {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoEnableLeakedPersonalAccessTokenAutoRevocation"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $Policy = Get-ADOPSTenantPolicy -PolicyCategory EnableLeakedPersonalAccessTokenAutoRevocation -Force

    if ($null -eq $Policy) {
        $Message = "Tenant Policy for EnableLeakedPersonalAccessTokenAutoRevocation not found. This may be due to insufficient permissions or the Azure DevOps Organization is not backed by an Entra ID tenant.
        Please see [Manage Tenant Policies](https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators?view=azure-devops#prerequisites)"
        Write-Verbose $Message
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason $Message
    }
    else {
        $result = [bool]$Policy.value
        if ($result) {
            $resultMarkdown = "Your tenant has leaked Personal Access Token auto-revocation enabled."
        }
        else {
            $resultMarkdown = "Your tenant does not have leaked Personal Access Token auto-revocation enabled."
        }

        Add-AuTestResultDetail -Result $resultMarkdown

        return $result
    }
}

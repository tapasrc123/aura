<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the configuration of external guest access to Azure DevOps.

    https://learn.microsoft.com/azure/devops/organizations/security/security-overview?view=azure-devops#manage-external-guest-access

.EXAMPLE
    ```
    Test-AzdoExternalGuestAccess
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoExternalGuestAccess
#>
function Test-AzdoExternalGuestAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoExternalGuestAccess"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $PrivacyPolicies = Get-ADOPSOrganizationPolicy -PolicyCategory 'User' -Force
    $Policy = $PrivacyPolicies.policy | where-object -property name -eq 'Policy.DisallowAadGuestUserAccess'
    $result = $Policy.value
    if ($result) {
        $resultMarkdown = "Your tenant has restricted external guest access to your Azure DevOps organization."
    } else {
        $resultMarkdown = "External user(s) can be added to the organization to which they were invited and have immediate access. A guest user can add other guest users to the organization after being granted the Guest Inviter role in Microsoft Entra ID."
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

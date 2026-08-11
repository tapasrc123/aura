function Test-AuCaSecureSecurityInfoRegistration {
    <#
    .Synopsis
    Checks if the tenant has at least one Conditional Access policy securing security info registration.

    .Description
    Security info registration Conditional Access policy can secure the registration of security info for users in the tenant.

    Learn more:
    https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-registration

    .Example
    Test-AuCaSecureSecurityInfoRegistration

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCaSecureSecurityInfoRegistration
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    if ( ( Get-AuLicenseInformation EntraID ) -eq "Free" ) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    try {
        $policies = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }
        # Remove policies that require password change, as they are related to user risk and not MFA on signin
        $policies = $policies | Where-Object { $_.grantControls.builtInControls -notcontains 'passwordChange' }
        $policiesResult = New-Object System.Collections.ArrayList

        $result = $false
        foreach ($policy in $policies) {
            if (
                $policy.conditions.users.includeUsers -eq "All" -and
                $policy.conditions.clientAppTypes -eq "all" -and
                $policy.conditions.applications.includeUserActions -eq "urn:user:registersecurityinfo" -and
                $policy.conditions.locations.includeLocations -eq "All" -and
                $null -ne $policy.conditions.locations.excludeLocations
            ) {
                $result = $true
                $CurrentResult = $true
                $policiesResult.Add($policy) | Out-Null
            } else {
                $CurrentResult = $false
            }
            Write-Verbose "$($policy.displayName) - $CurrentResult"
        }

        if ( $result ) {
            $testResult = "The following Conditional Access policies secure security info registration.`n`n%TestResult%"
        } else {
            $testResult = "No Conditional Access policy securing security info registration."
        }
        Add-AuTestResultDetail -Result $testResult -GraphObjects $policiesResult -GraphObjectType ConditionalAccess

        return $result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $false
    }
}

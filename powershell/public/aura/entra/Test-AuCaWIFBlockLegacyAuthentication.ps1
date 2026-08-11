function Test-AuCaWIFBlockLegacyAuthentication {
    <#
    .SYNOPSIS
    Checks if the user is blocked from using legacy authentication

    .DESCRIPTION
    Checks if the user is blocked from using legacy authentication using the Conditional Access WhatIf Graph API endpoint.

    .PARAMETER UserId
    The UserId to test the Conditional Access policies with

    .EXAMPLE
    Test-AuCaWIFBlockLegacyAuthentication -UserId "e7417ac7-0485-4014-9100-33163bd6211f"

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCaWIFBlockLegacyAuthentication
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # The UserId to test the Conditional Access policies with
        [Parameter(Mandatory)]
        [string]$UserId
    )

    if ( ( Get-AuLicenseInformation EntraID ) -eq "Free" ) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    try {
        $policiesResult = Test-AuConditionalAccessWhatIf -UserId $UserId -IncludeApplications "00000002-0000-0ff1-ce00-000000000000" -ClientAppType exchangeActiveSync
        if ( $null -ne $policiesResult ) {
            $testResult = "Well done. The following Conditional Access policies are currently blocking legacy authentication.`n`n%TestResult%"
            $Result = $true
        } else {
            $testResult = "No Conditional Access policy found that blocks legacy authentication."
            $Result = $false
        }

        Add-AuTestResultDetail -Result $testResult -GraphObjects $policiesResult -GraphObjectType ConditionalAccess
        Write-Verbose "Checking if the user $UserId is blocked from using legacy authentication"
        return $Result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        Write-Verbose "An error occurred while checking if the user $UserId is blocked from using legacy authentication"
        return $false
    }
}

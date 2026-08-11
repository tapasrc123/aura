function Test-AuExoDelicensingResiliency {
    <#
    .SYNOPSIS
    Checks if Delicensing Resiliency is enabled in Exchange Online

    .DESCRIPTION
    Delicensing Resiliency should be enabled to maintain access to mailboxes
    when licenses are removed, providing a grace period before access is lost.
    This helps prevent immediate disruption when licenses expire or are reassigned.

    .EXAMPLE
    Test-AuExoDelicensingResiliency

    Returns true if Delicensing Resiliency is enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuExoDelicensingResiliency
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    Write-Verbose "Checking license requirements..."
    try {
        $licenseCount = Get-AuLicenseInformation -Product ExoLicenseCount
        $meetsLicenseRequirement = $licenseCount -gt 5000
        Write-Verbose "License count: $licenseCount, Meets requirement: $meetsLicenseRequirement"
    } catch {
        Write-Verbose "Unable to check license requirements: $_"
        # If we can't check licenses, still proceed with the main test but note the limitation
        $licenseCount = $null
        $meetsLicenseRequirement = $null
    }

    # If license requirements are not met, return early with informative message
    if ($meetsLicenseRequirement -ne $true) {
        Add-AuTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Not enough non-trial licenses. See [Delicensing Resiliency](https://learn.microsoft.com/Exchange/recipients-in-exchange-online/manage-user-mailboxes/exchange-online-delicensing-resiliency)"
        return $null
    }

    try {
        # License requirements are met or couldn't be determined, proceed with the actual delicensing check
        Write-Verbose "Proceeding with Delicensing Resiliency status check..."
        Write-Verbose "Getting Organization Configuration..."
        $organizationConfig = Get-AuExo -Request OrganizationConfig

        $delicensingState = $organizationConfig.DelayedDelicensingEnabledState
        $result = $delicensingState -match "Enabled: True"

        if ($result) {
            $testResultMarkdown = "Well done. Delicensing Resiliency is enabled.`n`n"
        } else {
            $testResultMarkdown = "'DelayedDelicensingEnabled' in OrganizationConfig should be ``True`` and is ``False```n`n"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    return $result
}

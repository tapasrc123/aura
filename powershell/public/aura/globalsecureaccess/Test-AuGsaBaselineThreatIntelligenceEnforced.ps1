function Test-AuGsaBaselineThreatIntelligenceEnforced {
    <#
    .SYNOPSIS
        Checks that the baseline Global Secure Access security profile enforces a threat-intelligence floor.

    .DESCRIPTION
        The baseline security profile (priority 65000) applies to all Internet Access traffic with no
        Conditional Access required. Linking an enabled threat-intelligence policy to the baseline
        provides an always-on malware and phishing floor that also covers non-client / remote-network
        traffic, the Conditional Access token-propagation gap, and users not matched by any user-aware
        profile. Microsoft recommends linking the threat-intelligence policy to the baseline.

    .EXAMPLE
        Test-AuGsaBaselineThreatIntelligenceEnforced

        Returns $true if the baseline security profile has an enabled threat-intelligence policy linked.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuGsaBaselineThreatIntelligenceEnforced
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    Write-Verbose "Running Test-AuGsaBaselineThreatIntelligenceEnforced..."

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    if ((Get-AuLicenseInformation -Product EntraID) -eq 'Free') {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    try {
        $forwardingProfiles = Invoke-AuGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion beta
        $internetProfile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'internet' }
        if (-not ($internetProfile -and $internetProfile.state -eq 'enabled')) {
            Add-AuTestResultDetail -Result 'The Internet Access traffic forwarding profile is not enabled, so there is no internet traffic to protect.'
            return $null
        }

        $filteringProfiles = Invoke-AuGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -ApiVersion beta -QueryParameters @{ '$expand' = 'policies' }
        $baseline = $filteringProfiles | Where-Object { $_.priority -eq 65000 } | Select-Object -First 1
        if (-not $baseline) {
            Add-AuTestResultDetail -Result 'The baseline security profile (priority 65000) was not found. Verify that Internet Access is onboarded.'
            return $null
        }

        $hasThreatIntelligence = [bool](
            @($baseline.policies) | Where-Object {
                $_.'@odata.type' -match 'threatIntelligencePolicyLink' -and $_.state -ne 'disabled'
            }
        )

        if ($hasThreatIntelligence) {
            $testResult = "Well done. The baseline security profile enforces a threat-intelligence (malware/phishing) floor for all Internet Access traffic.`n`n"
        } else {
            $testResult = "The baseline security profile has **no enabled threat-intelligence policy** linked. Non-client / remote-network traffic, the Conditional Access token-propagation gap, and unmatched users have no malware/phishing floor. Link a threat-intelligence policy to the baseline profile.`n`n"
        }

        Add-AuTestResultDetail -Result $testResult
        return $hasThreatIntelligence
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

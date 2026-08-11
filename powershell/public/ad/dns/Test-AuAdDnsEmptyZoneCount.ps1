function Test-AuAdDnsEmptyZoneCount {
    <#
    .SYNOPSIS
    Counts DNS zones that contain zero records.

    .DESCRIPTION
    This test identifies DNS zones that have no resource records configured.
    Empty zones may indicate incomplete configuration, abandoned zones, or
    zones created for future use. Monitoring empty zones helps maintain
    DNS infrastructure hygiene.

    .EXAMPLE
    Test-AuAdDnsEmptyZoneCount

    Returns $true if DNS zone data is accessible, $false otherwise.
    The test result includes the count of empty zones.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDnsEmptyZoneCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDnsEmptyZoneCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $dnsZones = $adState.DNSZones
    $dnsRecords = $adState.DNSRecords

    # If DNS data is not available, skip the test
    if ($null -eq $dnsZones -or $dnsZones.Count -eq 0) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory -SkippedBecauseReason "DNS data is not available. Ensure the DnsServer module is installed and you have appropriate permissions."
        return $null
    }

    # Find empty zones (zones with no records)
    $emptyZones = @()
    foreach ($zone in $dnsZones) {
        $zoneRecords = $dnsRecords | Where-Object { $_.ZoneName -eq $zone.ZoneName }
        $recordCount = ($zoneRecords | Measure-Object).Count

        if ($recordCount -eq 0) {
            $emptyZones += $zone
        }
    }

    $emptyZoneCount = ($emptyZones | Measure-Object).Count
    $totalZoneCount = ($dnsZones | Measure-Object).Count

    # Test passes if we successfully retrieved DNS data
    $testResult = $totalZoneCount -ge 0

    # Generate markdown results
    if ($testResult) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total DNS Zones | $totalZoneCount |" + "`n"
        $result += "| Empty Zones | $emptyZoneCount |" + "`n"
        $result += "| Zones with Records | $($totalZoneCount - $emptyZoneCount) |" + "`n"

        if ($emptyZoneCount -gt 0) {
            $result += "`n### Empty Zones" + "`n" + "`n"
            $result += "| Zone Name | Zone Type |" + "`n"
            $result += "| --- | --- |" + "`n"
            foreach ($zone in $emptyZones) {
                $result += "| $($zone.ZoneName) | $($zone.ZoneType) |" + "`n"
            }
        }

        $testResultMarkdown = "Active Directory DNS zones have been analyzed. $emptyZoneCount out of $totalZoneCount zones are empty.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve DNS zone data. Ensure you have appropriate permissions and the DnsServer module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

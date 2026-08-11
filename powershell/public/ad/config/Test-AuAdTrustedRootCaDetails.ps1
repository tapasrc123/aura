function Test-AuAdTrustedRootCaDetails {
    <#
    .SYNOPSIS
    Retrieves detailed information about trusted root certificate authorities.

    .DESCRIPTION
    This test retrieves detailed information about trusted root CAs from the Certification
    Authorities container in Active Directory, including certificate validity information.

    .EXAMPLE
    Test-AuAdTrustedRootCaDetails

    Returns $true if trusted root CA details are accessible, $false otherwise.
    The test result includes details of each trusted root CA.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdTrustedRootCaDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdTrustedRootCaDetails"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $rootCAs = $config.TrustedRootCAs
    $caCount = ($rootCAs | Measure-Object).Count

    # Test passes if we successfully retrieved the data
    $testResult = $null -ne $rootCAs

    # Generate markdown results
    if ($testResult) {
        $result = "| Root CA | Certificate Present |" + "`n"
        $result += "| --- | --- |" + "`n"

        foreach ($ca in $rootCAs | Select-Object -First 10) {
            $caName = $ca.Name
            $hasCert = if ($ca.cACertificate) { "Yes" } else { "No" }
            $result += "| $caName | $hasCert |" + "`n"
        }

        if ($caCount -gt 10) {
            $result += "| ... ($($caCount - 10) more) | ... |" + "`n"
        }

        $testResultMarkdown = "Active Directory trusted root CA details have been analyzed. $caCount trusted root CA(s) found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve trusted root CA details from Active Directory. Ensure you have appropriate permissions."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

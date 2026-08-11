function Test-AuAdCertificateTemplatesCount {
    <#
    .SYNOPSIS
    Counts the number of certificate templates published in Active Directory.

    .DESCRIPTION
    This test retrieves the Active Directory configuration data for certificate templates
    and reports the total number of certificate template objects present.

    .EXAMPLE
    Test-AuAdCertificateTemplatesCount

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdCertificateTemplatesCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdCertificateTemplatesCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $certificateTemplates = $config.CertificateTemplates
    $certificateTemplatesCount = @($certificateTemplates).Count
    $hasData = $null -ne $config.CertificateTemplates

    # Test passes when configuration data is available
    $testResult = $hasData -and ($certificateTemplatesCount -ge 0)

    # Generate markdown results
    if ($hasData) {
        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Certificate Templates Count | $certificateTemplatesCount |" + "`n"
        $testResultMarkdown = "Active Directory certificate templates have been counted. $certificateTemplatesCount certificate template(s) were found.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration data for CertificateTemplates. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

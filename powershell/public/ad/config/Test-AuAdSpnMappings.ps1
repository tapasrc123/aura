function Test-AuAdSpnMappings {
    <#
    .SYNOPSIS
    Returns Active Directory SPN mappings from configuration.

    .DESCRIPTION
    Phase 14 (AD Configuration tests) - AD-CFG-03.
    This test retrieves $config.SpnMappings and returns the array count and values.

    .EXAMPLE
    Test-AuAdSpnMappings

    Returns $true if configuration data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdSpnMappings
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdSpnMappings"

    $adState = Get-AuADDomainState

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $config = $adState.Configuration
    $spnMappings = if ($null -ne $config) { $config.SpnMappings } else { $null }
    $spnMappingsSafe = if ($null -ne $spnMappings) { @($spnMappings) } else { @() }

    $spnMappingsCount = ($spnMappingsSafe | Measure-Object).Count
    $testResult = $null -ne $config

    if ($testResult) {
        $result = "| Property | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| SPN Mappings Count | $spnMappingsCount |" + "`n" + "`n"

        $result += "**SPN Mappings:**" + "`n"
        if ($spnMappingsCount -gt 0) {
            foreach ($mapping in $spnMappingsSafe) {
                $escapedMapping = if ($null -eq $mapping) { '' } else { ($mapping -replace "`r", '' -replace "" + "`n", ' ') }
                $result += "- $escapedMapping" + "`n"
            }
        } else {
            $result += "- (none)" + "`n"
        }

        $testResultMarkdown = "Active Directory SPN mappings have been retrieved.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory configuration. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}

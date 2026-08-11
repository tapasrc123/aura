function Test-AuCisZAP {
    <#
    .SYNOPSIS
    Checks if the Zero-hour auto purge (ZAP) for Microsoft Teams is enabled

    .DESCRIPTION
    Zero-hour auto purge (ZAP) should be enabled for Microsoft Teams
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisZAP

    Returns true if Zero-hour auto purge (ZAP) is enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisZAP
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Teams)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedTeams
        return $null
    }

    if (-not (Get-AuLicenseInformation -Product Mdo)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedMdo
        return $null
    }

    try {
        Write-Verbose 'Get TeamsProtectionPolicy'
        $teamsProtectionPolicy = Get-TeamsProtectionPolicy | Select-Object ZapEnabled

        Write-Verbose 'Add policy to result if ZAP is not enabled'
        $result = $teamsProtectionPolicy | Where-Object { $_.ZapEnabled -ne 'True' }

        $testResult = ($result | Measure-Object).Count -eq 0
        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant has Zero-hour auto purge (ZAP) enabled for Microsoft Teams:`n`n%TestResult%"
        } else {
            $testResultMarkdown = "Your tenant does not have Zero-hour auto purge (ZAP) enabled for Microsoft Teams:`n`n%TestResult%"
        }

        $resultMd = "| Zero-hour auto purge (ZAP) |`n"
        $resultMd += "| --- |`n"
        if ($testResult) {
            $itemResult = '✅ Enabled'
        } else {
            $itemResult = '❌ Not Enabled'
        }
        $resultMd += "| $($itemResult) |`n"

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

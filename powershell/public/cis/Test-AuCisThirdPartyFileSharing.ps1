function Test-AuCisThirdPartyFileSharing {
    <#
    .SYNOPSIS
    Ensure third-party file sharing cloud services in Teams are disabled

    .DESCRIPTION
    Ensure third-party file sharing cloud services in Teams are disabled
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisThirdPartyFileSharing

    Returns true if all third-party file sharing cloud services in Teams are disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisThirdPartyFileSharing
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Test-AuConnection Teams)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedTeams
        return $null
    }

    Write-Verbose 'Test-AuCisThirdPartyFileSharing: Checking if third-party file sharing cloud services in Teams are disabled'

    try {
        $return = $true
        $thirdPartyCloudServices = Get-CsTeamsClientConfiguration -Identity Global | Select-Object AllowDropbox, AllowBox, AllowGoogleDrive, AllowShareFile, AllowEgnyte

        $passResult = '✅ Pass'
        $failResult = '❌ Fail'

        $result = "| Policy | Value | Status |`n"
        $result += "| --- | --- | --- |`n"

        foreach ($thirdPartyProvider in ($thirdPartyCloudServices.PSObject.Properties)) {
            if ($thirdPartyProvider.Value -eq $false) {
                $result += "| $($thirdPartyProvider.Name) | $($thirdPartyProvider.Value) | $passResult |`n"
            } else {
                $result += "| $($thirdPartyProvider.Name) | $($thirdPartyProvider.Value) | $failResult |`n"
                $return = $false
            }
        }

        if ($return) {
            $testResultMarkdown = "Well done. All third-party cloud services are disabled.`n`n%TestResult%"
        } else {
            $testResultMarkdown = "All or specific third-party cloud services are enabled.`n`n%TestResult%"
        }
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Test-AuAdGpoDenyAceDetails {
    <#
    .SYNOPSIS
    Returns details of GPO reports that include a Deny ACE.

    .DESCRIPTION
    This test retrieves GPO state data and returns a markdown table listing the GPO
    reports where a Deny ACE is present.

    .EXAMPLE
    Test-AuAdGpoDenyAceDetails

    Returns $true when no GPO reports include a Deny ACE, otherwise $false.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoDenyAceDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using Details')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoDenyAceDetails"
    $gpoState = $null
    try {
        $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo deny ace details"

    $gpoReports = $null
    if ($gpoState.PSObject.Properties.Name -contains 'GPOReports') {
        $gpoReports = $gpoState.GPOReports
    } elseif ($gpoState.PSObject.Properties.Name -contains 'GpoReports') {
        $gpoReports = $gpoState.GpoReports
    } else {
        $gpoReports = @()
        foreach ($gpo in @($gpoState.GPOs)) {
            foreach ($prop in @('GpoReports', 'GPOReports', 'GpoReport', 'GPOReport')) {
                if ($gpo.PSObject.Properties.Name -contains $prop -and $null -ne $gpo.$prop) {
                    $value = $gpo.$prop
                    if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
                        $gpoReports += @($value)
                    } else {
                        $gpoReports += $value
                    }
                }
            }
        }
    }

    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve GPO reports from Get-AuADGpoState.'
        return $false
    }

    $gpoReports = @($gpoReports)
    $reportsWithDenyAce = @(
        foreach ($report in $gpoReports) {
            $hasDenyAce = $null
            if ($report.PSObject.Properties.Name -contains 'HasDenyAce') {
                $hasDenyAce = $report.HasDenyAce
            }

            if ($hasDenyAce -eq $true) {
                $report
            }
        }
    )

    $denyAceCount = ($reportsWithDenyAce | Measure-Object).Count
    $testResult = $denyAceCount -eq 0

    $table = "| GPO Name | HasDenyAce |" + "`n"
    $table += '| --- | --- |' + "`n"

    foreach ($report in @($reportsWithDenyAce | Sort-Object Name)) {
        $name = if ($null -ne $report.Name) { [string]$report.Name } else { '' }
        $name = $name -replace '\|', '\\&#124;'

        $hasDenyAce = $report.HasDenyAce
        if ($null -eq $hasDenyAce) { $hasDenyAce = '' }
        $table += "| $name | $hasDenyAce |" + "`n"
    }

    $recommendation = if ($testResult) {
        '✅ No GPO reports include a Deny ACE.'
    } else {
        "⚠️ GPO reports include a Deny ACE ($denyAceCount)."
    }
    Write-Verbose "Counts computed"

    $testResultMarkdown = "$recommendation`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $table

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoDenyAceDetails"
    return $testResult
}

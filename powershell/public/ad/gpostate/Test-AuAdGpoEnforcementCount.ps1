<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoEnforcementCount {
    <#
    .SYNOPSIS
    Counts the number of GPOs that have enforced GPO links.

    .DESCRIPTION
    This test retrieves Active Directory Group Policy state information using Get-AuADGpoState,
    then counts how many returned GPO reports indicate enforced links.

    .EXAMPLE
    Test-AuAdGpoEnforcementCount

    Returns $true if GPO report data is accessible, $false otherwise.
    The test result includes the number of GPOs with enforced links.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoEnforcementCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoEnforcementCount"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo enforcement count"

    $gpoReports = $gpoState.GPOReports
    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory GPO report data from Get-AuADGpoState.'
        return $false
    }

    $gpoReportsArray = @($gpoReports | Where-Object { $null -ne $_ })
    $totalCount = $gpoReportsArray.Count
    $enforcedCount = @($gpoReportsArray | Where-Object { [int]$_.Enforcement -gt 0 }).Count

    $testResult = $true
    $enforcedPercentage = if ($totalCount -gt 0) { [Math]::Round(($enforcedCount / $totalCount) * 100, 2) } else { 0 }

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total GPOs | $totalCount |" + "`n"
    $result += "| GPOs with enforced links | $enforcedCount |" + "`n"
    $result += "| Enforced ratio | $enforcedPercentage% |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory GPOs have been analyzed for enforced links. $enforcedCount out of $totalCount GPO(s) have enforced link(s).`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoEnforcementCount"
    return $testResult
}

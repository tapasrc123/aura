<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoDefaultPasswordFoundCount {
    <#
    .SYNOPSIS
    Counts the number of GPOs that contain a default password (decoded from cpassword).

    .DESCRIPTION
    This test retrieves Active Directory Group Policy state information using Get-AuADGpoState,
    then counts how many returned GPO reports indicate DefaultPasswordFound was true.

    .EXAMPLE
    Test-AuAdGpoDefaultPasswordFoundCount

    Returns $true if GPO report data is accessible, $false otherwise.
    The test result includes the number of GPOs with DefaultPasswordFound.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoDefaultPasswordFoundCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoDefaultPasswordFoundCount"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo default password found count"

    $gpoReports = $gpoState.GPOReports
    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory GPO report data from Get-AuADGpoState.'
        return $false
    }

    $gpoReportsArray = @($gpoReports | Where-Object { $null -ne $_ })
    $totalCount = $gpoReportsArray.Count
    $defaultPasswordCount = @($gpoReportsArray | Where-Object { [bool]$_.DefaultPasswordFound }).Count

    $testResult = $true
    $defaultPasswordPercentage = if ($totalCount -gt 0) { [Math]::Round(($defaultPasswordCount / $totalCount) * 100, 2) } else { 0 }

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total GPOs | $totalCount |" + "`n"
    $result += "| GPOs with default password | $defaultPasswordCount |" + "`n"
    $result += "| Default password ratio | $defaultPasswordPercentage% |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory GPOs have been analyzed for default password usage. $defaultPasswordCount out of $totalCount GPO(s) contain a default password.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoDefaultPasswordFoundCount"
    return $testResult
}

<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoCpasswordFoundCount {
    <#
    .SYNOPSIS
    Counts the number of GPOs that contain a cpassword.

    .DESCRIPTION
    This test retrieves Active Directory Group Policy state information using Get-AuADGpoState,
    then counts how many returned GPO reports indicate a cpassword was found.

    .EXAMPLE
    Test-AuAdGpoCpasswordFoundCount

    Returns $true if GPO report data is accessible, $false otherwise.
    The test result includes the number of GPOs with cpassword present.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoCpasswordFoundCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoCpasswordFoundCount"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo cpassword found count"

    $gpoReports = $gpoState.GPOReports
    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory GPO report data from Get-AuADGpoState.'
        return $false
    }

    $gpoReportsArray = @($gpoReports | Where-Object { $null -ne $_ })
    $totalCount = $gpoReportsArray.Count
    $cpasswordCount = @($gpoReportsArray | Where-Object { [bool]$_.CpasswordFound }).Count

    $testResult = $true
    $cpasswordPercentage = if ($totalCount -gt 0) { [Math]::Round(($cpasswordCount / $totalCount) * 100, 2) } else { 0 }

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total GPOs | $totalCount |" + "`n"
    $result += "| GPOs with cpassword | $cpasswordCount |" + "`n"
    $result += "| cpassword ratio | $cpasswordPercentage% |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory GPOs have been analyzed for cpassword usage. $cpasswordCount out of $totalCount GPO(s) contain a cpassword.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoCpasswordFoundCount"
    return $testResult
}

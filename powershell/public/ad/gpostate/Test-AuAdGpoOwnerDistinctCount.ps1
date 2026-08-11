<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoOwnerDistinctCount {
    <#
    .SYNOPSIS
    Counts the number of distinct GPO owners.

    .DESCRIPTION
    This test retrieves Active Directory GPO state data using Get-AuADGpoState and counts the number of
    distinct (non-empty) Owner values found across returned GPO objects.

    .EXAMPLE
    Test-AuAdGpoOwnerDistinctCount

    Returns $true if GPO state data is accessible, $false otherwise.
    The test result includes the distinct owner count.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoOwnerDistinctCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoOwnerDistinctCount"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo owner distinct count"

    $gpos = $gpoState.GPOs
    if ($null -eq $gpos) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory Group Policy Objects (GPOs) from Get-AuADGpoState.'
        return $false
    }

    $gposArray = @($gpos | Where-Object { $null -ne $_ })

    $owners = $gposArray |
        ForEach-Object {
            $o = $_.Owner
            if (-not [string]::IsNullOrWhiteSpace([string]$o)) { [string]$o }
        } |
        Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
        Select-Object -Unique

    $distinctOwnerCount = @($owners).Count
    $testResult = $true

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Distinct GPO owner count | $distinctOwnerCount |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory GPO owners have been analyzed. There are $distinctOwnerCount distinct owner(s).`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoOwnerDistinctCount"
    return $testResult
}

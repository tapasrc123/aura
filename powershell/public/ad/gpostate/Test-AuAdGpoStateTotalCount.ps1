<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoStateTotalCount {
    <#
    .SYNOPSIS
    Counts the total number of Group Policy Objects (GPOs) returned by Get-AuADGpoState.

    .DESCRIPTION
    This test retrieves Active Directory GPO state data using Get-AuADGpoState and counts the total
    number of GPO entries present in the returned state.

    .EXAMPLE
    Test-AuAdGpoStateTotalCount

    Returns $true if GPO state data is accessible, $false otherwise.
    The test result includes the total number of returned GPOs.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoStateTotalCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoStateTotalCount"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"

    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo state total count"

    $gpos = $gpoState.GPOs
    if ($null -eq $gpos) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory Group Policy Objects (GPOs) from Get-AuADGpoState.'
        return $false
    }

    $totalCount = @($gpos | Where-Object { $null -ne $_ }).Count

    $testResult = $true

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total GPOs (state) | $totalCount |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory GPO state has been analyzed. The domain contains $totalCount GPO(s) (state view).`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoStateTotalCount"
    return $testResult
}

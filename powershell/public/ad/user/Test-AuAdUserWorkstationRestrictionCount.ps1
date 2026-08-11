function Test-AuAdUserWorkstationRestrictionCount {
    <#
    .SYNOPSIS
    Counts user accounts with logon workstation restrictions configured.

    .DESCRIPTION
    This test identifies user accounts where the LogonWorkstations attribute is set.
    Workstation restrictions can be a useful hardening control for sensitive accounts and
    this test helps measure how broadly that control is being used.

    .EXAMPLE
    Test-AuAdUserWorkstationRestrictionCount

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUserWorkstationRestrictionCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUserWorkstationRestrictionCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Not connected to Active Directory."
        return $null
    }
    Write-Verbose "Filtering/counting user workstation restriction count"

    $users = @($adState.Users)
    $restrictedUsers = @($users | Where-Object {
            -not [string]::IsNullOrWhiteSpace([string]$_.LogonWorkstations)
        })

    $restrictedCount = $restrictedUsers.Count
    $totalCount = $users.Count
    $enabledCount = @($users | Where-Object { $_.Enabled -eq $true }).Count

    $testResult = $null -ne $adState.Users

    if ($testResult) {
        $percentage = if ($totalCount -gt 0) {
            [Math]::Round(($restrictedCount / $totalCount) * 100, 2)
        } else {
            0
        }

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total Users | $totalCount |" + "`n"
        $result += "| Enabled Users | $enabledCount |" + "`n"
        $result += "| Users with Workstation Restrictions | $restrictedCount |" + "`n"
        $result += "| Restriction Percentage | $percentage% |" + "`n" + "`n"
    Write-Verbose "Counts computed"

        $testResultMarkdown = "Active Directory user objects have been analyzed. $restrictedCount out of $totalCount users ($percentage%) have workstation logon restrictions configured.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory user objects. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdUserWorkstationRestrictionCount"

    return $testResult
}

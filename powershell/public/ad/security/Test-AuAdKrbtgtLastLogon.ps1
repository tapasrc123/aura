function Test-AuAdKrbtgtLastLogon {
    <#
    .SYNOPSIS
    Checks the KRBTGT account last logon time.

    .DESCRIPTION
    The KRBTGT account is a service account that should never have interactive logons.
    This test retrieves the last logon timestamp for the KRBTGT account, which should
    typically show no logon activity or only system-generated authentication events.

    Security Note:
    - KRBTGT should not have interactive logons
    - Any logon activity may indicate suspicious activity
    - The account is used internally by the KDC service only

    .EXAMPLE
    Test-AuAdKrbtgtLastLogon

    Returns $true if KRBTGT account data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdKrbtgtLastLogon
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdKrbtgtLastLogon"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting krbtgt last logon"

    $users = $adState.Users
    $krbtgt = $users | Where-Object { $_.SamAccountName -eq 'krbtgt' } | Select-Object -First 1

    if ($null -eq $krbtgt) {
        Add-AuTestResultDetail -Result "KRBTGT account not found in Active Directory."
        return $false
    }

    $lastLogon = $krbtgt.LastLogonDate
    $testResult = $true

    $result = "| Property | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Account Name | $($krbtgt.SamAccountName) |" + "`n"
    $result += "| Last Logon Date | $(if ($lastLogon) { $lastLogon.ToString('yyyy-MM-dd HH:mm:ss') } else { 'Never' }) |" + "`n"
    $result += "| Account Enabled | $($krbtgt.Enabled) |" + "`n"
    $result += "| Password Last Set | $(if ($krbtgt.PasswordLastSet) { $krbtgt.PasswordLastSet.ToString('yyyy-MM-dd HH:mm:ss') } else { 'Never' }) |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "KRBTGT account last logon information retrieved. This service account should not have interactive logons.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdKrbtgtLastLogon"

    return $testResult
}

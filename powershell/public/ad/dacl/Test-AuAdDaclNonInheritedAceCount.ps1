function Test-AuAdDaclNonInheritedAceCount {
    <#
    .SYNOPSIS
    Counts non-inherited ACEs in Active Directory DACLs.

    .DESCRIPTION
    This test analyzes DACL entries from Get-AuADDomainState and counts ACEs that are
    explicitly assigned rather than inherited. Non-inherited ACEs are often where
    custom delegations, exceptions, and potentially risky access grants are introduced.

    .EXAMPLE
    Test-AuAdDaclNonInheritedAceCount

    Returns $true if DACL data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDaclNonInheritedAceCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDaclNonInheritedAceCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting dacl non inherited ace count"

    if (-not ($adState.ContainsKey('DaclEntries'))) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory DACL entries from Get-AuADDomainState.'
        return $false
    }

    $daclEntries = @($adState.DaclEntries | Where-Object { $null -ne $_ })
    $nonInheritedEntries = @(
        $daclEntries | Where-Object {
            $_.IsInherited -eq $false -or [string]$_.IsInherited -eq 'False'
        }
    )

    $testResult = $true

    $result = '| Metric | Value |' + "`n"
    $result += '| --- | --- |' + "`n"
    $result += "| Total DACL Entries | $($daclEntries.Count) |" + "`n"
    $result += "| Non-Inherited ACEs | $($nonInheritedEntries.Count) |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory DACL inheritance was analyzed. $($nonInheritedEntries.Count) ACE(s) are explicitly assigned and not inherited.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdDaclNonInheritedAceCount"
    return $testResult
}

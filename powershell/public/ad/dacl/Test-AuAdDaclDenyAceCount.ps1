function Test-AuAdDaclDenyAceCount {
    <#
    .SYNOPSIS
    Counts deny authorization ACEs in collected DACL data.

    .DESCRIPTION
    This informational test reviews collected Active Directory DACL data and counts ACEs where the
    access control type contains Deny. Deny ACEs are security-significant because they can override
    allow permissions and affect delegated administration, object visibility, or operational access
    in unexpected ways.

    .EXAMPLE
    Test-AuAdDaclDenyAceCount

    Returns $true if DACL data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDaclDenyAceCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDaclDenyAceCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason 'Not connected to Active Directory.'
        return $null
    }
    Write-Verbose "Filtering/counting dacl deny ace count"

    $daclEntries = @($adState.DaclEntries)
    $totalDaclEntryCount = ($daclEntries | Measure-Object).Count
    $denyEntries = @($daclEntries | Where-Object { $_.AccessControlType -match 'Deny' })
    $denyAceCount = ($denyEntries | Measure-Object).Count
    $affectedObjects = (@(
            $denyEntries |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.ObjectDN) } |
                Select-Object -ExpandProperty ObjectDN -Unique
        ) | Measure-Object).Count

    $testResult = $true

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total DACL Entries | $totalDaclEntryCount |" + "`n"
    $result += "| Deny ACEs | $denyAceCount |" + "`n"
    $result += "| Objects With Deny ACEs | $affectedObjects |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory DACL data has been reviewed for deny authorizations. $denyAceCount deny ACE(s) were identified across $affectedObjects object(s).`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdDaclDenyAceCount"
    return $testResult
}

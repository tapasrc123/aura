function Test-AuAdDaclOuObjectCount {
    <#
    .SYNOPSIS
    Counts DACL entries on Organizational Unit objects.

    .DESCRIPTION
    This informational test filters collected DACL data to Organizational Unit objects and counts
    the number of ACEs present on those OU objects. OU permissions are security-relevant because OUs
    are common delegation boundaries for administration, policy application, and object management in
    Active Directory.

    .EXAMPLE
    Test-AuAdDaclOuObjectCount

    Returns $true if DACL data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDaclOuObjectCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDaclOuObjectCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason 'Not connected to Active Directory.'
        return $null
    }
    Write-Verbose "Filtering/counting dacl ou object count"

    $daclEntries = @($adState.DaclEntries)
    $ouDaclEntries = @($daclEntries | Where-Object { $_.ObjectClass -eq 'organizationalUnit' })
    $totalDaclEntryCount = ($daclEntries | Measure-Object).Count
    $ouDaclEntryCount = ($ouDaclEntries | Measure-Object).Count
    $distinctOuObjectCount = (@(
            $ouDaclEntries |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.ObjectDN) } |
                Select-Object -ExpandProperty ObjectDN -Unique
        ) | Measure-Object).Count

    $testResult = $true

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total DACL Entries | $totalDaclEntryCount |" + "`n"
    $result += "| OU DACL Entries | $ouDaclEntryCount |" + "`n"
    $result += "| Distinct OU Objects With DACL Entries | $distinctOuObjectCount |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Active Directory DACL data has been filtered to Organizational Unit objects. $ouDaclEntryCount DACL entr$(if ($ouDaclEntryCount -eq 1) { 'y' } else { 'ies' }) were found across $distinctOuObjectCount OU object(s).`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdDaclOuObjectCount"
    return $testResult
}

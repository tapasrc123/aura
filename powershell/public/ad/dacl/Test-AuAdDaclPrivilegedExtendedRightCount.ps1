function Test-AuAdDaclPrivilegedExtendedRightCount {
    <#
    .SYNOPSIS
    Counts allow ACEs that grant the ExtendedRight permission.

    .DESCRIPTION
    This test reviews DACL entries and counts allow ACEs that include the
    ExtendedRight permission. Extended rights can delegate powerful object-specific
    operations and should be understood within the context of directory delegation.

    .EXAMPLE
    Test-AuAdDaclPrivilegedExtendedRightCount

    Returns $true if DACL data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDaclPrivilegedExtendedRightCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDaclPrivilegedExtendedRightCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting dacl privileged extended right count"

    $daclEntries = @($adState.DaclEntries)
    $extendedRightEntries = @(
        $daclEntries | Where-Object {
            $_.AccessControlType -like 'AccessAllowed*' -and
            [string]$_.ActiveDirectoryRights -match '(^|,\s*)ExtendedRight(,|$)'
        }
    )

    $normalizedObjectTypes = @(
        foreach ($entry in $extendedRightEntries) {
            if ([string]::IsNullOrWhiteSpace($entry.ObjectType) -or $entry.ObjectType -eq '00000000-0000-0000-0000-000000000000') {
                'All / Not specified'
            }
            else {
                [string]$entry.ObjectType
            }
        }
    )

    $testResult = $true

    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total DACL ACEs | $((@($daclEntries) | Measure-Object).Count) |" + "`n"
    $result += "| ExtendedRight allow ACEs | $($extendedRightEntries.Count) |" + "`n"
    $result += "| Distinct ObjectType values | $(@($normalizedObjectTypes | Sort-Object -Unique).Count) |" + "`n"
    $result += "| Distinct identities with ExtendedRight | $(@($extendedRightEntries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.IdentityReference) } | Select-Object -ExpandProperty IdentityReference -Unique).Count) |" + "`n"
    $result += "| Distinct objects with ExtendedRight | $(@($extendedRightEntries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ObjectDN) } | Select-Object -ExpandProperty ObjectDN -Unique).Count) |" + "`n"
    Write-Verbose "Counts computed"

    $testResultMarkdown = "This informational test counts allow ACEs that grant the ExtendedRight permission.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdDaclPrivilegedExtendedRightCount"
    return $testResult
}

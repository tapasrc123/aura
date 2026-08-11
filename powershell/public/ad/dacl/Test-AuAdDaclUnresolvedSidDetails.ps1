function Test-AuAdDaclUnresolvedSidDetails {
    <#
    .SYNOPSIS
    Returns unresolved SID details from Active Directory DACL entries.

    .DESCRIPTION
    This test analyzes DACL entries from Get-AuADDomainState and groups orphaned SID
    references by directory object. Reviewing unresolved SIDs by object helps identify
    where stale ACEs remain after account deletions, migrations, or delegated access
    changes.

    .EXAMPLE
    Test-AuAdDaclUnresolvedSidDetails

    Returns $true if DACL data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDaclUnresolvedSidDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDaclUnresolvedSidDetails"

    $adState = Get-AuADDomainState
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    if (-not ($adState.ContainsKey('DaclEntries'))) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory DACL entries from Get-AuADDomainState.'
        return $false
    }

    $daclEntries = @($adState.DaclEntries | Where-Object { $null -ne $_ })
    $unresolvedEntries = @(
        $daclEntries | Where-Object {
            [string]$_.IdentityReference -like 'S-1-5-21-*'
        }
    )

    $objectGroups = @(
        $unresolvedEntries |
        Group-Object -Property ObjectDN |
        Sort-Object @{ Expression = 'Count'; Descending = $true }, @{ Expression = 'Name'; Descending = $false }
    )

    $result = '| ObjectDN | Distinct Unresolved SID Count | Unresolved SIDs |' + "`n"
    $result += '| --- | --- | --- |' + "`n"

    foreach ($group in $objectGroups) {
        $objectDn = [string]$group.Name
        if ([string]::IsNullOrWhiteSpace($objectDn)) {
            $objectDn = '(No ObjectDN)'
        }

        $objectDn = $objectDn -replace '\|', '\\&#124;'

        $sidList = @(
            $group.Group |
            ForEach-Object { [string]$_.IdentityReference } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
        )

        $sidListJoined = ($sidList | ForEach-Object { $_ -replace '\|', '\\&#124;' }) -join ', '
        $result += "| $objectDn | $($sidList.Count) | $sidListJoined |" + "`n"
    }

    $testResult = $true
    $testResultMarkdown = "Active Directory DACL entries were analyzed for orphaned SID references. $($objectGroups.Count) object(s) contain unresolved SID ACEs.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}

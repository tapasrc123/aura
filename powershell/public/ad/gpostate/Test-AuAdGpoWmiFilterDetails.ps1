<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoWmiFilterDetails {
    <#
    .SYNOPSIS
    Returns details of GPOs that have a non-empty WMI filter.

    .DESCRIPTION
    This test retrieves Active Directory GPO state data using Get-AuADGpoState and returns a markdown
    table listing all GPOs whose WmiFilter property is configured.

    .EXAMPLE
    Test-AuAdGpoWmiFilterDetails

    Returns $true if GPO state data is accessible, $false otherwise.
    The test result includes a markdown table of GPO WMI filter configuration.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoWmiFilterDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoWmiFilterDetails"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo wmi filter details"

    $gpos = $gpoState.GPOs
    if ($null -eq $gpos) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory Group Policy Objects (GPOs) from Get-AuADGpoState.'
        return $false
    }

    $gposArray = @($gpos | Where-Object { $null -ne $_ })

    $wmiFiltered = $gposArray | Where-Object {
        $wf = $_.WmiFilter
        -not [string]::IsNullOrWhiteSpace([string]$wf)
    }

    $wmiFilteredCount = @($wmiFiltered).Count
    $testResult = $true

    $table = "| GPO DisplayName | Id | GpoStatus | WmiFilter | Owner |" + "`n"
    $table += '| --- | --- | --- | --- | --- |' + "`n"

    foreach ($gpo in @($wmiFiltered | Sort-Object -Property DisplayName)) {
        $displayName = [string]$gpo.DisplayName
        $displayName = $displayName -replace '\|', '\\&#124;'

        $id = [string]$gpo.Id
        $owner = if ($null -ne $gpo.Owner) { [string]$gpo.Owner } else { '' }
        $owner = $owner -replace '\|', '\\&#124;'

        $status = if ($null -ne $gpo.GpoStatus) { $gpo.GpoStatus } else { '' }
        $wmiFilter = [string]$gpo.WmiFilter
        $wmiFilter = $wmiFilter -replace '\|', '\\&#124;'

        $table += "| $displayName | $id | $status | $wmiFilter | $owner |" + "`n"
    }

    $recommendation = if ($wmiFilteredCount -gt 0) {
        "GPO WMI filter details were returned ($wmiFilteredCount). Review these filters to ensure they are still intended."
    } else {
        '✅ No GPOs with WMI filter configuration were found.'
    }
    Write-Verbose "Counts computed"

    $testResultMarkdown = "$recommendation`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $table

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoWmiFilterDetails"
    return $testResult
}

<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoDefaultPasswordFoundDetails {
    <#
    .SYNOPSIS
    Returns details of GPOs that contain a default password.

    .DESCRIPTION
    This test retrieves Active Directory Group Policy state information using Get-AuADGpoState,
    then returns a markdown table listing all GPO reports whose DefaultPasswordFound value is true.

    .EXAMPLE
    Test-AuAdGpoDefaultPasswordFoundDetails

    Returns $true if GPO report data is accessible, $false otherwise.
    The test result includes a markdown table of GPOs with a default password.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoDefaultPasswordFoundDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoDefaultPasswordFoundDetails"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo default password found details"

    $gpoReports = $gpoState.GPOReports
    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory GPO report data from Get-AuADGpoState.'
        return $false
    }

    $gpoReportsArray = @($gpoReports | Where-Object { $null -ne $_ })
    $found = $gpoReportsArray | Where-Object { [bool]$_.DefaultPasswordFound }
    $foundCount = @($found).Count

    $testResult = $true

    $table = "| GPO Name | DefaultPasswordFound | CpasswordFound |" + "`n"
    $table += '| --- | --- | --- |' + "`n"

    foreach ($report in ($found | Sort-Object -Property Name)) {
        $name = [string]$report.Name
        $name = $name -replace '\\|', '\\&#124;'

        $defaultPasswordFound = [bool]$report.DefaultPasswordFound
        $cpasswordFound = [bool]$report.CpasswordFound
        $table += "| $name | $defaultPasswordFound | $cpasswordFound |" + "`n"
    }

    $recommendation = if ($foundCount -gt 0) {
        "GPO default password details were returned ($foundCount). Review these GPOs to ensure Group Policy Preferences passwords are handled securely."
    } else {
        '✅ No GPOs with default password were found.'
    }
    Write-Verbose "Counts computed"

    $testResultMarkdown = "$recommendation`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $table

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoDefaultPasswordFoundDetails"
    return $testResult
}

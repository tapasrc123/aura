<# <!-- OMO_INTERNAL_INITIATOR --> #>
function Test-AuAdGpoNoApplyGroupPolicyAceDetails {
    <#
    .SYNOPSIS
    Returns details of GPOs missing the "Apply Group Policy" ACE.

    .DESCRIPTION
    This test retrieves Active Directory Group Policy state information using Get-AuADGpoState,
    then analyzes each GPO report to identify which GPOs are missing the ACE required for
    applying group policy.

    .EXAMPLE
    Test-AuAdGpoNoApplyGroupPolicyAceDetails

    Returns $true if GPO report data is accessible, $false otherwise.
    The test result includes a markdown table listing GPOs missing the required ACE.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdGpoNoApplyGroupPolicyAceDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdGpoNoApplyGroupPolicyAceDetails"
    $gpoState = Get-AuADGpoState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $gpoState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }
    Write-Verbose "Filtering/counting gpo no apply group policy ace details"

    $gpoReports = $gpoState.GPOReports
    if ($null -eq $gpoReports) {
        Add-AuTestResultDetail -Result 'Unable to retrieve Active Directory GPO report data from Get-AuADGpoState.'
        return $false
    }

    $gpoReportsArray = @($gpoReports | Where-Object { $null -ne $_ })
    $noApplyAceReports = @($gpoReportsArray | Where-Object { -not [bool]$_.HasApplyGroupPolicyAce })

    $table = "| GPO Name | HasApplyGroupPolicyAce |" + "`n"
    $table += '| --- | --- |' + "`n"

    foreach ($report in ($noApplyAceReports | Sort-Object -Property Name)) {
        $name = [string]$report.Name
        $name = $name -replace '\|', '\\&#124;'
        $table += "| $name | $([bool]$report.HasApplyGroupPolicyAce) |" + "`n"
    }

    $testResult = $true
    Write-Verbose "Counts computed"
    $testResultMarkdown = "GPO apply permissions were analyzed. $($noApplyAceReports.Count) GPO(s) are missing the required ACE.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $table

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdGpoNoApplyGroupPolicyAceDetails"
    return $testResult
}

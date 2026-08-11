function Test-AuAdUserBuiltInAdminPasswordAgeDetails {
    <#
    .SYNOPSIS
    Returns password age details for built-in administrator style accounts.

    .DESCRIPTION
    This test reports when built-in administrator style accounts last changed
    their passwords. Long-lived credentials on highly privileged accounts can
    materially increase risk and should be reviewed regularly.

    .EXAMPLE
    Test-AuAdUserBuiltInAdminPasswordAgeDetails

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUserBuiltInAdminPasswordAgeDetails
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Clarity in using plural')]
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUserBuiltInAdminPasswordAgeDetails"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Not connected to Active Directory."
        return $null
    }
    Write-Verbose "Filtering/counting user built in admin password age details"

    $users = $adState.Users

    $builtInAdminUsers = @($users | Where-Object {
            $sidValue = [string]$_.SID
            $sidValue -match '-500$' -or $_.isCriticalSystemObject -eq $true
        } | Sort-Object SamAccountName)

    $testResult = $true

    $result = "### Built-In Administrator Password Age Details" + "`n" + "`n"
    $result += "| SamAccountName | Display Name | Enabled | Password Last Set | Password Age (Days) | Password Never Expires |" + "`n"
    $result += "| --- | --- | --- | --- | --- | --- |" + "`n"

    if ($builtInAdminUsers.Count -gt 0) {
        foreach ($user in $builtInAdminUsers) {
            $passwordLastSetText = if ($null -ne $user.PasswordLastSet) { Get-Date $user.PasswordLastSet -Format 'yyyy-MM-dd HH:mm:ss' } else { 'Never/Unknown' }
            $passwordAgeDays = if ($null -ne $user.PasswordLastSet) { [int](((Get-Date) - $user.PasswordLastSet).TotalDays) } else { 'N/A' }
            $result += "| $($user.SamAccountName) | $($user.Name) | $($user.Enabled) | $passwordLastSetText | $passwordAgeDays | $($user.PasswordNeverExpires) |" + "`n"
        }
    } else {
        $result += "| No built-in administrator style accounts found | - | - | - | - | - |" + "`n"
    }
    Write-Verbose "Counts computed"

    $testResultMarkdown = "Built-in administrator style account password age data was retrieved from Active Directory.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdUserBuiltInAdminPasswordAgeDetails"

    return $testResult
}

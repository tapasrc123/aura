function Test-AuAdUserPasswordNotRequiredCount {
    <#
    .SYNOPSIS
    Counts user accounts where a password is not required.

    .DESCRIPTION
    This test identifies user accounts configured with the PasswordNotRequired flag.
    Accounts that do not require passwords represent a high-risk configuration and should
    be investigated immediately.

    .EXAMPLE
    Test-AuAdUserPasswordNotRequiredCount

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdUserPasswordNotRequiredCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdUserPasswordNotRequiredCount"
    $adState = Get-AuADDomainState
    Write-Verbose "Retrieved AD state"
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Not connected to Active Directory."
        return $null
    }
    Write-Verbose "Filtering/counting user password not required count"

    $users = @($adState.Users)
    $passwordNotRequiredUsers = @($users | Where-Object { $_.PasswordNotRequired -eq $true })

    $passwordNotRequiredCount = $passwordNotRequiredUsers.Count
    $totalCount = $users.Count
    $enabledCount = @($users | Where-Object { $_.Enabled -eq $true }).Count

    $testResult = $null -ne $adState.Users

    if ($testResult) {
        $percentage = if ($totalCount -gt 0) {
            [Math]::Round(($passwordNotRequiredCount / $totalCount) * 100, 2)
        } else {
            0
        }

        $result = "| Metric | Value |" + "`n"
        $result += "| --- | --- |" + "`n"
        $result += "| Total Users | $totalCount |" + "`n"
        $result += "| Enabled Users | $enabledCount |" + "`n"
        $result += "| Users with Password Not Required | $passwordNotRequiredCount |" + "`n"
        $result += "| Password Not Required Percentage | $percentage% |" + "`n" + "`n"
    Write-Verbose "Counts computed"

        $testResultMarkdown = "Active Directory user objects have been analyzed. $passwordNotRequiredCount out of $totalCount users ($percentage%) do not require a password.`n`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    } else {
        $testResultMarkdown = "Unable to retrieve Active Directory user objects. Ensure you have appropriate permissions and the Active Directory module is installed."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    Write-Verbose "Completed Test-AuAdUserPasswordNotRequiredCount"

    return $testResult
}

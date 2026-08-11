function Test-AuCisSharedMailboxSignIn {
    <#
    .SYNOPSIS
    Checks if shared mailboxes allow sign-ins

    .DESCRIPTION
    Ensure Sign ins are blocked for shared mailboxes.
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisSharedMailboxSignIn

    Returns true if no shared mailboxes allow sign-ins

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisSharedMailboxSignIn
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    try {
        Write-Verbose 'Getting all shared mailboxes'
        $sharedMailboxes = Get-AuExo -Request EXOSharedMailbox -ErrorAction Stop
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    if (($sharedMailboxes | Measure-Object).Count -eq 0) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason 'There are no shared mailboxes in your tenant.'
        return $null
    }

    try {
        Write-Verbose 'For each mailbox get mailbox and AccountEnabled status'
        $mgUsers = Invoke-AuGraphRequest -RelativeUri "users" -UniqueId @($sharedMailboxes.ExternalDirectoryObjectId) -Select id, displayName, userPrincipalName, accountEnabled
        $mailboxDetails = foreach ($mgUser in $mgUsers) {
            $mgUser | Select-Object DisplayName, UserPrincipalName, AccountEnabled
        }

        Write-Verbose 'Select shared mailboxes where sign-in is enabled'
        $result = $mailboxDetails | Where-Object { $_.AccountEnabled -eq 'True' }
        $resultCount = ($result | Measure-Object).Count

        $testResult = if ($resultCount -eq 0) { $true } else { $false }
        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant has no shared mailboxes with sign-in enabled:`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "Your tenant has $(($result | Measure-Object).Count) shared mailboxes with sign-in enabled:`n`n%TestResult%"
        }

        $resultMd = "| Shared Mailbox | Sign-in Disabled |`n"
        $resultMd += "| --- | --- |`n"
        foreach ($item in $result | Sort-Object @sortSplat) {
            $itemResult = '❌ Fail'
            if ($item.id -notin $result.id) {
                $itemResult = '✅ Pass'
            }
            $resultMd += "| $($item.displayName) | $($itemResult) |`n"
        }
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

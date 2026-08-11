function Test-AuExoRejectDirectSend {
    <#
    .SYNOPSIS
    Checks if direct send is configured to reject

    .DESCRIPTION
    Attackers can exploit direct send to send spam or phishing emails without authentication.
    Direct Send covers anonymous messages (unauthenticated messages) sent from your own domain
    to your organization's mailboxes using the tenant MX

    .EXAMPLE
    Test-AuExoRejectDirectSend

    Returns true if direct send is configured to reject

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuExoRejectDirectSend
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    try {
        Write-Verbose "Getting Organization..."
        $organizationConfig = Get-AuExo -Request OrganizationConfig

        $result = $organizationConfig.RejectDirectSend

        if ($result) {
            $testResultMarkdown = "Well done. RejectDirectSend is ``$($result)``.`n`n"
        } else {
            $testResultMarkdown = "``RejectDirectSend`` should be ``True``. RejectDirectSend is ``$($result)``.`n`n"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    return $result
}

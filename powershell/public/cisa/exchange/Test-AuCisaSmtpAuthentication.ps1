function Test-AuCisaSmtpAuthentication {
    <#
    .SYNOPSIS
    Checks state of SMTP authentication in Exchange Online.

    .DESCRIPTION
    SMTP authentication SHALL be disabled.

    .EXAMPLE
    Test-AuCisaSmtpAuthentication

    Returns true if SMTP authentication is disabled in Exchange Online.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSmtpAuthentication
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection ExchangeOnline)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    $config = Get-AuExo -Request TransportConfig

    $testResult = $config.SmtpClientAuthenticationDisabled

    $portalLink = "https://admin.exchange.microsoft.com/#/settings"
    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [SMTP Authentication]($portalLink) disabled."
    } else {
        $testResultMarkdown = "Your tenant has [SMTP Authentication]($portalLink) enabled."
    }

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

function Test-AuCisaSpamAlternative {
    <#
    .SYNOPSIS
    Checks state of spam filter

    .DESCRIPTION
    If a third-party party filtering solution is used, the solution SHOULD offer services comparable to the native spam filtering offered by Microsoft.

    .EXAMPLE
    Test-AuCisaSpamAlternative

    Always returns $null

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpamAlternative
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection ExchangeOnline)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }elseif(!(Test-AuConnection SecurityCompliance)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    }else{
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Unable to validate 3rd party solutions."
        return $null
    }
}

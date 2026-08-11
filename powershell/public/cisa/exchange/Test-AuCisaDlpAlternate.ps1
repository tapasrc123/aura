function Test-AuCisaDlpAlternate {
    <#
    .SYNOPSIS
    This will always return $null

    .DESCRIPTION
    The selected DLP solution SHOULD offer services comparable to the native DLP solution offered by Microsoft.

    .EXAMPLE
    Test-AuCisaDlpAlternate

    Always will return $null

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaDlpAlternate
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    #Add License Check
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

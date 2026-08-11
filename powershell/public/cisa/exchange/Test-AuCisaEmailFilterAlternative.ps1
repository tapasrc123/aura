function Test-AuCisaEmailFilterAlternative {
    <#
    .SYNOPSIS
    Placeholder

    .DESCRIPTION
    Alternatively chosen filtering solutions SHOULD offer services comparable to Microsoft Defender's Common Attachment Filter.

    .EXAMPLE
    Test-AuCisaEmailFilterAlternative

    Always returns null

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaEmailFilterAlternative
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    } elseif (!(Test-AuConnection SecurityCompliance)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    } elseif ( 'Eop' -in (Get-AuLicenseInformation -Product Eop) -or 'Eop' -in (Get-AuLicenseInformation -Product MdoV2) ) {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Tenant is licensed for Exchange Online Protection; an alternative mail filter is not needed."
        return $null
    } else {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "Tenant is not licensed for Exchange Online Protection and there is no implementation to check for alternate mail filters available."
        return $null
    }
}

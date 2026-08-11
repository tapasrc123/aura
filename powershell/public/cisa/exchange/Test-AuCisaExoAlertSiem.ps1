function Test-AuCisaExoAlertSiem {
    <#
    .SYNOPSIS
    Checks state of alerts

    .DESCRIPTION
    Alerts SHOULD be sent to a monitored address or incorporated into a security information and event management (SIEM) system.

    .EXAMPLE
    Test-AuCisaExoAlertSiem

    Returns null

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaExoAlertSiem
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
    } elseif("P1" -notin (Get-AuLicenseInformation -Product MdoV2)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedMdoP1
        return $null
    } else {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason 'Not available for API validation.'
        return $null
    }
}

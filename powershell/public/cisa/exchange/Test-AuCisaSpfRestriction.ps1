function Test-AuCisaSpfRestriction {
    <#
    .SYNOPSIS
    Checks state of SPF records for all exo domains

    .DESCRIPTION
    A list of approved IP addresses for sending mail SHALL be maintained.

    .EXAMPLE
    Test-AuCisaSpfRestriction

    Returns true if SPF record exists and has a fail all modifier for all exo domains

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpfRestriction
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "This test has been deprecated by CISA as of May 2024 (MS.EXO.2.1v1)."
    return $null
}

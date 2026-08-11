function Test-AuCisaAppGroupOwnerConsent {
    <#
    .SYNOPSIS
    Checks if group owners can consent to apps

    .DESCRIPTION
    Group owners SHALL NOT be allowed to consent to applications.

    .EXAMPLE
    Test-AuCisaAppGroupOwnerConsent

    Returns true if disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaAppGroupOwnerConsent
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "This test has been deprecated by CISA as of March 2025 (MS.AAD.5.4v1)."
    return $null
}

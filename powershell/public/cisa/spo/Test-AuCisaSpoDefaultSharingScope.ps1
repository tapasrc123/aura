function Test-AuCisaSpoDefaultSharingScope {
    <#
    .SYNOPSIS
    Checks state of default SharePoint Online sharing scope

    .DESCRIPTION
    Default sharing scope SHOULD be set to Specific People (Only the people the user specifies).

    .EXAMPLE
    Test-AuCisaSpoDefaultSharingScope

    Returns true if default sharing scope is restricted to specific people

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoDefaultSharingScope
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    try {
        $spoTenant = Get-AuSpo

        # DefaultSharingLinkType: None = default (not explicitly set), Direct = Specific People, Internal = Organization, AnonymousAccess = Anyone
        $testResult = $spoTenant.DefaultSharingLinkType -eq "Direct"

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant default sharing scope is set to Specific People."
        } else {
            $testResultMarkdown = "Your tenant default sharing scope is not set to Specific People.`n`n* Current setting: ``$($spoTenant.DefaultSharingLinkType)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity Medium

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

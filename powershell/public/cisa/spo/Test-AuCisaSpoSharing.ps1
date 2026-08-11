function Test-AuCisaSpoSharing {
    <#
    .SYNOPSIS
    Checks state of SharePoint Online sharing

    .DESCRIPTION
    External sharing for SharePoint SHALL be limited to Existing guests or Only People in your organization.

    .EXAMPLE
    Test-AuCisaSpoSharing

    Returns true if sharing is restricted

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoSharing
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

        $testResult = $spoTenant.SharingCapability -in @("Disabled", "ExistingExternalUserSharingOnly")

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant restricts SharePoint Online sharing."
        } else {
            $testResultMarkdown = "Your tenant does not restrict SharePoint Online sharing.`n`n* Current setting: ``$($spoTenant.SharingCapability)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity High

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

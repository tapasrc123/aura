function Test-AuCisaSpoOneDriveSharing {
    <#
    .SYNOPSIS
    Checks state of OneDrive sharing

    .DESCRIPTION
    External sharing for OneDrive SHALL be limited to Existing guests or Only People in your organization.

    .EXAMPLE
    Test-AuCisaSpoOneDriveSharing

    Returns true if OneDrive sharing is restricted

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoOneDriveSharing
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

        # OneDriveSharingCapability: Disabled, ExistingExternalUserSharingOnly, ExternalUserSharingOnly, ExternalUserAndGuestSharing
        $testResult = $spoTenant.OneDriveSharingCapability -in @("Disabled", "ExistingExternalUserSharingOnly")

        if ($testResult) {
            $testResultMarkdown = "Well done. OneDrive sharing is restricted."
        } else {
            $testResultMarkdown = "OneDrive sharing is not restricted.`n`n* Current setting: ``$($spoTenant.OneDriveSharingCapability)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity High

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

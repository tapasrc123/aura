function Test-AuCisaSpoSharingAllowedDomain {
    <#
    .SYNOPSIS
    Checks state of SharePoint Online sharing

    .DESCRIPTION
    External sharing SHALL be restricted to approved external domains and/or users in approved security groups per interagency collaboration needs.

    .EXAMPLE
    Test-AuCisaSpoSharingAllowedDomain

    Returns true if sharing uses restricted domains

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaSpoSharingAllowedDomain
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

        if ($spoTenant.SharingCapability -eq "Disabled") {
            Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "SharePoint Online external sharing is disabled."
            return $null
        }

        $testResult = $spoTenant.SharingDomainRestrictionMode -eq 'AllowList'

        if ($testResult) {
            $allowedDomains = $spoTenant.SharingAllowedDomainList -split ' ' | Where-Object { $_ -ne '' }
            $domainList = ($allowedDomains | ForEach-Object { "* $_" }) -join "`n"
            $testResultMarkdown = "Well done. Your tenant restricts SharePoint Online sharing to approved domains.`n`n$domainList"
        } else {
            $testResultMarkdown = "Your tenant does not restrict SharePoint Online sharing to approved domains.`n`n* Current restriction mode: ``$($spoTenant.SharingDomainRestrictionMode)``"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown -Severity Medium

        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

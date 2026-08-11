function Test-AuCisGitHubStrictBasePermission {
    <#
    .SYNOPSIS
    CIS.GH.1.3.8: Ensure strict base permissions are set for repositories.

    .DESCRIPTION
    CIS GitHub Benchmark v1.2.0 section 1.3.8 marks this recommendation as
    Manual. This test automates the organization default repository permission
    exposed by GET /orgs/{org} and requires the value to be none or read.

    .EXAMPLE
    Test-AuCisGitHubStrictBasePermission

    Returns true when default_repository_permission is none or read.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisGitHubStrictBasePermission
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection GitHub)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGitHub
        return $null
    }

    try {
        Write-Verbose 'Retrieving GitHub organization settings for CIS.GH.1.3.8.'
        $org = Get-AuGitHubOrganization
        $field = 'default_repository_permission'
        if (-not (Test-AuGitHubObjectProperty -InputObject $org -PropertyName $field)) {
            Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason "GitHub organization response did not include required field '$field'. This field is required to evaluate CIS.GH.1.3.8 and may be missing because of permissions, plan, API version, or organization type."
            return $null
        }

        $allowedValues = @('none', 'read')
        $actual = [string]$org.$field
        $result = $allowedValues -contains $actual
        $resultMarkdown = @"
CIS.GH.1.3.8 automated evidence from ``GET /orgs/{org}``.

| Field | Actual | Expected |
| --- | --- | --- |
| ``$field`` | ``$actual`` | ``none`` or ``read`` |
"@
        Add-AuTestResultDetail -Result $resultMarkdown
        return $result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

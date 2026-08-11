function Get-AuGitHubOrganization {
    <#
    .SYNOPSIS
    Internal: Gets the connected GitHub organization object using the session cache.
    #>
    [CmdletBinding()]
    param()

    if ($null -eq $__AuSession.GitHubConnection -or
        $__AuSession.GitHubConnection.Connected -ne $true) {
        throw "Not connected to GitHub. Call Connect-AuGitHub first."
    }

    # Connect-AuGitHub stores the raw organization login; encode it here for the path segment.
    $encodedOrg = [System.Uri]::EscapeDataString($__AuSession.GitHubConnection.Organization)
    Invoke-AuGitHubRequest -RelativeUri "/orgs/$encodedOrg"
}

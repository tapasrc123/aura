function Request-AuGitHubAppOrganizationInstall {
    <#
    .SYNOPSIS
    Guides an interactive user through installing or approving the Aura GitHub App for an organization.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Consistent with other Connect-* interactive flows')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Organization,

        [Parameter(Mandatory = $true)]
        [string] $InstallUrl,

        [Parameter(Mandatory = $false)]
        [string] $Reason,

        [Parameter(Mandatory = $false)]
        [string] $TokenDocsUrl = 'https://aura.onetapas.com/docs/commands/Connect-AuGitHub'
    )

    if (-not (Get-AuUserInteractive)) {
        return $false
    }

    Write-Host ''
    Write-Host "The Aura GitHub App must be installed or approved for organization '$Organization' before Aura can read organization settings." -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($Reason)) {
        Write-Host "GitHub API: $Reason" -ForegroundColor DarkGray
    }
    Write-Host "If you continue, Aura will open the GitHub App install page: $InstallUrl" -ForegroundColor Yellow
    Write-Host "GitHub will ask you to select '$Organization' and install, request, or approve the app. Aura will retry the connection after you finish." -ForegroundColor Yellow

    $response = Read-Host "Open the GitHub App install page now? [Y/n]"
    if (-not [string]::IsNullOrWhiteSpace($response) -and $response -notmatch '^(?i:y|yes)$') {
        Write-Host ''
        Write-Host 'No problem. You can use a GitHub token instead of the Aura GitHub App.' -ForegroundColor Yellow
        Write-Host 'Create a classic PAT with admin:org, or a fine-grained token with Organization Members: read and Organization Administration: read.' -ForegroundColor Yellow
        Write-Host 'Then reconnect with one of these options:' -ForegroundColor Yellow
        Write-Host '  $token = Read-Host "GitHub token" -AsSecureString' -ForegroundColor Cyan
        Write-Host "  Connect-AuGitHub -Organization '$Organization' -Token `$token" -ForegroundColor Cyan
        Write-Host "  `$env:AURA_GITHUB_TOKEN = '<token>'; Connect-AuGitHub -Organization '$Organization'" -ForegroundColor Cyan
        Write-Host "See the Aura docs for token-based GitHub auth: $TokenDocsUrl" -ForegroundColor Yellow
        return $false
    }

    $opened = Open-AuBrowserUrl -Uri $InstallUrl
    if ($opened) {
        Write-Host "Opened the Aura GitHub App install page in your browser." -ForegroundColor Yellow
    } else {
        Write-Host "Open the Aura GitHub App install page: $InstallUrl" -ForegroundColor Yellow
    }
    Write-Host "Select '$Organization', then install or request/approve the app for the organization." -ForegroundColor Yellow
    $null = Read-Host "Press Enter after the Aura GitHub App is installed or approved for '$Organization' to retry"
    return $true
}

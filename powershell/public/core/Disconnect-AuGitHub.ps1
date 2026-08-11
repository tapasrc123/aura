function Disconnect-AuGitHub {
    <#
    .SYNOPSIS
    Clears the current GitHub REST session in Aura.

    .DESCRIPTION
    Removes the GitHub auth header, the connection metadata, and the per-session
    REST response cache from the Aura module's session state. Idempotent — safe to call when
    no GitHub session is active.

    Use this when you want to drop the in-memory token, switch organizations, or clean up
    troubleshooting state. Disconnect-Aura also clears this state; Disconnect-AuGraph
    preserves GitHub state.

    .EXAMPLE
    Disconnect-AuGitHub

    Clears any active GitHub session.

    .LINK
    https://aura.onetapas.com/docs/commands/Disconnect-AuGitHub
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Consistent with other Connect/Disconnect-* functions')]
    [CmdletBinding()]
    param()

    $hadState = ($null -ne $__AuSession.GitHubConnection) -or ($null -ne $__AuSession.GitHubAuthHeader)

    $__AuSession.GitHubConnection = $null
    $__AuSession.GitHubAuthHeader = $null
    $__AuSession.GitHubCache = @{}

    if ($hadState) {
        Write-Host 'Disconnected from GitHub.' -ForegroundColor Green
    } else {
        Write-Verbose 'No GitHub session to disconnect.'
    }
}

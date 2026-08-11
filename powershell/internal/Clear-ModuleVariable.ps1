function Clear-ModuleVariable {
    <#
    .SYNOPSIS
    Resets all module variables to their default values.

    .DESCRIPTION
    Variables like $AuGraphCache and $AuGraphBaseUri are module-level variables that are cached
    during the running of a test for performance reasons.

    This function will be called for each fresh run of Invoke-Aura.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Module variables used in other functions.')]
    param()

    Clear-AuGraphCache
    $__AuSession.GraphBaseUri = $null
    $__AuSession.TestResultDetail = @{}
    $__AuSession.AuraConfig = $null
    $__AuSession.AdminPortalUrl = @{}
    Clear-AuDnsCache
    Clear-AuExoCache
    Clear-AuADCache
    $__AuSession.AIAgentInfo = $null
    $__AuSession.AzureDevOpsConnectionCache = $null
    # Invoke-Aura resets the per-run cache but preserves the existing GitHub session.
    # Disconnect-AuGitHub, including through Disconnect-Aura, owns clearing GitHubConnection and GitHubAuthHeader.
    $__AuSession.GitHubCache = @{}
    $__AuSession.SpoCache = @{}
    # $__AuSession.Connections = @() # Do not clear connections as they are used to track the connection state. This module variable should only be set by Connect-Aura and Disconnect-Aura.
}

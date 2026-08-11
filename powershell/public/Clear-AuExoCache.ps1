function Clear-AuExoCache {
    <#
    .SYNOPSIS
    Resets the local cache of Exchange Online queries. Use this if you need to force a refresh of the cache in the current session.

    .DESCRIPTION
    By default all requests are cached and re-used for the duration of the session.

    Use this function to clear the cache and force a refresh of the data.

    .EXAMPLE
    Clear-AuExoCache

    This example clears the cache of all EXO requests.

    .LINK
    https://aura.onetapas.com/docs/commands/Clear-AuExoCache
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Setting module level variable')]
    [CmdletBinding()]
    param()

    Write-Verbose -Message "Clearing the results for EXO requests in this session"

    $__AuSession.ExoCache = @{}
    $__AuSession.OrcaCache = @{}
}

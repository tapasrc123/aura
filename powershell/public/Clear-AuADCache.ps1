function Clear-AuADCache {
    <#
    .SYNOPSIS
    Resets the local cache of Active Directory data. Use this if you need to force a refresh of the cache in the current session.

    .DESCRIPTION
    By default all Active Directory data is cached and re-used for the duration of the session.

    Use this function to clear the cache and force a refresh of the data from Active Directory.

    .EXAMPLE
    Clear-AuADCache

    This example clears the cache of all Active Directory data.

    .LINK
    https://aura.onetapas.com/docs/commands/Clear-AuADCache
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='Setting module level variable')]
    [CmdletBinding()]
    param()

    Write-Verbose -Message "Clearing the results cached from Active Directory in this session"

    $__AuSession.ADCache = @{}
    $__AuSession.ADCollectionTime = $null
}

function Test-AuCisTeamsLobbyBypass {
    <#
    .SYNOPSIS
    Ensure only people in my org can bypass the lobby

    .DESCRIPTION
    Only people in my org can bypass the lobby
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisTeamsLobbyBypass

    Returns true if only people in my org can bypass the lobby

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisTeamsLobbyBypass
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Test-AuConnection Teams)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedTeams
        return $null
    }

    Write-Verbose 'Test-AuCisTeamsLobbyBypass: Testing if only people in my org can bypass the lobby'
    try {
        $TeamsMeetingPolicy = Get-CsTeamsMeetingPolicy -Identity Global | Select-Object -ExpandProperty AutoAdmittedUsers
        if ($TeamsMeetingPolicy -eq 'InvitedUsers' -or $TeamsMeetingPolicy -eq 'EveryoneInCompanyExcludingGuests' -or $TeamsMeetingPolicy -eq 'OrganizerOnly') {
            Add-AuTestResultDetail -Result 'Well done. Only people in your org can bypass the lobby.'
            return $true
        } else {
            Add-AuTestResultDetail -Result "Following people can bypass your lobby: '$($TeamsMeetingPolicy)'."
            return $false
        }
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Test-AuCisaGuestInvitation {
    <#
    .SYNOPSIS
    Checks if guest invitations are restricted to admins

    .DESCRIPTION
    Only users with the Guest Inviter role SHOULD be able to invite guest users.

    .EXAMPLE
    Test-AuCisaGuestInvitation

    Returns true if guest invitations are restricted to admins

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaGuestInvitation
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $result = Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $testResult = ($result.allowInvitesFrom -eq "adminsAndGuestInviters") -or ($result.allowInvitesFrom -eq "none")

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant restricts who can invite guests:`n`nallowInvitesFrom : $($result.allowInvitesFrom)"
    } else {
        $testResultMarkdown = "Your tenant allows anyone to invite guests.`n`nallowInvitesFrom : $($result.allowInvitesFrom)"
    }
    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}

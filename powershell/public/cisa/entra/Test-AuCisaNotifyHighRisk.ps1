function Test-AuCisaNotifyHighRisk {
    <#
    .SYNOPSIS
    Checks if Risk Based Policies - MS.AAD.2.2v1 has recipients

    .DESCRIPTION
    A notification SHOULD be sent to the administrator when high-risk users are detected.

    Queries /identityProtection/settings/notifications
    and returns the result of
    (graph/identityProtection/settings/notifications)

    .EXAMPLE
    Test-AuCisaNotifyHighRisk

    Returns the result of (graph.microsoft.com/beta/identityProtection/settings/notifications)

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaNotifyHighRisk
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-AuLicenseInformation -Product EntraID
    if($EntraIDPlan -ne "P2"){
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return $null
    }

    #Connect-MgGraph -UseDeviceCode -Scopes IdentityRiskEvent.Read.All
    $result = Invoke-AuGraphRequest -RelativeUri "identityProtection/settings/notifications" -ApiVersion "beta"

    $notficationRecipients =  ($result.notificationRecipients + $result.additionalRecipients) | Where-Object {`
            $_.isRiskyUsersAlertsRecipient }

    $testResult = ($notficationRecipients|Measure-Object).Count -ge 1

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more recipients for notifications of risky user logins:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any recipients for notifications of risky user logins."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType IdentityProtection -GraphObjects $notficationRecipients

    return $testResult
}

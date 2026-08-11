function Test-AuGsaPrivateAccessAppNotOnDefaultConnectorGroup {
    <#
    .SYNOPSIS
        Checks that no Entra Private Access application is served by the Default connector group.

    .DESCRIPTION
        Newly installed Microsoft Entra private network connectors automatically join the Default
        connector group. If an application is served by the Default group, a freshly installed or
        misconfigured connector immediately begins handling its traffic - a routing and outage risk.
        The Default group should stay an idle / onboarding pool, and every Private Access application
        should be served through a dedicated connector group.

    .EXAMPLE
        Test-AuGsaPrivateAccessAppNotOnDefaultConnectorGroup

        Returns $true if no Entra Private Access application is assigned to the Default connector group.

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuGsaPrivateAccessAppNotOnDefaultConnectorGroup
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    Write-Verbose "Running Test-AuGsaPrivateAccessAppNotOnDefaultConnectorGroup..."

    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    if ((Get-AuLicenseInformation -Product EntraID) -eq 'Free') {
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    try {
        $apps = Get-AuPrivateAccessApplication
        if (-not $apps) {
            Add-AuTestResultDetail -Result 'No Entra Private Access applications were found in this tenant.'
            return $null
        }

        # Resolve each app and its connector group. Unresolved apps or Graph failures propagate to the
        # outer catch (indeterminate / skip) rather than being silently treated as "not on Default".
        $onDefault = @()
        foreach ($app in $apps) {
            $appObject = Invoke-AuGraphRequest -RelativeUri 'applications' -Filter "appId eq '$($app.appId)'" -ApiVersion beta | Select-Object -First 1
            $connectorGroup = Invoke-AuGraphRequest -RelativeUri "applications/$($appObject.id)/connectorGroup" -ApiVersion beta -ErrorAction Stop

            if ($connectorGroup -and $connectorGroup.isDefault -eq $true) {
                $onDefault += $app
            }
        }

        $result = ($onDefault.Count -eq 0)
        if ($result) {
            $testResult = "Well done. No Entra Private Access application is assigned to the **Default** connector group.`n`n"
        } else {
            $testResult = "These Entra Private Access applications are served by the **Default** connector group. New connectors auto-join Default, so move them to a dedicated connector group:`n`n"
            foreach ($app in $onDefault) {
                $testResult += "* $($app.displayName)`n"
            }
        }

        Add-AuTestResultDetail -Result $testResult
        return $result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Test-AuEntraMsolPowerShellBlocked {
    <#
    .SYNOPSIS
    Checks if the legacy MSOnline (MSOL) PowerShell module is blocked from authenticating to the tenant

    .DESCRIPTION
    The MSOnline (MSOL) and Azure AD PowerShell modules were retired by Microsoft and no longer receive
    security updates. The blockMsolPowerShell setting on the tenant's authorization policy lets an admin
    explicitly block authentication requests from the legacy MSOnline PowerShell module's service
    principal, closing an unsupported and unmonitored administrative access path.

    This setting isn't enabled by default for every tenant, so it needs to be checked explicitly rather
    than assumed to already be in place.

    .EXAMPLE
    Test-AuEntraMsolPowerShellBlocked

    Returns true if the legacy MSOnline (MSOL) PowerShell module is blocked from authenticating to the tenant

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuEntraMsolPowerShellBlocked
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    Write-Verbose "Checking if the legacy MSOnline (MSOL) PowerShell module is blocked..."
    try {
        $authorizationPolicy = Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -Select "blockMsolPowerShell" -ErrorAction Stop

        $msolPowerShellBlocked = $authorizationPolicy.blockMsolPowerShell -eq $true

        if ($msolPowerShellBlocked) {
            $testResult = "Well done. The legacy MSOnline (MSOL) PowerShell module is blocked from authenticating to this tenant."
        } else {
            $testResult = "The legacy MSOnline (MSOL) PowerShell module is **not** blocked for this tenant.`n`n" `
                + "The MSOnline module was retired by Microsoft and no longer receives security updates, so leaving it unblocked keeps an unsupported and unmonitored administrative access path open."
        }
        Add-AuTestResultDetail -Result $testResult
        return $msolPowerShellBlocked
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 403) {
            Add-AuTestResultDetail -SkippedBecause NotAuthorized
        } else {
            Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        }
        return $null
    }
}

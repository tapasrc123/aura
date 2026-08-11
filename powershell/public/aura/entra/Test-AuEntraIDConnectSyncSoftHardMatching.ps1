function Test-AuEntraIDConnectSyncSoftHardMatching {
    <#
    .SYNOPSIS
    Ensure soft and hard matching for on-premises synchronization objects is blocked

    .DESCRIPTION
    Soft and hard matching for on-premises synchronization objects is a feature that allows Entra ID to match users based on their userprincipalname, email address or other attributes.
    This can lead to unintended consequences, such as mismatching user data.

    .EXAMPLE
    Test-AuEntraIDConnectSyncSoftHardMatching

    Returns true if soft and hard matching is blocked / disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuEntraIDConnectSyncSoftHardMatching
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }
    $return = $true

    Write-Verbose "Checking if on-premises directory synchronization soft- and hard-match is blocked..."
    try {
        $organizationConfig = Invoke-AuGraphRequest -RelativeUri "organization"
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
    if ($organizationConfig.onPremisesSyncEnabled -ne $true) {
        Add-AuTestResultDetail -SkippedBecause 'Custom' -SkippedCustomReason 'OnPremisesSynchronization is not configured'
        return $null
    }

    try {
        $onPremisesSynchronizationConfig = Invoke-AuGraphRequest -RelativeUri "directory/onPremisesSynchronization"
        $passResult = "✅ Pass"
        $failResult = "❌ Fail"

        $result = "| Policy | Value | Status |`n"
        $result += "| --- | --- | --- |`n"

        if ($onPremisesSynchronizationConfig.features.blockSoftMatchEnabled -eq $false) {
            $result += "| Block soft-match | $($onPremisesSynchronizationConfig.features.blockSoftMatchEnabled) | $failResult |`n"
            $return = $false
        } else {
            $result += "| Block soft-match | $($onPremisesSynchronizationConfig.features.blockSoftMatchEnabled) | $passResult |`n"
        }
        if ($onPremisesSynchronizationConfig.features.blockCloudObjectTakeoverThroughHardMatchEnabled -eq $false) {
            $result += "| Block hard-match | $($onPremisesSynchronizationConfig.features.blockCloudObjectTakeoverThroughHardMatchEnabled) | $failResult |`n"
            $return = $false
        } else {
            $result += "| Block hard-match | $($onPremisesSynchronizationConfig.features.blockCloudObjectTakeoverThroughHardMatchEnabled) | $passResult |`n"
        }

        if ($return) {
            $testResult = "Well done. On-premises directory synchronization soft- and hard-match is blocked.`n`n$($result)"
            Add-AuTestResultDetail -Result $testResult
        } else {
            $testResult = "On-premises directory synchronization soft-match and / or hard-match is allowed.`n`n$($result)"
            Add-AuTestResultDetail -Result $testResult
        }
        return $return
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 403) {
            Add-AuTestResultDetail -SkippedBecause NotAuthorized
        } else {
            Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        }
        return $null
    }
}

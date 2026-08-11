function Test-AuDeviceRegistrationLocalAdminsGlobalAdmin {
    <#
    .SYNOPSIS
    Tests whether Global Administrators are configured as local administrators on devices during Microsoft Entra join.

    .DESCRIPTION
    Global Administrator role should not be added as local administrator on the device during Microsoft Entra join.

    .EXAMPLE
    Test-AuDeviceRegistrationLocalAdminsGlobalAdmin
    Returns true if Global Administrators are not configured as local administrators on devices during Microsoft Entra join, false if they are, and null if the test could not be completed.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuDeviceRegistrationLocalAdminsGlobalAdmin
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose 'Testing Entra Device Registration Policy configuration for Entra Join local admin settings'
    if (-not (Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }
    try {
        $deviceRegistrationPolicy = @(Invoke-AuGraphRequest -RelativeUri 'policies/deviceRegistrationPolicy' -ApiVersion beta)
        $testResult = '```' + "`n"
        $testResult += $deviceRegistrationPolicy.azureADJoin.localAdmins | ConvertTo-Json
        $testResult += "`n"
        $testResult += '```'
        Add-AuTestResultDetail -Result $testResult
        return $deviceRegistrationPolicy.azureADJoin.localAdmins.enableGlobalAdmins -eq $false
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

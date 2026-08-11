function Test-AuDeviceRegistrationLocalAdminsRegisteringUser {
    <#
    .SYNOPSIS
    Tests whether registering users are configured as local administrators on devices during Microsoft Entra join.

    .DESCRIPTION
    Registering users should not be added as local administrators on the device during Microsoft Entra join.

    .EXAMPLE
    Test-AuDeviceRegistrationLocalAdminsRegisteringUser

    Returns true if registering users are not configured as local administrators on devices during Microsoft Entra join, false if they are, and null if the test could not be completed.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuDeviceRegistrationLocalAdminsRegisteringUser
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose 'Testing Entra Device Registration Policy configuration for Entra Join local admin settings'
    if(-not (Test-AuConnection Graph)){
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
        return $deviceRegistrationPolicy.azureADJoin.localAdmins.registeringUsers.'@odata.type' -eq '#microsoft.graph.noDeviceRegistrationMembership'
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

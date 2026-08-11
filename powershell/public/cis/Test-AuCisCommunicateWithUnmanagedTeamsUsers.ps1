function Test-AuCisCommunicateWithUnmanagedTeamsUsers {
    <#
    .SYNOPSIS
    Ensure communication with unmanaged Teams users is disabled

    .DESCRIPTION
    Communication with unmanaged Teams users is disabled
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisCommunicateWithUnmanagedTeamsUsers

    Returns true if communication with unmanaged Teams users is disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisCommunicateWithUnmanagedTeamsUsers
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This test checks multiple users.')]
    param()

    if (-not (Test-AuConnection Teams)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedTeams
        return $null
    }

    Write-Verbose 'Test-AuCisCommunicateWithUnmanagedTeamsUsers: Checking if communication with unmanaged Teams users is disabled'

    try {
        $AllowTeamsConsumer = Get-CsTenantFederationConfiguration | Select-Object -ExpandProperty AllowTeamsConsumer
        if ($AllowTeamsConsumer -eq $false) {
            Add-AuTestResultDetail -Result 'Well done. Communication with unmanaged Teams users is disabled.'
            return $true
        } else {
            $ExternalAccessPolicy = Get-CsExternalAccessPolicy -Identity Global
            if ($ExternalAccessPolicy.EnableTeamsConsumerAccess -eq $false) {
                Add-AuTestResultDetail -Result 'Well done. Communication with unmanaged Teams users is disabled.'
                return $true
            } else {
                Add-AuTestResultDetail -Result 'Communication with unmanaged Teams users is enabled.'
                return $false
            }
        }
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

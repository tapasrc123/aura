function Test-AuCisCommunicateInitiateExternalTeamsUsers {
    <#
    .SYNOPSIS
    Ensure external Teams users cannot initiate conversations

    .DESCRIPTION
    External Teams users cannot initiate conversations
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisCommunicateInitiateExternalTeamsUsers

    Returns true if external Teams users cannot initiate conversations

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisCommunicateInitiateExternalTeamsUsers
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This test checks multiple users.')]
    param()

    if (-not (Test-AuConnection Teams)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedTeams
        return $null
    }

    Write-Verbose 'Test-AuCisCommunicateInitiateExternalTeamsUsers: Checking if external unmanaged Teams users cannot initiate conversations'

    try {
        $AllowTeamsConsumerInbound = Get-CsTenantFederationConfiguration | Select-Object -ExpandProperty AllowTeamsConsumerInbound
        if ($AllowTeamsConsumerInbound -eq $false) {
            Add-AuTestResultDetail -Result 'Well done. External unmanaged Teams users cannot initiate conversations.'
            return $true
        }
        else {
            $ExternalAccessPolicy = Get-CsExternalAccessPolicy -Identity Global
            if ($ExternalAccessPolicy.EnableTeamsConsumerInbound -eq $false) {
                Add-AuTestResultDetail -Result 'Well done. External unmanaged Teams users cannot initiate conversations.'
                return $true
            }
            else {
                Add-AuTestResultDetail -Result 'External unmanaged Teams users can initiate conversations.'
                return $false
            }
        }
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

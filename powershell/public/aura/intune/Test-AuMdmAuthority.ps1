function Test-AuMdmAuthority {
    <#
    .SYNOPSIS
    Check the MDM Authority for Intune.
    .DESCRIPTION
    This command checks the Mobile Device Management (MDM) Authority setting in Microsoft Intune to determine if Intune is the configured MDM authority.

    .EXAMPLE
    Test-AuMdmAuthority

    Returns true if Intune is set as the MDM authority, false otherwise.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuMdmAuthority
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose 'Testing MDM Authority...'
    if (-not (Get-AuLicenseInformation -Product Intune)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedIntune
        return $null
    }

    try {
        Write-Verbose 'Retrieving MDM Authority status...'
        $org = Invoke-AuGraphRequest -RelativeUri 'organization' -ApiVersion beta
        $detailedOrgInfo = Invoke-AuGraphRequest -RelativeUri "organization/$($org.id)?`$select=mobiledevicemanagementauthority" -ApiVersion beta
        Add-AuTestResultDetail -Result ('MDM Authority is set to: {0}' -f $detailedOrgInfo.mobileDeviceManagementAuthority)
        return $detailedOrgInfo.mobileDeviceManagementAuthority -eq 'intune'
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Test-AuTenantCustomization {
    <#
    .SYNOPSIS
    Check the Intune Tenant Customization.
    .DESCRIPTION
    This command checks the Intune Tenant Customization settings, specifically the Default Branding Profile, to determine if it has been customized.

    .EXAMPLE
    Test-AuTenantCustomization

    Returns true if the Default Branding Profile is customized or if custom branding profiles exist.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuTenantCustomization
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Get-AuLicenseInformation -Product Intune)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedIntune
        return $null
    }

    try {
        Write-Verbose 'Retrieving Intune Branding Profiles status...'
        $brandingProfiles = Invoke-AuGraphRequest -RelativeUri 'deviceManagement/intuneBrandingProfiles' -ApiVersion beta
        $defaultProfile = $brandingProfiles | Where-Object { $_.isDefaultProfile }

        # displayName is reflected as 'Organization name' in the portal
        $defaultProfileIsCustomized = -not ([string]::IsNullOrEmpty($defaultProfile.displayName) -and [string]::IsNullOrEmpty($defaultProfile.privacyUrl))

        $testResultMarkdown = ""
        if ($defaultProfileIsCustomized) {
            $testResultMarkdown = "The Default Branding Profile is customized or at least one custom branding profile exists."

            if (-not [string]::IsNullOrEmpty($defaultProfile.displayName)) {
                $testResultMarkdown += "`n- Organization Name is set to '$($defaultProfile.displayName)'."
            }
        } else {
            $testResultMarkdown = "The Default Branding Profile is not customized."
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $defaultProfileIsCustomized -or $brandingProfiles.Count -gt 1
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

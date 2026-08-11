function Test-AuDeviceComplianceSettings {
    <#
    .SYNOPSIS
    Ensure the built-in Device Compliance Policy marks devices with no compliance policy assigned as 'Not compliant'

    .DESCRIPTION
    The built-in Device Compliance Policy should mark devices with no compliance policy assigned as 'Not compliant'


    .EXAMPLE
    Test-AuDeviceComplianceSettings

    Returns true if the device compliance settings are configured

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuDeviceComplianceSettings
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This test checks multiple settings.')]
    param()

    if (-not (Get-AuLicenseInformation -Product Intune)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedIntune
        return $null
    }

    try {
        $deviceComplianceSettings = Invoke-AuGraphRequest -RelativeUri 'deviceManagement/settings' -ApiVersion beta
        Write-Verbose "Device Compliance Settings: $deviceComplianceSettings"
        if ($deviceComplianceSettings.secureByDefault -ne $true) {
            $testResultMarkdown = "Your Intune built-in Device Compliance Policy **incorrectly** marks devices with no compliance policy assigned as 'Compliant'."
            $return = $false
        } else {
            $testResultMarkdown = "Well done. Your Intune built-in Device Compliance Policy marks devices with no compliance policy assigned as 'Not compliant'."
            $return = $true
        }
        Add-AuTestResultDetail -Result $testResultMarkdown
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

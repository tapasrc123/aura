function Test-AuManagedDeviceCleanupSettings {
    <#
    .SYNOPSIS
    Ensure device clean-up rule is configured

    .DESCRIPTION
    The device clean-up rule should be configured

    .EXAMPLE
    Test-AuManagedDeviceCleanupSettings

    Returns true if the device clean-up rule is configured

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuManagedDeviceCleanupSettings
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This test refers to multiple settings.')]
    param()

    Write-Verbose 'Testing device clean-up rule configuration'
    if (-not (Get-AuLicenseInformation -Product Intune)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedIntune
        return $null
    }

    try {
        $deviceCleanupSettings = Invoke-AuGraphRequest -RelativeUri 'deviceManagement/managedDeviceCleanupRules' -ApiVersion beta
        if ((-not $deviceCleanupSettings.deviceInactivityBeforeRetirementInDays) -or ($deviceCleanupSettings.deviceInactivityBeforeRetirementInDays -eq 0)) {
            $testResultMarkdown = 'No Intune device clean-up rule is configured.'
            $return = $false
        } else {
            $testResultMarkdown = "Well done. At least one Intune device clean-up rule is configured.`n"
            $testResultMarkdown += "| Name | Platform | Days to retire |`n"
            $testResultMarkdown += "| --- | --- | --- |`n"
            foreach ($setting in $deviceCleanupSettings) {
                $testResultMarkdown += "| $($setting.displayName) | $($setting.deviceCleanupRulePlatformType) | $($setting.deviceInactivityBeforeRetirementInDays) |`n"
            }
            $return = $true
        }
        Add-AuTestResultDetail -Result $testResultMarkdown
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Get-AuraConfigGlobalSetting {
    <#
    .SYNOPSIS
    Gets the global settings from the Aura config.
    .DESCRIPTION
    This function retrieves the value of the specified global setting from the Aura config.
    It returns the value of the specified global setting, which may be of any type depending on the configuration.
    .EXAMPLE
    $globalSettings = Get-AuraConfigGlobalSetting -SettingName 'EmergencyAccessAccounts'
    # This will return the global settings for the setting with name 'EmergencyAccessAccounts'.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The setting name of the configuration for which to retrieve the settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SettingName
    )

    # Check if the Aura config is loaded
    if (-not ($__AuSession -and $__AuSession.AuraConfig -and $__AuSession.AuraConfig.GlobalSettings )) {
        Write-Verbose "Aura global config not loaded. Please run Get-AuraConfig first to load the config."
        return $null
    } else {
        Write-Verbose "Aura global config loaded"
        Write-Verbose "Aura global config `"$SettingName`": $($__AuSession.AuraConfig.GlobalSettings.$SettingName | ConvertTo-Json -Depth 5 -Compress)"
    }

    # Retrieve the test settings from the Aura config
    return $__AuSession.AuraConfig.GlobalSettings.$SettingName
}

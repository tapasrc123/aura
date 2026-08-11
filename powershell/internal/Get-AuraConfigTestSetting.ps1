function Get-AuraConfigTestSetting {
    <#
    .SYNOPSIS
    Gets the test settings for a specific test ID from the Aura config.
    .DESCRIPTION
    This function retrieves the test settings for a specific test ID from the Aura config.
    It returns the settings as a hashtable, which can be used to customize the behavior of the test.
    .EXAMPLE
    $testSettings = Get-AuraConfigTestSetting -TestId 'Mt.1001'
    # This will return the test settings for the test with ID 'Mt.1001'.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The ID of the test for which to retrieve the settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TestId
    )

    # Check if the Aura config is loaded
    if (-not ($__AuSession -and $__AuSession.AuraConfig)) {
        Write-Verbose "Aura config not loaded. Please run Get-AuraConfig first to get config for TestId: $TestId"
        return $null
    }

    # Retrieve the test settings from the Aura config
    return $__AuSession.AuraConfig.TestSettingsHash[$TestId]
}

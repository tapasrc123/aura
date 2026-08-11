function Get-AuraConfig {
    <#
    .SYNOPSIS
    Reads the Aura config from (usually from the root of the ./tests directory)

    .DESCRIPTION
    This also uses the ./Custom/aura-config.json file if it exists and
    merges the settings, allowing users to override the default settings.
    The Custom/custom directory name is matched case-insensitively.

    .EXAMPLE
    $auraConfig = Get-AuraConfig -ConfigFilePath 'C:\path\to\aura-config.json'
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # Path to the Aura config file or the directory containing the config file (aura-config.json).
        [Parameter(Mandatory = $true)]
        $Path,

        # Optional tenant ID. When provided, looks for aura-config.{TenantId}.json first,
        # then falls back to aura-config.json.
        [Parameter(Mandatory = $false)]
        [string] $TenantId
    )

    Write-Verbose "Getting Aura config from $Path"

    # Helper to find a config file by name in a directory, walking up to 5 parent levels
    function Find-ConfigFile {
        param([string]$SearchPath, [string]$FileName)

        if (Test-Path $SearchPath -PathType Container) {
            $candidate = Join-Path -Path $SearchPath -ChildPath $FileName
            if (Test-Path -Path $candidate) { return $candidate }

            # Check tests subfolder
            $testsCandidate = Join-Path -Path (Join-Path -Path $SearchPath -ChildPath 'tests') -ChildPath $FileName
            if (Test-Path -Path $testsCandidate) { return $testsCandidate }

            # Walk up to 5 parent directories
            $currentDir = $SearchPath
            for ($i = 1; $i -le 5; $i++) {
                $parentDir = Split-Path -Path $currentDir -Parent
                if ($parentDir -eq $currentDir -or [string]::IsNullOrEmpty($parentDir)) { break }
                $currentDir = $parentDir
                $candidate = Join-Path -Path $currentDir -ChildPath $FileName
                if (Test-Path -Path $candidate) { return $candidate }
            }
        }

        return $null
    }

    function Find-CustomConfigFile {
        param([string]$ConfigDirectory)

        foreach ($customDirectoryName in @('Custom', 'custom')) {
            $customConfigPath = Join-Path -Path (Join-Path -Path $ConfigDirectory -ChildPath $customDirectoryName) -ChildPath 'aura-config.json'
            if (Test-Path -Path $customConfigPath -PathType Leaf) {
                return $customConfigPath
            }
        }

        $customDirectory = Get-ChildItem -Path $ConfigDirectory -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ieq 'custom' } |
            Select-Object -First 1

        if ($customDirectory) {
            $customConfigPath = Join-Path -Path $customDirectory.FullName -ChildPath 'aura-config.json'
            if (Test-Path -Path $customConfigPath -PathType Leaf) {
                return $customConfigPath
            }
        }

        return $null
    }

    $ConfigFilePath = $null

    try {
        # If a valid TenantId (GUID) is provided, look for tenant-specific config first
        $isValidTenantId = $TenantId -as [guid]
        if ($isValidTenantId) {
            $tenantFileName = "aura-config.$TenantId.json"
            $ConfigFilePath = Find-ConfigFile -SearchPath $Path -FileName $tenantFileName
            if ($ConfigFilePath) {
                Write-Verbose "Found tenant-specific config: $ConfigFilePath"
            } else {
                Write-Verbose "No tenant-specific config ($tenantFileName) found. Falling back to default."
            }
        }

        # Fall back to the default aura-config.json
        if (-not $ConfigFilePath) {
            # If Path is a direct file reference, use it as-is (preserves original behavior)
            if (Test-Path -Path $Path -PathType Leaf) {
                $ConfigFilePath = $Path
            } else {
                $ConfigFilePath = Find-ConfigFile -SearchPath $Path -FileName 'aura-config.json'
            }
        }
    } catch {
        Write-Verbose "Error while trying to seek the config file: $_"
    }

    if (-not $ConfigFilePath -or -not (Test-Path -Path $ConfigFilePath)) {
        # If we didn't find it anywhere, let's use the default config file
        Write-Verbose "Config file not found. Using default config file."
        $ConfigFilePath = Join-Path (Get-AuraTestFolderPath) -ChildPath 'aura-config.json'
        if (-not (Test-Path -Path $ConfigFilePath)) {
            Write-Warning "Default config file not found at $ConfigFilePath. Please provide a valid path to the config file."
            return $null
        }
    }

    Write-Verbose "Loading Aura config from: $ConfigFilePath"
    $auraConfig = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json

    $loadedModuleVersion = if ($auraConfig.PSObject.Properties.Name -contains 'ModuleVersion') { $auraConfig.ModuleVersion } else { '<none>' }
    $loadedConfigVersion = if ($auraConfig.PSObject.Properties.Name -contains 'ConfigVersion') { $auraConfig.ConfigVersion } else { '<none>' }
    Write-Verbose "Loaded Aura config: ModuleVersion=$loadedModuleVersion, ConfigVersion=$loadedConfigVersion"

    # Store the source file name so the report can show which config was loaded
    $configFileName = Split-Path -Path $ConfigFilePath -Leaf
    Add-Member -InputObject $auraConfig -MemberType NoteProperty -Name 'ConfigSource' -Value $configFileName

    # Add a new property called TestSettingsHash to the config object with Id as the key for faster access
    Add-Member -InputObject $auraConfig -MemberType NoteProperty -Name 'TestSettingsHash' -Value @{}

    foreach ($testSetting in $auraConfig.TestSettings) {
        $auraConfig.TestSettingsHash.Add($testSetting.Id, $testSetting)
    }

    # Read the custom config file if it exists
    $customConfigPath = Find-CustomConfigFile -ConfigDirectory (Split-Path -Path $ConfigFilePath -Parent)
    if ($customConfigPath -and (Test-Path -Path $customConfigPath -PathType Leaf)) {
        Write-Verbose "Custom config file found at $customConfigPath. Merging with main config."
        $customConfig = Get-Content -Path $customConfigPath -Raw | ConvertFrom-Json

        # Go through each GlobalSetting in custom and override the main config if it exists, otherwise append
        foreach ($property in $customConfig.GlobalSettings.PSObject.Properties) {
            if ($auraConfig.GlobalSettings.PSObject.Properties.Name -contains $property.Name) {
                Write-Verbose "Updating GlobalSetting `"$($property.Name)`" from custom config."
                $auraConfig.GlobalSettings.$($property.Name) = $property.Value
            } else {
                Write-Verbose "Adding GlobalSetting `"$($property.Name)`" from custom config."
                Add-Member -InputObject $auraConfig.GlobalSettings -MemberType NoteProperty -Name $property.Name -Value $property.Value
            }
        }

        # Go through each TestSetting in custom and override the main config if it exists
        foreach ($customSetting in $customConfig.TestSettings) {
            $mainTestSetting = $auraConfig.TestSettingsHash[$customSetting.Id]
            if ($mainTestSetting) {
                Write-Verbose "Updating TestSetting with Id $($customSetting.Id) from custom config."
                # Update the existing properties (right now only Severity is supported)
                $mainTestSetting.Severity = $customSetting.Severity
            }
        }
    } else {
        Write-Verbose "No custom config file found. Using main config only."
    }

    return $auraConfig
}

function Get-IsNewAuraVersionAvailable {
    <#
    .SYNOPSIS
        Checks the PowerShell Gallery for a newer version of the Aura module and displays a message if a newer version is available.

    .DESCRIPTION
        Compares the installed version of the Aura module with the latest version available on the PowerShell Gallery.
        This is useful to let the user know if there are newer versions with updates and bug fixes.
        The function returns $true if a newer version is available, otherwise $false.

    .EXAMPLE
        Get-IsNewAuraVersionAvailable
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [OutputType([bool])]
    param()

    function ConvertTo-ComparableVersion {
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            [object] $InputVersion
        )

        if ($null -eq $InputVersion) {
            return $null
        }

        if ($InputVersion -is [version]) {
            return $InputVersion
        }

        $versionString = [string]$InputVersion
        if ([string]::IsNullOrWhiteSpace($versionString)) {
            return $null
        }

        # Normalize prerelease-like strings to comparable version values.
        $numericVersion = $versionString -replace '-.*$', ''

        try {
            return [version]$numericVersion
        } catch {
            Write-Verbose -Message "Could not parse current module version '$InputVersion' (numeric: '$numericVersion')."
            return $null
        }
    }

    try {
        $currentVersion = ConvertTo-ComparableVersion -InputVersion (Get-AuModuleVersion)
        $latestVersion = Get-AuLatestModuleVersion -Name Aura -TimeoutSec 10

        if ($null -eq $currentVersion) {
            Write-Verbose -Message 'Unable to determine installed Aura version.'
            return $false
        }

        if ($null -ne $latestVersion -and $currentVersion -lt $latestVersion) {
            Write-Host '🔥 FYI: A newer version of Aura is available! Run the commands below to update to the latest version.'
            Write-Host "💥 Installed version: $currentVersion → Latest version: $latestVersion" -ForegroundColor DarkGray
            Write-Host '✨ Update-Module Aura' -NoNewline -ForegroundColor Green
            Write-Host ' → Install the latest version of Aura.' -ForegroundColor Yellow
            Write-Host '💫 Update-AuraTests' -NoNewline -ForegroundColor Green
            Write-Host ' → Get the latest tests built by the Aura team and community.' -ForegroundColor Yellow
            return $true
        }
    } catch { Write-Verbose -Message $_ }
    return $false
}

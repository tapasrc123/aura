Describe 'Get-IsNewAuraVersionAvailable' {
    BeforeAll {
        . "$PSScriptRoot/../../internal/Get-AuLatestModuleVersion.ps1"
        . "$PSScriptRoot/../../internal/Get-AuModuleVersion.ps1"
        . "$PSScriptRoot/../../internal/Get-IsNewAuraVersionAvailable.ps1"
    }

    Context 'When a newer version exists' {
        It 'returns true' {
            $latestVersion = [version]'2.5.0'

            Mock Get-AuModuleVersion { [version]'2.4.0' }
            Mock Get-AuLatestModuleVersion { $latestVersion }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            $result | Should -BeTrue
            Should -Invoke Get-AuModuleVersion -Exactly 1
            Should -Invoke Get-AuLatestModuleVersion -Exactly 1
        }

        It 'returns false when installed is equal to latest' {
            Mock Get-AuModuleVersion { [version]'2.0.0' }
            Mock Get-AuLatestModuleVersion { [version]'2.0.0' }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            $result | Should -BeFalse
        }

        It 'returns false when current version is not comparable (for example, Next)' {
            Mock Get-AuModuleVersion { 'Next' }
            Mock Get-AuLatestModuleVersion { [version]'2.0.0' }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            $result | Should -BeFalse
        }
    }

    Context 'When latest version cannot be determined' {
        It 'returns false' {
            Mock Get-AuModuleVersion { [version]'2.4.0' }
            Mock Get-AuLatestModuleVersion { $null }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            $result | Should -BeFalse
            Should -Invoke Get-AuLatestModuleVersion -Exactly 1
        }
    }

    Context 'When version lookup throws' {
        It 'returns false and does not throw' {
            Mock Get-AuModuleVersion { [version]'2.4.0' }
            Mock Get-AuLatestModuleVersion { throw 'Lookup failed' }
            Mock Write-Host {}

            { Get-IsNewAuraVersionAvailable } | Should -Not -Throw
            Get-IsNewAuraVersionAvailable | Should -BeFalse
        }
    }

    Context 'When installed version cannot be determined' {
        It 'returns false' {
            Mock Get-AuModuleVersion { $null }
            Mock Get-AuLatestModuleVersion { [version]'2.5.0' }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            $result | Should -BeFalse
        }
    }

    Context 'When current module version is a prerelease string' {
        It 'parses and compares prerelease versions correctly' {
            Mock Get-AuModuleVersion { '2.0.0-beta' }
            Mock Get-AuLatestModuleVersion { [version]'2.1.0' }
            Mock Write-Host {}

            $result = Get-IsNewAuraVersionAvailable

            # 2.0.0-beta is normalized to 2.0.0 for deterministic comparison.
            $result | Should -BeTrue
        }
    }
}

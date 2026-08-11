Describe 'Test-AuCaAzureDevOps' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../Aura.psd1 -Force

        function New-CaPolicy {
            param(
                [string]$Id,
                [string]$DisplayName,
                [string[]]$IncludeApplications
            )

            return [PSCustomObject]@{
                id          = $Id
                displayName = $DisplayName
                state       = 'enabled'
                conditions  = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        includeApplications = $IncludeApplications
                    }
                }
            }
        }
    }

    Context 'Azure DevOps app is unavailable in tenant' {
        It 'Should skip and return null' {
            $script:SkippedBecause = $null
            $script:SkippedCustomReason = $null

            Mock -ModuleName Aura Test-AuConnection { return $true }
            Mock -ModuleName Aura Get-AuLicenseInformation { return 'P1' }
            Mock -ModuleName Aura Invoke-AuGraphRequest { return @() }
            Mock -ModuleName Aura Add-AuTestResultDetail {
                param($SkippedBecause, $SkippedCustomReason)
                $script:SkippedBecause = $SkippedBecause
                $script:SkippedCustomReason = $SkippedCustomReason
            }

            $result = Test-AuCaAzureDevOps

            $result | Should -BeNull
            $script:SkippedBecause | Should -Be 'Custom'
            $script:SkippedCustomReason | Should -BeLike '*499b84ac-1321-427f-aa17-267ca6975798*'
        }
    }

    Context 'Azure DevOps app skip propagation' {
        It 'Should not convert the custom skip into an error' {
            Mock -ModuleName Aura Test-AuConnection { return $true }
            Mock -ModuleName Aura Get-AuLicenseInformation { return 'P1' }
            Mock -ModuleName Aura Invoke-AuGraphRequest { return @() }
            Mock -ModuleName Aura Add-AuTestResultDetail {
                param($SkippedBecause)
                if ($SkippedBecause -eq 'Custom') {
                    throw 'Pester skip signal'
                }
            }

            { Test-AuCaAzureDevOps } | Should -Throw 'Pester skip signal'
            Should -Invoke -ModuleName Aura Add-AuTestResultDetail -ParameterFilter { $SkippedBecause -eq 'Error' } -Times 0 -Exactly
        }
    }

    Context 'Azure DevOps app is available in tenant' {
        BeforeEach {
            Mock -ModuleName Aura Test-AuConnection { return $true }
            Mock -ModuleName Aura Get-AuLicenseInformation { return 'P1' }
            Mock -ModuleName Aura Invoke-AuGraphRequest { return @{ id = 'sp-id' } }
        }

        It 'Should return true when at least one enabled policy explicitly includes Azure DevOps' {
            $policies = @(
                New-CaPolicy -Id 'policy1' -DisplayName 'Include Azure DevOps' -IncludeApplications @('499b84ac-1321-427f-aa17-267ca6975798')
            )
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policies }
            Mock -ModuleName Aura Add-AuTestResultDetail {}

            Test-AuCaAzureDevOps | Should -BeTrue
        }

        It 'Should return false when no enabled policy explicitly includes Azure DevOps' {
            $policies = @(
                New-CaPolicy -Id 'policy1' -DisplayName 'All apps policy' -IncludeApplications @('All')
            )
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policies }
            Mock -ModuleName Aura Add-AuTestResultDetail {}

            Test-AuCaAzureDevOps | Should -BeFalse
        }
    }
}

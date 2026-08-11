BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force

    function Get-PesterResultsFixture {
        param(
            [Parameter(Mandatory = $true)]
            [string] $TestName,

            [Parameter(Mandatory = $true)]
            [string] $Result
        )

        $duration = if ($Result -eq 'NotRun') { [TimeSpan]::Zero } else { [TimeSpan]::FromSeconds(1) }
        $pesterTest = [PSCustomObject]@{
            ExpandedName = $TestName
            Result       = $Result
            ErrorRecord  = @()
            ScriptBlock  = [scriptblock]::Create('$true | Should -BeTrue')
            Block        = [PSCustomObject]@{
                Tag          = @('MT.1068')
                ExpandedName = 'MT.1068'
            }
            Duration     = $duration
            Tag          = @('MT.1068')
        }

        return [PSCustomObject]@{
            Tests             = @($pesterTest)
            Containers        = @(
                [PSCustomObject]@{
                    Blocks = @(
                        [PSCustomObject]@{
                            Name   = 'MT.1068'
                            Result = $Result
                            Tag    = @('MT.1068')
                        }
                    )
                }
            )
            Result            = $Result
            ExecutedAt        = [DateTime]::UtcNow
            Duration          = $duration
            UserDuration      = $duration
            DiscoveryDuration = [TimeSpan]::Zero
            FrameworkDuration = [TimeSpan]::Zero
        }
    }
}

Describe 'ConvertTo-AuraResult' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.TestResultDetail = @{}
            $__AuSession.AuraConfig = [PSCustomObject]@{
                GlobalSettings   = [PSCustomObject]@{}
                TestSettings     = @()
                TestSettingsHash = @{}
            }
        }
        Mock Test-AuConnection -ModuleName Aura { $false }
        Mock Get-AuModuleVersion -ModuleName Aura { '0.0.0-test' }
        Mock Get-AuLatestModuleVersion -ModuleName Aura { $null }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.TestResultDetail = @{}
            $__AuSession.AuraConfig = $null
        }
    }

    It 'Converts GitHub manual-review details to Investigate instead of Skipped' {
        InModuleScope Aura {
            $testName = 'CIS.GH.1.2.3: Ensure repository deletion is limited to specific users'
            $__AuSession.TestResultDetail[$testName] = @{
                TestTitle       = $testName
                TestDescription = 'GitHub repository deletion control.'
                TestResult      = 'Manual review required - members_can_delete_repositories is true.'
                TestSkipped     = $null
                SkippedReason   = $null
                TestInvestigate = $true
                Severity        = 'High'
                Service         = 'GitHub'
            }

            $pesterTest = [PSCustomObject]@{
                ExpandedName = $testName
                Result       = 'Passed'
                ErrorRecord  = @()
                ScriptBlock  = [scriptblock]::Create('$result = Test-AuCisGitHubRepositoryDeletionLimited')
                Block        = [PSCustomObject]@{
                    Tag          = @('CIS.GH.1.2.3', 'CIS GH')
                    ExpandedName = 'CIS'
                }
                Duration     = [TimeSpan]::FromSeconds(1)
                Tag          = @('CIS.GH.1.2.3')
            }
            $pesterResults = [PSCustomObject]@{
                Tests             = @($pesterTest)
                Containers        = @(
                    [PSCustomObject]@{
                        Blocks = @(
                            [PSCustomObject]@{
                                Name   = 'CIS'
                                Result = 'Passed'
                                Tag    = @('CIS')
                            }
                        )
                    }
                )
                Result            = 'Passed'
                ExecutedAt        = [DateTime]::UtcNow
                Duration          = [TimeSpan]::FromSeconds(1)
                UserDuration      = [TimeSpan]::FromSeconds(1)
                DiscoveryDuration = [TimeSpan]::Zero
                FrameworkDuration = [TimeSpan]::Zero
            }

            $result = ConvertTo-AuraResult -PesterResults $pesterResults

            $result.Tests[0].Result | Should -Be 'Investigate'
            $result.InvestigateCount | Should -Be 1
            $result.SkippedCount | Should -Be 0
            $result.Tests[0].ResultDetail.TestResult | Should -Match 'Manual review required'
        }
    }

    It 'Does not query PowerShell Gallery when version checks are skipped' {
        InModuleScope Aura {
            $pesterResults = [PSCustomObject]@{
                Tests             = @()
                Containers        = @()
                Result            = 'Passed'
                ExecutedAt        = [DateTime]::UtcNow
                Duration          = [TimeSpan]::Zero
                UserDuration      = [TimeSpan]::Zero
                DiscoveryDuration = [TimeSpan]::Zero
                FrameworkDuration = [TimeSpan]::Zero
            }

            $result = ConvertTo-AuraResult -PesterResults $pesterResults -SkipVersionCheck

            $result.LatestVersion | Should -Be 'Unknown'
        }

        Should -Invoke Get-AuLatestModuleVersion -ModuleName Aura -Exactly 0
    }

    It 'Does not warn about malformed names for filtered NotRun tests' {
        $testName = 'Should pass all rules'
        $pesterResults = Get-PesterResultsFixture -TestName $testName -Result 'NotRun'
        InModuleScope Aura -Parameters @{ TestName = $testName; PesterResults = $pesterResults } {
            $warnings = @()
            $result = ConvertTo-AuraResult -PesterResults $PesterResults -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings | Should -BeNullOrEmpty
            $result.Tests | Should -HaveCount 1
            $result.Tests[0].Id | Should -Be $TestName
            $result.Tests[0].Title | Should -Be $TestName
            $result.Tests[0].Result | Should -Be 'NotRun'
            $result.NotRunCount | Should -Be 1
        }
    }

    It 'Warns about malformed names for executed tests' {
        $pesterResults = Get-PesterResultsFixture -TestName 'Should pass all rules' -Result 'Passed'
        InModuleScope Aura -Parameters @{ PesterResults = $pesterResults } {
            $warnings = @()
            $result = ConvertTo-AuraResult -PesterResults $PesterResults -WarningVariable warnings -WarningAction SilentlyContinue

            $warnings | Should -HaveCount 1
            $warnings[0].Message | Should -Match "Test name does not contain a ':' character"
            $result.Tests | Should -HaveCount 1
            $result.Tests[0].Result | Should -Be 'Passed'
            $result.PassedCount | Should -Be 1
        }
    }
}

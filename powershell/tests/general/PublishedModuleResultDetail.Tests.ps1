BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:BuildScriptPath = Join-Path $script:RepoRoot 'build/Build-AuraModule.ps1'
    $script:ValidationScriptPath = Join-Path $script:RepoRoot 'build/Test-AuraModuleOutput.ps1'
    $script:ArtifactRoot = Join-Path $script:RepoRoot ".tmp-aura-published-result-tests-$([guid]::NewGuid())"

    & $script:BuildScriptPath `
        -SourceRoot (Join-Path $script:RepoRoot 'powershell') `
        -TestsRoot (Join-Path $script:RepoRoot 'tests') `
        -OutputRoot $script:ArtifactRoot *> $null
}

AfterAll {
    Get-Module -Name Aura -All | Remove-Module -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $script:ArtifactRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Published module result detail metadata' {
    BeforeEach {
        Get-Module -Name Aura -All | Remove-Module -Force -ErrorAction SilentlyContinue
        Import-Module (Join-Path $script:ArtifactRoot 'Aura.psd1') -Force
        $pesterContext = [PSCustomObject]@{
            CurrentTest = [PSCustomObject]@{
                ExpandedName = 'Published module result detail probe'
                Tag = @()
                Block = [PSCustomObject]@{ Tag = @() }
            }
        }
        Set-Variable -Name ____Pester -Scope Global -Value $pesterContext
        InModuleScope Aura {
            $__AuSession.TestResultDetail = @{}
        }
    }

    AfterEach {
        Remove-Variable -Name ____Pester -Scope Global -ErrorAction SilentlyContinue
        Get-Module -Name Aura -All | Remove-Module -Force -ErrorAction SilentlyContinue
    }

    It 'passes behavioral output validation for bundled metadata' {
        {
            & $script:ValidationScriptPath -ModulePath $script:ArtifactRoot *> $null
        } | Should -Not -Throw
    }

    It 'renders bundled Markdown through a consolidated helper' {
        Mock -ModuleName Aura Test-AuConnection { $true }
        Mock -ModuleName Aura Get-AuLicenseInformation { 'Licensed' }
        Mock -ModuleName Aura Get-AuExo { @() }

        Test-AuCisaDlp | Should -BeFalse

        $detail = InModuleScope Aura {
            $__AuSession.TestResultDetail.Values | Select-Object -First 1
        }
        $detail.TestDescription | Should -Match '^A DLP solution SHALL be used\.'
        $detail.TestDescription | Should -Not -Match 'function\s+Test-AuCisaDlp'
        $detail.TestResult | Should -Match 'does not have.*Data Loss Prevention Policies.*enabled'
    }

    It 'loads adjacent Markdown for custom tests' {
        Add-AuTestResultDetail -Result 'CUSTOM_RESULT'

        $detail = InModuleScope Aura {
            $__AuSession.TestResultDetail.Values | Select-Object -First 1
        }
        $detail.TestDescription | Should -Match 'CUSTOM_DESCRIPTION_SENTINEL'
        $detail.TestResult.Trim() | Should -Be 'Custom rendered: CUSTOM_RESULT'
    }

    It 'preserves literal replacement tokens in graph Markdown' {
        $graphMarkdown = 'Name $_ $& $$ $`'
        Mock -ModuleName Aura Get-GraphObjectMarkdown { 'Name $_ $& $$ $`' }

        Add-AuTestResultDetail `
            -Description 'Graph object results.' `
            -Result 'Objects: %TestResult%' `
            -GraphObjects @([PSCustomObject]@{ Id = '1' }) `
            -GraphObjectType Users

        $detail = InModuleScope Aura {
            $__AuSession.TestResultDetail.Values | Select-Object -First 1
        }
        $detail.TestResult | Should -Be "Objects: $graphMarkdown"
    }
}

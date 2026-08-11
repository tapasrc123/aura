BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Test-AuContext — Microsoft Graph scopes' {
    It 'Uses the shared comparison when a ReadWrite scope satisfies a Read scope' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                AuthType = 'Delegated'
                Scopes   = @('User.ReadWrite')
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            @('User.Read')
        } -ModuleName Aura

        InModuleScope Aura {
            Test-AuContext | Should -BeTrue
        }
    }

    It 'Reports scopes that remain missing after comparison' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                AuthType = 'Delegated'
                Scopes   = @('Directory.Read.All')
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            @(
                'Directory.Read.All'
                'Reports.Read.All'
            )
        } -ModuleName Aura

        InModuleScope Aura {
            { Test-AuContext } |
                Should -Throw -ExpectedMessage '*Reports.Read.All*'
        }
    }
}

Describe 'Get-AuGitHubRepoFromGit' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../Aura.psd1 -Force
    }

    Context 'When git is not available' {
        It 'Returns $null when git command is not on PATH' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { $null } -ParameterFilter { $Name -eq 'git' }
                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When git remote is configured' {
        It 'Parses an HTTPS GitHub URL with .git suffix' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com/tapasrc123/aura.git' }

                $result = Get-AuGitHubRepoFromGit
                $result | Should -Not -BeNullOrEmpty
                $result.Organization | Should -Be 'tapasrc123'
                $result.Repository   | Should -Be 'aura'
            }
        }

        It 'Parses an HTTPS GitHub URL without .git suffix' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com/contoso/security-tests' }

                $result = Get-AuGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'security-tests'
            }
        }

        It 'Parses an SSH (scp-style) GitHub URL' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'git@github.com:fabrikam/aura-tests.git' }

                $result = Get-AuGitHubRepoFromGit
                $result.Organization | Should -Be 'fabrikam'
                $result.Repository   | Should -Be 'aura-tests'
            }
        }

        It 'Parses an ssh:// GitHub URL' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'ssh://git@github.com/contoso/repo.git' }

                $result = Get-AuGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'repo'
            }
        }

        It 'Returns $null for non-GitHub remotes' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://dev.azure.com/contoso/_git/repo' }

                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null when git remote returns nothing' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { '' }

                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a lookalike host that ends with github.com (e.g. evilgithub.com)' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://evilgithub.com/owner/repo.git' }

                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a host that has github.com as a subdomain prefix (e.g. github.com.attacker.com)' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com.attacker.com/owner/repo.git' }

                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a hyphenated lookalike (e.g. my-github.com)' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://my-github.com/owner/repo.git' }

                Get-AuGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Parses an HTTPS GitHub URL with www. prefix' {
            InModuleScope -ModuleName 'Aura' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://www.github.com/contoso/repo.git' }

                $result = Get-AuGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'repo'
            }
        }
    }
}

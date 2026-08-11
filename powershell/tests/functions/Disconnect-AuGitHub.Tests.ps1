BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Disconnect-AuGitHub' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
        }
    }

    Context 'When GitHub state is set' {
        It 'Clears GitHubConnection, GitHubAuthHeader, and GitHubCache' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer token' }
                $__AuSession.GitHubCache      = @{ 'foo' = 'bar' }
            }
            Disconnect-AuGitHub 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader | Should -BeNullOrEmpty
                $__AuSession.GitHubCache.Count | Should -Be 0
            }
        }
    }

    Context 'When GitHub state is already null' {
        It 'Does not throw' {
            { Disconnect-AuGitHub 6>$null } | Should -Not -Throw
        }

        It 'Leaves session keys null' {
            Disconnect-AuGitHub 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader | Should -BeNullOrEmpty
            }
        }
    }
}

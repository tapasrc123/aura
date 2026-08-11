BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Disconnect-Aura - GitHub session lifecycle' {
    BeforeEach {
        Mock Disconnect-MgGraph -ModuleName Aura {}

        InModuleScope Aura {
            $__AuSession.Connections      = @()
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.Connections      = @()
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
        }
    }

    Context 'Default name (Disconnect-Aura)' {
        It 'clears GitHub session state' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer token' }
                $__AuSession.GitHubCache      = @{ 'foo' = 'bar' }
            }
            Disconnect-Aura 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader | Should -BeNullOrEmpty
                $__AuSession.GitHubCache.Count | Should -Be 0
            }
        }
    }

    Context 'Module-qualified invocation (Aura\Disconnect-Aura)' {
        It 'clears GitHub session state' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer token' }
                $__AuSession.GitHubCache      = @{ 'foo' = 'bar' }
            }
            Aura\Disconnect-Aura 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader | Should -BeNullOrEmpty
                $__AuSession.GitHubCache.Count | Should -Be 0
            }
        }
    }

    Context 'Disconnect-Aura alias' {
        It 'clears GitHub session state' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer token' }
                $__AuSession.GitHubCache      = @{ 'foo' = 'bar' }
            }
            Disconnect-Aura 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader | Should -BeNullOrEmpty
                $__AuSession.GitHubCache.Count | Should -Be 0
            }
        }
    }

    Context 'Disconnect-AuGraph alias' {
        It 'does not clear GitHub session state' {
            InModuleScope Aura {
                $__AuSession.Connections      = @('GitHub')
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer token' }
                $__AuSession.GitHubCache      = @{ 'foo' = 'bar' }
            }
            Disconnect-AuGraph 6>$null
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -Not -BeNullOrEmpty
                $__AuSession.GitHubConnection.Organization | Should -Be 'myorg'
                $__AuSession.GitHubAuthHeader | Should -Not -BeNullOrEmpty
                $__AuSession.GitHubAuthHeader['Authorization'] | Should -Be 'Bearer token'
                $__AuSession.GitHubCache['foo'] | Should -Be 'bar'
            }
        }
    }

    Context 'When no GitHub state exists' {
        It 'Produces no GitHub-related host output' {
            $hostOutput = Disconnect-Aura 6>&1 | Out-String
            $hostOutput | Should -Not -Match 'Disconnected from GitHub'
        }
    }
}

Describe 'Disconnect-Aura - Active Directory session lifecycle' {
    BeforeEach {
        Mock Disconnect-MgGraph -ModuleName Aura {}

        InModuleScope Aura {
            $__AuSession.Connections = @()
            $__AuSession.ADConnection = [PSCustomObject]@{
                Connected        = $true
                DomainController = 'dc01.contoso.com'
            }
            $__AuSession.ADCache = @{ DomainState = [PSCustomObject]@{ Domain = 'contoso.com' } }
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.Connections = @()
            $__AuSession.ADConnection = $null
            $__AuSession.ADCache = @{}
        }
    }

    It 'Clears Active Directory state even if another Connect-Aura call replaced the service list' {
        InModuleScope Aura {
            $__AuSession.Connections = @('Graph')
        }

        Disconnect-Aura 6>$null

        InModuleScope Aura {
            $__AuSession.ADConnection | Should -BeNullOrEmpty
            $__AuSession.ADCache.Count | Should -Be 0
        }
    }

    It 'Preserves Active Directory state when only Disconnect-AuGraph is requested' {
        Disconnect-AuGraph 6>$null

        InModuleScope Aura {
            $__AuSession.ADConnection.Connected | Should -BeTrue
            $__AuSession.ADCache.Count | Should -Be 1
        }
    }
}

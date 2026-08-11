BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Clear-ModuleVariable — GitHub session lifecycle' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
            $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer testtoken' }
            $__AuSession.GitHubCache      = @{ somekey = 'cached-value' }
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
        }
    }

    It 'Preserves GitHubConnection after Clear-ModuleVariable' {
        InModuleScope Aura {
            Clear-ModuleVariable
            $__AuSession.GitHubConnection | Should -Not -BeNullOrEmpty
            $__AuSession.GitHubConnection.Connected | Should -BeTrue
        }
    }

    It 'Preserves GitHubAuthHeader after Clear-ModuleVariable' {
        InModuleScope Aura {
            Clear-ModuleVariable
            $__AuSession.GitHubAuthHeader | Should -Not -BeNullOrEmpty
            $__AuSession.GitHubAuthHeader['Authorization'] | Should -Be 'Bearer testtoken'
        }
    }

    It 'Resets GitHubCache to empty after Clear-ModuleVariable' {
        InModuleScope Aura {
            Clear-ModuleVariable
            $__AuSession.GitHubCache.Count | Should -Be 0
        }
    }

    It 'Test-AuConnection GitHub still returns True after Clear-ModuleVariable' {
        InModuleScope Aura {
            Clear-ModuleVariable
            Test-AuConnection -Service GitHub | Should -BeTrue
        }
    }
}

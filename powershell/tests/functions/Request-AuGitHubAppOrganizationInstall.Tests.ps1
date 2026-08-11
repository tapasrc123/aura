BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Request-AuGitHubAppOrganizationInstall' {
    BeforeEach {
        $script:readHostCallCount = 0
        Mock Get-AuUserInteractive -ModuleName Aura { $true }
    }

    It 'Explains the install step, opens the browser only after confirmation, and returns true' {
        Mock Read-Host -ModuleName Aura {
            $script:readHostCallCount++
            if ($script:readHostCallCount -eq 1) { return 'Y' }
            return ''
        }
        Mock Open-AuBrowserUrl -ModuleName Aura { $true }

        InModuleScope Aura {
            $result = Request-AuGitHubAppOrganizationInstall -Organization 'myorg' -InstallUrl 'https://github.com/apps/aura-cli/installations/new' -Reason 'forbidden' 6>$null
            $result | Should -BeTrue
        }

        Should -Invoke Open-AuBrowserUrl -ModuleName Aura -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://github.com/apps/aura-cli/installations/new'
        }
        Should -Invoke Read-Host -ModuleName Aura -Times 1 -Exactly -ParameterFilter {
            $Prompt -eq 'Open the GitHub App install page now? [Y/n]'
        }
        Should -Invoke Read-Host -ModuleName Aura -Times 2 -Exactly
    }

    It 'Defaults to opening the browser when the user presses Enter at the confirmation prompt' {
        Mock Read-Host -ModuleName Aura { '' }
        Mock Open-AuBrowserUrl -ModuleName Aura { $true }

        InModuleScope Aura {
            $result = Request-AuGitHubAppOrganizationInstall -Organization 'myorg' -InstallUrl 'https://github.com/apps/aura-cli/installations/new' -Reason 'forbidden' 6>$null
            $result | Should -BeTrue
        }

        Should -Invoke Open-AuBrowserUrl -ModuleName Aura -Times 1 -Exactly -ParameterFilter {
            $Uri -eq 'https://github.com/apps/aura-cli/installations/new'
        }
        Should -Invoke Read-Host -ModuleName Aura -Times 1 -Exactly -ParameterFilter {
            $Prompt -eq 'Open the GitHub App install page now? [Y/n]'
        }
        Should -Invoke Read-Host -ModuleName Aura -Times 2 -Exactly
    }

    It 'Does not open the browser when the user declines and returns false' {
        Mock Read-Host -ModuleName Aura { 'N' }
        Mock Open-AuBrowserUrl -ModuleName Aura { throw 'Browser must not open when the user declines.' }

        InModuleScope Aura {
            $result = Request-AuGitHubAppOrganizationInstall -Organization 'myorg' -InstallUrl 'https://github.com/apps/aura-cli/installations/new' -Reason 'forbidden' 6>$null
            $result | Should -BeFalse
        }

        Should -Invoke Open-AuBrowserUrl -ModuleName Aura -Times 0 -Exactly
        Should -Invoke Read-Host -ModuleName Aura -Times 1 -Exactly
    }

    It 'Returns false without prompting in non-interactive sessions' {
        Mock Get-AuUserInteractive -ModuleName Aura { $false }
        Mock Read-Host -ModuleName Aura { throw 'Read-Host must not be called in non-interactive sessions.' }
        Mock Open-AuBrowserUrl -ModuleName Aura { throw 'Browser must not open in non-interactive sessions.' }

        InModuleScope Aura {
            $result = Request-AuGitHubAppOrganizationInstall -Organization 'myorg' -InstallUrl 'https://github.com/apps/aura-cli/installations/new' 6>$null
            $result | Should -BeFalse
        }

        Should -Invoke Read-Host -ModuleName Aura -Times 0 -Exactly
        Should -Invoke Open-AuBrowserUrl -ModuleName Aura -Times 0 -Exactly
    }
}

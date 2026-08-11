BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Get-AuSession — GitHubAuthHeader redaction' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.GitHubAuthHeader = $null
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.GitHubAuthHeader = $null
        }
    }

    Context 'When GitHubAuthHeader is null' {
        It 'Returns null without error' {
            $result = Get-AuSession
            $result.GitHubAuthHeader | Should -BeNullOrEmpty
        }
    }

    Context 'When GitHubAuthHeader is a hashtable with Authorization (PascalCase)' {
        It 'Redacts Authorization and preserves other headers' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = @{
                    Authorization          = 'Bearer ghp_realtoken123'
                    Accept                 = 'application/vnd.github+json'
                    'X-GitHub-Api-Version' = '2022-11-28'
                    'User-Agent'           = 'Aura-GitHubCis'
                }
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader | Should -BeOfType [System.Collections.IDictionary]
            $result.GitHubAuthHeader['Authorization']          | Should -Be '<redacted>'
            $result.GitHubAuthHeader['Accept']                 | Should -Be 'application/vnd.github+json'
            $result.GitHubAuthHeader['X-GitHub-Api-Version']   | Should -Be '2022-11-28'
            $result.GitHubAuthHeader['User-Agent']             | Should -Be 'Aura-GitHubCis'
        }
    }

    Context 'When GitHubAuthHeader has lowercase authorization key' {
        It 'Redacts the lowercase key and leaves no token in any value' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = @{
                    authorization = 'Bearer ghp_realtoken123'
                    Accept        = 'application/vnd.github+json'
                }
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader['authorization'] | Should -Be '<redacted>'
            foreach ($v in $result.GitHubAuthHeader.Values) {
                $v | Should -Not -Be 'Bearer ghp_realtoken123'
            }
        }
    }

    Context 'When GitHubAuthHeader has uppercase AUTHORIZATION key' {
        It 'Redacts the uppercase key' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = @{
                    AUTHORIZATION = 'Bearer ghp_realtoken123'
                    Accept        = 'application/vnd.github+json'
                }
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader['AUTHORIZATION'] | Should -Be '<redacted>'
            foreach ($v in $result.GitHubAuthHeader.Values) {
                $v | Should -Not -Be 'Bearer ghp_realtoken123'
            }
        }
    }

    Context 'When GitHubAuthHeader has BOTH Authorization and authorization' {
        It 'Redacts every Authorization-like key' {
            InModuleScope Aura {
                $h = [ordered]@{}
                $h['Authorization'] = 'Bearer ghp_realtoken123'
                $h['authorization'] = 'Bearer ghp_realtoken123'
                $h['Accept']        = 'application/vnd.github+json'
                $__AuSession.GitHubAuthHeader = $h
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader['Authorization'] | Should -Be '<redacted>'
            $result.GitHubAuthHeader['authorization'] | Should -Be '<redacted>'
            foreach ($v in $result.GitHubAuthHeader.Values) {
                $v | Should -Not -Be 'Bearer ghp_realtoken123'
            }
        }
    }

    Context 'When GitHubAuthHeader is an OrderedDictionary' {
        It 'Redacts Authorization and preserves remaining keys' {
            InModuleScope Aura {
                $h = [ordered]@{}
                $h['Authorization']        = 'Bearer ghp_realtoken123'
                $h['Accept']               = 'application/vnd.github+json'
                $h['X-GitHub-Api-Version'] = '2022-11-28'
                $__AuSession.GitHubAuthHeader = $h
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader | Should -BeOfType [System.Collections.IDictionary]
            $result.GitHubAuthHeader['Authorization']        | Should -Be '<redacted>'
            $result.GitHubAuthHeader['Accept']               | Should -Be 'application/vnd.github+json'
            $result.GitHubAuthHeader['X-GitHub-Api-Version'] | Should -Be '2022-11-28'
        }
    }

    Context 'When GitHubAuthHeader is an unsupported non-null shape' {
        It 'Replaces the entire value with the redacted sentinel string (fail-closed)' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = 'Bearer ghp_realtoken123'
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader | Should -Be '<redacted>'
        }

        It 'Replaces a PSCustomObject auth-like blob with the redacted sentinel string' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = [PSCustomObject]@{ Authorization = 'Bearer ghp_realtoken123' }
            }
            $result = Get-AuSession
            $result.GitHubAuthHeader | Should -Be '<redacted>'
        }
    }

    Context 'Live session is not mutated by Get-AuSession' {
        It 'Leaves $__AuSession.GitHubAuthHeader.Authorization intact for internal callers' {
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader = @{
                    Authorization = 'Bearer ghp_realtoken123'
                    Accept        = 'application/vnd.github+json'
                }
            }
            Get-AuSession | Out-Null
            InModuleScope Aura {
                $__AuSession.GitHubAuthHeader['Authorization'] | Should -Be 'Bearer ghp_realtoken123'
            }
        }
    }
}

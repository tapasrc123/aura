BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Invoke-AuGitHubRequest' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = [PSCustomObject]@{
                Connected    = $true
                Organization = 'myorg'
                ApiBaseUri   = 'https://api.github.com'
                ApiVersion   = '2022-11-28'
            }
            $__AuSession.GitHubAuthHeader = @{ Authorization = 'Bearer faketoken' }
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

    Context 'Connection guard' {
        It 'Throws when GitHubConnection is null' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = $null
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Throw '*Connect-AuGitHub*'
            }
        }

        It 'Throws when Connected = $false' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $false }
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Throw '*Connect-AuGitHub*'
            }
        }
    }

    Context 'Cache key helper' {
        It 'Builds cache keys as ApiVersion|absoluteUri' {
            InModuleScope Aura {
                Get-AuGitHubCacheKey -ApiVersion '2022-11-28' -AbsoluteUri 'https://api.github.com/orgs/myorg' | Should -Be '2022-11-28|https://api.github.com/orgs/myorg'
            }
        }
    }

    Context 'Cache behavior' {
        BeforeEach {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{ Content = '{"login":"myorg"}'; Headers = @{} }
            }
            Mock Get-AuGitHubCacheKey -ModuleName Aura {
                "$ApiVersion|$AbsoluteUri"
            }
        }

        It 'Returns cached result; Invoke-WebRequest called only once for two identical calls' {
            InModuleScope Aura {
                Invoke-AuGitHubRequest '/orgs/myorg' | Out-Null
                Invoke-AuGitHubRequest '/orgs/myorg' | Out-Null
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 1
            Should -Invoke Get-AuGitHubCacheKey -ModuleName Aura -Exactly -Times 2 -ParameterFilter {
                $ApiVersion -eq '2022-11-28' -and $AbsoluteUri -eq 'https://api.github.com/orgs/myorg'
            }
        }

        It 'Cache key is ApiVersion|absoluteUri' {
            InModuleScope Aura {
                Invoke-AuGitHubRequest '/orgs/myorg' | Out-Null
                $expectedKey = '2022-11-28|https://api.github.com/orgs/myorg'
                $__AuSession.GitHubCache.ContainsKey($expectedKey) | Should -BeTrue
            }
        }

        It 'Stores result in cache on successful call (no -DisableCache)' {
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg'
                $result.login | Should -Be 'myorg'
                $__AuSession.GitHubCache.Count | Should -Be 1
                $cacheKey = '2022-11-28|https://api.github.com/orgs/myorg'
                $__AuSession.GitHubCache[$cacheKey].login | Should -Be 'myorg'
            }
        }

        It '-DisableCache bypasses existing cache entry and does NOT store result' {
            InModuleScope Aura {
                $cacheKey = '2022-11-28|https://api.github.com/orgs/myorg'
                $__AuSession.GitHubCache[$cacheKey] = [PSCustomObject]@{ login = 'cached-value' }

                $result = Invoke-AuGitHubRequest '/orgs/myorg' -DisableCache

                # Web request was made (bypassed cache)
                $result.login | Should -Be 'myorg'
                # Original cache entry is untouched (not overwritten)
                $__AuSession.GitHubCache[$cacheKey].login | Should -Be 'cached-value'
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 1
        }
    }

    Context 'Non-paginated request' {
        It 'Returns single object body without -Paginate' {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{ Content = '{"login":"myorg","plan":{"name":"enterprise"}}'; Headers = @{} }
            }
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg'
                $result.login | Should -Be 'myorg'
            }
        }
    }

    Context 'Pagination' {
        It 'Follows Link rel=next until no next link; returns all items combined' {
            # [?&]page= matches ?page= or &page= but NOT per_page= (per_page contains 'page=' at offset 4)
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -notmatch '[?&]page=\d' } {
                [PSCustomObject]@{
                    Content = '[{"id":1},{"id":2}]'
                    Headers = @{ 'Link' = '<https://api.github.com/orgs/myorg/members?page=2>; rel="next"' }
                }
            }
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -match '[?&]page=\d' } {
                [PSCustomObject]@{ Content = '[{"id":3}]'; Headers = @{} }
            }

            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg/members' -Paginate
                $result.Count | Should -Be 3
                $result[2].id | Should -Be 3
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 2
        }
    }

    Context 'Pagination of empty arrays' {
        It 'Returns an empty result (count 0) when the only page is `[]` with no next link' {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{ Content = '[]'; Headers = @{} }
            }
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg/members' -Paginate
                @($result).Count | Should -Be 0
                # Must not contain a spurious $null item (the regression case).
                @($result) -contains $null | Should -BeFalse
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 1
        }

        It 'Skips an empty intermediate page without contributing $null items' {
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -notmatch '[?&]page=\d' } {
                [PSCustomObject]@{
                    Content = '[]'
                    Headers = @{ 'Link' = '<https://api.github.com/orgs/myorg/members?page=2>; rel="next"' }
                }
            }
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -match '[?&]page=\d' } {
                [PSCustomObject]@{ Content = '[{"id":7}]'; Headers = @{} }
            }
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg/members' -Paginate
                @($result).Count | Should -Be 1
                @($result)[0].id | Should -Be 7
                @($result) -contains $null | Should -BeFalse
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 2
        }

        It 'Non-paginated `[]` response does not return a single $null item' {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{ Content = '[]'; Headers = @{} }
            }
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg/members'
                @($result).Count | Should -Be 0
                @($result) -contains $null | Should -BeFalse
            }
        }
    }

    Context 'Pagination cross-origin guard' {
        It 'Throws and stops paginating when next link is on a different origin' {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{
                    Content = '[{"id":1}]'
                    Headers = @{ 'Link' = '<https://evil.example/orgs/myorg/members?page=2>; rel="next"' }
                }
            }
            InModuleScope Aura {
                { Invoke-AuGitHubRequest '/orgs/myorg/members' -Paginate } |
                    Should -Throw '*outside the configured ApiBaseUri*'
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 1
        }

        It 'Allows a same-origin next link with a base path prefix (GHE-style /api/v3)' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection.ApiBaseUri = 'https://ghe.example.com/api/v3'
            }
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -notmatch '[?&]page=\d' } {
                [PSCustomObject]@{
                    Content = '[{"id":1}]'
                    Headers = @{ 'Link' = '<https://ghe.example.com/api/v3/orgs/myorg/members?page=2>; rel="next"' }
                }
            }
            Mock Invoke-WebRequest -ModuleName Aura -ParameterFilter { $Uri -match '[?&]page=\d' } {
                [PSCustomObject]@{ Content = '[{"id":2}]'; Headers = @{} }
            }
            InModuleScope Aura {
                $result = Invoke-AuGitHubRequest '/orgs/myorg/members' -Paginate
                $result.Count | Should -Be 2
            }
            Should -Invoke Invoke-WebRequest -ModuleName Aura -Exactly -Times 2
        }
    }

    Context 'Rate limit handling' {
        It 'Emits verbose message when x-ratelimit-remaining is 0 on successful response' {
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{
                    Content = '{"login":"myorg"}'
                    Headers = @{ 'x-ratelimit-remaining' = '0'; 'x-ratelimit-reset' = '9999999999' }
                }
            }
            InModuleScope Aura {
                $allOutput   = Invoke-AuGitHubRequest '/orgs/myorg' -Verbose 4>&1
                $verboseMsgs = ($allOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }).Message
                $verboseMsgs | Should -Match 'rate limit'
            }
        }

        It 'Throws on primary rate-limit exhaustion (HTTP 403, remaining = 0)' {
            Mock Invoke-WebRequest -ModuleName Aura {
                $fakeResp = [PSCustomObject]@{
                    StatusCode = 403
                    Headers    = @{ 'x-ratelimit-remaining' = '0'; 'x-ratelimit-reset' = '9999999999' }
                }
                $ex = [System.Exception]::new('Forbidden')
                Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value $fakeResp
                throw $ex
            }
            InModuleScope Aura {
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Throw '*rate limit*'
            }
        }

        It 'Rethrows ordinary 403 without rate-limit headers as the original error (not a rate-limit message)' {
            Mock Invoke-WebRequest -ModuleName Aura {
                $fakeResp = [PSCustomObject]@{
                    StatusCode = 403
                    Headers    = @{}
                }
                $ex = [System.Exception]::new('Forbidden')
                Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value $fakeResp
                throw $ex
            }
            InModuleScope Aura {
                $thrownMessage = $null
                try { Invoke-AuGitHubRequest '/orgs/myorg' } catch { $thrownMessage = $_.Exception.Message }
                $thrownMessage | Should -Match 'Forbidden'
                $thrownMessage | Should -Not -Match 'rate limit'
            }
        }

        It 'Rethrows original error when x-ratelimit-remaining is malformed (no parse exception)' {
            Mock Invoke-WebRequest -ModuleName Aura {
                $fakeResp = [PSCustomObject]@{
                    StatusCode = 403
                    Headers    = @{ 'x-ratelimit-remaining' = 'not-a-number' }
                }
                $ex = [System.Exception]::new('Forbidden')
                Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value $fakeResp
                throw $ex
            }
            InModuleScope Aura {
                $thrownMessage = $null
                try { Invoke-AuGitHubRequest '/orgs/myorg' } catch { $thrownMessage = $_.Exception.Message }
                $thrownMessage | Should -Match 'Forbidden'
                $thrownMessage | Should -Not -Match 'rate limit'
                $thrownMessage | Should -Not -Match 'Cannot convert'
            }
        }

        It 'Does not throw on successful response when x-ratelimit-reset is out of range for FromUnixTimeSeconds' {
            # 253402300800 is one second past the documented upper bound of FromUnixTimeSeconds
            # (max accepted = 253402300799 = 9999-12-31T23:59:59Z). A bogus reset epoch from
            # an upstream proxy must not raise ArgumentOutOfRangeException and mask the response.
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{
                    Content = '{"login":"myorg"}'
                    Headers = @{ 'x-ratelimit-remaining' = '0'; 'x-ratelimit-reset' = '253402300800' }
                }
            }
            InModuleScope Aura {
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Not -Throw
                $result = Invoke-AuGitHubRequest '/orgs/myorg' -DisableCache
                $result.login | Should -Be 'myorg'
            }
        }

        It 'Does not throw on successful response when x-ratelimit-remaining is malformed' {
            # Successful response body is valid; a malformed rate-limit header (e.g. an upstream
            # proxy rewriting the value) must not raise a parse exception that masks the response.
            Mock Invoke-WebRequest -ModuleName Aura {
                [PSCustomObject]@{
                    Content = '{"login":"myorg"}'
                    Headers = @{ 'x-ratelimit-remaining' = 'not-a-number'; 'x-ratelimit-reset' = 'also-bogus' }
                }
            }
            InModuleScope Aura {
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Not -Throw
                $result = Invoke-AuGitHubRequest '/orgs/myorg' -DisableCache
                $result.login | Should -Be 'myorg'
            }
        }

        It 'Throws on secondary rate-limit (HTTP 429, retry-after header present)' {
            Mock Invoke-WebRequest -ModuleName Aura {
                $fakeResp = [PSCustomObject]@{
                    StatusCode = 429
                    Headers    = @{ 'retry-after' = '30' }
                }
                $ex = [System.Exception]::new('Too Many Requests')
                Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value $fakeResp
                throw $ex
            }
            InModuleScope Aura {
                { Invoke-AuGitHubRequest '/orgs/myorg' } | Should -Throw '*secondary rate limit*'
            }
        }
    }
}

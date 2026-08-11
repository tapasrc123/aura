BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Get-AuGitHubResponseHeaderValue' {
    Context 'Null headers' {
        It 'Returns $null when Headers is $null' {
            InModuleScope Aura {
                Get-AuGitHubResponseHeaderValue -Headers $null -Name 'x-ratelimit-remaining' | Should -BeNullOrEmpty
            }
        }
    }

    Context 'IDictionary headers (PS 5.1 WebHeaderCollection style)' {
        It 'Returns value for exact-case match' {
            InModuleScope Aura {
                $headers = @{ 'x-ratelimit-remaining' = '42' }
                Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-remaining' | Should -Be '42'
            }
        }

        It 'Returns value for different-case header name' {
            InModuleScope Aura {
                $headers = @{ 'X-RateLimit-Remaining' = '10' }
                Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-remaining' | Should -Be '10'
            }
        }

        It 'Returns first element when header value is an array' {
            InModuleScope Aura {
                $headers = @{ 'Link' = @('<https://api.github.com/next>; rel="next"', '<https://api.github.com/last>; rel="last"') }
                $result = Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'Link'
                $result | Should -Be '<https://api.github.com/next>; rel="next"'
            }
        }

        It 'Returns $null when header is not present' {
            InModuleScope Aura {
                $headers = @{ 'content-type' = 'application/json' }
                Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-remaining' | Should -BeNullOrEmpty
            }
        }
    }

    Context 'HttpResponseHeaders with GetValues (PS 7 style)' {
        It 'Returns value when GetValues succeeds' {
            InModuleScope Aura {
                $headers = [PSCustomObject]@{}
                $headers | Add-Member -MemberType ScriptMethod -Name GetValues -Value {
                    param([string]$name)
                    if ($name -eq 'x-ratelimit-reset') { return @('1700000000') }
                    throw "Header '$name' not found"
                }
                $result = Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-reset'
                $result | Should -Be '1700000000'
            }
        }

        It 'Returns $null when GetValues throws for unknown header' {
            InModuleScope Aura {
                $headers = [PSCustomObject]@{}
                $headers | Add-Member -MemberType ScriptMethod -Name GetValues -Value {
                    param([string]$name)
                    throw "Header '$name' not found"
                }
                Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-remaining' | Should -BeNullOrEmpty
            }
        }
    }

    Context 'HttpResponseHeaders with TryGetValues (PS 7 style)' {
        It 'Returns value when TryGetValues succeeds' {
            InModuleScope Aura {
                $headers = [PSCustomObject]@{}
                $headers | Add-Member -MemberType ScriptMethod -Name TryGetValues -Value {
                    param([string]$name, [ref]$values)
                    if ($name -eq 'retry-after') {
                        $values.Value = @('30')
                        return $true
                    }
                    return $false
                }
                $result = Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'retry-after'
                $result | Should -Be '30'
            }
        }

        It 'Returns $null when TryGetValues returns false' {
            InModuleScope Aura {
                $headers = [PSCustomObject]@{}
                $headers | Add-Member -MemberType ScriptMethod -Name TryGetValues -Value {
                    param([string]$name, [ref]$values)
                    $null = $name
                    $null = $values
                    return $false
                }
                Get-AuGitHubResponseHeaderValue -Headers $headers -Name 'x-ratelimit-remaining' | Should -BeNullOrEmpty
            }
        }
    }
}

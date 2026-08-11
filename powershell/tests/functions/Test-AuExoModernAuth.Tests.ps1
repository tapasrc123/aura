Describe 'Test-AuExoModernAuth' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../Aura.psd1 -Force
        Mock -ModuleName Aura Test-AuConnection { return $true }
    }

    Context 'Modern authentication enabled (boolean $true)' {
        BeforeAll {
            Mock -ModuleName Aura Get-AuExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = $true
                }
            }
        }

        It 'Should return $true when OAuth2ClientProfileEnabled is $true' {
            Test-AuExoModernAuth | Should -BeTrue
        }
    }

    Context 'Modern authentication disabled (boolean $false)' {
        BeforeAll {
            Mock -ModuleName Aura Get-AuExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = $false
                }
            }
        }

        It 'Should return $false when OAuth2ClientProfileEnabled is $false' {
            Test-AuExoModernAuth | Should -BeFalse
        }
    }

    Context 'Modern authentication enabled (string "True")' {
        BeforeAll {
            Mock -ModuleName Aura Get-AuExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = 'True'
                }
            }
        }

        It 'Should return $true when OAuth2ClientProfileEnabled is the string "True"' {
            Test-AuExoModernAuth | Should -BeTrue
        }
    }

    Context 'Modern authentication disabled (string "False")' {
        BeforeAll {
            Mock -ModuleName Aura Get-AuExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = 'False'
                }
            }
        }

        It 'Should return $false when OAuth2ClientProfileEnabled is the string "False"' {
            Test-AuExoModernAuth | Should -BeFalse
        }
    }
}

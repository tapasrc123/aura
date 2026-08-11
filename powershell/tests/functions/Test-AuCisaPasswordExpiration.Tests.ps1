Describe 'Test-AuCisaPasswordExpiration' {
    BeforeAll {
        function New-TestDomain {
            param(
                [string]$Id,
                [bool]$IsVerified = $true,
                [string]$AuthenticationType = 'Managed',
                [object]$PasswordValidityPeriodInDays = $null,
                [object[]]$SupportedServices = @('Email'),
                [bool]$IsDefault = $false
            )

            return [PSCustomObject]@{
                id = $Id
                isVerified = $IsVerified
                authenticationType = $AuthenticationType
                PasswordValidityPeriodInDays = $PasswordValidityPeriodInDays
                supportedServices = $SupportedServices
                isDefault = $IsDefault
            }
        }
    }

    BeforeEach {
        $script:testResultMarkdown = $null

        Mock -ModuleName Aura Test-AuConnection { return $true }
        Mock -ModuleName Aura Add-AuTestResultDetail {
            param($Result)

            $script:testResultMarkdown = $Result
        }
    }

    It 'passes only when managed verified domains are explicitly set to never expire' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            return @(
                (New-TestDomain -Id 'contoso.onmicrosoft.com' -PasswordValidityPeriodInDays ([int]::MaxValue) -IsDefault $true),
                (New-TestDomain -Id 'contoso.com' -PasswordValidityPeriodInDays ([int]::MaxValue))
            )
        }

        Test-AuCisaPasswordExpiration | Should -BeTrue
        $script:testResultMarkdown | Should -Match 'Well done'
    }

    It 'fails when PasswordValidityPeriodInDays is null because never expire is not explicitly configured' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            return @(
                (New-TestDomain -Id 'contoso.onmicrosoft.com' -PasswordValidityPeriodInDays $null)
            )
        }

        Test-AuCisaPasswordExpiration | Should -BeFalse
        $script:testResultMarkdown | Should -Match 'not explicitly set to never expire'
    }

    It 'fails when PasswordValidityPeriodInDays is a finite value' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            return @(
                (New-TestDomain -Id 'contoso.onmicrosoft.com' -PasswordValidityPeriodInDays 90)
            )
        }

        Test-AuCisaPasswordExpiration | Should -BeFalse
        $script:testResultMarkdown | Should -Match 'Password expiration is not explicitly set to never expire'
    }

    It 'skips SharePoint-only legacy domains and reports the reason' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            return @(
                (New-TestDomain -Id 'contoso.onmicrosoft.com' -PasswordValidityPeriodInDays ([int]::MaxValue)),
                (New-TestDomain -Id 'contoso-public.sharepoint.com' -PasswordValidityPeriodInDays $null -SupportedServices @('SharePoint'))
            )
        }

        Test-AuCisaPasswordExpiration | Should -BeTrue
        $script:testResultMarkdown | Should -Match 'Legacy SharePoint-only domain'
    }

    It 'does not skip domains that include SharePoint alongside other supported services' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            return @(
                (New-TestDomain -Id 'contoso.onmicrosoft.com' -PasswordValidityPeriodInDays ([int]::MaxValue)),
                (New-TestDomain -Id 'contoso.com' -PasswordValidityPeriodInDays $null -SupportedServices @('Email', 'SharePoint'))
            )
        }

        Test-AuCisaPasswordExpiration | Should -BeFalse
        $script:testResultMarkdown | Should -Match 'Password expiration is not explicitly set to never expire'
    }
}

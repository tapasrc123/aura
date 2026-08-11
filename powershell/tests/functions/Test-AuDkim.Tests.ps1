BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'DKIM checks with no signing configuration' -ForEach @(
    @{ CommandName = 'Test-AuCisDkim' }
    @{ CommandName = 'Test-AuCisaDkim' }
) {
    BeforeEach {
        Mock -ModuleName Aura Test-AuConnection { return $true }
        Mock -ModuleName Aura Add-AuTestResultDetail { }
        Mock -ModuleName Aura Get-MailAuthenticationRecord {
            throw 'DNS lookup should not be attempted without a DKIM signing configuration'
        }
    }

    It '<CommandName> returns <ExpectedOutcome> for <DomainName>' -ForEach @(
        @{
            DomainName                = 'contoso.onmicrosoft.com'
            InitialDomain             = $true
            IsCoexistenceDomain       = $false
            SendingFromDomainDisabled = $false
            ExpectedOutcome           = 'passed'
            ExpectedResult            = $true
        }
        @{
            DomainName                = 'secondary.onmicrosoft.com'
            InitialDomain             = $false
            IsCoexistenceDomain       = $false
            SendingFromDomainDisabled = $false
            ExpectedOutcome           = 'failed'
            ExpectedResult            = $false
        }
        @{
            DomainName                = 'parked.example'
            InitialDomain             = $false
            IsCoexistenceDomain       = $false
            SendingFromDomainDisabled = $true
            ExpectedOutcome           = 'skipped'
            ExpectedResult            = $null
        }
        @{
            DomainName                = 'contoso.mail.onmicrosoft.com'
            InitialDomain             = $false
            IsCoexistenceDomain       = $true
            SendingFromDomainDisabled = $false
            ExpectedOutcome           = 'failed'
            ExpectedResult            = $false
        }
        @{
            DomainName                = 'contoso.mail.onmicrosoft.com'
            InitialDomain             = $false
            IsCoexistenceDomain       = $true
            SendingFromDomainDisabled = $true
            ExpectedOutcome           = 'skipped'
            ExpectedResult            = $null
        }
        @{
            DomainName                = 'contoso.com'
            InitialDomain             = $false
            IsCoexistenceDomain       = $false
            SendingFromDomainDisabled = $false
            ExpectedOutcome           = 'failed'
            ExpectedResult            = $false
        }
    ) {
        Mock -ModuleName Aura Get-AuExo {
            if ($Request -eq 'AcceptedDomain') {
                return [PSCustomObject]@{
                    DomainName                = $DomainName
                    InitialDomain             = $InitialDomain
                    IsCoexistenceDomain       = $IsCoexistenceDomain
                    SendingFromDomainDisabled = $SendingFromDomainDisabled
                }
            }

            return @()
        }

        $result = & $CommandName
        if ($null -eq $ExpectedResult) {
            $result | Should -BeNullOrEmpty
        } else {
            $result | Should -Be $ExpectedResult
        }
        Should -Invoke Get-MailAuthenticationRecord -ModuleName Aura -Exactly 0
    }
}

BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force

    # Keep -Service All tests isolated from optional service modules that may not be installed.
    $script:createdStubs = @()
    foreach ($cmd in 'Get-AzContext','Connect-AzAccount','Connect-ExchangeOnline','Connect-IPPSSession','Get-ConnectionInformation','Connect-MgGraph','Connect-MicrosoftTeams','Get-ADRootDSE') {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            New-Item -Path "function:global:$cmd" -Value { } | Out-Null
            $script:createdStubs += $cmd
        }
    }
}

AfterAll {
    foreach ($cmd in $script:createdStubs) {
        Remove-Item -Path "function:global:$cmd" -ErrorAction SilentlyContinue
    }
}

Describe 'Connect-Aura' {
    It 'Offers GitHub as a -Service option' {
        $serviceParameter = (Get-Command Connect-Aura).Parameters['Service']
        $validateSet = $serviceParameter.Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } |
            Select-Object -First 1

        $validateSet.ValidValues | Should -Contain 'GitHub'
    }

    It 'Offers ActiveDirectory as a -Service option' {
        $serviceParameter = (Get-Command Connect-Aura).Parameters['Service']
        $validateSet = $serviceParameter.Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } |
            Select-Object -First 1

        $validateSet.ValidValues | Should -Contain 'ActiveDirectory'
    }

    It 'Offers GitHubOrganization as a parameter' {
        (Get-Command Connect-Aura).Parameters.Keys | Should -Contain 'GitHubOrganization'
    }

    It 'Calls Connect-AuGitHub when -Service GitHub is specified' {
        Mock Connect-AuGitHub -ModuleName Aura {}

        Connect-Aura -Service GitHub

        Should -Invoke Connect-AuGitHub -ModuleName Aura -Times 1 -Exactly
    }

    It 'Passes -GitHubOrganization to Connect-AuGitHub' {
        Mock Connect-AuGitHub -ModuleName Aura -ParameterFilter { $Organization -eq 'myorg' } {}

        Connect-Aura -Service GitHub -GitHubOrganization 'myorg'

        Should -Invoke Connect-AuGitHub -ModuleName Aura -Times 1 -Exactly -ParameterFilter { $Organization -eq 'myorg' }
    }

    It 'Validates Active Directory when -Service ActiveDirectory is specified' {
        Mock Get-ADRootDSE -ModuleName Aura {
            [PSCustomObject]@{
                defaultNamingContext       = 'DC=contoso,DC=com'
                configurationNamingContext = 'CN=Configuration,DC=contoso,DC=com'
                schemaNamingContext        = 'CN=Schema,CN=Configuration,DC=contoso,DC=com'
                dnsHostName                = 'dc01.contoso.com'
            }
        }

        Connect-Aura -Service ActiveDirectory

        Should -Invoke Get-ADRootDSE -ModuleName Aura -Times 1 -Exactly
    }

    It 'Does not call opt-in services when -Service All is specified' {
        Mock Get-AzContext -ModuleName Aura { [PSCustomObject]@{ Account = 'test@contoso.com' } }
        Mock Get-AuDataverseEnvironmentUrl -ModuleName Aura { $null }
        Mock Connect-ExchangeOnline -ModuleName Aura {}
        Mock Connect-IPPSSession -ModuleName Aura {}
        Mock Get-ConnectionInformation -ModuleName Aura { @() }
        Mock Connect-MgGraph -ModuleName Aura {}
        Mock Connect-MicrosoftTeams -ModuleName Aura {}
        Mock Connect-AuGitHub -ModuleName Aura { throw 'Connect-AuGitHub should not be called for -Service All.' }
        Mock Get-ADRootDSE -ModuleName Aura { throw 'Get-ADRootDSE should not be called for -Service All.' }

        Connect-Aura -Service All 3>$null 6>$null

        Should -Invoke Connect-AuGitHub -ModuleName Aura -Times 0 -Exactly
        Should -Invoke Get-ADRootDSE -ModuleName Aura -Times 0 -Exactly
    }
}

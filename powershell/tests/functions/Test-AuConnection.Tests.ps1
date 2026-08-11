BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force

    # Bypass Pester's slow command-resolution path when MS service modules are not loaded
    # in the test environment. Track which stubs we created so AfterAll cleans up only
    # those — never touch real cmdlets that were already present.
    $script:createdStubs = @()
    foreach ($cmd in 'Get-AzContext','Invoke-AzRestMethod','Get-MgContext','Get-CsTenant','Get-PnPConnection') {
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

Describe 'Test-AuConnection — Active Directory service' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.ADConnection = $null
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.ADConnection = $null
        }
    }

    It 'Offers ActiveDirectory as a -Service option' {
        $serviceParameter = (Get-Command Test-AuConnection).Parameters['Service']
        $validateSet = $serviceParameter.Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } |
            Select-Object -First 1

        $validateSet.ValidValues | Should -Contain 'ActiveDirectory'
    }

    It 'Documents that Active Directory requires an explicit connection and is not included in All' {
        $help = Get-Help Test-AuConnection -Detailed | Out-String
        $help | Should -Match 'Active Directory and GitHub require an explicit connection'
        $help | Should -Match 'Active Directory is not included in -Service All'
    }

    It 'Returns false before Connect-Aura validates Active Directory' {
        Test-AuConnection -Service ActiveDirectory | Should -BeFalse
    }

    It 'Returns true after Connect-Aura validates Active Directory' {
        InModuleScope Aura {
            $__AuSession.ADConnection = [PSCustomObject]@{
                Connected            = $true
                DomainController     = 'dc01.contoso.com'
                DefaultNamingContext = 'DC=contoso,DC=com'
            }
        }

        Test-AuConnection -Service ActiveDirectory | Should -BeTrue
    }

    It 'Returns Active Directory details only when explicitly requested' {
        InModuleScope Aura {
            $__AuSession.ADConnection = [PSCustomObject]@{
                Connected        = $true
                DomainController = 'dc01.contoso.com'
            }
        }

        $result = Test-AuConnection -Service ActiveDirectory -Details

        $result.ActiveDirectory.Connected | Should -BeTrue
        $result.ActiveDirectory.DomainController | Should -Be 'dc01.contoso.com'
        $result.AllConnected | Should -BeTrue
    }

    It 'Formats Active Directory connection details' {
        InModuleScope Aura {
            $__AuSession.ADConnection = [PSCustomObject]@{
                Connected                  = $true
                DomainController           = 'dc01.contoso.com'
                DefaultNamingContext       = 'DC=contoso,DC=com'
                ConfigurationNamingContext = 'CN=Configuration,DC=contoso,DC=com'
                SchemaNamingContext        = 'CN=Schema,CN=Configuration,DC=contoso,DC=com'
            }
        }

        $rendered = Test-AuConnection -Service ActiveDirectory -Details | Out-String

        $rendered | Should -Match 'Active Directory'
        $rendered | Should -Match 'dc01.contoso.com'
        $rendered | Should -Match 'DC=contoso,DC=com'
    }
}

Describe 'Test-AuConnection — GitHub service' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection      = $null
            $__AuSession.ADConnection          = $null
            $__AuSession.AzureDevOpsConnectionCache = $null
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection      = $null
            $__AuSession.ADConnection          = $null
            $__AuSession.AzureDevOpsConnectionCache = $null
        }
    }

    Context 'Help' {
        It 'Documents the -Service All GitHub explicit connection behavior' {
            $help = Get-Help Test-AuConnection -Detailed | Out-String
            $help | Should -Match 'not included in -Service All'
            $help | Should -Not -Match 'NotCalled sentinel'
            $help | Should -Match 'current session state is included in the default -Details summary'
        }
    }

    Context 'When Connect-AuGitHub has never been called' {
        It 'Returns $false for -Service GitHub' {
            InModuleScope Aura {
                Test-AuConnection -Service GitHub | Should -BeFalse
            }
        }

        It 'Records that Connect-AuGitHub has not been called' {
            InModuleScope Aura {
                Test-AuConnection -Service GitHub | Out-Null
                $__AuSession.GitHubConnection | Should -Not -BeNullOrEmpty
                $__AuSession.GitHubConnection.FailureReason | Should -Be 'NotCalled'
            }
        }
    }

    Context 'When GitHub is explicitly disconnected' {
        It 'Returns $false when Connected is $false' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $false; FailureReason = 'TokenInvalid' }
                Test-AuConnection -Service GitHub | Should -BeFalse
            }
        }

        It 'Returns $false when membership is pending (FailureReason = OrgMembershipPending)' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $false; FailureReason = 'OrgMembershipPending' }
                Test-AuConnection -Service GitHub | Should -BeFalse
            }
        }
    }

    Context 'When GitHub is connected' {
        It 'Returns $true' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                Test-AuConnection -Service GitHub | Should -BeTrue
            }
        }

        It 'Returns an object with GitHub populated and AllConnected $true when using -Details' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $result = Test-AuConnection -Service GitHub -Details
                $result.GitHub | Should -Not -BeNullOrEmpty
                $result.GitHub.Connected | Should -BeTrue
                $result.AllConnected | Should -BeTrue
            }
        }
    }

    Context 'When GitHub is not connected' {
        It 'Returns an object with GitHub $null and AllConnected $false when using -Details' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $false; FailureReason = 'NoToken' }
                $result = Test-AuConnection -Service GitHub -Details
                $result.GitHub | Should -BeNullOrEmpty
                $result.AllConnected | Should -BeFalse
            }
        }
    }

    Context '-Service GitHub -Details with GitHub connected' {
        It 'Populates the GitHub property and returns AllConnected $true' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
            }
            $result = Test-AuConnection -Service GitHub -Details
            $result.GitHub | Should -Not -BeNullOrEmpty
            $result.GitHub.Connected | Should -BeTrue
            $result.AllConnected | Should -BeTrue
        }
    }

    Context '-Service All - GitHub is not included' {
        It 'Returns AllConnected $true when all included services are connected and GitHub session is absent' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection      = $null
                $__AuSession.AzureDevOpsConnectionCache = [PSCustomObject]@{ Organization = 'ado-org' }
            }
            Mock Get-AzContext { [PSCustomObject]@{ Account = 'test@contoso.com' } } -ModuleName Aura
            Mock Invoke-AzRestMethod { [PSCustomObject]@{} } -ModuleName Aura
            Mock Get-MgContext { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            Mock Get-AuExo {
                @(
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $false }
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $true }
                )
            } -ModuleName Aura
            Mock Get-CsTenant { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            Mock Get-PnPConnection { [PSCustomObject]@{ Url = 'https://contoso.sharepoint.com' } } -ModuleName Aura
            $result = Test-AuConnection -Service All -Details
            $result.AllConnected | Should -BeTrue
            $result.GitHub | Should -BeNullOrEmpty
            InModuleScope Aura {
                $__AuSession.GitHubConnection | Should -BeNullOrEmpty
            }
        }
    }

    Context '-Service All - GitHub NotCalled sentinel is ignored' {
        It 'does not set the GitHub details property' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection      = [PSCustomObject]@{ Connected = $false; FailureReason = 'NotCalled' }
                $__AuSession.AzureDevOpsConnectionCache = 'NotConnected'
            }
            Mock Get-AzContext { [PSCustomObject]@{ Account = 'test@contoso.com' } } -ModuleName Aura
            Mock Invoke-AzRestMethod { [PSCustomObject]@{} } -ModuleName Aura
            Mock Get-MgContext { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            Mock Get-AuExo {
                @(
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $false }
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $true }
                )
            } -ModuleName Aura
            Mock Get-CsTenant { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            $result = Test-AuConnection -Service All -Details
            $result.AllConnected | Should -BeFalse
            $result.GitHub | Should -BeNullOrEmpty
        }
    }

    Context '-Service GitHub -Details formatted output' {
        It 'Renders safe GitHub metadata and excludes auth/token values' {
            $fakeToken = 'ghp_FAKE_TOKEN_VALUE_DO_NOT_USE'
            InModuleScope Aura -ArgumentList $fakeToken {
                param($FakeToken)
                $__AuSession.GitHubConnection = [PSCustomObject]@{
                    Connected                        = $true
                    Organization                     = 'myorg'
                    TokenLogin                       = 'octocat'
                    ApiBaseUri                       = 'https://api.github.com'
                    ApiVersion                       = '2022-11-28'
                    Role                             = 'admin'
                    RoleState                        = 'active'
                    AdministrationPermissionVerified = $true
                }
                $__AuSession.GitHubAuthHeader = @{
                    Authorization = "Bearer $FakeToken"
                }
            }
            $rendered = Test-AuConnection -Service GitHub -Details | Out-String
            $rendered | Should -Match 'GitHub'
            $rendered | Should -Match 'myorg'
            $rendered | Should -Match 'octocat'
            $rendered | Should -Not -Match 'Bearer'
            $rendered | Should -Not -Match 'Authorization'
            $rendered | Should -Not -Match ([regex]::Escape($fakeToken))
        }
    }

    Context '-Service All — GitHub connected session is ignored' {
        It 'Does not populate the GitHub or Active Directory properties' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection      = [PSCustomObject]@{ Connected = $true; Organization = 'myorg' }
                $__AuSession.ADConnection          = [PSCustomObject]@{ Connected = $true; DomainController = 'dc01.contoso.com' }
                $__AuSession.AzureDevOpsConnectionCache = 'NotConnected'
            }
            Mock Get-AzContext { [PSCustomObject]@{ Account = 'test@contoso.com' } } -ModuleName Aura
            Mock Invoke-AzRestMethod { [PSCustomObject]@{} } -ModuleName Aura
            Mock Get-MgContext { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            Mock Get-AuExo {
                @(
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $false }
                    [PSCustomObject]@{ Name = 'ExchangeOnline'; State = 'Connected'; IsEopSession = $true }
                )
            } -ModuleName Aura
            Mock Get-CsTenant { [PSCustomObject]@{ TenantId = 'tenant-id' } } -ModuleName Aura
            $result = Test-AuConnection -Service All -Details
            $result.GitHub | Should -BeNullOrEmpty
            $result.ActiveDirectory | Should -BeNullOrEmpty
        }
    }
}

Describe 'Test-AuConnection — Microsoft Graph scopes' {
    It 'Returns included and missing Graph scopes when Details is requested' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                TenantId   = 'tenant-id'
                Environment = 'Global'
                Account    = 'admin@contoso.com'
                AuthType   = 'Delegated'
                Scopes     = @(
                    'Directory.Read.All'
                    'Policy.Read.ConditionalAccess'
                )
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            @(
                'Directory.Read.All'
                'Policy.Read.ConditionalAccess'
                'Reports.Read.All'
            )
        } -ModuleName Aura

        $Result = Test-AuConnection -Service Graph -Details

        @($Result.Graph.Scopes).Count | Should -Be 2
        $Result.Graph.Scopes | Should -Contain 'Directory.Read.All'
        $Result.Graph.Scopes | Should -Contain 'Policy.Read.ConditionalAccess'

        $Result.Graph.PSObject.Properties['MissingScopes'] |
            Should -BeNullOrEmpty

        $Result.GraphScopeDetails.EvaluationStatus | Should -Be 'Succeeded'
        @($Result.GraphScopeDetails.IncludedScopes).Count | Should -Be 2
        @($Result.GraphScopeDetails.RequiredScopes).Count | Should -Be 3
        @($Result.GraphScopeDetails.MissingScopes).Count | Should -Be 1
        $Result.GraphScopeDetails.MissingScopes | Should -Contain 'Reports.Read.All'

        $Result.AllConnected | Should -BeTrue
    }

    It 'Treats a ReadWrite scope as satisfying the corresponding Read scope' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                TenantId   = 'tenant-id'
                Environment = 'Global'
                Account    = 'admin@contoso.com'
                AuthType   = 'Delegated'
                Scopes     = @(
                    'Directory.Read.All'
                    'Policy.ReadWrite.ConditionalAccess'
                    'User.ReadWrite'
                )
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            @(
                'Directory.Read.All'
                'Policy.Read.ConditionalAccess'
                'User.Read'
            )
        } -ModuleName Aura

        $Result = Test-AuConnection -Service Graph -Details

        $Result.Graph.Scopes |
            Should -Contain 'Policy.ReadWrite.ConditionalAccess'

        $Result.Graph.Scopes |
            Should -Contain 'User.ReadWrite'

        $Result.GraphScopeDetails.MissingScopes |
            Should -Not -Contain 'Policy.Read.ConditionalAccess'

        $Result.GraphScopeDetails.MissingScopes |
            Should -Not -Contain 'User.Read'
    }

    It 'Returns disconnected state when no Graph context exists' {
        Mock Get-MgContext { $null } -ModuleName Aura

        $Result = Test-AuConnection -Service Graph -Details

        $Result.Graph | Should -BeNullOrEmpty
        $Result.AllConnected | Should -BeFalse
    }

    It 'Formats included and missing Graph scopes' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                TenantId    = 'tenant-id'
                Environment = 'Global'
                Account     = 'admin@contoso.com'
                AuthType    = 'Delegated'
                Scopes      = @('Directory.Read.All')
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            @(
                'Directory.Read.All'
                'Reports.Read.All'
            )
        } -ModuleName Aura

        $Rendered = Test-AuConnection -Service Graph -Details | Out-String

        $Rendered | Should -Match 'Included scopes:\s+1'
        $Rendered | Should -Match 'Directory\.Read\.All'
        $Rendered | Should -Match 'Missing scopes:\s+1'
        $Rendered | Should -Match 'Reports\.Read\.All'
    }

    It 'Does not evaluate Graph scopes when Details is not requested' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                Scopes = @('Directory.Read.All')
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            throw 'Scope evaluation should not run'
        } -ModuleName Aura

        Test-AuConnection -Service Graph |
            Should -BeTrue

        Should -Invoke Get-AuGraphScope `
            -ModuleName Aura `
            -Times 0 `
            -Exactly
    }

    It 'Keeps the Graph connection details when scope evaluation fails' {
        Mock Get-MgContext {
            [PSCustomObject]@{
                TenantId    = 'tenant-id'
                Environment = 'Global'
                Account     = 'admin@contoso.com'
                AuthType    = 'Delegated'
                Scopes      = @('Directory.Read.All')
            }
        } -ModuleName Aura

        Mock Get-AuGraphScope {
            throw 'Unable to retrieve required scopes'
        } -ModuleName Aura

        $Result = Test-AuConnection -Service Graph -Details

        $Result.Graph | Should -Not -BeNullOrEmpty
        $Result.Graph.TenantId | Should -Be 'tenant-id'
        $Result.Graph.PSObject.Properties['MissingScopes'] |
            Should -BeNullOrEmpty
        $Result.GraphScopeDetails.EvaluationStatus | Should -Be 'Failed'
        @($Result.GraphScopeDetails.IncludedScopes).Count | Should -Be 1
        $Result.GraphScopeDetails.MissingScopes | Should -BeNullOrEmpty
        $Result.AllConnected | Should -BeTrue

        $Rendered = $Result | Out-String

        $Rendered | Should -Match 'Missing scopes:\s+\(scope evaluation failed\)'

        $Rendered | Should -Not -Match 'Missing scopes:\s+0'
    }
}

Describe 'Test-AuConnection — requested service formatting' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.ADConnection = $null
            $__AuSession.GitHubConnection = $null
            $__AuSession.AzureDevOpsConnectionCache = $null
        }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.ADConnection = $null
            $__AuSession.GitHubConnection = $null
            $__AuSession.AzureDevOpsConnectionCache = $null
        }
    }

    It 'Shows a complete summary with Microsoft Graph first and opt-in services last' {
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache = 'NotConnected'
        }
        Mock Get-AzContext { $null } -ModuleName Aura
        Mock Get-MgContext { $null } -ModuleName Aura
        Mock Get-AuExo { @() } -ModuleName Aura
        Mock Get-CsTenant { $null } -ModuleName Aura
        Mock Get-PnPConnection { $null } -ModuleName Aura

        $Result = Test-AuConnection -Details
        $Rendered = $Result | Out-String

        @($Result.ServicesChecked) |
            Should -Be @('All', 'ActiveDirectory', 'GitHub')

        $ExpectedServiceOrder = @(
            'Microsoft Graph'
            'Azure'
            'Azure DevOps'
            'Exchange Online'
            'Exchange Online Protection'
            'SharePoint Online'
            'Microsoft Teams'
            'Active Directory'
            'GitHub'
        )

        $ExpectedServiceOrder | ForEach-Object {
            $Rendered | Should -Match "(?m)^$([regex]::Escape($_))\s+: Not connected\r?$"
        }

        for ($i = 1; $i -lt $ExpectedServiceOrder.Count; $i++) {
            $Rendered.IndexOf($ExpectedServiceOrder[$i]) |
                Should -BeGreaterThan $Rendered.IndexOf($ExpectedServiceOrder[$i - 1])
        }
        $Result.AllConnected | Should -BeFalse
    }

    It 'Keeps the default Boolean check scoped to Microsoft Graph' {
        Mock Get-MgContext { $null } -ModuleName Aura
        Mock Get-AzContext {
            throw 'Azure should not be checked by the default Boolean call.'
        } -ModuleName Aura

        Test-AuConnection | Should -BeFalse

        Should -Invoke Get-AzContext `
            -ModuleName Aura `
            -Times 0 `
            -Exactly
    }

    It 'Shows each explicitly requested disconnected service and hides unrequested services' {
        Mock Get-MgContext { $null } -ModuleName Aura

        $Result = Test-AuConnection -Service Graph, GitHub -Details
        $Rendered = $Result | Out-String

        @($Result.ServicesChecked) | Should -Be @('Graph', 'GitHub')
        $Rendered | Should -Match '(?m)^Microsoft Graph\s+: Not connected\r?$'
        $Rendered | Should -Match '(?m)^GitHub\s+: Not connected\r?$'
        $Rendered | Should -Not -Match '(?m)^Azure\s+:'
    }

    It 'Shows connection status for every service included by All' {
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache = 'NotConnected'
        }
        Mock Get-AzContext { $null } -ModuleName Aura
        Mock Get-MgContext { $null } -ModuleName Aura
        Mock Get-AuExo { @() } -ModuleName Aura
        Mock Get-CsTenant { $null } -ModuleName Aura
        Mock Get-PnPConnection { $null } -ModuleName Aura

        $Rendered = Test-AuConnection -Service All -Details | Out-String

        $ExpectedServiceOrder = @(
            'Microsoft Graph'
            'Azure'
            'Azure DevOps'
            'Exchange Online'
            'Exchange Online Protection'
            'SharePoint Online'
            'Microsoft Teams'
        )

        $ExpectedServiceOrder | ForEach-Object {
            $Rendered | Should -Match "(?m)^$([regex]::Escape($_))\s+: Not connected\r?$"
        }

        for ($i = 1; $i -lt $ExpectedServiceOrder.Count; $i++) {
            $Rendered.IndexOf($ExpectedServiceOrder[$i]) |
                Should -BeGreaterThan $Rendered.IndexOf($ExpectedServiceOrder[$i - 1])
        }

        $Rendered | Should -Not -Match '(?m)^Active Directory\s+:'
        $Rendered | Should -Not -Match '(?m)^GitHub\s+:'
    }

    It 'Shows Exchange Online Protection for either service alias' -TestCases @(
        @{ Service = 'EOP' }
        @{ Service = 'SecurityCompliance' }
    ) {
        param($Service)

        Mock Get-AuExo { @() } -ModuleName Aura

        $Rendered = Test-AuConnection -Service $Service -Details | Out-String

        $Rendered |
            Should -Match '(?m)^Exchange Online Protection\s+: Not connected\r?$'
    }
}

Describe 'Test-AuConnection AzureDevOps cache' {
    BeforeEach {
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache = $null
            $__AuSession.Remove('AzureDevOpsConnection')
        }
    }

    AfterEach {
        InModuleScope Aura {
            Remove-Item -Path function:Get-ADOPSConnection -ErrorAction SilentlyContinue
            $__AuSession.AzureDevOpsConnectionCache = $null
            $__AuSession.Remove('AzureDevOpsConnection')
        }
    }

    It 'caches a successful Azure DevOps probe under a cache-specific key' {
        $result = InModuleScope Aura {
            New-Item -Path function:Get-ADOPSConnection -Value { @{ Organization = 'ado-org' } } -Force | Out-Null
            Test-AuConnection -Service AzureDevOps -Details
        }

        $result.AllConnected | Should -BeTrue
        $result.AzureDevOps['Organization'] | Should -Be 'ado-org'
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache['Organization'] | Should -Be 'ado-org'
            $__AuSession.ContainsKey('AzureDevOpsConnection') | Should -BeFalse
        }
    }

    It 'caches a failed Azure DevOps probe as NotConnected' {
        $result = InModuleScope Aura {
            New-Item -Path function:Get-ADOPSConnection -Value { $null } -Force | Out-Null
            Test-AuConnection -Service AzureDevOps -Details
        }

        $result.AllConnected | Should -BeFalse
        $result.AzureDevOps | Should -BeNullOrEmpty
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache | Should -Be 'NotConnected'
            $__AuSession.ContainsKey('AzureDevOpsConnection') | Should -BeFalse
        }
    }

    It 'uses the cached Azure DevOps probe result without re-querying the external command' {
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache = @{ Organization = 'cached-org' }
        }
        $result = InModuleScope Aura {
            New-Item -Path function:Get-ADOPSConnection -Value { throw 'Get-ADOPSConnection should not be called when cache exists.' } -Force | Out-Null
            Test-AuConnection -Service AzureDevOps -Details
        }

        $result.AllConnected | Should -BeTrue
        $result.AzureDevOps['Organization'] | Should -Be 'cached-org'
    }

    It 'clears the Azure DevOps probe cache during module-variable reset' {
        InModuleScope Aura {
            $__AuSession.AzureDevOpsConnectionCache = @{ Organization = 'cached-org' }

            Clear-ModuleVariable

            $__AuSession.AzureDevOpsConnectionCache | Should -BeNullOrEmpty
            $__AuSession.ContainsKey('AzureDevOpsConnection') | Should -BeFalse
        }
    }
}

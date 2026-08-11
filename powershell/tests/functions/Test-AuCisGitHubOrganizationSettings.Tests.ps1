BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'CIS GitHub organization setting tests' {
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
            $__AuSession.AuraConfig    = [PSCustomObject]@{ GlobalSettings = [PSCustomObject]@{} }
        }

        $script:orgResponse = [PSCustomObject]@{
            login                                    = 'myorg'
            members_can_create_public_repositories  = $false
            members_can_create_private_repositories = $false
            members_can_create_internal_repositories = $false
            members_allowed_repository_creation_type = 'none'
            members_can_delete_repositories         = $false
            members_can_delete_issues               = $false
            members_can_create_teams                = $false
            default_repository_permission           = 'read'
        }

        Mock Invoke-AuGitHubRequest -ModuleName Aura { $script:orgResponse }
        Mock Add-AuTestResultDetail -ModuleName Aura { }
    }

    AfterEach {
        InModuleScope Aura {
            $__AuSession.GitHubConnection = $null
            $__AuSession.GitHubAuthHeader = $null
            $__AuSession.GitHubCache      = @{}
            $__AuSession.AuraConfig    = $null
        }
    }

    Context 'Helpers' {
        It 'Test-AuGitHubObjectProperty treats a $false property as present' {
            InModuleScope Aura {
                $obj = [PSCustomObject]@{ members_can_delete_issues = $false }
                Test-AuGitHubObjectProperty -InputObject $obj -PropertyName 'members_can_delete_issues' | Should -BeTrue
                Test-AuGitHubObjectProperty -InputObject $obj -PropertyName 'missing_field' | Should -BeFalse
            }
        }

        It 'Get-AuGitHubOrganization uses the connected organization and request cache helper' {
            InModuleScope Aura {
                $result = Get-AuGitHubOrganization
                $result.login | Should -Be 'myorg'
            }
            Should -Invoke Invoke-AuGitHubRequest -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $RelativeUri -eq '/orgs/myorg'
            }
        }

        It 'Get-AuGitHubOrganization throws when GitHub is not connected' {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = $null
                { Get-AuGitHubOrganization } | Should -Throw -ExpectedMessage 'Not connected to GitHub. Call Connect-AuGitHub first.'
            }
        }
    }

    Context 'Pass cases' {
        It 'Passes repository creation when API evidence is compliant' {
            Test-AuCisGitHubRepositoryCreationLimited | Should -BeTrue
        }

        It 'Passes team creation when API evidence is compliant' {
            Test-AuCisGitHubTeamCreationLimited | Should -BeTrue
        }

        It 'Passes strict base permissions when API evidence is compliant' {
            Test-AuCisGitHubStrictBasePermission | Should -BeTrue
        }

        It 'Passes repository creation when the internal repository field is not returned' {
            $script:orgResponse = [PSCustomObject]@{
                members_can_create_public_repositories  = $false
                members_can_create_private_repositories = $false
            }

            Test-AuCisGitHubRepositoryCreationLimited | Should -BeTrue
        }

        It 'Passes repository creation when only returned internal repository creation is allowed' {
            $script:orgResponse.members_can_create_internal_repositories = $true

            Test-AuCisGitHubRepositoryCreationLimited | Should -BeTrue
        }

        It 'Passes when GitHub returns mixed-case Read because -contains is case-insensitive' {
            # This documents PowerShell's default case-insensitive -contains behavior.
            $script:orgResponse.default_repository_permission = 'Read'

            Test-AuCisGitHubStrictBasePermission | Should -BeTrue
        }
    }

    Context 'Result rendering' {
        $renderingCases = @(
            @{
                Function        = 'Test-AuCisGitHubRepositoryCreationLimited'
                Id              = 'CIS.GH.1.2.2'
                ExpectedRows    = @(
                    '\| `members_can_create_public_repositories` \| `False` \| `False` \|'
                    '\| `members_can_create_private_repositories` \| `False` \| `False` \|'
                    '\| `members_can_create_internal_repositories` \| `False` \| `Informational` \|'
                )
                HasLegacyFooter = $true
                HasInternalNote = $true
                IsInvestigate   = $false
            }
            @{
                Function        = 'Test-AuCisGitHubRepositoryDeletionLimited'
                Id              = 'CIS.GH.1.2.3'
                ExpectedRows    = @('\| `members_can_delete_repositories` \| `False` \| `False` \|')
                HasLegacyFooter = $false
                HasInternalNote = $false
                IsInvestigate   = $true
            }
            @{
                Function        = 'Test-AuCisGitHubIssueDeletionLimited'
                Id              = 'CIS.GH.1.2.4'
                ExpectedRows    = @('\| `members_can_delete_issues` \| `False` \| `False` \|')
                HasLegacyFooter = $false
                HasInternalNote = $false
                IsInvestigate   = $true
            }
            @{
                Function        = 'Test-AuCisGitHubTeamCreationLimited'
                Id              = 'CIS.GH.1.3.2'
                ExpectedRows    = @('\| `members_can_create_teams` \| `False` \| `False` \|')
                HasLegacyFooter = $false
                HasInternalNote = $false
                IsInvestigate   = $false
            }
            @{
                Function        = 'Test-AuCisGitHubStrictBasePermission'
                Id              = 'CIS.GH.1.3.8'
                ExpectedRows    = @('\| `default_repository_permission` \| `read` \| `none` or `read` \|')
                HasLegacyFooter = $false
                HasInternalNote = $false
                IsInvestigate   = $false
            }
        )

        It 'Renders <Function> with the common evidence table shape' -ForEach $renderingCases {
            $functionResult = & $Function
            if ($IsInvestigate) {
                $functionResult | Should -BeNullOrEmpty
            } else {
                $functionResult | Should -BeTrue
            }

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $Result -match "$Id automated evidence from ``GET /orgs/\{org\}``\." -and
                $Result -match '\| Field \| Actual \| Expected \|' -and
                $Result -match '\| --- \| --- \| --- \|' -and
                (($IsInvestigate -and $Investigate -eq $true) -or (-not $IsInvestigate -and -not $Investigate))
            }

            foreach ($row in $ExpectedRows) {
                Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                    $Result -match $row
                }
            }

            if ($HasLegacyFooter) {
                Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                    $Result -match 'Deprecated umbrella field `members_allowed_repository_creation_type` was returned as `none`' -and
                    $Result -match 'granular fields above are the decisive checks'
                }
            } else {
                Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                    $Result -notmatch 'Deprecated umbrella field'
                }
            }

            if ($HasInternalNote) {
                Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                    $Result -match "The internal-repository row is informational\. CIS GH 1\.2\.2's literal audit covers public and private only\."
                }
            }
        }

        It 'Renders repository creation deprecated umbrella footer when the umbrella field is omitted' {
            $script:orgResponse = [PSCustomObject]@{
                login                                    = 'myorg'
                members_can_create_public_repositories  = $false
                members_can_create_private_repositories = $false
            }

            Test-AuCisGitHubRepositoryCreationLimited | Should -BeTrue

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $Result -match '\| `members_can_create_public_repositories` \| `False` \| `False` \|' -and
                $Result -match '\| `members_can_create_private_repositories` \| `False` \| `False` \|' -and
                $Result -match 'Deprecated umbrella field `members_allowed_repository_creation_type` was not returned' -and
                $Result -match 'granular fields above are the decisive checks'
            }
        }
    }

    Context 'Fail cases' {
        $failCases = @(
            @{
                Name     = 'repository creation when public repository creation is allowed'
                Function = 'Test-AuCisGitHubRepositoryCreationLimited'
                Mutate   = { $script:orgResponse.members_can_create_public_repositories = $true }
            }
            @{
                Name     = 'team creation when member team creation is allowed'
                Function = 'Test-AuCisGitHubTeamCreationLimited'
                Mutate   = { $script:orgResponse.members_can_create_teams = $true }
            }
            @{
                Name     = 'strict base permissions when default permission is write'
                Function = 'Test-AuCisGitHubStrictBasePermission'
                Mutate   = { $script:orgResponse.default_repository_permission = 'write' }
            }
        )

        It 'Fails <Name>' -ForEach $failCases {
            & $Mutate
            & $Function | Should -BeFalse
        }

    }

    Context 'Manual review required' {
        It 'Marks repository deletion as investigate when member repository deletion is disabled' {
            Test-AuCisGitHubRepositoryDeletionLimited | Should -BeNullOrEmpty

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                -not $SkippedBecause -and
                -not $SkippedCustomReason -and
                $Investigate -eq $true -and
                $Result -match 'Manual review required' -and
                $Result -match 'organization owners are trusted and qualified' -and
                $Result -match '\| `members_can_delete_repositories` \| `False` \| `False` \|'
            }
        }

        It 'Marks repository deletion as investigate when member repository deletion is enabled' {
            $script:orgResponse.members_can_delete_repositories = $true

            Test-AuCisGitHubRepositoryDeletionLimited | Should -BeNullOrEmpty

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                -not $SkippedBecause -and
                -not $SkippedCustomReason -and
                $Investigate -eq $true -and
                $Result -match 'Manual review required' -and
                $Result -match 'repository admin members are trusted and qualified' -and
                $Result -match '\| `members_can_delete_repositories` \| `True` \| `False` \|'
            }
        }

        It 'Marks issue deletion as investigate when member issue deletion is disabled' {
            Test-AuCisGitHubIssueDeletionLimited | Should -BeNullOrEmpty

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                -not $SkippedBecause -and
                -not $SkippedCustomReason -and
                $Investigate -eq $true -and
                $Result -match 'Manual review required' -and
                $Result -match 'organization owners are trusted and qualified' -and
                $Result -match '\| `members_can_delete_issues` \| `False` \| `False` \|'
            }
        }

        It 'Marks issue deletion as investigate when member issue deletion is enabled' {
            $script:orgResponse.members_can_delete_issues = $true

            Test-AuCisGitHubIssueDeletionLimited | Should -BeNullOrEmpty

            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                -not $SkippedBecause -and
                -not $SkippedCustomReason -and
                $Investigate -eq $true -and
                $Result -match 'Manual review required' -and
                $Result -match 'repository admin members are trusted and qualified' -and
                $Result -match '\| `members_can_delete_issues` \| `True` \| `False` \|'
            }
        }
    }

    Context 'Missing evidence' {
        $missingFieldCases = @(
            @{
                Function = 'Test-AuCisGitHubRepositoryCreationLimited'
                Field    = 'members_can_create_public_repositories'
            }
            @{
                Function = 'Test-AuCisGitHubRepositoryDeletionLimited'
                Field    = 'members_can_delete_repositories'
            }
            @{
                Function = 'Test-AuCisGitHubIssueDeletionLimited'
                Field    = 'members_can_delete_issues'
            }
            @{
                Function = 'Test-AuCisGitHubTeamCreationLimited'
                Field    = 'members_can_create_teams'
            }
            @{
                Function = 'Test-AuCisGitHubStrictBasePermission'
                Field    = 'default_repository_permission'
            }
        )

        It 'Skips <Function> when <Field> is missing' -ForEach $missingFieldCases {
            $script:orgResponse = [PSCustomObject]@{ login = 'myorg' }

            & $Function | Should -BeNullOrEmpty
            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $SkippedBecause -eq 'Custom' -and $SkippedCustomReason -match $Field
            }
        }
    }

    Context 'Disconnected GitHub' {
        $functions = @(
            'Test-AuCisGitHubRepositoryCreationLimited'
            'Test-AuCisGitHubRepositoryDeletionLimited'
            'Test-AuCisGitHubIssueDeletionLimited'
            'Test-AuCisGitHubTeamCreationLimited'
            'Test-AuCisGitHubStrictBasePermission'
        )

        It 'Skips <_> when GitHub is not connected' -ForEach $functions {
            InModuleScope Aura {
                $__AuSession.GitHubConnection = $null
            }

            & $_ | Should -BeNullOrEmpty
            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $SkippedBecause -eq 'NotConnectedGitHub'
            }
            Should -Invoke Invoke-AuGitHubRequest -ModuleName Aura -Exactly -Times 0
        }
    }

    Context 'GitHub request errors' {
        $functions = @(
            'Test-AuCisGitHubRepositoryCreationLimited'
            'Test-AuCisGitHubRepositoryDeletionLimited'
            'Test-AuCisGitHubIssueDeletionLimited'
            'Test-AuCisGitHubTeamCreationLimited'
            'Test-AuCisGitHubStrictBasePermission'
        )

        It 'Skips <_> when the GitHub organization request throws' -ForEach $functions {
            Mock Invoke-AuGitHubRequest -ModuleName Aura { throw 'GitHub API boom' }

            & $_ | Should -BeNullOrEmpty
            Should -Invoke Add-AuTestResultDetail -ModuleName Aura -Exactly -Times 1 -ParameterFilter {
                $SkippedBecause -eq 'Error' -and $null -ne $SkippedError
            }
        }
    }
}

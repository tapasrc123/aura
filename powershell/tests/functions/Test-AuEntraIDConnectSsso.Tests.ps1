Describe 'Test-AuEntraIDConnectSsso' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../Aura.psd1 -Force
    }

    BeforeEach {
        $script:SkippedBecause = $null
        $script:SkippedCustomReason = $null

        Mock -ModuleName Aura Test-AuConnection { return $true }
        Mock -ModuleName Aura Add-AuTestResultDetail {
            param($SkippedBecause, $SkippedCustomReason)
            $script:SkippedBecause = $SkippedBecause
            $script:SkippedCustomReason = $SkippedCustomReason
        }
    }

    It 'skips when the DeviceInfo hunting table is unavailable' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            param($RelativeUri, $Body)

            if ($RelativeUri -eq 'organization') {
                return [PSCustomObject]@{ onPremisesSyncEnabled = $true }
            }
            if ($Body -match 'IdentityLogonEvents') {
                return [PSCustomObject]@{
                    results = @([PSCustomObject]@{ ColumnName = 'LogonType' })
                }
            }
            if ($Body -match 'DeviceInfo') {
                throw "POST https://graph.microsoft.com/beta/security/runHuntingQuery HTTP/1.1 400 Bad Request: 'getschema' operator: Failed to resolve table or column expression named 'DeviceInfo'."
            }
        }

        Test-AuEntraIDConnectSsso | Should -BeNull
        $script:SkippedBecause | Should -Be 'Custom'
        $script:SkippedCustomReason | Should -BeLike '*IdentityLogonEvents and DeviceInfo*'
    }

    It 'keeps unrelated bad requests classified as errors' {
        Mock -ModuleName Aura Invoke-AuGraphRequest {
            param($RelativeUri, $Body)

            if ($RelativeUri -eq 'organization') {
                return [PSCustomObject]@{ onPremisesSyncEnabled = $true }
            }
            if ($Body -match 'IdentityLogonEvents') {
                throw 'POST https://graph.microsoft.com/beta/security/runHuntingQuery HTTP/1.1 400 Bad Request: The query is invalid for another reason.'
            }
        }

        Test-AuEntraIDConnectSsso | Should -BeNull
        $script:SkippedBecause | Should -Be 'Error'
        $script:SkippedCustomReason | Should -BeNull
    }
}

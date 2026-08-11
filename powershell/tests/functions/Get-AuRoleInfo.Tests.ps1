BeforeAll {
    Import-Module $PSScriptRoot/../../Aura.psd1 -Force
}

Describe 'Get-AuRoleInfo' -Tag 'Unit' {
    Context 'role table resilience' {
        # Regression test for the MT.1020 (Test-AuCaExclusionForDirectorySyncAccount)
        # failure: under Invoke-Aura the module-load-time assignment of
        # $script:AuRoles did not persist into the Pester test-execution context, so
        # Get-AuRoleInfo threw "You cannot call a method on a null-valued expression"
        # at $script:AuRoles.ContainsKey(). The fix builds the tables lazily, so a
        # null table at call time self-heals instead of throwing.
        It 'rebuilds the role table when $script:AuRoles is $null at call time' {
            InModuleScope Aura {
                $script:AuRoles = $null
                $script:AuRoleAliases = $null

                $role = Get-AuRoleInfo -RoleName 'DirectorySynchronizationAccounts'

                "$role" | Should -Be 'd29b2b05-8046-44ba-8758-1e26182fcf32'
                $script:AuRoles | Should -Not -BeNullOrEmpty
                $script:AuRoleAliases | Should -Not -BeNull
            }
        }

        It 'resolves aliases when the tables are $null at call time' {
            InModuleScope Aura {
                $script:AuRoles = $null
                $script:AuRoleAliases = $null

                $role = Get-AuRoleInfo -RoleName 'AzureADJoinedDeviceLocalAdministrator'

                "$role" | Should -Be '9f06204d-73c1-4d4c-880a-6edb90606fd8'
            }
        }

        It 'still returns $null for an unknown role after a null table' {
            InModuleScope Aura {
                $script:AuRoles = $null
                $script:AuRoleAliases = $null

                Get-AuRoleInfo -RoleName 'ThisRoleDoesNotExist' | Should -BeNullOrEmpty
            }
        }
    }
}

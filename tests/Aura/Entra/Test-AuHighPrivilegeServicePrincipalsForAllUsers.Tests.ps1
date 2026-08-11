Describe 'Aura/Entra' -Tag 'Aura', 'Entra', 'App', 'Graph' {
    It 'MT.1186: Require explicit assignment of high-privilege first-party Entra Apps. See https://aura.onetapas.com/docs/tests/MT.1186' -Tag 'MT.1186' {
        Test-AuHighPrivilegeServicePrincipalsForAllUsers | Should -Be $true -Because 'high-privilege first-party service principals such as Azure PowerShell, Azure CLI and Azure Developer CLI, Microsoft Graph Command Line Tools, Graph Explorer, and Azure AD PowerShell should require explicit assignment to users'
    }
}

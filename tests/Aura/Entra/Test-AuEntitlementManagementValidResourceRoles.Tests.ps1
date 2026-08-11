Describe "Aura/Entra" -Tag "Aura", "Governance", "Entra", "AccessPackages" {
    It "MT.1106: Catalog resources must have valid roles (no stale / removed app roles or SPNs). See https://aura.onetapas.com/docs/tests/MT.1106" -Tag "MT.1106" {
        $result = Test-AuEntitlementManagementValidResourceRoles
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Catalog resources must have valid roles to ensure proper access provisioning. Stale or removed app roles and service principals can cause assignment failures."
        }
    }
}

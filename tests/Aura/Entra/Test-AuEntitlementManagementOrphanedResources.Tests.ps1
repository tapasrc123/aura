Describe "Aura/Entra" -Tag "Aura", "Governance", "Entra", "AccessPackages" {
    It "MT.1110: No catalog should contain resources without any associated access packages. See https://aura.onetapas.com/docs/tests/MT.1110" -Tag "MT.1110" {
        $result = Test-AuEntitlementManagementOrphanedResources
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Catalog resources without associated access packages indicate configuration drift and should be removed to maintain clean governance setup."
        }
    }
}

Describe "Aura/Entra" -Tag "Aura", "Governance", "Entra", "AccessPackages" {
    It "MT.1107: Access packages and catalogs should not reference deleted groups. See https://aura.onetapas.com/docs/tests/MT.1107" -Tag "MT.1107" {
        $result = Test-AuEntitlementManagementDeletedGroups
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Access packages and catalogs should not reference deleted groups to prevent access provisioning failures and configuration inconsistencies."
        }
    }
}

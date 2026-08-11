Describe "Aura/Entra" -Tag "Aura", "Governance", "Entra", "AccessPackages" {
    It "MT.1108: Access packages should not reference inactive or orphaned assignment policies. See https://aura.onetapas.com/docs/tests/MT.1108" -Tag "MT.1108" {
        $result = Test-AuEntitlementManagementInactivePolicies
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Access packages should not have inactive or misconfigured assignment policies that block access requests or break approval workflows."
        }
    }
}

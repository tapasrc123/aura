Describe "Aura/Entra" -Tag "Aura", "Authentication" {
    It "MT.1067: Authentication method policies should not reference non-existent groups. See https://aura.onetapas.com/docs/tests/MT.1067" -Tag "MT.1067" {

        Test-AuAuthenticationPolicyReferencedObjectsExist | Should -Be $true -Because "authentication method policies should not reference deleted or non-existent groups"
    }
}

Describe "Aura/Entra" -Tag "Aura", "Entra" {
    It "MT.1193: Entra Private Access application segments should avoid broad or risky destinations. See https://aura.onetapas.com/docs/tests/MT.1193" -Tag "MT.1193", "Preview" {
        $result = Test-AuGsaPrivateAccessAppSegmentHygiene

        if ($null -ne $result) {
            $result | Should -Be $true -Because "dnsSuffix, wildcard, single-label, and all-IP segments break least-privilege and can mask DNS gaps or break Kerberos SSO."
        }
    }
}

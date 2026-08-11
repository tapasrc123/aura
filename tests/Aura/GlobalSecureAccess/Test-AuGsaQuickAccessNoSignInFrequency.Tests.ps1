Describe "Aura/Entra" -Tag "Aura", "Entra", "CA" {
    It "MT.1195: The Quick Access app should not be subject to a sign-in frequency Conditional Access control. See https://aura.onetapas.com/docs/tests/MT.1195" -Tag "MT.1195", "Preview" {
        $result = Test-AuGsaQuickAccessNoSignInFrequency

        if ($null -ne $result) {
            $result | Should -Be $true -Because "sign-in frequency on Quick Access re-triggers authentication on Private DNS lookups, causing unexpected prompts."
        }
    }
}

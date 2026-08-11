Describe "Aura/Entra" -Tag "Aura", "Entra", "CA" {
    It "MT.1191: Break-glass accounts should be excluded from the Compliant Network Conditional Access policy. See https://aura.onetapas.com/docs/tests/MT.1191" -Tag "MT.1191", "Preview" {
        $result = Test-AuGsaCompliantNetworkBreakGlassExcluded

        if ($null -ne $result) {
            $result | Should -Be $true -Because "a Compliant Network block policy must never lock out emergency access accounts."
        }
    }
}

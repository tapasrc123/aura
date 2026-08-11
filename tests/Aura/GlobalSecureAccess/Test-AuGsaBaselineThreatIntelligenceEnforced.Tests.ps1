Describe "Aura/Entra" -Tag "Aura", "Entra" {
    It "MT.1194: The baseline Global Secure Access security profile should enforce a threat-intelligence floor. See https://aura.onetapas.com/docs/tests/MT.1194" -Tag "MT.1194", "Preview" {
        $result = Test-AuGsaBaselineThreatIntelligenceEnforced

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the baseline is the only universal malware/phishing floor (covers non-client, token-gap, and unmatched traffic)."
        }
    }
}

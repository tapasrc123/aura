Describe "Aura/Entra" -Tag "Aura", "Entra" {
    It "MT.1189: Groups assigned to Global Secure Access traffic forwarding profiles should not be nested. See https://aura.onetapas.com/docs/tests/MT.1189" -Tag "MT.1189", "Preview" {
        $result = Test-AuGsaForwardingProfileAssignmentNotNested

        if ($null -ne $result) {
            $result | Should -Be $true -Because "traffic forwarding profile assignment grants the profile to direct group members only; nested members are excluded."
        }
    }
}

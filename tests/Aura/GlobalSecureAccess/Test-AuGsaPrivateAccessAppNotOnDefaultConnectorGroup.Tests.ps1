Describe "Aura/Entra" -Tag "Aura", "Entra" {
    It "MT.1190: Entra Private Access applications should not use the Default connector group. See https://aura.onetapas.com/docs/tests/MT.1190" -Tag "MT.1190", "Preview" {
        $result = Test-AuGsaPrivateAccessAppNotOnDefaultConnectorGroup

        if ($null -ne $result) {
            $result | Should -Be $true -Because "new connectors auto-join Default, so serving apps from it risks routing production traffic through unintended connectors."
        }
    }
}

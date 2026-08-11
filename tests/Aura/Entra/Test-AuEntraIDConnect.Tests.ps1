BeforeDiscovery {
    try {
        $EntraIDPlan = Get-AuLicenseInformation -Product "EntraID"
    } catch {
        $EntraIDPlan = "NotConnected"
    }
}

Describe "Aura/Entra" -Tag "Aura", "Entra", "Graph", "Hybrid" {
    It "MT.1084: Microsoft Entra seamless single sign-on should be disabled for all domains in EntraID Connect servers. See https://aura.onetapas.com/docs/tests/MT.1084" -Tag "MT.1084" -Skip:( $EntraIDPlan -ne "P2" ) {
        Test-AuEntraIDConnectSsso | Should -Be $True -Because "Microsoft Entra seamless single sign-on should be disabled for all domains in EntraID Connect servers."
    }
}

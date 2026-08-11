Describe 'Aura/Entra' -Tag 'App', 'Entra', 'Graph', 'LongRunning', 'Aura' {
    It 'MT.1057: App registrations should no longer use secrets. See https://aura.onetapas.com/docs/tests/MT.1057' -Tag 'MT.1057' {
        Test-AuAppRegistrationsWithSecrets | Should -Be $true -Because 'app registrations should not use secrets and instead use workload identities or certificate-based authentication'
    }
    It 'MT.1058: Exchange application access policies must be configured. See https://aura.onetapas.com/docs/tests/MT.1058' -Tag 'MT.1058' {
        $result = Test-AuSpExchangeAppAccessPolicy

        if ($null -ne $result) {
            $result | Should -Be $true -Because 'all applications with Exchange permissions should have access policies configured'
        }
    }
    It 'MT.1075: Require explicit assignment of Third Party Entra Apps. See https://aura.onetapas.com/docs/tests/MT.1075' -Tag 'MT.1075' {
        Test-AuServicePrincipalsForAllUsers | Should -Be $true -Because 'Third Party Service Principals should require explicit assignment to users'
    }
}

Describe 'Aura/Entra' -Tag 'Entra', 'Graph', 'Hybrid', 'Aura' {
    It 'MT.1073: Soft- and hard-matching of synchronized objects should be blocked. See https://aura.onetapas.com/docs/tests/MT.1073' -Tag 'MT.1073' {
        Test-AuEntraIDConnectSyncSoftHardMatching | Should -Be $true -Because 'on-premises directory synchronization soft- and hard-match is blocked'
    }

    It 'MT.1147: Do not sync krbtgt_AzureAD to Entra ID. See https://aura.onetapas.com/docs/tests/MT.1147' -Tag 'MT.1147' {
        Test-AuKrbtgtAzureADNotSynced | Should -Be $true -Because 'krbtgt_AzureAD should exist only in Entra ID and should not be synchronized from on-premises Active Directory'
    }

    It 'MT.1183: Temporary bypass for onPremisesObjectIdentifier updates should be disabled. See https://aura.onetapas.com/docs/tests/MT.1183' -Tag 'MT.1183' {
        Test-AuEntraIDConnectSyncOnPremisesObjectIdentifierUpdatesBlocked | Should -Be $true -Because 'the temporary bypass for onPremisesObjectIdentifier updates should be disabled'
    }
}

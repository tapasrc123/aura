Describe "Active Directory - Replication" -Tag "AD", "AD.Replication", "AD-ROOTDSE-02" {
    It "AD-ROOTDSE-02: Supported SASL mechanism details should be retrievable" {

        $result = Test-AuAdSupportedSaslMechanismDetails

        if ($null -ne $result) {
            $result | Should -Be $true -Because "Root DSE data should be accessible"
        }
    }
}

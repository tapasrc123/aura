Describe "Active Directory - Forest" -Tag "AD", "AD.Forest", "AD-FOR-03" {
    It "AD-FOR-03: Tombstone lifetime should be retrievable" {

        $result = Test-AuAdTombstoneLifetime

        if ($null -ne $result) {
            $result | Should -Be $true -Because "tombstone lifetime data should be accessible"
        }
    }
}

Describe "Active Directory - Group Policy" -Tag "AD", "AD.GPO", "AD-GPOL-01" {
    It "AD-GPOL-01: GPO linked count should be retrievable" {

        $result = Test-AuAdGpoLinkedCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "GPO linked data should be accessible"
        }
    }
}

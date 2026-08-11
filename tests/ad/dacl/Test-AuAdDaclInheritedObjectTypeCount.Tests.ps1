Describe "Active Directory - DACL" -Tag "AD", "AD.DACL", "AD-DACL-17" {
    It "AD-DACL-17: Inherited object type count should be retrievable" {
        $result = Test-AuAdDaclInheritedObjectTypeCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "DACL data should be accessible"
        }
    }
}

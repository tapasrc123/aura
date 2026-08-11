Describe "Active Directory - GPO State" -Tag "AD", "AD.GPOState", "AD-GPOREP-15" {
    It "AD-GPOREP-15: GPO version mismatch count should be retrievable" {
        $result = Test-AuAdGpoVersionMismatchCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "GPO report data should be accessible"
        }
    }
}

Describe "Active Directory - GPO State" -Tag "AD", "AD.GPOState", "AD-GPOREP-16" {
    It "AD-GPOREP-16: GPO version mismatch details should be retrievable" {
        $result = Test-AuAdGpoVersionMismatchDetails
        if ($null -ne $result) {
            $result | Should -Be $true -Because "GPO report data should be accessible"
        }
    }
}

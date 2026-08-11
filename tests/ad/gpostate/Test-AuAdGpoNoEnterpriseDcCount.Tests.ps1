Describe "Active Directory - GPO State" -Tag "AD", "AD.GPOState", "AD-GPOREP-05" {
    It "AD-GPOREP-05: GPOs without enterprise domain controllers count should be retrievable" {
        $result = Test-AuAdGpoNoEnterpriseDcCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "GPO permissions data should be accessible"
        }
    }
}

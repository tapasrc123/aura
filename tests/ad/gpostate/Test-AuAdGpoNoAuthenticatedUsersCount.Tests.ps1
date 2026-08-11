Describe "Active Directory - GPO State" -Tag "AD", "AD.GPOState", "AD-GPOREP-03" {
    It "AD-GPOREP-03: GPOs without authenticated users count should be retrievable" {
        $result = Test-AuAdGpoNoAuthenticatedUsersCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "GPO permissions data should be accessible"
        }
    }
}

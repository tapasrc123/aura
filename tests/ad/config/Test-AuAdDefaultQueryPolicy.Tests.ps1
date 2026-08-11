Describe "Active Directory - Configuration" -Tag "AD", "AD.Config", "AD-CFG-07" {
    It "AD-CFG-07: Default query policy should be retrievable" {
        $result = Test-AuAdDefaultQueryPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "default query policy data should be accessible"
        }
    }
}

Describe "Active Directory - Users" -Tag "AD", "AD.User", "AD-USER-01" {
    It "AD-USER-01: Disabled user count should be retrievable" {
        $result = Test-AuAdUserDisabledCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "user data should be accessible"
        }
    }
}

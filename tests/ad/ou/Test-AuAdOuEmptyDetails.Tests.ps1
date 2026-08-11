Describe "Active Directory - Organizational Units" -Tag "AD", "AD.OU", "AD-OU-05" {
    It "AD-OU-05: OU empty details should be retrievable" {

        $result = Test-AuAdOuEmptyDetails

        if ($null -ne $result) {
            $result | Should -Be $true -Because "OU data should be accessible to list empty OU details"
        }
    }
}

Describe "Active Directory - SPN Analysis" -Tag "AD", "AD.SPN", "AD-SPN-02" {
    It "AD-SPN-02: Computer SPN service class usage should be retrievable" {

        $result = Test-AuAdComputerSpnServiceClassUsage

        if ($null -ne $result) {
            $result | Should -Be $true -Because "computer SPN service class usage data should be accessible"
        }
    }
}

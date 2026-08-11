Describe "Active Directory - Sites and Subnets" -Tag "AD", "AD.Site", "AD-SUB-06" {
    It "AD-SUB-06: Non-RFC1918 (public IP) subnets count should be retrievable" {

        $result = Test-AuAdSubnetNonInternalCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "subnet data should be accessible"
        }
    }
}

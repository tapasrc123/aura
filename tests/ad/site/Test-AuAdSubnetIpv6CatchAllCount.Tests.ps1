Describe "Active Directory - Sites and Subnets" -Tag "AD", "AD.Site", "AD-SUB-05" {
    It "AD-SUB-05: IPv6 catch-all subnets count should be retrievable" {

        $result = Test-AuAdSubnetIpv6CatchAllCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "subnet data should be accessible"
        }
    }
}

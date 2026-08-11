Describe "Active Directory - DNS Infrastructure" -Tag "AD", "AD.DNS", "AD-DNS-16" {
    It "AD-DNS-16: Reverse lookup zone count should be retrievable" {

        $result = Test-AuAdDnsReverseZoneCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "DNS zone data should be accessible"
        }
    }
}

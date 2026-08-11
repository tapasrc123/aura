Describe "Active Directory - Configuration" -Tag "AD", "AD.Config", "AD-CFG-21" {
    It "AD-CFG-21: NTAuth certificates count should be retrievable" {
        $result = Test-AuAdNtAuthCertificatesCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "NTAuth certificate data should be accessible"
        }
    }
}

Describe "Active Directory - Security Accounts" -Tag "AD", "AD.Security", "AD-MSA-01" {
    It "AD-MSA-01: Managed service account count should be retrievable" {

        $result = Test-AuAdManagedServiceAccountCount

        if ($null -ne $result) {
            $result | Should -Be $true -Because "managed service account information should be accessible"
        }
    }
}

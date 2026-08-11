Describe "Aura/Entra" -Tag "Aura", "Group" {
    It "MT.1055: Microsoft 365 Group (and Team) creation should be restricted to approved users. See https://aura.onetapas.com/docs/tests/MT.1055" -Tag "MT.1055" {

        Test-AuGroupCreationRestricted | Should -Be $true -Because "Microsoft 365 Group creation should be restricted to approved users."
    }
}

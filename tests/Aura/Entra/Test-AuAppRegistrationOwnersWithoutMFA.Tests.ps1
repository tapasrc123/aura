Describe 'Aura/Entra' -Tag 'Aura', 'App', 'Entra', 'LongRunning' {
    It 'MT.1063: All App registration owners should have MFA registered' -Tag 'MT.1063' {
        $result = Test-AuAppRegistrationOwnersWithoutMFA
        $result | Should -Be $true -Because 'All App registration owners should have MFA registered.'
    }
}

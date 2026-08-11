Describe 'Aura/Entra' -Tag 'Aura', 'App', 'Entra', 'Graph', 'LongRunning', 'Preview' {
    It 'MT.1050: Apps with high-risk permissions having a direct path to Global Administrator' -Tag 'MT.1050' {
        $result = Test-AuHighRiskAppPermissions -AttackPath 'Direct'
        if ($null -ne $result) {
            $result | Should -Be $true -Because 'no graph application has permissions with a risk of having a direct path to Global Administrator and full tenant takeover.'
        }
    }

    It 'MT.1051: Apps with high-risk permissions having an indirect path to Global Administrator' -Tag 'MT.1051' {
        $result = Test-AuHighRiskAppPermissions -AttackPath 'Indirect'
        if ($null -ne $result) {
            $result | Should -Be $true -Because 'no graph application has permissions with a risk of having an indirect path to Global Administrator and full tenant takeover.'
        }
    }
}

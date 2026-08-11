Describe 'Test-AuDomainsDmarcRecordMaturity' {
    BeforeEach {
        $script:skipCustomReason = $null

        Mock -ModuleName Aura Test-AuConnection { return $true }
        Mock -ModuleName Aura Add-AuTestResultDetail {
            param(
                $SkippedBecause,
                $SkippedCustomReason
            )

            $script:skipCustomReason = $SkippedCustomReason
        }
    }

    It 'skips cleanly when no verified managed domains are found' {
        Mock -ModuleName Aura Invoke-AuGraphRequest { return @() }

        Test-AuDomainsDmarcRecordMaturity | Should -Be $null
        $script:skipCustomReason | Should -Be 'No verified and managed domains found in tenant'
    }
}

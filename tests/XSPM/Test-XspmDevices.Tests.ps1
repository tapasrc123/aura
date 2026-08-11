BeforeDiscovery {
    try {
        $DefenderPlan = Get-AuLicenseInformation -Product "DefenderXDR"
    } catch {
        Write-Verbose "You do not have the required licenses to run Defender XSPM tests."
        Add-AuTestResultDetail -SkippedBecause NotLicensedDefenderXDR
        $DefenderPlan = "NotLicensed"
    }
}

Describe "Exposure Management" -Tag "XSPM", "LongRunning", "Device" -Skip:( $DefenderPlan -ne "DefenderXDR" ) {
    # Devices should not share both critical and non-critical user credentials.
    It "MT.1086: Devices should not share both critical and non-critical user credentials. See https://aura.onetapas.com/docs/tests/MT.1086" -Tag "MT.1086" {
        Test-AuXspmCriticalCredsOnDevicesWithNonCriticalAccounts | Should -Be $true -Because "Devices should not share both critical and non-critical user credentials, as this may lead to potential security risks and compromise of critical assets via a non-critical account."
    }

    # Devices should not be publicly exposed with remotely exploitable, highly likely to be exploited, high or critical severity CVE's.
    It "MT.1087: Devices should not be publicly exposed with remotely exploitable, highly likely to be exploited, high or critical severity CVE's. See https://aura.onetapas.com/docs/tests/MT.1087" -Tag "MT.1087" {
        Test-AuXspmPublicRemotelyExploitableHighExposureDevices | Should -Be $true -Because "Devices should not be publicly exposed with remotely exploitable, highly likely to be exploited, high or critical severity CVE's. Such devices are at high risk of being compromised by attackers, potentially leading to data breaches and other security incidents."
    }

    # Devices with critical credentials should be protected by TPM.
    It "MT.1088: Devices with critical credentials should be protected by TPM. See https://aura.onetapas.com/docs/tests/MT.1088" -Tag "MT.1088" {
        Test-AuXspmCriticalCredentialsOnNonTpmProtectedDevices | Should -Be $true -Because "Devices with critical credentials should be protected by TPM. Without TPM protection, these devices are vulnerable to various attacks that could compromise sensitive credentials, leading to potential security breaches."
    }

    # Devices with critical credentials should be protected by Credential Guard.
    It "MT.1089: Devices with critical credentials should be protected by Credential Guard. See https://aura.onetapas.com/docs/tests/MT.1089" -Tag "MT.1089" {
        Test-AuXspmCriticalCredentialsOnNonCredGuardProtectedDevices | Should -Be $true -Because "Devices with critical credentials should be protected by Credential Guard. Without Credential Guard protection, these devices are vulnerable to various attacks that could compromise sensitive credentials, leading to potential security breaches."
    }
}

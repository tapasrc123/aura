Describe "Aura/Defender" -Tag "Aura", "Defender" {
    It "MT.1148: Archive Scanning should be enabled. See https://aura.onetapas.com/docs/tests/MT.1148" -Tag "MT.1148" {
        $result = Test-AuMdeArchiveScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "archive scanning helps detect malware in compressed files"
        }
    }

    It "MT.1149: Behavior Monitoring should be enabled. See https://aura.onetapas.com/docs/tests/MT.1149" -Tag "MT.1149" {
        $result = Test-AuMdeBehaviorMonitoring
        if ($null -ne $result) {
            $result | Should -Be $true -Because "behavior monitoring is essential for detecting advanced threats"
        }
    }

    It "MT.1150: Cloud Protection should be enabled. See https://aura.onetapas.com/docs/tests/MT.1150" -Tag "MT.1150" {
        $result = Test-AuMdeCloudProtection
        if ($null -ne $result) {
            $result | Should -Be $true -Because "cloud protection provides real-time threat intelligence"
        }
    }

    It "MT.1151: Email Scanning should be enabled. See https://aura.onetapas.com/docs/tests/MT.1151" -Tag "MT.1151" {
        $result = Test-AuMdeEmailScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "email scanning should be enabled to protect Exchange queues"
        }
    }

    It "MT.1152: Script Scanning should be enabled. See https://aura.onetapas.com/docs/tests/MT.1152" -Tag "MT.1152" {
        $result = Test-AuMdeScriptScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "script scanning should be enabled to block malicious scripts"
        }
    }

    It "MT.1153: Real-time Monitoring should be enabled. See https://aura.onetapas.com/docs/tests/MT.1153" -Tag "MT.1153" {
        $result = Test-AuMdeRealtimeMonitoring
        if ($null -ne $result) {
            $result | Should -Be $true -Because "real-time monitoring provides essential protection against live threats"
        }
    }

    It "MT.1154: Full Scan Removable Drives should be enabled. See https://aura.onetapas.com/docs/tests/MT.1154" -Tag "MT.1154" {
        $result = Test-AuMdeRemovableDriveScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "full scan of removable drives should be enabled to mitigate USB risks"
        }
    }

    It "MT.1155: Full Scan Mapped Drives should be disabled for performance. See https://aura.onetapas.com/docs/tests/MT.1155" -Tag "MT.1155" {
        $result = Test-AuMdeMappedDriveScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "full scan of mapped drives should be disabled for performance optimization"
        }
    }

    It "MT.1156: Scanning Network Files should be enabled. See https://aura.onetapas.com/docs/tests/MT.1156" -Tag "MT.1156" {
        $result = Test-AuMdeNetworkFileScanning
        if ($null -ne $result) {
            $result | Should -Be $true -Because "scanning network files should be enabled for comprehensive protection"
        }
    }

    It "MT.1157: CPU Load Factor should be optimized (20-30%). See https://aura.onetapas.com/docs/tests/MT.1157" -Tag "MT.1157" {
        $result = Test-AuMdeCpuLoadFactor
        if ($null -ne $result) {
            $result | Should -Be $true -Because "CPU load should be balanced between performance and security"
        }
    }

    It "MT.1158: Scan should be scheduled. See https://aura.onetapas.com/docs/tests/MT.1158" -Tag "MT.1158" {
        $result = Test-AuMdeScheduleScanDay
        if ($null -ne $result) {
            $result | Should -Be $true -Because "scans should be scheduled for comprehensive coverage"
        }
    }

    It "MT.1159: Quick Scan Time configuration is not required. See https://aura.onetapas.com/docs/tests/MT.1159" -Tag "MT.1159" {
        $result = Test-AuMdeQuickScanTime
        if ($null -ne $result) {
            $result | Should -Be $true -Because "quick scan time configuration is not required"
        }
    }

    It "MT.1160: Signatures should be checked before scan. See https://aura.onetapas.com/docs/tests/MT.1160" -Tag "MT.1160" {
        $result = Test-AuMdeSignatureBeforeScan
        if ($null -ne $result) {
            $result | Should -Be $true -Because "signatures should be checked before scan for zero-day protection"
        }
    }

    It "MT.1161: Cloud Block Level should be High or higher. See https://aura.onetapas.com/docs/tests/MT.1161" -Tag "MT.1161" {
        $result = Test-AuMdeCloudBlockLevel
        if ($null -ne $result) {
            $result | Should -Be $true -Because "cloud block level should be High or higher for maximum protection"
        }
    }

    It "MT.1162: Cloud Extended Timeout should be 30-50 seconds. See https://aura.onetapas.com/docs/tests/MT.1162" -Tag "MT.1162" {
        $result = Test-AuMdeCloudExtendedTimeout
        if ($null -ne $result) {
            $result | Should -Be $true -Because "cloud extended timeout should be 30-50 seconds for optimal detection"
        }
    }

    It "MT.1163: Signature Update Interval should be 1-4 hours. See https://aura.onetapas.com/docs/tests/MT.1163" -Tag "MT.1163" {
        $result = Test-AuMdeSignatureUpdateInterval
        if ($null -ne $result) {
            $result | Should -Be $true -Because "signature update interval should be 1-4 hours for current protection"
        }
    }

    It "MT.1164: PUA Protection should be enabled. See https://aura.onetapas.com/docs/tests/MT.1164" -Tag "MT.1164" {
        $result = Test-AuMdePuaProtection
        if ($null -ne $result) {
            $result | Should -Be $true -Because "PUA protection should be enabled to block potentially unwanted applications"
        }
    }

    It "MT.1165: Network Protection should be enabled. See https://aura.onetapas.com/docs/tests/MT.1165" -Tag "MT.1165" {
        $result = Test-AuMdeNetworkProtection
        if ($null -ne $result) {
            $result | Should -Be $true -Because "network protection should be enabled to block web-based threats"
        }
    }

    It "MT.1166: Local Admin Merge should be disabled. See https://aura.onetapas.com/docs/tests/MT.1166" -Tag "MT.1166" {
        $result = Test-AuMdeDisableLocalAdminMerge
        if ($null -ne $result) {
            $result | Should -Be $true -Because "local admin merge should be disabled to prevent local exclusions"
        }
    }

    It "MT.1167: Real-Time Scan Direction should cover both directions. See https://aura.onetapas.com/docs/tests/MT.1167" -Tag "MT.1167" {
        $result = Test-AuMdeRealtimeScanDirection
        if ($null -ne $result) {
            $result | Should -Be $true -Because "real-time scan should monitor both incoming and outgoing traffic"
        }
    }

    It "MT.1168: Cleaned Malware should be retained for at least 30 days. See https://aura.onetapas.com/docs/tests/MT.1168" -Tag "MT.1168" {
        $result = Test-AuMdeRetainCleanedMalware
        if ($null -ne $result) {
            $result | Should -Be $true -Because "cleaned malware should be retained for forensic analysis"
        }
    }

    It "MT.1169: Catch-up Full Scan should be disabled. See https://aura.onetapas.com/docs/tests/MT.1169" -Tag "MT.1169" {
        $result = Test-AuMdeCatchupFullScan
        if ($null -ne $result) {
            $result | Should -Be $true -Because "catch-up full scan should be disabled to avoid additional system load"
        }
    }

    It "MT.1170: Catch-up Quick Scan should be disabled. See https://aura.onetapas.com/docs/tests/MT.1170" -Tag "MT.1170" {
        $result = Test-AuMdeCatchupQuickScan
        if ($null -ne $result) {
            $result | Should -Be $true -Because "catch-up quick scan should be disabled"
        }
    }

    It "MT.1171: Sample Submission should send safe samples automatically. See https://aura.onetapas.com/docs/tests/MT.1171" -Tag "MT.1171" {
        $result = Test-AuMdeSubmitSamplesConsent
        if ($null -ne $result) {
            $result | Should -Be $true -Because "sample submission should be configured to send safe samples automatically"
        }
    }
}

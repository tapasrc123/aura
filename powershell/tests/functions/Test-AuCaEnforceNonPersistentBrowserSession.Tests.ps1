
Describe 'Test-AuCaEnforceNonPersistentBrowserSession' {
    BeforeAll {
        Mock -ModuleName Aura Get-AuLicenseInformation { return "P1" }

        function Get-BaselinePolicy {
            return [PSCustomObject]@{
                state = "enabled"
                conditions = @{
                    users = @{
                        includeUsers = "All"
                    }
                    applications = @{
                        includeApplications = "All"
                    }
                    devices = @{
                        deviceFilter = @{
                            mode = "include"
                            rule = 'device.trustType -ne "ServerAD" -or device.isCompliant -ne True'
                        }
                    }
                }
                sessionControls = @{
                    persistentBrowser = @{
                        isEnabled = $true
                        mode = "never"
                    }
                }
            }
        }
    }

    Context "CA: Enforce non persistent browser session" {

        It 'Policy without non persistent browser session should fail' {
            $policy = Get-BaselinePolicy
            $policy.sessionControls.persistentBrowser.isEnabled = $false

            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

            Test-AuCaEnforceNonPersistentBrowserSession | Should -BeFalse
        }

        It 'Include: Non Hybrid or Non-compliant device filter should Pass' {
            $policy = Get-BaselinePolicy
            $policy.conditions.devices.deviceFilter.mode = "include"
            $policy.conditions.devices.deviceFilter.rule = 'device.trustType -ne "ServerAD" -or device.isCompliant -ne True'
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

            Test-AuCaEnforceNonPersistentBrowserSession | Should -BeTrue
        }

        It 'Include: Non Compliant device filter (no-hybrid) should Pass' {
            # Should work with CA policies that only check for compliant devices
            # See https://github.com/tapasrc123/aura/issues/433
            $policy = Get-BaselinePolicy
            $policy.conditions.devices.deviceFilter.mode = "include"
            $policy.conditions.devices.deviceFilter.rule = 'device.isCompliant -ne True'
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

            Test-AuCaEnforceNonPersistentBrowserSession | Should -BeTrue
        }

        It 'Exclude: Hybrid or compliant device filter should Pass' {
            $policy = Get-BaselinePolicy
            $policy.conditions.devices.deviceFilter.mode = "exclude"
            $policy.conditions.devices.deviceFilter.rule = 'device.trustType -eq "ServerAD" -or device.isCompliant -eq True'
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

            Test-AuCaEnforceNonPersistentBrowserSession | Should -BeTrue
        }

        It 'Exclude: Compliant device filter (no-hybrid) should Pass' {
            # Should work with CA policies that only check for compliant devices
            # See https://github.com/tapasrc123/aura/issues/433
            $policy = Get-BaselinePolicy
            $policy.conditions.devices.deviceFilter.mode = "exclude"
            $policy.conditions.devices.deviceFilter.rule = 'device.isCompliant -eq True'
            Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

            Test-AuCaEnforceNonPersistentBrowserSession | Should -BeTrue
        }
    }
}

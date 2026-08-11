BeforeDiscovery {
    try {
        $EntraIDPlan = Get-AuLicenseInformation -Product 'EntraID'
        $RegularUsers = Get-AuUser -Count 5 -UserType 'Member'
        $AdminUsers = Get-AuUser -Count 5 -UserType 'Admin'
        $EmergencyAccessUsers = Get-AuUser -Count 5 -UserType 'EmergencyAccess'
        # Remove emergency access users from regular users
        $RegularUsers = $RegularUsers | Where-Object { $_.id -notin $EmergencyAccessUsers.id }
        # Remove emergency access users from admin users
        $AdminUsers = $AdminUsers | Where-Object { $_.id -notin $EmergencyAccessUsers.id }
        Write-Verbose "EntraIDPlan: $EntraIDPlan"
        Write-Verbose "RegularUsers: $($RegularUsers.id)"
        Write-Verbose "AdminUsers: $($AdminUsers.id)"
    } catch {
        $EntraIDPlan = "NotConnected"
    }
}


Describe 'Aura/Entra' -Tag 'CA', 'CAWhatIf', 'LongRunning', 'Aura' {

    Context 'Aura/Entra' -ForEach @( $RegularUsers ) {
        # Regular users
        It "MT.1033.$($RegularUsers.IndexOf($_)): User should be blocked from using legacy authentication ($($_.userPrincipalName))" -Tag 'MT.1033', 'CA', 'CAWhatIf', 'LongRunning', 'Aura' -Skip:( $EntraIDPlan -eq 'Free' ) {
            Test-AuCaWIFBlockLegacyAuthentication -UserId $id | Should -Be $true
        }

    }

    Context 'Aura/Entra' -ForEach @( $EmergencyAccessUsers ) {
        # Emergency access users
        It "MT.1034.$($EmergencyAccessUsers.IndexOf($_)): Emergency access users should not be blocked ($($_.userPrincipalName))" -Tag 'MT.1034' {
            if ( ( Get-AuLicenseInformation EntraID ) -eq 'Free' ) {
                Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
            } else {
                Test-AuConditionalAccessWhatIf -UserId $id -IncludeApplications '00000002-0000-0ff1-ce00-000000000000' -ClientAppType exchangeActiveSync | Should -BeNullOrEmpty
            }
        }

    }

}

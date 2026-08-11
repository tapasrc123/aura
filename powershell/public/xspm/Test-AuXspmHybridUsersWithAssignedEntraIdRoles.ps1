function Test-AuXspmHybridUsersWithAssignedEntraIdRoles {
    <#
    .SYNOPSIS
    Tests if hybrid users have been assigned eligible or permanent to Entra ID roles.

    .DESCRIPTION
    This function checks if any hybrid users (synchronized from on-premises Active Directory) have been assigned eligible or permanent Entra ID roles, which can lead to privilege escalation by compromising the on-premises AD.

    .OUTPUTS
    [bool] - Returns $true if no hybrid users with assigned Entra ID roles are found, $false if any are found, $null if skipped or prerequisites not met.

    .EXAMPLE
    Test-AuXspmHybridUsersWithAssignedEntraIdRoles

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuXspmHybridUsersWithAssignedEntraIdRoles
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This test checks multiple users and roles.')]
    [OutputType([bool])]
    param()

    $UnifiedIdentityInfoExecutable = Get-AuXspmUnifiedIdentityInfo -ValidateRequiredTablesOnly
    if ( $UnifiedIdentityInfoExecutable -eq $false) {
            Add-AuTestResultDetail -SkippedBecause 'Custom' -SkippedCustomReason 'This test requires availability of MDA App Governance and MDI to get data for Defender XDR Advanced Hunting tables. Check https://aura.onetapas.com/docs/tests/MT.1081/#Prerequisites for more information.'
            return $null
    }

    try {
        Write-Verbose "Get details from UnifiedIdentityInfo ..."
        $UnifiedIdentityInfo = Get-AuXspmUnifiedIdentityInfo
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    $HighPrivilegedUsersByEntraRoles = $UnifiedIdentityInfo | Where-Object { $_.Type -eq "User" -and ($_.AssignedEntraRoles.Classification -eq "ControlPlane" -or $_.AssignedEntraRoles.Classification -eq "ManagementPlane" -or $_.AssignedEntraRoles.RoleIsPrivileged -eq $True) | Sort-Object Classification, AccountDisplayName}
    $HighPrivilegedHybridUsers = $HighPrivilegedUsersByEntraRoles | Where-Object { $_.SourceProvider -eq "ActiveDirectory" -or $_.SourceProvider -eq "Hybrid"}

    $Severity = "Medium"

    if ($return -or [string]::IsNullOrEmpty($HighPrivilegedHybridUsers)) {
        $testResultMarkdown = "Well done. No hybrid users with sensitive directory roles."
    } else {
        $testResultMarkdown = "At least one hybrid user with a risk of sensitive directory role membership.`n`n%TestResult%"

        $result = "| AccountName | Classification | Sensitive Directory Role | ChangeSource |`n"
        $result += "| --- | --- | --- | --- |`n"

        Write-Verbose "Found $($HighPrivilegedHybridUsers.Count) hybrid users with directory roles in total."

        foreach ($HighPrivilegedHybridUser in $HighPrivilegedHybridUsers) {
            $filteredDirectoryRoles = $HighPrivilegedHybridUser.AssignedEntraRoles | Where-Object { $_.Classification -eq "ControlPlane" -or $_.Classification -eq "ManagementPlane" -or $_.RoleIsPrivileged -eq $True} | Select-Object RoleDefinitionName, Classification
            $UserSensitiveDirectoryRoles = $filteredDirectoryRoles | foreach-object { (Get-AuXspmPrivilegedClassificationIcon -AdminTierLevelName $_.Classification) + " " + $_.RoleDefinitionName }
            $UserSensitiveDirectoryRolesResult = @()
            $UserSensitiveDirectoryRoles | ForEach-Object {
                $UserSensitiveDirectoryRolesResult += '`' + $_ + '`'
            }
            $AdminTierLevelIcon = Get-AuXspmPrivilegedClassificationIcon -AdminTierLevelName $HighPrivilegedHybridUser.Classification
            if ($HighPrivilegedHybridUser.Classification -eq "ControlPlane") {
                $Severity = "High"
            }

            $HybridUserLink = "[$($HighPrivilegedHybridUser.AccountDisplayName)](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($HighPrivilegedHybridUser.AccountObjectId))"
            $result += "| $($AdminTierLevelIcon) $($HybridUserLink) | $($HighPrivilegedHybridUser.Classification) | $($UserSensitiveDirectoryRolesResult) | $($HighPrivilegedHybridUser.SourceProvider) |`n"
        }
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -Severity $Severity

    $result = [string]::IsNullOrEmpty($HighPrivilegedHybridUsers)
    return $result
}

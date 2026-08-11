function Test-AuExoOutlookAddin {
    <#
    .SYNOPSIS
    Checks if users installing Outlook add-ins is not allowed

    .DESCRIPTION
    This command checks if users are able to install add-ins for Outlook in Exchange Online.
    By default, users can install add-ins in their Microsoft Outlook Desktop client, allowing data
    access within the client application. Attackers exploit vulnerable or custom add-ins to access user data.

    .EXAMPLE
    Test-AuExoOutlookAddin

    Returns true if users are restricted from installing Outlook add-ins.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuExoOutlookAddin
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    try {
        Write-Verbose "Getting Role Assignment Policies..."
        $roleAssignmentPolicy = Get-AuExo -Request RoleAssignmentPolicy
        Write-Verbose "Found $($roleAssignmentPolicy.Count) Exchange Role Assignment Policy"

        $portalLink_SecureScore = "$($__AuSession.AdminPortalUrl.Security)securescore"

        $roleAssignmentPolicyDefault = $roleAssignmentPolicy | Where-Object { $_.Identity -eq "Default Role Assignment Policy" }
        Write-Verbose "Filtered $($roleAssignmentPolicyDefault.Count) Default Web mailbox policy"

        # Get Management Role Assignments
        $managementRoleAssignments = Get-AuExo -Request ManagementRoleAssignment

        $myCustomApps = $managementRoleAssignments | Where-Object {
            $_.Role -eq "My Custom Apps" -and $_.RoleAssigneeName -eq $roleAssignmentPolicyDefault.Name
        }
        $myMarketplaceApps = $managementRoleAssignments | Where-Object {
            $_.Role -eq "My Marketplace Apps" -and $_.RoleAssigneeName -eq $roleAssignmentPolicyDefault.Name
        }
        $myReadWriteMailboxApps = $managementRoleAssignments | Where-Object {
            $_.Role -eq "My ReadWriteMailbox Apps" -and $_.RoleAssigneeName -eq $roleAssignmentPolicyDefault.Name
        }

        $result = [bool]$myCustomApps -or [bool]$myMarketplaceApps -or [bool]$myReadWriteMailboxApps

        if ($result -eq $false) {
            $testResultMarkdown = "Well done. Apps in 'Default Role Assignment Policy' is ``$($result)```n`n"
        } else {
            $testResultMarkdown = "Apps in 'Default Role Assignment Policy' should be ``False`` and is ``$($result)`` in [SecureScore]($portalLink_SecureScore)`n`n"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    return !$result
}

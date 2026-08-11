function Test-AuSecurityGroupCreationRestricted {
    <#
    .SYNOPSIS
    Tests if security group creation is restricted to admin users.
    .DESCRIPTION
    This function checks if security group creation is restricted to admin users by querying the authorization policy settings.
    .OUTPUTS
    [bool] - Returns $true if security group creation is restricted to admin users, otherwise returns $false.
    .EXAMPLE
    Test-AuSecurityGroupCreationRestricted
    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuSecurityGroupCreationRestricted
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # Add the connection check
    if (-not (Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    Write-Verbose 'Test-AuSecurityGroupCreationRestricted: Checking if security group creation is restricted to admin users..'

    try {
        # Get the authorization policy settings
        $settings = Invoke-AuGraphRequest -RelativeUri 'policies/authorizationPolicy?$select=defaultUserRolePermissions' -ApiVersion 'beta' -ErrorAction Stop

        # Initialize the result variable
        $securityGroupCreationRestricted = $false

        # Check if defaultUserRolePermissions exists and get the allowedToCreateSecurityGroups setting
        if ($null -ne $settings.defaultUserRolePermissions) {
            $allowedToCreateSecurityGroups = $settings.defaultUserRolePermissions.allowedToCreateSecurityGroups

            # If allowedToCreateSecurityGroups is false, then security group creation is restricted
            $securityGroupCreationRestricted = ($allowedToCreateSecurityGroups -eq $false)
        } else {
            Write-Verbose 'defaultUserRolePermissions not found in authorization policy'
        }

        if ($securityGroupCreationRestricted) {
            $value = 'No'
            $status = '✅'
            $testResultMarkdown = "Well done. Security group creation is restricted to admin users."
        } else {
            $value = 'Yes'
            $status = '❌'
            $testResultMarkdown = "Security group creation is not restricted and non-admin users may be able to create security groups."
        }

        $testResultMarkdown += "`n`n|Setting|Value|Status|`n|---|---|---|`n"
        $testResultMarkdown += "|[Users can create security groups](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/)|$value|$status|"

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $securityGroupCreationRestricted

    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

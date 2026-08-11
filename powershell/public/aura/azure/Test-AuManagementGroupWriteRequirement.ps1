function Test-AuManagementGroupWriteRequirement {
    <#
    .SYNOPSIS
    Checks if write permissions are required to create new management groups

    .DESCRIPTION
    This test ensures that only users with explicit write access can create new management groups.
    This is important to prevent unauthorized creation of management groups which could lead to security risks.

    .EXAMPLE
    Test-AuManagementGroupWriteRequirement

    Returns true if write permissions are required for creating new management groups.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuManagementGroupWriteRequirement
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Azure)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    # Get all management groups in the tenant and filter the tenant root management group by id
    $rootManagementGroup = Get-AuAzureManagementGroup | Where-Object { $_.id -match "$($_.properties.tenantid)$" }

    if (!$rootManagementGroup) {
        Write-Verbose "Tenant Root Group not found in management groups."
        Add-AuTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Tenant Root Group not found"
        return $null
    }

    try {
        # Query the management group settings to check authorization requirements
        $settingResponse = Invoke-AuAzureRequest `
            -RelativeUri "/providers/Microsoft.Management/managementGroups/$($rootManagementGroup.name)/settings/default" `
            -ApiVersion "2020-05-01"

        # Extract the setting that controls write permissions for group creation
        $requireWritePermissions = $settingResponse.properties.requireAuthorizationForGroupCreation
        Write-Verbose "Require write permissions for creating management groups: $requireWritePermissions"

        $testResult = $requireWritePermissions -eq $true

        # Build result message based on the setting
        if ($testResult) {
            $testResultMarkdown = "Write permissions are required for creating new management groups."
        } else {
            $testResultMarkdown = "Write permissions are NOT required for creating new management groups. Anyone in the tenant may create them."
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

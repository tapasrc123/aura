function Test-AuUserAccessAdmin {
    <#
    .SYNOPSIS
    Checks if any Global Admins have User Access Control permissions at the Root Scope

    .DESCRIPTION
    Ensure that no one has permanent access to all subscriptions through the Root Scope.

    .EXAMPLE
    Test-AuUserAccessAdmin

    Returns true if no User Access Control permissions are assigned at the root scope

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuUserAccessAdmin
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Checking if connected to Graph"
    if (!(Test-AuConnection Graph)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    if(!(Test-AuConnection Azure)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    Write-Verbose "Getting all User Access Administrators at Root Scope"

    try {
        $userAccessResult = Invoke-AuAzureRequest -RelativeUri 'providers/Microsoft.Authorization/roleAssignments' -Filter 'atScope()' -ApiVersion '2022-04-01'

        if ($null -eq $userAccessResult) {
            Add-AuTestResultDetail -SkippedBecause NotAuthorized
            return $null
        }

        $userAccessAdmins = Get-ObjectProperty $userAccessResult 'value'

        # Get the count of role assignments
        $roleAssignmentCount = $userAccessAdmins | Measure-Object | Select-Object -ExpandProperty Count

        $testResult = $roleAssignmentCount -eq 0

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant has no User Access Administrators."
        }
        else {
            $testResultMarkdown = "Your tenant has $roleAssignmentCount resource(s) with access to manage access to all Azure subscriptions and management groups in this tenant.`n`n"

            $testResultMarkdown += Get-AuDirectoryObjects $userAccessAdmins.properties.principalId -AsMarkdown
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

}

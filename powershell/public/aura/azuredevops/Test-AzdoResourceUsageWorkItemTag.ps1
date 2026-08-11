<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the status of the usage of tag definitions in Azure DevOps, as Azure DevOps supports up to 150,000 tag definitions per organization or collection.

    https://learn.microsoft.com/azure/devops/organizations/settings/work/object-limits?view=azure-devops

.EXAMPLE
    ```
    Test-AzdoResourceUsageWorkItemTag
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoResourceUsageWorkItemTag
#>
function Test-AzdoResourceUsageWorkItemTag {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoResourceUsageWorkItemTag"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $WorkItemTags = (Get-ADOPSResourceUsage -Force).'Work Item Tags'

    $CurrentUsage = $($WorkItemTags.count / $WorkItemTags.limit).ToString("P")

    if ($($WorkItemTags.count / $WorkItemTags.limit) -gt 0.9) {
        $resultMarkdown = "Work Item Tags Resource Usage limit is greater than 90% - Current usage: $CurrentUsage"
        $result = $false
    } else {
        $resultMarkdown = "Work Item Tags Resource Usage limit is at $CurrentUsage"
        $result = $true
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

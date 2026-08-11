<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the status of limitation regarding projects in Azure DevOps, As it supports up to 1,000 projects within an organization

    https://learn.microsoft.com/azure/devops/organizations/projects/about-projects?view=azure-devops

.EXAMPLE
    ```
    Test-AzdoResourceUsageProject
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoResourceUsageProject
#>
function Test-AzdoResourceUsageProject {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoResourceUsageProject"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $Projects = (Get-ADOPSResourceUsage -Force).Projects

    $CurrentUsage = $($Projects.count / $Projects.limit).ToString("P")

    if ($($Projects.count / $Projects.limit) -gt 0.9) {
        $resultMarkdown = "Project Resource Usage limit is greater than 90% - Current usage: $CurrentUsage"
        $result = $false
    } else {
        $resultMarkdown = "Project Resource Usage limit is at $CurrentUsage"
        $result = $true
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

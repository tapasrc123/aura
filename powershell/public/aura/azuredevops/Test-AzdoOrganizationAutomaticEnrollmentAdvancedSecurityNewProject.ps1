<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks if GitHub advanced Security for Azure DevOps is automatically enabled for new projects.

    https://learn.microsoft.com/azure/devops/repos/security/configure-github-advanced-security-features?view=azure-devops&tabs=yaml#organization-level-onboarding

.EXAMPLE
    ```
    Test-AzdoOrganizationAutomaticEnrollmentAdvancedSecurityNewProject
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoOrganizationAutomaticEnrollmentAdvancedSecurityNewProject
#>

function Test-AzdoOrganizationAutomaticEnrollmentAdvancedSecurityNewProject {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoOrganizationAutomaticEnrollmentAdvancedSecurityNewProject"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }
    $result = (Get-ADOPSOrganizationAdvancedSecurity).enableOnCreate

    if ($result) {
        $resultMarkdown = "New projects will by default have Advanced Security enabled."
    } else {
        $resultMarkdown = "New projects must be manually enrolled in Advanced Security."
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

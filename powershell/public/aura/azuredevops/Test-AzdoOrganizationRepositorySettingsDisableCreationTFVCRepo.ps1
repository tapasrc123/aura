<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the status if creation of Team Foundation Version Control (TFVC) repositories is disabled.

    https://learn.microsoft.com/azure/devops/release-notes/roadmap/2024/no-tfvc-in-new-projects

.EXAMPLE
    ```
    Test-AzdoOrganizationRepositorySettingsDisableCreationTFVCRepo
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoOrganizationRepositorySettingsDisableCreationTFVCRepo
#>
function Test-AzdoOrganizationRepositorySettingsDisableCreationTFVCRepo {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoOrganizationRepositorySettingsDisableCreationTFVCRepo"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $result = (Get-ADOPSOrganizationRepositorySettings -Force | Where-object key -eq "DisableTfvcRepositories").value

    if ($result) {
        $resultMarkdown = "Team Foundation Version Control (TFVC) repositories cannot be created."
    } else {
        $resultMarkdown = "Team Foundation Version Control (TFVC) can be created."
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

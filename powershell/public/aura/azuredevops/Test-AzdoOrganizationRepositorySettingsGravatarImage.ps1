<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the status if Gravatar images are shown for users outside of your enterprise.

    https://learn.microsoft.com/azure/devops/repos/git/repository-settings?view=azure-devops&tabs=browser#gravatar-images

.EXAMPLE
    ```
    Test-AzdoOrganizationRepositorySettingsGravatarImage
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoOrganizationRepositorySettingsGravatarImage
#>
function Test-AzdoOrganizationRepositorySettingsGravatarImage {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoOrganizationRepositorySettingsGravatarImage"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $result = (Get-ADOPSOrganizationRepositorySettings -Force | Where-object key -eq "GravatarEnabled").value

    if (-not $result) {
        $resultMarkdown = "Gravatar images are not exposed outside of your enterprise."
    } else {
        $resultMarkdown = "Gravatar images are exposed for users outside of your enterprise."
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

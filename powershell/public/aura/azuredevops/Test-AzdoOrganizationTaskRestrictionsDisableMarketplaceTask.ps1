<#
.SYNOPSIS
    Returns a boolean depending on the configuration.

.DESCRIPTION
    Checks the ability to install and run tasks from the Marketplace, which gives you greater control over the code that executes in a pipeline.

    https://learn.microsoft.com/azure/devops/pipelines/security/overview?view=azure-devops#prevent-malicious-code-execution

.EXAMPLE
    ```
    Test-AzdoOrganizationTaskRestrictionsDisableMarketplaceTask
    ```

    Returns a boolean depending on the configuration.

.LINK
    https://aura.onetapas.com/docs/commands/Test-AzdoOrganizationTaskRestrictionsDisableMarketplaceTask
#>
function Test-AzdoOrganizationTaskRestrictionsDisableMarketplaceTask {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Running Test-AzdoOrganizationTaskRestrictionsDisableMarketplaceTask"

    if (-not (Test-AuConnection AzureDevOps)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzureDevOps
        return $null
    }

    $settings = Get-ADOPSOrganizationPipelineSettings

    if ($settings -eq 'AccessDeniedException') {
        Add-AuTestResultDetail -SkippedBecause Custom -SkippedCustomReason 'Insufficient permissions to access the pipeline settings API. Please ensure you have the necessary permissions to access this information.'
        return $null
    }

    $result = $settings.disableMarketplaceTasksVar

    if ($result) {
        $resultMarkdown = "The ability to install and run tasks from the Marketplace has been restricted."
    } else {
        $resultMarkdown = "It is allowed to install and run tasks from the Marketplace."
    }

    Add-AuTestResultDetail -Result $resultMarkdown

    return $result
}

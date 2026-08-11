function Test-AuVaultSoftDelete {
    <#
    .SYNOPSIS
    Checks if all Recovery Services Vaults have Soft Delete enabled

    .DESCRIPTION
    This test ensures that all Recovery Services Vaults have Soft Delete enabled
    by evaluating the `enhancedSecurityState` property. Soft Delete protects backup
    data from accidental or malicious deletion and is a recommended security control.

    .EXAMPLE
    Test-AuVaultSoftDelete

    Returns true if all vaults have Soft Delete enabled.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuVaultSoftDelete
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection Azure)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedAzure
        return $null
    }

    $nonCompliantVaults = @()
    $resultsMarkdown = ""

    try {
        # Use Azure Resource Graph to get all Recovery Services Vaults across all subscriptions
        $query = "Resources | where type =~ 'Microsoft.RecoveryServices/vaults' | project id, name, resourceGroup, subscriptionId, location"
        $vaults = Invoke-AuAzureResourceGraphRequest -Query $query
    }
    catch {
        Add-AuTestResultDetail -SkippedBecause "Custom" -SkippedCustomReason "Failed to get Recovery Services Vaults" -SkippedError $_
        return $null
    }

    Write-Verbose "Found $($vaults.Count) Recovery Services Vaults to check"

    foreach ($vault in $vaults) {
        try {
            $vaultName = $vault.name
            $vaultRg = $vault.resourceGroup
            $subId = $vault.subscriptionId

            # Get the vault configuration to check soft delete status
            $vaultConfig = Invoke-AuAzureRequest `
                -RelativeUri "/subscriptions/$subId/resourceGroups/$vaultRg/providers/Microsoft.RecoveryServices/vaults/$vaultName/backupconfig/vaultconfig" `
                -ApiVersion "2025-02-01"

            $softDeleteState = $vaultConfig.properties.enhancedSecurityState

            if (-not $softDeleteState) {
                $softDeleteState = "Unknown"
            }

            if ($softDeleteState -ne "Enabled") {
                $nonCompliantVaults += "- $vaultName (subscription: $subId, resource group: $vaultRg) has soft delete not enabled (state: $softDeleteState)"
            }
            else {
                $resultsMarkdown += "- $vaultName (subscription: $subId, resource group: $vaultRg) soft delete is enabled.`n"
            }
        }
        catch {
            $resultsMarkdown += "- Failed to check vault $($vault.name) in subscription $($vault.subscriptionId): $($_.Exception.Message)`n"
            continue
        }
    }

    if (!$vaults) {
        $testResult = $true
        $testResultMarkdown = "No Recovery Services Vaults found"
    }
    else {
        $testResult = $nonCompliantVaults.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = "All $($vaults.Count) Recovery Services Vaults have soft delete enabled.`n`n$resultsMarkdown"
        }
        else {
            $testResultMarkdown = "Some vaults do not have soft delete enabled:`n`n"
            $testResultMarkdown += ($nonCompliantVaults -join "`n")
            $testResultMarkdown += "`n`n**Compliant vaults:**`n$resultsMarkdown"
        }
    }

    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}

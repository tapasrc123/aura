function Test-AuCisSpoGuestCannotShareUnownedItem {
    <#
    .SYNOPSIS
        Ensure that SharePoint guest users cannot share items they don't own

    .DESCRIPTION
        7.2.5 (L2) Ensure that SharePoint guest users cannot share items they don't own
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoGuestCannotShareUnownedItem

        Returns true if SharePoint guest users cannot share items they don't own

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoGuestCannotShareUnownedItem
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing that SharePoint guest users cannot share items they don't own..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.PreventExternalUsersFromResharing) {
            $testResult = "Well done. External users cannot share items they don't own."
        } else {
            $testResult = "External users can share items they don't own."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

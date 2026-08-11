function Test-AuCisHostedConnectionFilterPolicy {
    <#
    .SYNOPSIS
    Checks if connection filter IPs are allow listed

    .DESCRIPTION
    The connection filter should not have allow listed IPs
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisHostedConnectionFilterPolicy

    Returns true if the IP allow list is empty

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisHostedConnectionFilterPolicy
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    try {
        Write-Verbose 'Getting the Hosted Connection Filter policy...'
        $connectionFilterIPAllowList = Get-HostedConnectionFilterPolicy | Where-Object {$_.isDefault -eq $true} | Select-Object IPAllowList

        Write-Verbose 'Check if the Connection Filter IP allow list is empty'
        $testResult = -not $connectionFilterIPAllowList.IPAllowList -or $connectionFilterIPAllowList.IPAllowList.Count -eq 0

        if ($testResult) {
            $testResultMarkdown = 'Well done. The connection filter IP allow list was empty ✅'
        } else {
            $testResultMarkdown = 'The connection filter IP allow list was not empty ❌'
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

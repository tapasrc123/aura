function Test-AuCisAttachmentFilter {
    <#
    .SYNOPSIS
    Checks if the default common attachment types filter is enabled

    .DESCRIPTION
    The common attachment types filter should be enabled
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisAttachmentFilter

    Returns true if the common attachment types filter is enabled.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisAttachmentFilter
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }
    elseif (!(Test-AuConnection SecurityCompliance)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    }

    try {
        Write-Verbose "Getting Malware Filter Policy..."
        $policies = Get-AuExo -Request MalwareFilterPolicy

        # We grab the default policy
        $policy = $policies | Where-Object { $_.IsDefault -eq $true }

        Write-Verbose "Executing checks"
        $fileFilter = $policy | Where-Object {
            $_.EnableFileFilter -match "True"
        }

        $testResult = ($fileFilter | Measure-Object).Count -ge 1

        $portalLink = "https://security.microsoft.com/presetSecurityPolicies"

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenants default malware filter policy has the common attachment file filter enabled ($portalLink).`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "Your tenants default malware filter policy does not have the common attachment file filter enabled ($portalLink).`n`n%TestResult%"
        }

        $resultMd = "| Policy | Result |`n"
        $resultMd += "| --- | --- |`n"

        if ($testResult) {
            $Result = "✅ Pass"
        }
        else {
            $Result = "❌ Fail"
        }

        $resultMd += "| EnableFileFilter | $Result |`n"

        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

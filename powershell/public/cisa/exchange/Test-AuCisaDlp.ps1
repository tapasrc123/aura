function Test-AuCisaDlp {
    <#
    .SYNOPSIS
    Checks state of DLP for EXO

    .DESCRIPTION
    A DLP solution SHALL be used.

    .EXAMPLE
    Test-AuCisaDlp

    Returns true if

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaDlp
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection ExchangeOnline)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }elseif(!(Test-AuConnection SecurityCompliance)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    }elseif($null -eq (Get-AuLicenseInformation -Product ExoDlp)){
        Add-AuTestResultDetail -SkippedBecause NotLicensedExoDlp
        return $null
    }

    $policies = Get-AuExo -Request DlpCompliancePolicy | Where-Object { $_.ExchangeLocation.DisplayName -contains "All" }

    $resultPolicies = $policies | Where-Object {`
        $_.Workload -like "*Exchange*" -and `
        -not $_.IsSimulationPolicy -and `
        $_.Enabled
    }

    $testResult = ($resultPolicies | Measure-Object).Count -ge 1

    $portalLink = "https://purview.microsoft.com/datalossprevention/policies"

    if ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has [Purview Data Loss Prevention Policies]($portalLink) enabled.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have [Purview Data Loss Prevention Policies]($portalLink) enabled.`n`n%TestResult%"
    }

    $result = ''
    if ($policies) {
        $passResult = "✅ Pass"
        $failResult = "❌ Fail"
        $result = "| Name | Status | Description |`n"
        $result += "| --- | --- | --- |`n"
        foreach ($item in ($policies | Sort-Object -Property name)) {
            $itemResult = $failResult
            if($item.Guid -in $resultPolicies.Guid){
                $itemResult = $passResult
            }
            $result += "| $($item.name) | $($itemResult) | $($item.comment) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

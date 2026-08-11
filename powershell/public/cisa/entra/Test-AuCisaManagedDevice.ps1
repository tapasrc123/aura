function Test-AuCisaManagedDevice {
    <#
    .SYNOPSIS
    Checks if a Conditional Access policy requiring managed device is enabled

    .DESCRIPTION
    Managed devices SHOULD be required for authentication.

    .EXAMPLE
    Test-AuCisaManagedDevice

    Returns true if at least one policy requires managed devices

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaManagedDevice
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Do not check if Hybrid Joined devices are accepted.
        [switch]$SkipHybridJoinCheck
    )

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $EntraIDPlan = Get-AuLicenseInformation -Product EntraID
    if($EntraIDPlan -eq "Free"){
        Add-AuTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $result = Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    if($SkipHybridJoinCheck){
        $policies = $result | Where-Object {`
            $_.conditions.applications.includeApplications -contains "All" -and `
            $_.conditions.users.includeUsers -contains "All" -and `
            $_.grantControls.builtInControls -contains "compliantDevice" }
    }else{
        $policies = $result | Where-Object {`
            $_.conditions.applications.includeApplications -contains "All" -and `
            $_.conditions.users.includeUsers -contains "All" -and `
            $_.grantControls.builtInControls -contains "compliantDevice" -and `
            $_.grantControls.builtInControls -contains "domainJoinedDevice" -and `
            $_.grantControls.operator -eq "OR" }
    }

    $testResult = ($policies|Measure-Object).Count -ge 1

    if ($testResult -and $SkipHybridJoinCheck) {
        $testResultMarkdown = "Well done, your security posture is more than CISA's recommended control. Your tenant has one or more policies that require a compliant device:`n`n%TestResult%"
    } elseif ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that require a compliant or domain joined device:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any Conditional Access policies that require managed devices."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $policies

    return $testResult
}

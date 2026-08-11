function Test-AuCisaManagedDeviceRegistration {
    <#
    .SYNOPSIS
    Checks if a policy is enabled requiring a managed device for registration

    .DESCRIPTION
    Managed Devices SHOULD be required to register MFA.

    .EXAMPLE
    Test-AuCisaManagedDeviceRegistration

    Returns true if at least one policy requires MFA for registration

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaManagedDeviceRegistration
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
            $_.conditions.applications.includeUserActions -contains "urn:user:registersecurityinfo" -and `
            $_.conditions.users.includeUsers -contains "All" -and `
            $_.grantControls.builtInControls -contains "compliantDevice" }
    }else{
        $policies = $result | Where-Object {`
            $_.conditions.applications.includeUserActions -contains "urn:user:registersecurityinfo" -and `
            $_.conditions.users.includeUsers -contains "All" -and `
            $_.grantControls.builtInControls -contains "compliantDevice" -and `
            $_.grantControls.builtInControls -contains "domainJoinedDevice" -and `
            $_.grantControls.operator -eq "OR" }
    }

    $testResult = ($policies|Measure-Object).Count -ge 1

    if ($testResult -and $SkipHybridJoinCheck) {
        $testResultMarkdown = "Well done, your security posture is more than CISA's recommended control. Your tenant has one or more policies that require a compliant device for registration:`n`n%TestResult%"
    } elseif ($testResult) {
        $testResultMarkdown = "Well done. Your tenant has one or more policies that require a compliant or domain joined device for registration:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Your tenant does not have any Conditional Access policies that require managed devices for registration."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $policies

    return $testResult
}

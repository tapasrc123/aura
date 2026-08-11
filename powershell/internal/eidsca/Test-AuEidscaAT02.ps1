function Test-AuEidscaAT02 {
    <#
    .SYNOPSIS
    Checks if Authentication Method - Temporary Access Pass - One-time is set to 'true'

    .DESCRIPTION

    Determines whether the pass is limited to a one-time use.

    Queries policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass')
    and returns the result of
    graph/policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass').isUsableOnce -eq 'true'

    .EXAMPLE
    Test-AuEidscaAT02

    Returns the result of graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass').isUsableOnce -eq 'true'
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ( $EnabledAuthMethods -notcontains 'TemporaryAccessPass' ) {
            Add-AuTestResultDetail -SkippedBecause 'Custom' -SkippedCustomReason 'Authentication method of Temporary Access Pass is not enabled.'
            return $null
    }
    $result = Invoke-AuGraphRequest -RelativeUri "policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass')" -ApiVersion beta

    $rawValue = $result.isUsableOnce
    [string]$tenantValue = $rawValue
    $testResult = $tenantValue -eq 'true'
    $tenantValueNotSet = ($null -eq $rawValue -or $rawValue -eq "") -and 'true' -notlike '*$null*'

    if($testResult){
        $testResultMarkdown = "Well done. The configuration in your tenant and recommended value is **'true'** for **policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass')**"
    } elseif ($tenantValueNotSet) {
        $testResultMarkdown = "Your tenant is **not configured explicitly**.`n`nThe recommended value is **'true'** for **policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass')**. It seems that you are using a default value by Microsoft. We recommend to set the setting value explicitly since non set values could change depending on what Microsoft decides the current default should be."
    } else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'true'** for **policies/authenticationMethodsPolicy/authenticationMethodConfigurations('TemporaryAccessPass')**"
    }
    Add-AuTestResultDetail -Result $testResultMarkdown -Severity 'Medium'

    return $tenantValue
}

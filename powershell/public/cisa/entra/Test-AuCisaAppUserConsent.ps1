function Test-AuCisaAppUserConsent {
    <#
    .SYNOPSIS
    Checks if user app consent is prevented

    .DESCRIPTION
    Only administrators SHALL be allowed to consent to applications.

    .EXAMPLE
    Test-AuCisaAppUserConsent

    Returns true if disabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisaAppUserConsent
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if(!(Test-AuConnection Graph)){
        Add-AuTestResultDetail -SkippedBecause NotConnectedGraph
        return $null
    }

    $result = Invoke-AuGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $permissions = $result.defaultUserRolePermissions.permissionGrantPoliciesAssigned | Where-Object {`
        $_ -like "ManagePermissionGrantsForSelf.*" }

    $testResult = ($permissions|Measure-Object).Count -eq 0

    if ($testResult) {
        $testResultMarkdown = "Well done. **[User consent for applications](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings)** is set to **Do not allow user consent** in your tenant."
    } else {
        $testResultMarkdown = "Your tenant [allows users to consent for applications](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings). The recommended setting is **Do not allow user consent**."
    }
    Add-AuTestResultDetail -Result $testResultMarkdown
    return $testResult
}

function Get-AuAuthenticationMethodPolicyConfig {
    <#
    .SYNOPSIS
    Get details of authentication methods

    .DESCRIPTION
    This function retrieves the configuration of authentication methods with specific state.

    .EXAMPLE
    Get-AuAuthenticationMethodPolicyConfig -State Enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuAuthenticationMethodPolicyConfig
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Enabled", "Disabled")]
        # Only return methods in the specified state. Can be Enabled or Disabled.
        [string]$State
    )

    Write-Verbose -Message "Getting authenticationMethodConfigurations from Authentication Methods Policy."
    if ($State) {
        return (Invoke-AuGraphRequest -RelativeUri 'policies/authenticationMethodsPolicy' -ApiVersion beta).authenticationMethodConfigurations | where-object {$_.state -eq $state}
    } else {
        return (Invoke-AuGraphRequest -RelativeUri 'policies/authenticationMethodsPolicy' -ApiVersion beta).authenticationMethodConfigurations
    }
}

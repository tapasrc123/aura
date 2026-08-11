function Get-AuConditionalAccessPolicy {
    <#
    .Synopsis
    Returns all the Conditional Access policies in the tenant.

    .Description
    Returns all the Conditional Access policies in the tenant.

    .Example
    Get-AuConditionalAccessPolicy

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuConditionalAccessPolicy
    #>
  [CmdletBinding()]
  param(
    # Specify if this request should skip cache and go directly to Graph.
    [Parameter(Mandatory = $false)]
    [Switch]$DisableCache
  )

  Write-Verbose -Message "Getting Conditional Access policies."

  return Invoke-AuGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta -DisableCache:$DisableCache

}

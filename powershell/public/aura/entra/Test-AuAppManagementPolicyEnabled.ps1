function Test-AuAppManagementPolicyEnabled {
    <#
    .Synopsis
    Checks if the default app management policy is enabled.

    .Description
    GET /policies/defaultAppManagementPolicy

    .Example
    Test-AuAppManagementPolicyEnabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAppManagementPolicyEnabled
    #>
  [CmdletBinding()]
  [OutputType([bool])]
  param()

  try {
    $defaultAppManagementPolicy = Invoke-AuGraphRequest -RelativeUri 'policies/defaultAppManagementPolicy'
    Write-Verbose -Message "Default App Management Policy: $($defaultAppManagementPolicy.isEnabled)"
    $result = $defaultAppManagementPolicy.isEnabled -eq 'True'

    if ($result) {
      $resultMarkdown = 'Well done. Your tenant has an app management policy enabled.'
    } else {
      $resultMarkdown = 'Your tenant does not have an app management policy defined.'
    }

    Add-AuTestResultDetail -Result $resultMarkdown
    return $result
  } catch {
    Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
    return $null
  }
}

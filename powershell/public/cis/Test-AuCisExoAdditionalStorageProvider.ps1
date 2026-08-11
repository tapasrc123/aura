function Test-AuCisExoAdditionalStorageProvider {
    <#
    .SYNOPSIS
    Checks if additional storage providers are restricted in Outlook on the web

    .DESCRIPTION
    This setting allows users to open certain external files while working in Outlook on the web.
    If allowed, keep in mind that Microsoft doesn't control the use terms or privacy policies of
    those third-party services.
    CIS Microsoft 365 Foundations Benchmark v6.0.1
    6.5.3 (L2) Ensure additional storage providers are restricted in Outlook on the web (Automated)

    .EXAMPLE
    Test-AuCisExoAdditionalStorageProvider

    Returns true if additional storage providers are restricted.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisExoAdditionalStorageProvider
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    }

    try {
        Write-Verbose "Getting OWA Mailbox Policy..."
        $owaMailboxPolicy = Get-AuExo -Request OwaMailboxPolicy
        Write-Verbose "Found $($owaMailboxPolicy.Count) Exchange Web mailbox policies"

        $portalLink_SecureScore = "$($__AuSession.AdminPortalUrl.Security)securescore"

        $owaMailboxPolicyDefault = $owaMailboxPolicy | Where-Object { $_.IsDefault -eq $true }
        Write-Verbose "Filtered $(@($owaMailboxPolicyDefault).Count) Default Web mailbox policy"

        if ($null -eq $owaMailboxPolicyDefault) {
            Add-AuTestResultDetail -SkippedBecause "No default OWA mailbox policy was found."
            return $null
        }

        $result = $owaMailboxPolicyDefault.AdditionalStorageProvidersAvailable

        if ($result -eq $false) {
            $testResultMarkdown = "Well done. AdditionalStorageProvidersAvailable is ``$($result)```n`n"
        } else {
            $testResultMarkdown = "``AdditionalStorageProvidersAvailable`` should be ``False`` and is ``$($result)`` in [SecureScore]($portalLink_SecureScore)`n`n"
        }

        Add-AuTestResultDetail -Result $testResultMarkdown
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }

    return !$result
}

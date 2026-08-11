function Get-AuSession {
    <#
    .SYNOPSIS
    Gets the current Aura session information which includes the current Graph base uri and other details.
    These are read-only and should not be modified directly.

    .DESCRIPTION
    Get-AuSession is intended for troubleshooting and diagnostic display of the current Aura
    module session. It returns a sanitized copy of the session data rather than the live internal
    session object.

    Sensitive values are stripped from the output. For example, the GitHubAuthHeader Authorization
    value is redacted so copied session output cannot leak the GitHub token. The live session used by
    internal callers is unchanged.

    .EXAMPLE
    Get-AuSession

    Returns the current Aura session information.

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuSession
    #>
    [CmdletBinding()]
    param()

    Write-Verbose 'Getting the current Aura session information.'

    # Return a sanitized copy so troubleshooting output cannot leak the GitHub token;
    # internal callers continue to use the live $__AuSession values.
    $sessionCopy = @{}
    foreach ($key in $__AuSession.Keys) {
        $sessionCopy[$key] = $__AuSession[$key]
    }

    $authHeader = $__AuSession['GitHubAuthHeader']
    if ($null -ne $authHeader) {
        if ($authHeader -is [System.Collections.IDictionary]) {
            $redactedHeader = [ordered]@{}
            foreach ($k in $authHeader.Keys) {
                if ($k -ieq 'Authorization') {
                    $redactedHeader[$k] = '<redacted>'
                } else {
                    $redactedHeader[$k] = $authHeader[$k]
                }
            }
            $sessionCopy['GitHubAuthHeader'] = $redactedHeader
        } else {
            $sessionCopy['GitHubAuthHeader'] = '<redacted>'
        }
    }

    Write-Output $sessionCopy
}

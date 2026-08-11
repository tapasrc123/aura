function Test-AuAdSupportedSaslMechanismCount {
    <#
    .SYNOPSIS
    Retrieves the count of supported SASL mechanisms in Active Directory.

    .DESCRIPTION
    Simple Authentication and Security Layer (SASL) mechanisms define the
    authentication protocols supported by Active Directory. The Root DSE
    (Directory Service Agent) publishes the supported SASL mechanisms which
    clients use to negotiate authentication.

    Common SASL mechanisms include:
    - GSSAPI: Kerberos-based authentication (most secure)
    - GSS-SPNEGO: Negotiate authentication
    - EXTERNAL: External authentication
    - DIGEST-MD5: Digest authentication

    Understanding supported mechanisms helps assess authentication capabilities
    and potential security implications.

    .EXAMPLE
    Test-AuAdSupportedSaslMechanismCount

    Returns $true if Root DSE data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdSupportedSaslMechanismCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdSupportedSaslMechanismCount"

    $adState = Get-AuADDomainState

    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $rootDse = $adState.RootDSE
    $saslMechanisms = $rootDse.SupportedSASLMechanisms
    $mechanismCount = if ($saslMechanisms) { ($saslMechanisms | Measure-Object).Count } else { 0 }

    $testResult = $true

    $result = "| Property | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Supported SASL Mechanisms Count | $mechanismCount |" + "`n"

    if ($mechanismCount -gt 0) {
        $result += "| Mechanisms | $(($saslMechanisms -join ', ')) |" + "`n"
    }

    $testResultMarkdown = "Active Directory supported SASL mechanisms have been enumerated. These mechanisms define available authentication protocols.`n`n%TestResult%"
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}

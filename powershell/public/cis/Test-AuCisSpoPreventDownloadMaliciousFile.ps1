function Test-AuCisSpoPreventDownloadMaliciousFile {
    <#
    .SYNOPSIS
        Ensure Office 365 SharePoint infected files are disallowed for download

    .DESCRIPTION
        7.3.1 (L2) Ensure Office 365 SharePoint infected files are disallowed for download
        CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
        Test-AuCisSpoPreventDownloadMaliciousFile

        Returns true if Office 365 SharePoint infected files are disallowed for download

    .LINK
        https://aura.onetapas.com/docs/commands/Test-AuCisSpoPreventDownloadMaliciousFile
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Write-Verbose "Testing malicious file download prevention in SharePoint Online..."

    if (!(Test-AuConnection SharePointOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSharePoint
        return $null
    }

    $return = $true
    try {
        $spoTenant = Get-AuSpo
        if ($spoTenant.DisallowInfectedFileDownload) {
            $testResult = "Well done. Malicious file download prevention is enabled in your SharePoint tenant."
        } else {
            $testResult = "Malicious file download prevention is not enabled in your SharePoint tenant."
            $return = $false
        }
        Add-AuTestResultDetail -Result $testResult
        return $return
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

function Test-AuCisSafeAttachment {
    <#
    .SYNOPSIS
    Checks if the Safe Attachments policy is enabled

    .DESCRIPTION
    The Safe Attachments policy is enabled
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisSafeAttachment

    Returns true safe attachments policy is enabled

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisSafeAttachment
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (!(Test-AuConnection ExchangeOnline)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedExchange
        return $null
    } elseif (!(Test-AuConnection SecurityCompliance)) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return $null
    } elseif ('P1' -notin (Get-AuLicenseInformation -Product MdoV2)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedMdoP1
        return $null
    }

    try {
        Write-Verbose 'Getting Safe Attachment Policy...'
        $policies = Get-AuExo -Request SafeAttachmentPolicy

        # We grab the default policy as that is what CIS checks
        $policy = $policies | Where-Object { $_.Name -eq 'Built-In Protection Policy' }

        $safeAttachmentCheckList = @()

        #Enable
        $safeAttachmentCheckList += [pscustomobject] @{
            'CheckName' = 'Enable'
            'Value'     = 'True'
        }

        #Action
        $safeAttachmentCheckList += [pscustomobject] @{
            'CheckName' = 'Action'
            'Value'     = 'Block'
        }

        #QuarantineTag
        $safeAttachmentCheckList += [pscustomobject] @{
            'CheckName' = 'QuarantineTag'
            'Value'     = 'AdminOnlyAccessPolicy'
        }

        Write-Verbose 'Executing checks'
        $failedCheckList = @()

        foreach ($check in $safeAttachmentCheckList) {
            $checkResult = $policy | Where-Object { $_.($check.CheckName) -notmatch $check.Value }
            if ($checkResult) {
                #If the check fails, add it to the list so we can report on it later
                $failedCheckList += $check.CheckName
            }
        }

        $testResult = ($failedCheckList | Measure-Object).Count -eq 0

        $portalLink = 'https://security.microsoft.com/safeattachmentv2'

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenants default safe attachments policy matches CIS recommendations ($portalLink).`n`n%TestResult%"
        } else {
            $testResultMarkdown = "Your tenants default safe attachments policy does not match CIS recommendations ($portalLink).`n`n%TestResult%"
        }

        $resultMd = "| Check Name | Result |`n"
        $resultMd += "| --- | --- |`n"
        foreach ($item in $safeAttachmentCheckList) {
            $itemResult = '❌ Fail'
            if ($item.CheckName -notin $failedCheckList) {
                $itemResult = '✅ Pass'
            }
            $resultMd += "| $($item.CheckName) | $($itemResult) |`n"
        }

        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $resultMd

        Add-AuTestResultDetail -Result $testResultMarkdown
        return $testResult
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

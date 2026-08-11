function Test-AuCisSafeAttachmentsAtpPolicy {
    <#
    .SYNOPSIS
    Checks if Safe Attachments for SharePoint, OneDrive, and Microsoft Teams are enabled

    .DESCRIPTION
    Safe Attachments for SharePoint, OneDrive, and Microsoft Teams should be enabled
    CIS Microsoft 365 Foundations Benchmark v6.0.1

    .EXAMPLE
    Test-AuCisSafeAttachmentsAtpPolicy

    Enabled for SharePoint, OneDrive, and Microsoft Teams

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCisSafeAttachmentsAtpPolicy
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
        Write-Verbose 'Getting 365 Atp Policy...'
        $policy = Get-AuExo -Request AtpPolicyForO365

        $atpPolicyCheckList = @()

        #EnableATPForSPOTeamsODB should be True
        $atpPolicyCheckList += [pscustomobject] @{
            'CheckName' = 'EnableATPForSPOTeamsODB'
            'Value'     = 'True'
        }

        #EnableSafeDocs should be True
        $atpPolicyCheckList += [pscustomobject] @{
            'CheckName' = 'EnableSafeDocs'
            'Value'     = 'True'
        }

        #AllowSafeDocsOpen should be False
        $atpPolicyCheckList += [pscustomobject] @{
            'CheckName' = 'AllowSafeDocsOpen'
            'Value'     = 'False'
        }

        Write-Verbose 'Executing checks'
        $failedCheckList = @()
        foreach ($check in $atpPolicyCheckList) {
            $checkResult = $policy | Where-Object { $_.($check.CheckName) -notmatch $check.Value }
            if ($checkResult) {
                #If the check fails, add it to the list so we can report on it later
                $failedCheckList += $check.CheckName
            }
        }

        $testResult = ($failedCheckList | Measure-Object).Count -eq 0

        $portalLink = 'https://security.microsoft.com/safeattachmentv2'

        if ($testResult) {
            $testResultMarkdown = "Well done. Your tenant has Safe Attachments for SharePoint, OneDrive, and Microsoft Teams enabled ($portalLink).`n`n%TestResult%"
        } else {
            $testResultMarkdown = "Your tenant does not have Safe Attachments for SharePoint, OneDrive, and Microsoft Teams enabled ($portalLink).`n`n%TestResult%"
        }

        $resultMd = "| Check Name | Result |`n"
        $resultMd += "| --- | --- |`n"
        foreach ($item in $atpPolicyCheckList) {
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

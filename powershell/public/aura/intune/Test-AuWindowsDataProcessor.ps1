function Test-AuWindowsDataProcessor {
    <#
    .SYNOPSIS
    Check the Intune Windows Data Processor settings.
    .DESCRIPTION
    This command checks the Windows Data Processor settings in Microsoft Intune to determine if features requiring Windows diagnostic data are enabled and if the Windows license verification is complete.

    .EXAMPLE
    Test-AuWindowsDataProcessor

    Returns true if features requiring Windows diagnostic data are enabled and the Windows license verification is complete.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuWindowsDataProcessor
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Get-AuLicenseInformation -Product Intune)) {
        Add-AuTestResultDetail -SkippedBecause NotLicensedIntune
        return $null
    }

    try {
        Write-Verbose 'Retrieving Windows Data Processor status...'
        $dataProcessor = Invoke-AuGraphRequest -RelativeUri 'deviceManagement/dataProcessorServiceForWindowsFeaturesOnboarding' -ApiVersion beta
        $testResultMarkdown = "Windows data processor status:`n"
        $testResultMarkdown += "* Enable features that require Windows diagnostic data in processor configuration: {0} `n" -f $dataProcessor.areDataProcessorServiceForWindowsFeaturesEnabled
        $testResultMarkdown += "* Windows license verification status: {0} `n" -f $dataProcessor.hasValidWindowsLicense
        Add-AuTestResultDetail -Result $testResultMarkdown
        return ($dataProcessor.hasValidWindowsLicense -and $dataProcessor.areDataProcessorServiceForWindowsFeaturesEnabled)
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}

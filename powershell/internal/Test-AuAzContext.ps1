function Test-AuAzContext {
    <#
    .SYNOPSIS
    Validates the AzContext to ensure a valid connection to Azure.
    This cmdlet is used mainly by the Get-AuraApp and Update-AuraApp cmdlets and related cmdlets.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    param ()

    $validContext = (Test-AuConnection Azure)

    if (-not $validContext) {
        Write-Host "`The cmdlet requires a connection to Azure. Please connect using using the following command." -ForegroundColor Red
        Write-Host "`Connect-Aura -Service Azure`n" -ForegroundColor Yellow
        $validContext = $false
    }

    return $validContext
}

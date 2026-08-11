function Get-AuConfirmation {
    <#
    .SYNOPSIS
    Get confirmation from user.

    .DESCRIPTION
    Get confirmation from user to continue with the operation.

    .EXAMPLE
    Get-AuConfirmation
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [CmdletBinding()]
    param ($message)

    $continue = $(Write-Host $message -ForegroundColor Yellow -NoNewline; Read-Host)
    return $continue -eq "Y"
}

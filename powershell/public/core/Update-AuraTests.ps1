function Update-AuraTests {
    <#
    .SYNOPSIS
    Updates the specified folder with the latest ready-made Aura tests built by the Aura team.

    .DESCRIPTION
    The Aura team maintains a repository of ready made tests that can be used to verify the configuration of your Microsoft 365 tenant.

    The tests can be viewed at https://github.com/tapasrc123/aura/tree/main/tests

    .PARAMETER Path
    The path to install or update the Aura tests in.

    .EXAMPLE
    Update-AuraTests -Path .\aura-tests

    Installs or updates the latest Aura tests in the specified directory.

    .EXAMPLE
    Update-AuraTests -Path .\

    Install the latest set of Aura tests in the current directory.

    .LINK
    https://aura.onetapas.com/docs/commands/Update-AuraTests
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This command updates multiple tests')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The path to install or update Aura tests in. Defaults to the current directory.
        [Parameter(Mandatory = $false)]
        [string] $Path = '.\',

        # Switch to control the toggling off of the "Are you sure?" prompt
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    Write-Verbose 'Checking if newer version is available.'
    Get-IsNewAuraVersionAvailable | Out-Null

    Write-Verbose "Updating Aura tests in '$Path'."
    Update-AuTests -Path $Path -Force:$Force
}

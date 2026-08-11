function Update-AuTests {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This command updates multiple tests')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The path to install the Aura tests to, defaults to the current directory.
        [Parameter(Mandatory = $true)]
        [string] $Path,

        # Defaults to update, used to show the correct message as 'installed' or 'updated'.
        [Parameter(Mandatory = $false)]
        [switch] $Install,

        # Switch to control the toggling off of the "Are you sure?" prompt
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    $AuraTestsPath = Get-AuraTestFolderPath
    if (-not (Test-Path -Path $AuraTestsPath -PathType Container)) {
        Write-Error "Aura tests not found at $AuraTestsPath"
        return
    }

    $AuraTests = (Get-ChildItem -Path $AuraTestsPath -Exclude 'Custom').Name

    $targetFolderExists = (Test-Path -Path $Path -PathType Container)
    if (-not $targetFolderExists) {
        Write-Verbose "Creating directory $([System.IO.Path]::GetFullPath($Path))"
        try {
            New-Item -Path $Path -ItemType Directory | Out-Null
        } catch {
            Write-Error "Unable to create directory $([System.IO.Path]::GetFullPath($Path))"
            Write-Verbose $_
            return
        }
    }

    $installOrUpdate = if ($Install) { 'installed' } else { 'updated' }

    if ($targetFolderExists) {
        # Check if the folder already exists and prompt user to confirm overwrite.
        $itemsToDelete = Get-ChildItem -Path $Path | Where-Object { $_.Name -in $($AuraTests) }

        if ($itemsToDelete.Count -gt 0) {
            $message = "`nThe following items will be deleted when installing the latest Aura tests:`n"
            $itemsToDelete | ForEach-Object { $message += "  $($_.FullName)`n" }

            # Display prompt unless Force has been explicitly set
            if (!$Force) {
                $message += 'Do you want to continue? (y/n): '
                $continue = Get-AuConfirmation $message
            }

            # Continue if either user has accepted prompt, or Force has been explicitly set
            if ($continue -or $Force) {
                foreach ($item in $itemsToDelete) {
                    if ($item.Attributes -ne 'Directory') {
                        Remove-Item -Path $item.FullName -Force
                    } else {
                        Remove-Item -Path $item.FullName -Recurse -Force
                    }
                }
            } else {
                Write-Host "Aura tests not $installOrUpdate." -ForegroundColor Red
                return
            }
        }
    }

    try {
        Write-Verbose "Copying Aura tests from $AuraTestsPath/* to $Path"
        Copy-Item -Path $AuraTestsPath/* -Destination $Path -Recurse -Force
    } catch {
        Write-Error "Unable to copy the Aura tests to $Path."
        Write-Verbose $_
        return
    }

    $message = "Run `Connect-Aura` to sign in and then run `Invoke-Aura` to start testing."
    #if (Get-MgContext) { #ToAdjust: Issue with -SkipGraphConnect
    if (Test-AuConnection Graph) {
        $message = 'Run Invoke-Aura to start testing.'
    }

    Write-Host "Aura tests $installOrUpdate successfully!`n$message" -ForegroundColor Green
}

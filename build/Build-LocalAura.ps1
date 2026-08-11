<#
.SYNOPSIS
    Builds, validates, and imports the local Aura module.

.DESCRIPTION
    Creates the publishable module under ./module, validates the build output,
    unloads any currently loaded Aura module, and imports the local build into
    the caller's global session so it remains available after this script exits.
    When BuildReport is specified, also builds the report web app and copies its
    generated HTML into the PowerShell assets before building the module.

.PARAMETER BuildReport
    Runs the report npm build and copies report/dist/index.html to
    powershell/assets/ReportTemplate.html before building the local module.
    Report dependencies must already be installed.

.EXAMPLE
    ./build/Build-LocalAura.ps1

    Builds and imports the local Aura module. Invoke-Aura can then be run
    against ./module/aura-tests.

.EXAMPLE
    ./build/Build-LocalAura.ps1 -BuildReport

    Builds and embeds the report template, then builds, validates, and imports
    the local Aura module.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Developer helper that reports the imported module path.')]
[CmdletBinding()]
param (
    [Parameter()]
    [switch] $BuildReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BuildScript = Join-Path $PSScriptRoot 'Build-AuraModule.ps1'
$ValidationScript = Join-Path $PSScriptRoot 'Test-AuraModuleOutput.ps1'
$ModulePath = Join-Path $PSScriptRoot '../module'
$ModuleManifestPath = Join-Path $ModulePath 'Aura.psd1'
$ReportProjectPath = Join-Path $PSScriptRoot '../report'
$ReportOutputPath = Join-Path $ReportProjectPath 'dist/index.html'
$ReportTemplatePath = Join-Path $PSScriptRoot '../powershell/assets/ReportTemplate.html'
$ProgressActivity = 'Preparing local Aura module'

try {
    if ($BuildReport.IsPresent) {
        Write-Progress -Activity $ProgressActivity -Status 'Building report' -PercentComplete 5

        $NpmCommand = Get-Command -Name 'npm' -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if (-not $NpmCommand) {
            throw 'npm is required to build the report but was not found.'
        }

        & $NpmCommand.Source --prefix $ReportProjectPath run build
        $NpmExitCode = $LASTEXITCODE
        if ($NpmExitCode -ne 0) {
            throw "Report build failed with npm exit code $NpmExitCode."
        }
        if (-not (Test-Path -LiteralPath $ReportOutputPath -PathType Leaf)) {
            throw "Report build did not produce the expected file: '$ReportOutputPath'."
        }

        Write-Progress -Activity $ProgressActivity -Status 'Copying report template' -PercentComplete 25
        Copy-Item -LiteralPath $ReportOutputPath -Destination $ReportTemplatePath -Force
    }

    $ModuleBuildProgress = if ($BuildReport.IsPresent) { 35 } else { 10 }
    Write-Progress -Activity $ProgressActivity -Status 'Building module' -PercentComplete $ModuleBuildProgress

    Get-Module -Name Aura -All | Remove-Module -Force -ErrorAction SilentlyContinue
    & $BuildScript 1>$null 3>$null 4>$null 5>$null 6>$null

    Write-Progress -Activity $ProgressActivity -Status 'Validating build' -PercentComplete 70
    & $ValidationScript -ModulePath $ModulePath 1>$null 3>$null 4>$null 5>$null 6>$null

    Write-Progress -Activity $ProgressActivity -Status 'Loading local module' -PercentComplete 90
    $ImportedModules = @(
        Import-Module $ModuleManifestPath -Force -Global -PassThru -ErrorAction Stop `
            3>$null 4>$null 5>$null 6>$null
    )
    $ImportedModule = $ImportedModules |
        Where-Object { $_.Name -eq 'Aura' } |
        Select-Object -First 1

    if (-not $ImportedModule) {
        throw 'Import-Module did not return the locally built Aura module.'
    }

    $ExpectedModuleBase = (Resolve-Path -LiteralPath $ModulePath).Path
    if ($ImportedModule.ModuleBase -ne $ExpectedModuleBase) {
        throw "Expected to import Aura from '$ExpectedModuleBase', but imported it from '$($ImportedModule.ModuleBase)'."
    }
} finally {
    Write-Progress -Activity $ProgressActivity -Completed
}

$ReadyEmoji = [char]::ConvertFromUtf32(0x1F525)
Write-Host "$ReadyEmoji Local Aura built and loaded: $($ImportedModule.ModuleBase)" -ForegroundColor Green

<#
.SYNOPSIS
    Validates the built Aura module output produced by Build-AuraModule.ps1.

.DESCRIPTION
    Runs post-build validation checks against the built module directory:

    - Confirms all expected files and directories are present.
    - Confirms the generated test metadata bundle is valid and populated.
    - Optionally confirms the manifest ModuleVersion matches an expected version.
    - Imports the built module and confirms the exported command count meets a minimum.
    - Exercises runtime companion Markdown resolution from the generated bundle.
    - Confirms comment-based help survived consolidation for a sample of functions.

    Throws a terminating error on the first failed check, making it suitable as a
    fail-fast validation step in CI workflows.

.PARAMETER ModulePath
    Path to the built module directory. Defaults to ../module relative to this script.

.PARAMETER ExpectedVersion
    Optional version the built manifest must declare. A prerelease suffix
    (for example 2.1.5-preview) is stripped before comparison because the manifest
    stores the prerelease label separately from ModuleVersion.

.PARAMETER MinimumCommandCount
    Minimum number of commands the built module must export. Defaults to 200.

.EXAMPLE
    ./build/Test-AuraModuleOutput.ps1

    Validates the default ./module build output.

.EXAMPLE
    ./build/Test-AuraModuleOutput.ps1 -ModulePath ./module -ExpectedVersion '2.1.5-preview'

    Validates the build output and confirms the manifest version matches 2.1.5.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'CI console script that reports progress to the workflow log.')]
[CmdletBinding()]
param (
    [Parameter()]
    [string] $ModulePath = "$PSScriptRoot/../module",

    [Parameter()]
    [string] $ExpectedVersion,

    [Parameter()]
    [ValidateRange(1, [int]::MaxValue)]
    [int] $MinimumCommandCount = 200
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ModulePath = (Resolve-Path -LiteralPath $ModulePath).Path
Write-Host "── Validating built module at $ModulePath" -ForegroundColor Cyan

# ──────────────────────────────────────────────────────────────────────────────
# Check 1 — Expected files and directories are present
# ──────────────────────────────────────────────────────────────────────────────

$ExpectedItems = @(
    'Aura.psd1'
    'Aura.psm1'
    'Aura.TestMetadata.json'
    'OrcaClasses.ps1'
    'Aura.Format.ps1xml'
    'assets'
    'aura-tests'
    'aura-tests/Custom'
)

foreach ($Item in $ExpectedItems) {
    $ItemPath = Join-Path $ModulePath $Item
    if (-not (Test-Path -LiteralPath $ItemPath)) {
        throw "Build output is missing expected item: $Item"
    }
}
Write-Host "   Verified: $($ExpectedItems.Count) expected files and directories present"

# ──────────────────────────────────────────────────────────────────────────────
# Check 2 — Test metadata bundle is valid and populated
# ──────────────────────────────────────────────────────────────────────────────

$TestMetadataPath = Join-Path $ModulePath 'Aura.TestMetadata.json'
$TestMetadata = Get-Content -LiteralPath $TestMetadataPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
$TestMetadataCount = @($TestMetadata.PSObject.Properties).Count
if ($TestMetadataCount -eq 0) {
    throw 'Test metadata bundle does not contain any entries.'
}
Write-Host "   Verified: test metadata bundle contains $TestMetadataCount entries"

# ──────────────────────────────────────────────────────────────────────────────
# Check 3 — Manifest version matches the expected (stamped) version
# ──────────────────────────────────────────────────────────────────────────────

$ManifestPath = Join-Path $ModulePath 'Aura.psd1'
$Manifest = Import-PowerShellDataFile -Path $ManifestPath

if ($ExpectedVersion) {
    # The manifest stores the prerelease label separately from ModuleVersion.
    $ExpectedBaseVersion = ($ExpectedVersion -split '-')[0]
    if ($Manifest.ModuleVersion -ne $ExpectedBaseVersion) {
        throw "Manifest ModuleVersion '$($Manifest.ModuleVersion)' does not match expected version '$ExpectedBaseVersion' (from '$ExpectedVersion')."
    }
    Write-Host "   Verified: ModuleVersion $($Manifest.ModuleVersion) matches expected version"
} else {
    Write-Host "   Manifest ModuleVersion: $($Manifest.ModuleVersion) (no expected version supplied)"
}

# ──────────────────────────────────────────────────────────────────────────────
# Check 4 — Module imports and exports the expected number of commands
# ──────────────────────────────────────────────────────────────────────────────

$ImportedModules = @(Import-Module $ManifestPath -Force -PassThru -ErrorAction Stop)
$ImportedModule = $ImportedModules | Where-Object { $_.Name -eq 'Aura' } | Select-Object -First 1
if (-not $ImportedModule) {
    throw 'Import-Module did not return the Aura module object.'
}

$CommandCount = $ImportedModule.ExportedCommands.Count
if ($CommandCount -lt $MinimumCommandCount) {
    throw "Built module exports $CommandCount commands; expected at least $MinimumCommandCount."
}
Write-Host "   Verified: module imports and exports $CommandCount commands"

# ──────────────────────────────────────────────────────────────────────────────
# Check 5 — Runtime result details resolve companion Markdown from the bundle
# ──────────────────────────────────────────────────────────────────────────────

$MetadataProbeCommand = 'Test-AuCisaDlp'
$MetadataProbeProperty = $TestMetadata.PSObject.Properties[$MetadataProbeCommand]
if (-not $MetadataProbeProperty) {
    throw "Test metadata bundle is missing the runtime probe entry: $MetadataProbeCommand"
}

$MetadataProbeTestName = '__AuraBuildMetadataProbe'
$MetadataProbeValue = 'Metadata bundle runtime probe'
$MetadataProbeResult = & $ImportedModule {
    param($TestName, $ProbeValue)

    function Test-AuCisaDlp {
        param($Name, $Result)

        Add-AuTestResultDetail -TestName $Name -TestTitle $Name -Result $Result
    }

    Test-AuCisaDlp -Name $TestName -Result $ProbeValue
    $__AuSession.TestResultDetail[$TestName]
} $MetadataProbeTestName $MetadataProbeValue

$ExpectedProbeDescription = $MetadataProbeProperty.Value.Description
$ExpectedProbeResult = $MetadataProbeProperty.Value.Result.Replace('%TestResult%', $MetadataProbeValue)
if (-not $MetadataProbeResult) {
    throw 'Built module did not record result details during the metadata runtime probe.'
}
if ($MetadataProbeResult.TestDescription -ne $ExpectedProbeDescription) {
    throw 'Built module did not resolve the expected companion Markdown description at runtime.'
}
if ($MetadataProbeResult.TestResult -ne $ExpectedProbeResult) {
    throw 'Built module did not render the expected companion Markdown result at runtime.'
}
Write-Host "   Verified: runtime result details resolve companion Markdown from $MetadataProbeCommand"

# ──────────────────────────────────────────────────────────────────────────────
# Check 6 — Comment-based help survived consolidation for a sample of functions
# ──────────────────────────────────────────────────────────────────────────────

$SampleFunctions = @('Invoke-Aura', 'Connect-Aura', 'Get-AuRole', 'Add-AuTestResultDetail')

foreach ($FunctionName in $SampleFunctions) {
    $Help = Get-Help -Name $FunctionName -ErrorAction Stop

    # When comment-based help is missing or broken, Get-Help falls back to an
    # auto-generated synopsis that begins with the function name and its syntax.
    if ([string]::IsNullOrWhiteSpace($Help.Synopsis) -or $Help.Synopsis.TrimStart().StartsWith($FunctionName)) {
        throw "Comment-based help is missing or broken for $FunctionName (synopsis: '$($Help.Synopsis)')."
    }
}
Write-Host "   Verified: comment-based help intact for $($SampleFunctions.Count) sample functions"

$ImportedModules | Remove-Module -Force -ErrorAction SilentlyContinue

Write-Host '── Built module validation passed' -ForegroundColor Green

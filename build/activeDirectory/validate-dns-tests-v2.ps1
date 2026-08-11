# DNS Tests Validation Script v2
# This script validates all 19 Phase 4 DNS tests against the live domain controller
# Bypasses full module import by directly loading test functions

$ErrorActionPreference = "Continue"
$results = @()

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Phase 4: DNS Infrastructure Validation" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Import required modules
Import-Module ActiveDirectory
Import-Module DnsServer

# Directly source the test functions
$dnsTestFiles = @(
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZoneCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZonesWithOnlySoaNs.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsRootServerIncorrectCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsRootServerIncorrectDetails.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsDynamicRecordCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZonesWithRecordsCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZoneRecordDetails.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZoneDelegationCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsZoneDelegationDetails.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsSoaDetails.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsAdSrvRecordCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsAdSrvRecordDetails.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsDnssecRecordCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsEmptyZoneCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsDuplicateZoneCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsReverseZoneCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsNonStandardZoneCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsReverseZoneNetworkCount.ps1",
    "/tmp/aura-powershell/public/ad/dns/Test-AuAdDnsReverseZoneNetworkDetails.ps1"
)

# Source Get-AuADDomainState first
. "/tmp/aura-powershell/public/Get-AuADDomainState.ps1"

# Source Add-AuTestResultDetail (mock if not available)
function Add-AuTestResultDetail {
    param(
        [string]$Result,
        [string]$SkippedBecause,
        [string]$SkippedBecauseReason
    )
    # Mock function - just output to verbose
    if ($SkippedBecause) {
        Write-Verbose "Test skipped because: $SkippedBecause"
    }
}

# Create mock session variable
$global:__AuSession = @{
    ADCache = @{}
}

# Source all DNS test files
foreach ($file in $dnsTestFiles) {
    try {
        . $file
        Write-Host "Loaded: $(Split-Path $file -Leaf)" -ForegroundColor DarkGray
    } catch {
        Write-Host "Failed to load: $(Split-Path $file -Leaf) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "All test functions loaded. Starting validation..." -ForegroundColor Cyan
Write-Host ""

# List of all DNS test functions
$dnsTests = @(
    "Test-AuAdDnsZoneCount",
    "Test-AuAdDnsZonesWithOnlySoaNs",
    "Test-AuAdDnsRootServerIncorrectCount",
    "Test-AuAdDnsRootServerIncorrectDetails",
    "Test-AuAdDnsDynamicRecordCount",
    "Test-AuAdDnsZonesWithRecordsCount",
    "Test-AuAdDnsZoneRecordDetails",
    "Test-AuAdDnsZoneDelegationCount",
    "Test-AuAdDnsZoneDelegationDetails",
    "Test-AuAdDnsSoaDetails",
    "Test-AuAdDnsAdSrvRecordCount",
    "Test-AuAdDnsAdSrvRecordDetails",
    "Test-AuAdDnsDnssecRecordCount",
    "Test-AuAdDnsEmptyZoneCount",
    "Test-AuAdDnsDuplicateZoneCount",
    "Test-AuAdDnsReverseZoneCount",
    "Test-AuAdDnsNonStandardZoneCount",
    "Test-AuAdDnsReverseZoneNetworkCount",
    "Test-AuAdDnsReverseZoneNetworkDetails"
)

$passed = 0
$failed = 0
$skipped = 0

foreach ($testName in $dnsTests) {
    Write-Host "Testing: $testName" -NoNewline

    try {
        $result = & $testName -ErrorAction Stop

        if ($null -eq $result) {
            Write-Host " [SKIPPED]" -ForegroundColor Yellow
            $skipped++
            $results += [PSCustomObject]@{
                TestName = $testName
                Result = "SKIPPED"
                ReturnValue = $null
                Error = "Test returned null (AD not connected or data unavailable)"
            }
        } elseif ($result -eq $true) {
            Write-Host " [PASS]" -ForegroundColor Green
            $passed++
            $results += [PSCustomObject]@{
                TestName = $testName
                Result = "PASS"
                ReturnValue = $result
                Error = $null
            }
        } else {
            Write-Host " [FAIL]" -ForegroundColor Red
            $failed++
            $results += [PSCustomObject]@{
                TestName = $testName
                Result = "FAIL"
                ReturnValue = $result
                Error = "Test returned false"
            }
        }
    } catch {
        Write-Host " [ERROR]" -ForegroundColor Red
        $failed++
        $results += [PSCustomObject]@{
            TestName = $testName
            Result = "ERROR"
            ReturnValue = $null
            Error = $_.Exception.Message
        }
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Total Tests:  $($dnsTests.Count)" -ForegroundColor White
Write-Host "Passed:       $passed" -ForegroundColor Green
Write-Host "Failed:       $failed" -ForegroundColor Red
Write-Host "Skipped:      $skipped" -ForegroundColor Yellow
Write-Host ""

if ($failed -eq 0) {
    Write-Host "VALIDATION SUCCESSFUL - All tests passed!" -ForegroundColor Green
} else {
    Write-Host "VALIDATION FAILED - $failed tests failed or had errors" -ForegroundColor Red
}

# Output detailed results
Write-Host ""
Write-Host "Detailed Results:" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Export results to file
$results | Export-Csv -Path "C:/tmp/dns-validation-results.csv" -NoTypeInformation
Write-Host "Results exported to: C:/tmp/dns-validation-results.csv" -ForegroundColor Cyan

# Return exit code
if ($failed -gt 0) { exit 1 } else { exit 0 }

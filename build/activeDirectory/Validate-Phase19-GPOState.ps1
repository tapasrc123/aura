# Phase 19 GPO State Validation Script
# This script validates all 27 GPO State test functions against the live DC

$ErrorActionPreference = "Stop"
$results = @()

Write-Host "=== Phase 19 GPO State Validation ===" -ForegroundColor Cyan
Write-Host "Domain: $env:USERDNSDOMAIN"
Write-Host "DC: $env:COMPUTERNAME"
Write-Host "Date: $(Get-Date)`n"

# Import required modules
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
Import-Module GroupPolicy -ErrorAction SilentlyContinue

# Source the functions
$functionPath = "/tmp/aura-powershell/public"
Get-ChildItem "$functionPath" -Recurse -Filter "*.ps1" | ForEach-Object {
    try {
        . $_.FullName
    } catch {
        Write-Warning "Failed to load $($_.Name): $_"
    }
}

# Test Get-AuADGpoState
Write-Host "Testing Get-AuADGpoState..." -NoNewline
$testResult = @{ TestName = "Get-AuADGpoState"; TestID = "N/A"; Result = "FAIL"; Details = "" }
try {
    $gpoState = Get-AuADGpoState
    if ($gpoState -and $gpoState.GPOs) {
        Write-Host " PASS" -ForegroundColor Green
        $testResult.Result = "PASS"
        $testResult.Details = "Found $($gpoState.GPOs.Count) GPOs, $($gpoState.GPOReports.Count) reports"
        Write-Host "  GPOs: $($gpoState.GPOs.Count)"
        Write-Host "  GPO Reports: $($gpoState.GPOReports.Count)"
    } else {
        Write-Host " FAIL (no data)" -ForegroundColor Red
        $testResult.Details = "No GPO data returned"
    }
} catch {
    Write-Host " FAIL ($_))" -ForegroundColor Red
    $testResult.Details = "Error: $_"
}
$results += $testResult

# Test functions to validate
$tests = @(
    @{ Name = "Test-AuAdGpoStateTotalCount"; ID = "AD-GPOS-01" },
    @{ Name = "Test-AuAdGpoWmiFilterCount"; ID = "AD-GPOS-02" },
    @{ Name = "Test-AuAdGpoWmiFilterDetails"; ID = "AD-GPOS-03" },
    @{ Name = "Test-AuAdGpoSettingsDisabledCount"; ID = "AD-GPOS-04" },
    @{ Name = "Test-AuAdGpoComputerSettingsDisabledDetails"; ID = "AD-GPOS-05" },
    @{ Name = "Test-AuAdGpoUserSettingsDisabledDetails"; ID = "AD-GPOS-06" },
    @{ Name = "Test-AuAdGpoAllSettingsDisabledDetails"; ID = "AD-GPOS-07" },
    @{ Name = "Test-AuAdGpoOwnerDistinctCount"; ID = "AD-GPOS-08" },
    @{ Name = "Test-AuAdGpoOwnerDetails"; ID = "AD-GPOS-09" },
    @{ Name = "Test-AuAdGpoNoPermissionsCount"; ID = "AD-GPOREP-01" },
    @{ Name = "Test-AuAdGpoNoPermissionsDetails"; ID = "AD-GPOREP-02" },
    @{ Name = "Test-AuAdGpoNoAuthenticatedUsersCount"; ID = "AD-GPOREP-03" },
    @{ Name = "Test-AuAdGpoNoAuthenticatedUsersDetails"; ID = "AD-GPOREP-04" },
    @{ Name = "Test-AuAdGpoNoEnterpriseDcCount"; ID = "AD-GPOREP-05" },
    @{ Name = "Test-AuAdGpoNoDomainComputersCount"; ID = "AD-GPOREP-06" },
    @{ Name = "Test-AuAdGpoDenyAceCount"; ID = "AD-GPOREP-07" },
    @{ Name = "Test-AuAdGpoDenyAceDetails"; ID = "AD-GPOREP-08" },
    @{ Name = "Test-AuAdGpoInheritedPermissionsCount"; ID = "AD-GPOREP-09" },
    @{ Name = "Test-AuAdGpoNoApplyGroupPolicyAceCount"; ID = "AD-GPOREP-10" },
    @{ Name = "Test-AuAdGpoNoApplyGroupPolicyAceDetails"; ID = "AD-GPOREP-11" },
    @{ Name = "Test-AuAdGpoDisabledLinkCount"; ID = "AD-GPOREP-12" },
    @{ Name = "Test-AuAdGpoDisabledLinkDetails"; ID = "AD-GPOREP-13" },
    @{ Name = "Test-AuAdGpoEnforcementCount"; ID = "AD-GPOREP-14" },
    @{ Name = "Test-AuAdGpoVersionMismatchCount"; ID = "AD-GPOREP-15" },
    @{ Name = "Test-AuAdGpoVersionMismatchDetails"; ID = "AD-GPOREP-16" },
    @{ Name = "Test-AuAdGpoCpasswordFoundCount"; ID = "AD-GPOREP-17" },
    @{ Name = "Test-AuAdGpoCpasswordFoundDetails"; ID = "AD-GPOREP-18" },
    @{ Name = "Test-AuAdGpoDefaultPasswordFoundCount"; ID = "AD-GPOREP-19" },
    @{ Name = "Test-AuAdGpoDefaultPasswordFoundDetails"; ID = "AD-GPOREP-20" }
)

foreach ($test in $tests) {
    Write-Host "Testing $($test.Name)..." -NoNewline
    $testResult = @{ TestName = $test.Name; TestID = $test.ID; Result = "FAIL"; Details = "" }

    try {
        $result = & $test.Name
        if ($result -eq $true) {
            Write-Host " PASS" -ForegroundColor Green
            $testResult.Result = "PASS"
        } elseif ($result -eq $null) {
            Write-Host " SKIP (no AD connection)" -ForegroundColor Yellow
            $testResult.Result = "SKIP"
            $testResult.Details = "Returned null - AD not connected"
        } else {
            Write-Host " FAIL (returned $result)" -ForegroundColor Red
            $testResult.Details = "Returned $result"
        }
    } catch {
        Write-Host " FAIL ($_))" -ForegroundColor Red
        $testResult.Details = "Error: $_"
    }

    $results += $testResult
}

# Summary
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
$passCount = ($results | Where-Object { $_.Result -eq "PASS" }).Count
$skipCount = ($results | Where-Object { $_.Result -eq "SKIP" }).Count
$failCount = ($results | Where-Object { $_.Result -eq "FAIL" }).Count

Write-Host "Total Tests: $($results.Count)"
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Skipped: $skipCount" -ForegroundColor Yellow
Write-Host "Failed: $failCount" -ForegroundColor Red

# Export results
$results | Export-Csv "/tmp/Phase19-ValidationResults.csv" -NoTypeInformation
Write-Host "`nResults exported to: /tmp/Phase19-ValidationResults.csv"

if ($failCount -eq 0) {
    Write-Host "`n✓ All tests passed validation!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n✗ Some tests failed validation" -ForegroundColor Red
    exit 1
}

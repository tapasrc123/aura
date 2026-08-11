# Phase 19 GPO State Validation

## Quick Validation (Recommended)

### Option 1: On Domain Controller (Simplest)

1. Copy the Aura module to the DC:
```powershell
# From management machine
Copy-Item -Path ".\powershell" -Destination "\\DC01\C$\temp\aura" -Recurse -Force
```

2. On the DC, run:
```powershell
# Import the module
Import-Module C:\temp\aura\Aura.psd1 -Force

# Quick validation (tests Get-AuADGpoState only)
.\build\activeDirectory\Simple-Validate-Phase19.ps1 -Quick

# Full validation (tests 11 key functions)
.\build\activeDirectory\Simple-Validate-Phase19.ps1

# Detailed validation with output table
.\build\activeDirectory\Simple-Validate-Phase19.ps1 -Detailed
```

### Option 2: Manual PowerShell Verification

```powershell
# 1. Import module
Import-Module .\powershell\Aura.psd1 -Force

# 2. Test the core function
$gpoState = Get-AuADGpoState
$gpoState.GPOs.Count          # Should return number of GPOs
$gpoState.GPOReports.Count    # Should return number of reports

# 3. Test individual functions
Test-AuAdGpoStateTotalCount           # Should return $true
Test-AuAdGpoWmiFilterCount            # Should return $true
Test-AuAdGpoNoPermissionsCount        # Should return $true
Test-AuAdGpoNoAuthenticatedUsersCount # Should return $true
Test-AuAdGpoCpasswordFoundCount       # Should return $true
```

### Option 3: Pester Tests

```powershell
# Run specific Pester tests
Invoke-Pester -Path "tests\Aura\ad\gpostate" -Tag "AD-GPOS-01"

# Run all Phase 19 tests
Invoke-Pester -Path "tests\Aura\ad\gpostate"
```

## Expected Results

### Success Criteria
- ✓ Get-AuADGpoState returns GPO data
- ✓ All Count functions return $true
- ✓ All Details functions return $true
- ✓ No errors in PowerShell console

### Sample Output
```
=== Phase 19 GPO State Simple Validation ===

Running full validation...
Testing Get-AuADGpoState [SETUP]... PASS
Testing Test-AuAdGpoStateTotalCount [AD-GPOS-01]... PASS
Testing Test-AuAdGpoWmiFilterCount [AD-GPOS-02]... PASS
Testing Test-AuAdGpoSettingsDisabledCount [AD-GPOS-04]... PASS
Testing Test-AuAdGpoOwnerDistinctCount [AD-GPOS-08]... PASS
Testing Test-AuAdGpoNoPermissionsCount [AD-GPOREP-01]... PASS
Testing Test-AuAdGpoNoAuthenticatedUsersCount [AD-GPOREP-03]... PASS
Testing Test-AuAdGpoDenyAceCount [AD-GPOREP-07]... PASS
Testing Test-AuAdGpoDisabledLinkCount [AD-GPOREP-12]... PASS
Testing Test-AuAdGpoVersionMismatchCount [AD-GPOREP-15]... PASS
Testing Test-AuAdGpoCpasswordFoundCount [AD-GPOREP-17]... PASS

=== Validation Summary ===
Passed: 11
Failed: 0
Total:  11

✓ All tests passed!
```

## Troubleshooting

### "Get-AuADGpoState returns null"
- Ensure you're running on a domain-joined machine or DC
- Check that ActiveDirectory and GroupPolicy modules are available
- Verify you have permissions to read GPOs

### "Command not found"
- Ensure Aura module is imported: `Import-Module .\powershell\Aura.psd1 -Force`
- Check that functions are exported: `Get-Command Test-AuAdGpo*`

### "Access denied"
- Run PowerShell as Administrator
- Verify you have Domain Admin or equivalent permissions

## Files Created in Phase 19

### PowerShell Functions (27 files)
Location: `powershell/public/ad/gpostate/`

**GPO State Tests (AD-GPOS-01 to AD-GPOS-09):**
- Test-AuAdGpoStateTotalCount.ps1
- Test-AuAdGpoWmiFilterCount.ps1
- Test-AuAdGpoWmiFilterDetails.ps1
- Test-AuAdGpoSettingsDisabledCount.ps1
- Test-AuAdGpoComputerSettingsDisabledDetails.ps1
- Test-AuAdGpoUserSettingsDisabledDetails.ps1
- Test-AuAdGpoAllSettingsDisabledDetails.ps1
- Test-AuAdGpoOwnerDistinctCount.ps1
- Test-AuAdGpoOwnerDetails.ps1

**GPO Report Tests (AD-GPOREP-01 to AD-GPOREP-20):**
- Test-AuAdGpoNoPermissionsCount.ps1
- Test-AuAdGpoNoPermissionsDetails.ps1
- Test-AuAdGpoNoAuthenticatedUsersCount.ps1
- Test-AuAdGpoNoAuthenticatedUsersDetails.ps1
- Test-AuAdGpoNoEnterpriseDcCount.ps1
- Test-AuAdGpoNoDomainComputersCount.ps1
- Test-AuAdGpoDenyAceCount.ps1
- Test-AuAdGpoDenyAceDetails.ps1
- Test-AuAdGpoInheritedPermissionsCount.ps1
- Test-AuAdGpoNoApplyGroupPolicyAceCount.ps1
- Test-AuAdGpoNoApplyGroupPolicyAceDetails.ps1
- Test-AuAdGpoDisabledLinkCount.ps1
- Test-AuAdGpoDisabledLinkDetails.ps1
- Test-AuAdGpoEnforcementCount.ps1
- Test-AuAdGpoVersionMismatchCount.ps1
- Test-AuAdGpoVersionMismatchDetails.ps1
- Test-AuAdGpoCpasswordFoundCount.ps1
- Test-AuAdGpoCpasswordFoundDetails.ps1
- Test-AuAdGpoDefaultPasswordFoundCount.ps1
- Test-AuAdGpoDefaultPasswordFoundDetails.ps1

### Pester Tests (29 files)
Location: `tests/Aura/ad/gpostate/`

### Enhanced Function
- Get-AuADGpoState.ps1 - Extended to collect GPO reports and permissions

### Module Updates
- Aura.psd1 - Added 27 new function exports
- ADTestBacklog.md - Marked Phase 19 complete

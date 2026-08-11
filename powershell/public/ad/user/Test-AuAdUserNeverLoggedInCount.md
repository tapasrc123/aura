#### Test-AuAdUserNeverLoggedInCount

#### Why This Test Matters

Enabled accounts that have never logged on may indicate incomplete provisioning, abandoned onboarding, or unnecessary standing access. These objects should be reviewed to ensure they still have a valid business purpose.

#### Security Recommendation

Investigate enabled accounts with no recorded logon activity. Disable or remove unused accounts and make sure future provisioning workflows include validation and cleanup steps.

#### How the Test Works

This test retrieves Active Directory user data from `Get-AuADDomainState`, filters to enabled users, and counts accounts where `LastLogonDate` is null.

#### Related Tests

- `Test-AuAdUserDormantEnabledCount`
- `Test-AuAdUserDisabledCount`
- `Test-AuAdUserPasswordNeverExpiresCount`

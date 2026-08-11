#### Test-AuAdGpoEnforcementCount

#### Why This Test Matters

Enforced Group Policy Object (GPO) links are special link entries that **block inheritance** from being overridden at lower levels (for example, by child OUs).

This can be a powerful mechanism for security baselines, but it also increases the chance that a critical policy unintentionally becomes “sticky” across the domain.

#### Security Recommendation

- **Enforced GPOs override inheritance blocking**: any configuration enforced at a higher scope can still apply even if child OUs attempt to disable inheritance.
- **Use enforced links sparingly**: reserve them for critical security policies that must apply everywhere.
- **Review enforced policies regularly**: confirm the GPO’s purpose and ownership, and ensure the enforced settings remain aligned with current security requirements.

#### How the Test Works

This test retrieves Active Directory GPO state from `Get-AuADGpoState` (using `$gpoState.GPOLinks`) and:

1. Examines each collected link object for the `Enforced` property.
2. Counts link entries where `Enforced` is `$true`.
3. Reports the enforced link count and the enforced ratio in Markdown.

#### Related Tests

- `Test-AuAdGpoTotalCount` - Counts total GPO inventory
- `Test-AuAdGpoLinkedCount` - Identifies GPOs that are actively linked
- `Test-AuAdGpoUnlinkedCount` - Identifies GPOs not linked anywhere
- `Test-AuAdGpoUnlinkedDetails` - Shows unlinked GPO details

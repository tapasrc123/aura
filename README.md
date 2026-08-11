# Aura

**Regression testing for your Microsoft 365 security configuration.**

Aura is a PowerShell test automation framework that treats tenant configuration as
something you can assert on. You run it on a schedule or in a pipeline, and it tells
you — in plain pass/fail terms — whether your Microsoft 365 and Entra ID settings still
match what you intended.

> **Aura is a fork of [Maester](https://github.com/maester365/maester)**, which is MIT
> licensed. Nearly all of the test logic here was written by the Maester Team and its
> contributors. Aura is not affiliated with or endorsed by that project. See
> [NOTICE.md](NOTICE.md) for full attribution and the list of changes.

## Why configuration needs tests

A Conditional Access policy that requires MFA for a security group is only as good as the
group behind it. Someone empties the group, or an exclusion gets added "temporarily" during
an incident, or the person who wrote the policy leaves and the next admin edits it without
knowing what it was protecting. Nothing alerts. The policy still exists, still looks
enabled, and no longer does anything.

Aura closes that gap the way unit tests close it in application code: you encode the
intent once, then run the assertion continuously and find out the day it stops holding.

## What you get

- **Hundreds of ready-made tests** across Entra ID, Exchange Online, Teams, SharePoint,
  Defender, and Active Directory.
- **Mapped to published baselines** — EIDSCA, CISA SCuBA, the CIS Microsoft 365 Benchmark,
  and ORCA — so a run doubles as a baseline conformance check.
- **Remediation on every failure**, including a deep link to the exact admin portal blade.
- **Custom tests** in plain Pester, so your own policy decisions live beside the built-ins.
- **Reports** in HTML, JSON, CSV, Markdown, or Excel.
- **Notifications** to email or Teams.
- **CI/CD ready** for GitHub Actions, Azure DevOps, and GitLab.

## Install

```powershell
Install-Module -Name Aura -Scope CurrentUser
```

Then install the test suite into a working folder:

```powershell
md aura-tests
cd aura-tests
Install-AuraTests
```

## Run

Connect with the scopes the tests need, then invoke:

```powershell
Connect-Aura
Invoke-Aura
```

`Invoke-Aura` writes an interactive HTML report and returns the results as objects.

Narrow a run to one baseline with tags:

```powershell
Invoke-Aura -Tag CIS
Invoke-Aura -Tag CISA, Entra
```

Send the outcome somewhere useful:

```powershell
Invoke-Aura -MailRecipient security@example.com
Invoke-Aura -TeamsChannelWebhookUri $webhook
```

Disconnect when you are done:

```powershell
Disconnect-Aura
```

## Command naming

Aura keeps upstream's two-tier convention, with its own prefixes:

| Kind | Pattern | Example |
| --- | --- | --- |
| Top-level entry points | `<Verb>-Aura` | `Invoke-Aura`, `Connect-Aura` |
| Helpers and data getters | `<Verb>-Au<Noun>` | `Get-AuUser`, `Clear-AuGraphCache` |
| Tests | `Test-Au<Area>` / `Test-<Baseline><Id>` | `Test-AuEidscaControl`, `Test-ORCA108_1` |

If you are coming from Maester, the mapping is mechanical: `Maester` → `Aura`, and the
`Mt` noun prefix → `Au`.

## Repository layout

| Path | Contents |
| --- | --- |
| `powershell/` | The Aura module — `public/` commands, `internal/` helpers, `tests/` unit tests |
| `tests/` | The shipped security test suite, by baseline |
| `report/` | Vite + React app that renders the HTML report |
| `website/` | Docusaurus documentation site |
| `build/` | Module build and release scripts |
| `action/`, `action.yml` | GitHub Action wrapper |

## Permissions

Aura reads configuration; it does not change it. The Graph scopes requested are read-only,
and `Connect-Aura` will tell you which ones a given test selection needs. Run it against
a tenant you are authorised to assess.

## Contributing

Tests are ordinary Pester files. Add one under `tests/`, give it a tag, and include the
remediation text and portal link in the failure message — that convention is what makes the
report actionable, and it is worth preserving.

## License

MIT — see [LICENSE](LICENSE). Copyright is held by the Maester Team for the upstream work
and by the Aura contributors for changes in this fork.

# Parked workflows

These are the upstream workflows, preserved verbatim but kept out of
`.github/workflows/` so GitHub will not run them. Nothing here is deleted — move a file
back into `.github/workflows/` when you actually want it.

They are parked because each one either publishes outside this repository, needs
credentials or a live tenant that this fork does not have, or commits back to `main` on
every push. On a fresh fork they would fail on the first push, and two of them would do
something worse than fail.

## Read this before re-enabling the publish workflows

`publish-module-preview.yaml`, `publish-module.yaml`,
`publish-module-manualversionupdate.yaml`, and `publish-tests.yaml` push the module to
the **public PowerShell Gallery**. `publish-module-preview.yaml` was triggered by any
push to `main` touching `powershell/**`.

Publishing is public and effectively permanent — the Gallery does not allow hard
deletion of a published version. Before re-enabling any of these:

1. Confirm the name `Aura` is available on the Gallery and that you intend to claim it.
2. Set the `PSGALLERY_API_KEY` secret (or whatever the workflow references).
3. Check the module GUID in `powershell/Aura.psd1` is the fork's own — it is
   `c5fca4ec-918a-4347-b876-3b286b143ae1`, not upstream's.

## Why each is parked

| Workflow | Reason |
| --- | --- |
| `publish-module-preview.yaml` | Publishes to PowerShell Gallery on every push to `main` |
| `publish-module.yaml` | Publishes a release to PowerShell Gallery |
| `publish-module-manualversionupdate.yaml` | Publishes to PowerShell Gallery |
| `publish-tests.yaml` | Publishes the test suite on release |
| `publish-versioned-docs.yml` | Publishes docs for a stable version |
| `build-docs.yaml` | Deploys the documentation site; needs Pages configured |
| `discord-codebase-digest.yml` | Posts to a Discord webhook that does not exist here |
| `aura-action-smoke-test.yaml` | Runs the action against a live demo tenant |
| `demo-tenant-quick-approval-trigger.yaml` | Demo-tenant automation tied to upstream's setup |
| `scorecard.yml` | Publishes results to the OSSF Scorecard service |
| `opengrep.yml` | Third-party scanning service credentials |
| `update-public-suffix-list.yaml` | Scheduled job that opens PRs |
| `update-role-definitions.yaml` | Scheduled job that opens PRs |
| `update-module-docs.yaml` | Auto-commits regenerated docs to `main` |
| `update-test-docs.yaml` | Auto-commits regenerated docs to `main` |

## Still active

`.github/workflows/` keeps the self-contained validation jobs: `build-validation`,
`psscriptanalyzer`, `codeql`, and `dependency-review`. Those read the repo and report
back, and need no secrets.

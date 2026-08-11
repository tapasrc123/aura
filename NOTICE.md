# Attribution

Aura is a fork of the [Maester](https://github.com/maester365/maester) project,
an open source Microsoft 365 security test automation framework created and
maintained by the Maester Team. Maester is distributed under the MIT License.

This fork renames the module, its command surface, and its documentation, but the
test logic, module architecture, report renderer, and the great majority of the
code in this repository originate with the Maester project and its contributors.

Aura is **not** affiliated with, endorsed by, or supported by the Maester Team.
Please direct issues with this fork here rather than upstream.

## What changed in this fork

| Upstream | Aura |
| --- | --- |
| Module `Maester` | Module `Aura` |
| `Invoke-Maester`, `Connect-Maester` | `Invoke-Aura`, `Connect-Aura` |
| `Mt` command noun prefix (`Get-MtUser`) | `Au` prefix (`Get-AuUser`) |
| `maester.dev` | `aura.onetapas.com` |

Content removed rather than rebranded, because rebranding it would misrepresent
its authors:

- `website/blog/` — posts written and signed by named individuals
- `website/contributors/` — contributor biographies
- `website/versioned_docs/` — documentation for historical Maester releases

## Upstream license

The full MIT License text, including the Maester Team's copyright notice, is
retained in [LICENSE](LICENSE).

## Third-party standards

The security tests carry over the upstream mappings to external baselines —
EIDSCA, CISA SCuBA, the CIS Microsoft 365 Benchmark, and ORCA. Those baselines
are published by their respective organisations and are referenced, not
redistributed. Each remains subject to its own terms.

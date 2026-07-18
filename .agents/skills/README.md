# Ambitions retained procedural adapters

Status: Active procedural registry
Authority: None

The five retained skills are task-specific operating adapters. They do not
define canon, authorize edits or merge, waive gates, or prove implementation,
validation, accessibility, privacy, device, or release status.

Start with `docs/canon/generated/CODEX_START_HERE.md` and a bounded canon pack.
The closed machine-readable registry at
`docs/canon/references/skill-dependencies.json` owns each adapter's allowed
purpose, canonical requirement IDs, exact dependency paths and SHA-256 digests,
schema/compiler compatibility, and `may_authorize = false` boundary.

| Adapter | Use |
|---|---|
| `ambitions-source-truth-authority` | Route repo work to current canon, live source, and evidence ceilings. |
| `ambitions-architecture-tree-enforcement` | Check canonical source-owner paths before source creation, movement, refactor, or review. |
| `ambitions-ios-quality-gate` | Route Apple-platform work to native, accessibility, and platform obligations. |
| `ambitions-release-proof-honesty` | Keep validation/readiness language within current proof. |
| `ambitions-runtime-contract-engineering` | Route scoped runtime contracts to canonical mutation, test, receipt, replay, and rollback requirements. |

Run:

```bash
python3 scripts/ambitions-canon.py skill-conformance --check
```

Any missing, stale, undeclared, circular, or authority-bearing adapter or
dependency fails closed. Update canon or the governed dependency registry;
never copy canonical law into a skill.

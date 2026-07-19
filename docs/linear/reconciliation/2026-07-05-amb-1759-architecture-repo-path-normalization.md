# AMB-1759 Architecture Repo Path Normalization

Status: Implemented Yellow / Ready For Review for this control-plane leaf
Date: 2026-07-05T14:59:05Z
Branch: `main`
Baseline main SHA: `18ef53a35f1f7290184402601d04f9ccfe8b980d`
Xcode version: Xcode 26.6, build version 17F113
Artifact paths: this packet, `scripts/ambitions-architecture-path-normalization-check.py`, `scripts/ambitions-quality-gate.py`
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1759` Architecture Repo Path Normalization

## Scope

This packet normalizes active architecture packet path authority to the current
repo layout and installs a changed-date active-packet guard for stale path drift.

The accepted root path authority for architecture packets is:

| Authority | Current repo path |
| --- | --- |
| XcodeGen source | `project.yml` at repo root |
| Swift package manifest | `Package.swift` at repo root |
| Native app source | `Native/Ambitions/` |
| Root surfaces | `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Surfaces/You` |
| Capture composer | `Native/Ambitions/Composer/Capture/` |
| Stage and Motion | `Native/Ambitions/Stage/` and `Native/Ambitions/Stage/Motion/` |
| Local runtime authority | `Native/Ambitions/Core/LocalRuntimeOS/` |
| Scripts | `scripts/` |
| Truth docs | `docs/truth/` |
| Reconciliation packets | `docs/linear/reconciliation/` |

`Features/` is not a canonical owner for new architecture. A packet may mention
`Features/` only as legacy/migration-debt context, not as a generic owner or
new work destination.

This work does not change Swift source, XcodeGen project source, Package.swift,
runtime behavior, rendered UI, privacy behavior, or release behavior.

## Guard Installed

`scripts/ambitions-architecture-path-normalization-check.py` scans active
architecture packets under:

```text
docs/linear/reconciliation/2026-07-05-*.md
docs/linear/reconciliation/2026-07-05-*.json
```

The guard fails stale project/package references. Spaced examples:

```text
Native / project.yml
Native / Package.swift
Native / Ambitions / project.yml
Native / Ambitions / Package.swift
```

It also fails generic `Features/` or `Native/Ambitions/Features` references
unless the line explicitly frames the reference as legacy, scaffolding,
migration debt, absent, or not a canonical owner.

`scripts/ambitions-quality-gate.py` now requires and runs this guard as part of
the strict quality gate.

## Active Packet Scan Result

Before this packet was added, the guard checked 10 active July 5 packets and
found no stale path authority.

After this packet was added, the guard checked 11 active July 5 packets and
found no stale path authority.

The older July 1 broad packets and retained audits are historical/supporting
material for this issue. They were not bulk-edited as part of AMB-1759 because
the acceptance target is active architecture packets, and older retained packets
must not be rewritten as proof theater.

## Validation run

Completed for this docs/control-plane packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `python3 scripts/ambitions-architecture-path-normalization-check.py` | 0 | Passed before packet creation with `architecture_packets_checked=10`; passed after packet creation with `architecture_packets_checked=11`. |
| `python3 -m py_compile scripts/ambitions-architecture-path-normalization-check.py scripts/ambitions-quality-gate.py` | 0 | Passed. |
| `python3 scripts/ambitions-quality-gate.py --self-test` | 0 | Passed after adding the guard to required quality scripts. |
| `git diff --check` | 0 | Passed. |
| `python3 scripts/ambitions-release-non-claim-gate.py` | 0 | Passed; `release_facing_packets_checked=1` after this packet's release-proof non-claim metadata was added. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=3`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; `changed_paths=3`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed; `checkedAcceptedYellowIssues=19`, `invalidAcceptedYellowIssues=0`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/linear/reconciliation/2026-07-05-amb-1759-architecture-repo-path-normalization.md scripts/ambitions-architecture-path-normalization-check.py scripts/ambitions-quality-gate.py` | 0 | Passed. |

## Validation not run

- XCTest, xcodebuild build, build-for-testing, focused test, and simulator test
  commands were not run under the user's standing instruction authorizing issue
  completion without testing until advised otherwise.
- No rendered UI, device, accessibility, privacy/legal, release, TestFlight, App
  Store, account, R2, or production environment proof was run.

## Non-Claims

- No source/runtime behavior change is claimed.
- No XcodeGen regeneration or package graph change is claimed.
- No final architecture Green, Release Green, Visual Green, device proof,
  accessibility conformance, privacy/legal approval, TestFlight readiness, App
  Store readiness, account readiness, R2 readiness, or production readiness is
  claimed.
- `AMB-1705` final architecture closeout remains blocked by separate proof and
  review gates.

## Private Life Orchestration Relationship

Private Life Orchestration preserved: this control-plane leaf protects the Proof
and Learning side of Ambitions' Intent -> Context -> Path -> Time Fit -> Reflow
-> Action -> Proof -> Learning loop by keeping architecture packets tied to
current repo path authority rather than stale or generic owner paths. It does
not alter user data, the private life graph, runtime mutation behavior, or
product surfaces.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in Swift source; script/docs evidence only.
- Non-canonical owners touched: none.
- Files moved or created: one new script guard and one reconciliation packet.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: older retained July 1 packets remain historical/supporting
  material; AMB-1759 scope is active architecture packets.
- Next repair train if debt remains: continue M14 with `AMB-1760` and the
  still-open parent/leaf blockers recorded by `AMB-1826`.
- No equivalent folder/path interpretation was used.

## Rollback

If this path-normalization gate must be reversed, revert this packet plus the
changes to `scripts/ambitions-architecture-path-normalization-check.py` and
`scripts/ambitions-quality-gate.py`, then move `AMB-1759` back to `Needs Repair`.

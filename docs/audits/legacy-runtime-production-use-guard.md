# Legacy Runtime Production Use Guard

Status: AMB-1715 Implemented Yellow

Snapshot date: 2026-07-02

Scope: AMB-1666 -> AMB-1715 only. This retained audit installs a guard for new
production use of the legacy `Native/Ambitions/Core/Runtime` owner. It does not
move source, delete remaining legacy files, migrate runtime authority, change
Swift behavior, or prove full LocalRuntimeOS completion.

Evidence class: Implemented Yellow. The guard reports new production legacy
runtime owner growth and explicit new production source references to
`Core/Runtime`. It preserves the AMB-1714 Yellow baseline of `112` remaining
legacy runtime files. It does not prove runtime correctness, build success,
device behavior, accessibility behavior, privacy/legal approval, TestFlight
readiness, App Store readiness, or Green project status.

## Canonical Constraints

Runtime mutation law remains:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Remediation direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
proof automation outranks prose
```

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Guard Behavior

Retained script:

- `scripts/ambitions-legacy-runtime-production-use-guard.py`

The guard:

- parses the AMB-1713 classification baseline from
  `docs/audits/legacy-runtime-strangler-classification.md`;
- subtracts the three AMB-1714 retired legacy owner paths;
- keeps the current legacy runtime production-file ceiling at `112`;
- reports any new production Swift file under `Native/Ambitions/Core/Runtime`;
- reports any AMB-1714 retired legacy owner path that is reintroduced;
- reports new production Swift diff lines outside `Core/Runtime` that
  explicitly reference `Core/Runtime`; and
- allows test or preview support paths to mention `Core/Runtime` for validation
  or quarantine work.

The guard is wired into:

- `scripts/ambitions-remediation-governance-check.py`

This means the required remediation governance check now runs the AMB-1715
legacy runtime production-use guard.

## Claim Ceiling

Final Architecture Tree inspected: yes.

Canonical owners touched:

- `Quality` / repo governance scripts
- `docs/audits`

Production Swift behavior touched: none.

Files created:

- `scripts/ambitions-legacy-runtime-production-use-guard.py`
- `docs/audits/legacy-runtime-production-use-guard.md`

Files updated:

- `scripts/ambitions-remediation-governance-check.py`

Old/non-canonical paths removed: none.

Compatibility shims left behind by this slice: none added.

Yellow architecture debt remains because `112` legacy runtime production files
still exist under `Core/Runtime`, including adapter shims, test-only support,
and the unresolved `RuntimePackageBoundaryModels.swift` owner decision. Next
repair train: AMB-1716 under AMB-1666.

No equivalent-folder or close-enough path interpretation was used.

# Legacy Runtime Production Use Guard

Status: AMB-1715 Implemented Yellow

Snapshot date: 2026-07-02

Scope: AMB-1666 -> AMB-1715, with AMB-1716 supersession applied. This retained
audit installs a guard for new production use of the legacy
`Native/Ambitions/Core/Runtime` owner. AMB-1716 extends the retired-path set for
the first test-support quarantine. It does not migrate runtime authority, change
Swift behavior, or prove full LocalRuntimeOS completion.

Evidence class: Implemented Yellow. The guard reports new production legacy
runtime owner growth and explicit new production source references to
`Core/Runtime`. It preserves the AMB-1716 Yellow baseline of `111` remaining
legacy runtime production files. It does not prove runtime correctness, device
behavior, accessibility behavior, privacy/legal approval, TestFlight readiness,
App Store readiness, or Green project status.

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
- subtracts the AMB-1714 and AMB-1716 retired legacy owner paths;
- keeps the current legacy runtime production-file ceiling at `111`;
- reports any new production Swift file under `Native/Ambitions/Core/Runtime`;
- reports any AMB-1714 or AMB-1716 retired legacy owner path that is
  reintroduced;
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

Files created by AMB-1715:

- `scripts/ambitions-legacy-runtime-production-use-guard.py`
- `docs/audits/legacy-runtime-production-use-guard.md`

Files updated by AMB-1715:

- `scripts/ambitions-remediation-governance-check.py`

Old/non-canonical paths removed: none.

Compatibility shims left behind by this slice: none added.

AMB-1716 supersession:

- Retired path added:
  `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift`
- Quarantined support owner:
  `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`
- Active guard ceiling: `111` legacy runtime production files.

Yellow architecture debt remains because `111` legacy runtime production files
still exist under `Core/Runtime`, including adapter shims, production-coupled
files that AMB-1713 classified as test-only support, and the unresolved
`RuntimePackageBoundaryModels.swift` owner decision. Next repair train: a
follow-up AMB-1666 runtime owner-move or quarantine leaf before parent Green.

No equivalent-folder or close-enough path interpretation was used.

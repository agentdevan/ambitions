# Today flagship calibration slice — R01

Package ID: `2026-07-23-today-flagship-calibration-slice-r01`

Revision: `AVF-TODAY-S10-R01`

Status: **READY FOR OWNER REVIEW**

Starting SHA: `f2781053d1ffcf962f112014b37d916bd677c450`

Implementation ending SHA: `1b2e0f5b4e92735aadcf91e4d92d10fd3620f8fe`

Branch: `codex/today-flagship-calibration-slice`

This package contains the first complete fixture-driven native Today
calibration journey: Today orientation, a stable Start Here Step, proposed
`Still counts` review, transitional saving, settled accepted truth, explicit
return, nearest-truthful Today continuity, and an interrupted recovery branch.

The ten matched frames are under `screenshots/`. Six supporting state and stress
frames are under `supporting-state/`. The three continuous Simulator recordings
are under `recordings/`. Machine-readable hashes, sizes, device details, state
sequences, and proof ceilings are in `screenshot-metadata.json` and
`journey-metadata.json`.

## Proof ceiling

- These screenshots and recordings are evaluation references, not production
  baselines.
- Fixture-host timing and transitions do not claim production persistence or
  asynchronous behavior.
- Direct-device proof remains required and incomplete.
- Today visual approval is an owner decision; this branch does not accept its
  own work.
- `APPROVED FOR SWIFTUI` remains `false`.
- Broad reconstruction and runtime integration remain unauthorized.
- The branch is unmerged and unpushed.

## Package index

- `implementation-plan.md` — planned scope and execution boundary
- `design-contract.md` — locked semantic and visual contract
- `architecture-assumptions.md` — ownership and presentation decisions
- `fixture-contract.md` — deterministic fixture family and identities
- `revision-AVF-TODAY-S10-R01.md` — revision ledger
- `visual-review.md` — frame-by-frame self-review
- `accessibility-review.md` — accessibility and content-stress results
- `benchmark-report.md` — warm visual-loop measurements
- `validation-results.md` — commands and outcomes
- `known-limitations.md` — honest Simulator and architecture ceilings
- `before-after-comparison.md` — accepted bootstrap to slice comparison
- `changed-files.md` — changed-path inventory and integration audit
- `commands.md` — exact execution command ledger
- `owner-review.md` — undecided owner decision surface

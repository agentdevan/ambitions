# Owner Review Resolution

Batch: `AMB-CHAMPION-MERGE-OWNER-REVIEW-01`
Status: YELLOW

## Summary

This batch records owner-reviewed accepted-Yellow boundaries for the six resolved concepts without merging implementation:

- Today -> `today_root`
- Capture -> `capture_root`
- Runtime recommendation/compiler -> `private_life_runtime`
- Proof/Receipt/Replay -> `proof_receipt_replay`
- Time/Plan/LifeShape -> `time_root`
- You/Profile/Personal Runtime -> `you_root`

Design primitives remain `RESCUE_AND_MERGE -> design_system`.

## Required Fields

| Field | Value |
| --- | --- |
| Status | YELLOW |
| Concept | Today / Start Here / legacy hero surface |
| Canonical owner before | `today_root` |
| Canonical owner after | `today_root` |
| Competing implementations | `Sources/Previews/**`, historical Today hero references |
| Better fragments rescued | visual state model, accessibility fixtures, preview references |
| Active code changed | none |
| Runtime wires | presence-check Yellow only; runtime wiring proof remains for Champion Merge |
| SourceRecord | recorded in `docs/codex/concept-lock-registry.yml` and the owner/selection ledgers |
| Receipt | recorded as owner-reviewed accepted Yellow boundary |
| ReplayTrace | not proven in this phase; deferred to Champion Merge |
| You inspection | noted as required for the runtime-owned concepts; no runtime behavior change here |
| Reset/delete | not changed |
| Tests run | `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-OWNER-REVIEW-01`; `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-OWNER-REVIEW-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-OWNER-REVIEW-01.md --batch-type guard-repair`; `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-CHAMPION-MERGE-OWNER-REVIEW-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-OWNER-REVIEW-01.md --changed-from 90eb6ced4c0ca10c2fccc7f35f6caa7f9e2b7253 --batch-type guard-repair` |
| Proof artifact | `build/reports/intelligence-consolidation/owner-review-resolution.md` |
| Supersession ledger update | owner-review accepted Yellow boundary recorded; no retirement approved in this phase |
| Best-code rescue ledger update | reviewed stronger fragments recorded without source merge |
| Concept lock update | owner-reviewed accepted Yellow boundary recorded in `docs/codex/concept-lock-registry.yml` |
| Duplicates remaining | Champion Merge batches remain for source merge and runtime proof |
| Retirement candidates | preview references and compatibility fragments only, pending later Champion Merge follow-up |
| Yellow/Red items | Yellow: implementation merge and runtime proof remain deferred; Red: none |
| Claims allowed | owner review complete, canonical owner resolved, accepted Yellow boundary recorded |
| Claims forbidden | runtime wiring proof, implementation merge, release or production claims |

## Per-Concept Notes

| Concept | Canonical owner | Status | Competing implementations | Better fragments rescued | Active code changed | Runtime wires | SourceRecord | Receipt | ReplayTrace | You inspection | Reset/delete | Tests run | Concept lock update | Supersession ledger update | Best-code rescue ledger update | Duplicates remaining | Retirement candidates | Yellow/Red items | Claims allowed | Claims forbidden |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Today / Start Here / legacy hero surface | `today_root` | OWNER_REVIEWED_ACCEPTED_YELLOW | `Sources/Previews/**`, historical Today hero references | visual state model, accessibility fixtures, preview references | none | presence-check Yellow only | recorded | recorded | deferred | noted | not changed | none | updated | updated | updated | yes | preview references only | Yellow: merge still deferred | owner review complete | implementation proof |
| Capture parser/routing/SmartAttachment | `capture_root` | OWNER_REVIEWED_ACCEPTED_YELLOW | capture runtime bridge tests, placement helpers | parsing and placement helpers | none | presence-check Yellow only | recorded | recorded | deferred | noted | not changed | none | updated | not needed | updated | yes | capture parser follow-up | Yellow: merge still deferred | owner review complete | implementation proof |
| Recommendation engine / Step candidate / Goal compiler | `private_life_runtime` | OWNER_REVIEWED_ACCEPTED_YELLOW | runtime compiler fragments, source bridge helpers | deterministic recommendation helpers | none | presence-check Yellow only | recorded | recorded | deferred | required | not changed | none | updated | not needed | updated | yes | runtime compiler follow-up | Yellow: merge still deferred | owner review complete | implementation proof |
| Proof / Receipt / ReplayTrace | `proof_receipt_replay` | OWNER_REVIEWED_ACCEPTED_YELLOW | duplicate proof drawers, receipt forks | trust primitives, replay helpers | none | presence-check Yellow only | recorded | recorded | deferred | required | not changed | none | updated | not needed | updated | yes | duplicate trust ledgers | Yellow: merge still deferred | owner review complete | implementation proof |
| Time / Plan / LifeShape | `time_root` | OWNER_REVIEWED_ACCEPTED_YELLOW | compatibility adapters, schedule helpers | availability and planning helpers | none | presence-check Yellow only | recorded | recorded | deferred | required | not changed | none | updated | updated | updated | yes | compatibility fragments | Yellow: merge still deferred | owner review complete | implementation proof |
| You / Profile / Personal Runtime | `you_root` | OWNER_REVIEWED_ACCEPTED_YELLOW | profile-era controls, trust overlays | inspection and trust controls | none | presence-check Yellow only | recorded | recorded | deferred | required | not changed | none | updated | not needed | updated | yes | profile-era fragments | Yellow: merge still deferred | owner review complete | implementation proof |

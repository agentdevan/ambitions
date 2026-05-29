# AMB-POST23-04 Next Train Recommendation

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Accepted Yellow
Date: 2026-05-19
Batch: AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION
Stage: next train recommendation

## Scope and Non-Claims

This report recommends the next post-23 train from the evidence already gathered in the preceding post-23 truth, repair, and authority cleanup reports.

It does not modify app source, tests, truth files, project config, package config, runner state, or any `.codex` mirrors. It is a recommendation report only.

This report does not claim:

- build success
- test success
- device proof
- accessibility conformance
- privacy or legal approval
- performance proof
- release readiness
- product completion
- flagship readiness
- same-intent/different-context proof
- relaunch replay proof

The active top-level IA remains `Today / Goals / Capture / Time / You`. `Plan` remains compatibility/contextual only unless a future scoped migration changes that truth.

## Evidence Base

Primary authority:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

Post-23 control docs:

- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md`

Post-23 reports:

- `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md`
- `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md`
- `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`

The key evidence pattern across those reports is consistent:

- core flagship surfaces exist in source
- several flagship objects remain partial in final proof form
- same-intent/different-context proof remains unproven
- relaunch replay proof remains unproven
- visual QA is unknown or unproven
- accessibility hooks exist, but conformance is not proven
- closure and recovery remain durable in part, but not fully end-to-end proven

## Frontend Authority Evidence

This recommendation also required the generated frontend authority artifacts for the active root surfaces.

The encyclopedia-to-frontend OS final gate is green:

- `build/reports/encyclopedia-to-frontend-os-final-gate.md`
- status: `green`
- checks passed for packet generation, packet index, root packets, all five required preflights, prompt runner headers, source bindings, drift checks, surface, queue, receipts/proof contracts, make targets, frontend routing, and the no-implementation/no-release-claim guards

The five required root surfaces all have matching packet and preflight evidence:

- `today_root_reality_meridian`
  - packet: `build/reports/frontend-authority-packets/today_root_reality_meridian.md`
  - preflight: `build/reports/frontend-authority-preflight/today_root_reality_meridian.md`
  - preflight status: `green`
- `goals_root_constellation_atlas`
  - packet: `build/reports/frontend-authority-packets/goals_root_constellation_atlas.md`
  - preflight: `build/reports/frontend-authority-preflight/goals_root_constellation_atlas.md`
  - preflight status: `green`
- `capture_root_atmosphere_composer`
  - packet: `build/reports/frontend-authority-packets/capture_root_atmosphere_composer.md`
  - preflight: `build/reports/frontend-authority-preflight/capture_root_atmosphere_composer.md`
  - preflight status: `green`
- `time_root_lifeshape_field`
  - packet: `build/reports/frontend-authority-packets/time_root_lifeshape_field.md`
  - preflight: `build/reports/frontend-authority-preflight/time_root_lifeshape_field.md`
  - preflight status: `green`
- `you_root_user_system_profile`
  - packet: `build/reports/frontend-authority-packets/you_root_user_system_profile.md`
  - preflight: `build/reports/frontend-authority-preflight/you_root_user_system_profile.md`
  - preflight status: `green`

Taken together, that frontend authority evidence supports the report's boundary condition: UI work is still not the first recommended next train because the core-loop proof and backend repair gaps remain the more urgent blockers.

## Decision Summary

The next recommended train is a core-loop proof and backend repair train, not UI Suite first.

That recommendation is based on the evidence gap, not on preference:

- the repo already has source-present surfaces and compatibility seams
- the missing proof is still around deterministic recommendation, relaunch continuity, durable closure, and receipt/proof persistence
- UI polish would be premature if the core loop is not yet fully provable

The recommendation therefore prioritizes proof and backend repair before broader visual implementation work.

## Why UI Suite Is Deferred

UI Suite is deferred because the current evidence does not yet prove the foundation it would polish.

UI Suite should come after the repo can honestly answer these questions:

- Is the recommendation deterministic and inspectable across contexts?
- Does relaunch preserve the same proof and continuity story?
- Does closure and recovery remain durable after state changes?
- Are proof and receipts persisted in a way the runtime can rely on?

Until those questions are proven, a UI-first train would risk polishing a foundation that is still only partially proven.

## Proposed Train Order

1. Core-loop proof and backend repair
2. UI Suite review and implementation
3. Frontend Flagship
4. Apple continuity and durability strategy
5. Launch-believability and closed beta readiness

This order is a recommendation, not a committed roadmap claim.

## Exact Proof Targets

The next proof-oriented train should target the following evidence gaps:

- deterministic recommendation proof
- relaunch replay proof
- closure and recovery durability
- receipt and proof persistence
- visual QA capture
- accessibility evidence

The first four are the critical blockers for a credible core-loop repair train. Visual QA and accessibility evidence remain necessary, but they should follow once the underlying behavior is provable enough to review honestly.

## Forbidden Scope

This recommendation report does not authorize:

- app-source implementation
- full UI Suite work
- broad redesign
- custom server work
- cloud AI dependency work
- release claims
- accessibility claims without proof
- privacy claims without proof
- performance claims without proof
- any canon or architecture change

It also does not reclassify `Plan` as active top-level IA.

## Validation

Checked in this phase:

```bash
test -f docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md
test -f docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md
test -f docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md
test -f docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md
test -f docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md
rg -n "Core-loop|Backend projection|UI Suite|same-intent|relaunch|accessibility|visual|STATUS: (GREEN|YELLOW|RED)" docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md
bash scripts/codex-forbidden-claim-scan.sh docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md
git diff --check -- docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md
git status --short --branch
```

Expected result for this phase: Accepted Yellow, because this recommendation report is complete and validated while the underlying foundation proof intentionally remains open.

## Accepted Yellow Closeout

This Yellow is accepted only for the recommendation artifact:

- The report completed its job: it recommends core-loop proof and backend repair before UI Suite.
- Frontend authority evidence is now explicit and points to green packet/preflight artifacts for all five required root surfaces.
- The remaining Yellow items are not report defects. They are the proof gaps routed to the next train: deterministic recommendation proof, relaunch replay, closure/recovery durability, receipt/proof persistence, visual QA, and accessibility evidence.
- This closeout does not claim product completion, build/test success, device proof, release readiness, accessibility conformance, or flagship readiness.

## Rollback

Remove this report only:

```bash
rm -f docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md
```

STATUS: ACCEPTED YELLOW

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

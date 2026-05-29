# PXOS Roadmap To Implementation Reorder Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Recurring PXOS implementation-readiness gate; PXOS implementation not started
Date: 2026-05-02

## Purpose

PX18 converts PXOS implementation readiness into a recurring gate. Run this
protocol before any PXOS implementation lane, Product Depth implementation
batch, user-facing AmbitionsOS exposure, or broad surface redesign.

The gate may reorder, split, block, or route future work. It must not implement
app behavior, start ME/CS/AOS/Product Depth by implication, weaken release
truth, or describe PXOS as shipped.

## Classification Options

- Keep order
- Move earlier
- Move later
- Split
- Merge
- Convert to recurring gate
- Block until dependency resolved
- Leave future/inactive

## Required Inputs

- Current global order.
- PX01-PX17 future-canon evidence.
- REC02-REC06 release evidence boundaries.
- PXOS gate matrix.
- PXOS dependency graph.
- ME, CS, AOS, Product Depth, and release/human-proof status truth.
- Current dirty-tree and branch state.
- Proposed next implementation lane or batch.

## Recurring Gate Procedure

1. Confirm branch is `main` and the working tree is safe.
2. Confirm PX01-PX17 remain complete as future canon only.
3. Confirm no PXOS, AmbitionsOS, Product Depth, release/platform, or app
   behavior claim outruns evidence.
4. Identify the proposed next lane or batch.
5. Classify the proposed lane with the options above.
6. Apply ME, CS, AOS, REC, accessibility, copy, visual, trust/proof, and
   validation-strength gates.
7. Produce one of: allowed next prompt, split prompt, repair prompt,
   dependency prompt, or human/operator checklist.
8. Stop on unresolved Red, weak implementation validation, human-proof
   requirement, or unclear ownership.

## Dependency Principles

1. Release evidence truth prevents false product claims.
2. PXOS canon should exist before major user-facing implementation.
3. ME extraction should occur before large UI/feature expansion in affected areas.
4. CS retirement should occur before renaming/removing legacy internal seams.
5. AOS runtime/intelligence should not expose user-facing intelligence until
   PXOS defines expression.
6. Product Depth follows PXOS canon and relevant ME/CS safety gates.
7. UI implementation needs PXOS source truth, accessibility, copy, visual,
   and validation gates.
8. Intelligence implementation needs AmbitionsOS truth, PXOS expression rules,
   privacy/trust/fallback gates.
9. Messaging must pass REC/PXOS release-claim boundaries.
10. Route/raw/external changes pass CS gates.
11. Large UI expansion passes ME gates.
12. Top-level surface changes pass PXOS hierarchy gates.

## Global Reorder Findings

- `REC01-REC06`: keep order as completed evidence layer. REC evidence and
  human-proof boundaries now precede public messaging claims.
- `PX01-PX17`: keep order as completed future canon. PXOS hierarchy, surface
  canon, recovery, trust, copy, visual, accessibility, degraded, depth,
  continuity, recommendation, and release messaging canon now exists.
- `PX18 reorder gate`: convert to recurring gate before major PXOS
  implementation or Product Depth implementation-readiness claims.
- `PX19-PX20`: keep order. Handoff and beyond-roadmap work can close the PXOS
  canon train if PX18 stays Green or accepted Yellow.
- `ME01-ME12`: move earlier before large UI work. Extraction gates protect
  affected large files before PXOS or Product Depth implementation.
- `CS01-CS10`: move earlier before renames/removals. Compatibility seams must
  be mapped before route, raw-value, external, persistence, or naming changes.
- `AOS01-AOS30`: split internal foundation from user-facing exposure. Internal
  AOS contracts may proceed only through AOS gates; exposure waits for PXOS
  expression, privacy, proof, fallback, and validation evidence.
- `Product Depth`: block until dependency resolved. Requires explicit approval,
  PX14/PX18, affected ME/CS gates, and AOS gates when runtime intelligence,
  proof, or recommendation logic is touched.
- Release readiness, TestFlight, and App Store evidence: move later as a
  human-proof stop. Human approval for batch continuation is not proof.

## Candidate Lane Readiness After PX18

- PX19 PXOS Handoff: ready if PX18 validation is Green or accepted Yellow.
  Continue under global order and docs-only boundaries.
- PX20 PXOS Beyond Roadmap: blocked until PX19. Continue only after handoff
  evidence.
- ME train: blocked until `Start ME Train`. Use ME01 after explicit approval
  and ME source-truth dry-run.
- CS train: blocked until `Start CS Train`. Use CS01 after explicit approval
  and compatibility dry-run.
- Product Depth train: blocked until `Start Product Depth Train` plus PX18
  Green. Use PD01 only after explicit approval and ME/CS dependency map.
- AOS train: blocked until `Start AOS Train`. Use AOS01 after explicit approval
  and runtime/privacy/source-truth dry-run.
- PXOS UI implementation: blocked until post-PX handoff plus affected
  ME/CS/AOS gates. Produce a named implementation prompt only after ownership,
  validation, and proof gates are complete.

## Readiness Decision

PX18 Green or accepted Yellow means the recurring gate exists and the PXOS canon
train may continue to PX19 handoff. It does not mean PXOS implementation may
start. It does not approve ME, CS, Product Depth, AOS, or release/platform
claims.

## Recurring Red Conditions

- proposed implementation lacks ME/CS/AOS/REC gate mapping;
- proposed implementation touches production Swift without owner and validation
  plan;
- Product Depth starts without explicit approval;
- AOS user-facing exposure starts without AOS contracts and PXOS expression proof;
- route/raw/external/persistence seams change without CS proof;
- large UI files grow without ME review;
- release/platform/readiness language outruns evidence;
- top-level surfaces become stacked-card detail containers;
- validation strength is Weak or Missing for implementation work.

## Output Contract

Each future PX18-style rerun must produce:

- selected lane or batch;
- classification;
- allowed files;
- forbidden files;
- required gates;
- validation strength requirement;
- Yellow ownership;
- Red blockers;
- next safe prompt path;
- rollback or repair route;
- statement of what the gate does not prove.

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

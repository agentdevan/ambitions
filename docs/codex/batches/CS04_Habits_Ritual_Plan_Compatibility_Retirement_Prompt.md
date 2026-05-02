# CS04 Habits Ritual Plan Compatibility Retirement Prompt

Status: Future prompt; do not run automatically.

## Batch Identity

- Batch ID: `CS04`
- Name: Habits Ritual Plan Compatibility Retirement
- Compatibility action: retires
- Candidate seam: Habits route/model compatibility for Ritual/Plan continuity
- Target: Retire only after legacy payload survival proof.

## Purpose

Retire or prove compatibility seams only when replacement, migration, rollback, and external-route evidence are stronger than the seam being removed. Preserve historical payloads, user data, routes, accessibility identifiers, visible humane copy, and release-claim truth.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/skills/compatibility-migration-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "Habits|Profile|You|Insights|Habits|activeFocus|TodayFocus|\.focus|failed|rawValue|deepLink|widget|AppIntent|import|export" Native docs .codex || true`

Stop if predecessor CS gates are not Green, if the seam owner is unclear, or if route/raw-value/persistence/external payload impact cannot be mapped.

## Allowed Files

- Seam owner files discovered and named in the replacement map
- Focused tests for legacy and replacement behavior
- Compatibility fixtures for old routes, raw values, imports/exports, widgets, App Intents, shortcuts, and persistence views when applicable
- `docs/**` and `.codex/**` for maps, reports, traceability, and evidence

## Forbidden Files

- `.github/workflows/**`
- Dependency manifests, lockfiles, signing/project release config
- Deleting legacy values, routes, payload decoders, fixtures, or migration adapters before proof exists
- Product behavior expansion, visual redesign, broad cleanup, AOS implementation, release claims, backend/sync/account/model/runtime work

## Implementation Boundary

This batch may map, prove, repair, hand off, or retire only the named seam action. A retire action requires replacement map, route/deep-link review, schema/persistence review, widget/App Intent/Shortcut review, import/export review, preview fixture review, focused tests, rollback path, and release-claim review before deletion.

## Required Non-Goals

No opportunistic renaming, no broad product language sweep, no schema migration without explicit migration gate, no platform-readiness claim, no release-readiness claim, no deletion before proof.

## Required Validation Commands

- `git status --short`
- Focused compatibility tests named by the seam map
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/build-local.sh || true` when app code changed
- `git diff --check`

## Required Evidence Outputs

- Compatibility seam report with old value, replacement value, affected routes, payloads, persistence/import/export impact, external surfaces, tests, rollback, and release-claim status
- Updated compatibility registry and traceability matrix
- Registry/context/run-state update after evidence
- Failure-forensics report for any unclassified compatibility issue

## Green / Yellow / Red Criteria

Green: replacement map is complete, old payloads still open, focused compatibility proof passes, rollback exists, and no release/platform claim is introduced.

Yellow: advisory docs/tooling backlog or a nonblocking legacy seam remains intentionally preserved with owner and review date.

Red: route/deep-link uncertainty, raw-value uncertainty, widget/App Intent/Shortcut uncertainty, import/export uncertainty, persistence/schema uncertainty, accessibility identifier mismatch, public copy regression, deletion before proof, or release claim ambiguity.

## Stop Conditions

Stop on any Red, missing seam owner, legacy payload failure, unclassified UI/test failure, migration uncertainty, missing rollback path, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve old values until proof is Green. Repair through CS09 only after classifying the compatibility failure. Do not remove fallback decoders or route aliases without documented retirement evidence.

## What This Batch Must Not Claim

It must not claim all compatibility seams are retired, external platform readiness, App Store/TestFlight/device readiness, or AmbitionsOS implementation.

## What This Batch Does Not Prove

It does not prove physical-device behavior, signed archive validation, public accessibility conformance, or future platform behavior beyond the focused seam evidence.

## Commit Message Recommendation

`Run CS04 Habits Ritual Plan Compatibility Retirement`

## Next Safe Prompt / Next Gate

Continue only to the next CS batch after Green evidence is recorded, committed, and pushed. Yellow or Red requires repair or user decision.

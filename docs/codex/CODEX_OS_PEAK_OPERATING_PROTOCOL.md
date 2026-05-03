# Codex OS Peak Operating Protocol

<!-- markdownlint-disable MD013 -->

Status: Active Codex operating protocol for Ambitions 4.0 plus External Brain train execution; not product implementation evidence.
Date: 2026-05-03

## Source-Truth Hierarchy

1. Current user directive and scoped repo guidance.
2. `AGENTS.md`, `README.md`, and `docs/README.md`.
3. Ambitions 3.0 source truth and primitive/product-language canon.
4. Ambitions 4.0 Execution Program and External Brain kernel canon.
5. PXOS, SI, Product Depth, AmbitionsOS, REC, ME, CS source docs for their owned layers.
6. `docs/codex/BATCH_REGISTRY.md` for status truth only.
7. Current source code and validation evidence for implementation truth.

## Batch Execution Lifecycle

Verify repo state, read source truth, select next eligible batch, run dry-run gate, name allowed and forbidden files, dedupe against existing canon, execute the smallest safe scope, validate, classify Green/Yellow/Red, update evidence/run-state, commit one logical batch, push, then continue only when continuation gates allow.

## Red Yellow Green Semantics

- Green: required evidence is present, scope boundary is respected, validation is adequate for the batch type, and no unsupported claim or hidden behavior drift exists.
- Yellow: advisory or deferred gap is classified, owned, noncritical to the next batch, and safe to continue.
- Red: unsafe dirty tree, source-truth conflict, forbidden file touch, privacy/security/accessibility/release-claim risk, weak implementation validation, destructive overwrite, compatibility break, or false claim.

## Continuation Rules

Continue automatically through Green and accepted Yellow. Repair recoverable Red into executable sub-stages when safe. Stop on unrecoverable Red. Do not continue through dirty unknown changes, human-proof requirements, destructive overwrite needs, unsupported release claims, or privacy/security ambiguity.

## Commit And Push Cadence

Use one logical batch per commit. Codex OS upgrades commit separately from batch execution. Evidence-only repairs may commit separately. Push after each accepted commit before selecting the next batch.

## No Background Work Rule

Do not leave uncommitted work, running sessions, unstaged generated artifacts, or hidden deferred edits. Every continuation point must be reconstructable from committed docs, run-state, validation logs, and git history.

## No-Overwrite Rule

Do not erase prior batch history, Yellow truth, audit reports, or active canon. Update an owner file only when it owns the truth being changed. Otherwise add a ledger/report that references the owner.

## No-Double-Work Rule

Before creating canon, search for existing owner docs, generated scaffold, prompts, skills, boards, scripts, and indexes. EB01 is evidence/reconciliation first because External Brain scaffold already exists.

## Human-Proof Boundaries

Codex cannot claim physical-device proof, public accessibility conformance, App Store/TestFlight readiness, legal/privacy signoff, signed archive proof, human visual approval, market proof, or release approval without matching human/operator evidence.

## Implementation-Claim Boundaries

Planned, canonized, scaffolded, prompted, audited, implemented, tested, device-verified, and release-ready are different states. A queued External Brain batch is not app behavior until code and tests prove it.

## Stop Conditions

Stop on unrecoverable Red, unknown dirty tree, destructive source-truth conflict, privacy/security uncertainty, unsupported dependency/workflow/signing need, false release claim, route/raw/persistence risk without proof, or repeated same-root Red after two repair attempts.

## Repair Conditions

Repair is allowed for missing ledger, broad batch scope, missing proof target, prompt incompleteness, docs-only split, validation script gap, dependency graph gap, or recoverable source-truth reconciliation when no product behavior changes are required.

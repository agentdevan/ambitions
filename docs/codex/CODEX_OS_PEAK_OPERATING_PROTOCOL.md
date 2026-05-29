# Codex OS Peak Operating Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active Codex operating protocol for Ambitions global train execution; not product implementation evidence.  
Date: 2026-05-08

## Source-Truth Hierarchy

1. Current user directive and scoped repo guidance.
2. `AGENTS.md`, `README.md`, and `docs/README.md`.
3. AmbitionsCanon and active product/design/source-truth owner docs.
4. Current global order, route owner docs, and active batch prompts for their owned layers.
5. `docs/codex/BATCH_REGISTRY.md` for operational batch status only.
6. Current source code and validation evidence for implementation truth.
7. `docs/codex/CODEX_OS_INDEX.md` and its route/gate/evidence/model-tier maps for Codex OS execution mechanics only.

## Route-First Context

Select one route from `.codex/routes/README.md` before broad search. Add a second route only for real cross-boundary work. Route files are maps, not source truth; owner docs and current source win.

## Model-Tier First Context

When the user invokes `resume mini global batch train`, `resume senior global batch train`, or any model-tier-specific execution, read `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` before selecting or closing the next batch.

- Mini Execution Tier can execute bounded batches, repair scoped failures, and record accepted Yellow only inside explicit proof rails.
- Mini Execution Tier must defer non-blocking senior-only gates to `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`.
- Mini Execution Tier must stop on blocking senior-only gates.
- Unknown model tier uses Mini-safe restrictions.
- Senior Judgment Tier resolves blocking deferrals and owns final judgment gates.

## ACX And Raw Logs

Use `scripts/ai/acx.py` for non-executing extraction only. Use `scripts/ai/acx_local.py` for allowlisted local profiles only. ACX Local preserves exit codes, captures stdout/stderr, writes raw logs and compact summaries under `.codex/logs/`, prints raw log paths, rejects unknown profiles, and rejects destructive command terms before execution.

## Usage-Efficiency Overlay

Use the Codex OS efficiency layer to reduce context and output waste without weakening proof:

- `docs/codex/CODEX_OS_INDEX.md` is the current navigation index for Codex OS entry points.
- `docs/codex/CODEX_USAGE_EFFICIENCY.md` defines ACX, route-first context, state mirrors, and validation tiers.
- `docs/codex/CODEX_EVIDENCE_STANDARD.md` defines raw-log and claim-boundary requirements.
- `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` defines Mini/Senior execution boundaries.
- `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md` records Mini-to-Senior deferrals.
- `.codex/routes/README.md` should be selected before broad repo search.
- `.codex/state/*.md` and `.codex/state/*.yml` are compact mirrors only; owner docs remain authoritative.
- `scripts/ai/acx.py` is a non-executing extractor for bounded reads, saved-log summaries, changed-file grouping from saved status text, advisory gates, and gate reports.
- Summarized ACX output is not enough for needs review build/test/gate, hard Red, release, device, accessibility, legal/privacy, model-tier deferral, and proof-sensitive claims. Use raw logs and owner evidence.

## Batch Execution Lifecycle

Verify repo state, read source truth, classify model tier when relevant, select next eligible batch, run dry-run gate, name allowed and forbidden files, dedupe against existing canon, execute the smallest safe scope, validate, classify Green/Yellow/Deferred/Red, update evidence/run-state/ledger, commit one logical batch, push, then continue only when continuation gates allow.

## Red Yellow Green Deferred Semantics

- Green: required evidence is present, scope boundary is respected, validation is adequate for the batch type, no unsupported claim or hidden behavior drift exists, and model-tier gates allow Green closure.
- Yellow: advisory or deferred gap is classified, owned, noncritical to the next batch, safe to continue, and not a hidden model-tier skip.
- Deferred: Mini cannot safely close a senior-only non-blocking gate, records it in the model-tier deferral ledger, makes no completion claim, and continues only when safe.
- Red: unsafe dirty tree, source-truth conflict, forbidden file touch, privacy/security/accessibility/release-claim risk, weak implementation validation, destructive overwrite, compatibility break, false claim, blocking senior-only gate, or Mini attempting to close a senior-only gate.

## Continuation Rules

Continue automatically through Green and accepted Yellow when owner, safety reason, and no-claim boundary are recorded. Mini may additionally continue through non-blocking model-tier deferrals only when the ledger proves safe continuation. Repair recoverable Red into executable sub-stages when safe. Stop on hard Red. Do not continue through dirty unknown changes, human-proof requirements, destructive overwrite needs, unsupported release/device/accessibility/legal/privacy claims, privacy/security ambiguity, or blocking senior-only gates.

## Commit And Push Cadence

Use one logical batch per commit. Codex OS upgrades commit separately from batch execution. Evidence-only repairs may commit separately. Push after each accepted commit before selecting the next batch.

## No Background Work Rule

Do not leave uncommitted work, running sessions, unstaged generated artifacts, hidden deferred edits, or unrecorded model-tier skips. Every continuation point must be reconstructable from committed docs, run-state, validation logs, deferral ledger, and git history.

## No-Overwrite Rule

Do not erase prior batch history, Yellow truth, audit reports, active canon, or model-tier deferral history. Update an owner file only when it owns the truth being changed. Otherwise add a ledger/report that references the owner.

## No-Double-Work Rule

Before creating canon, search for existing owner docs, generated scaffold, prompts, skills, boards, scripts, indexes, and deferral ledger entries. Extend or reconcile owners instead of creating duplicates.

## Human-Proof Boundaries

Codex cannot claim physical-device proof, public accessibility conformance, App Store/TestFlight readiness, legal/privacy signoff, signed archive proof, human visual approval, founder acceptance, market proof, or release approval without matching human/operator evidence.

## Implementation-Claim Boundaries

Planned, canonized, scaffolded, prompted, audited, implemented, tested, device-verified, model-tier-deferred, and release-ready are different states. A queued batch is not app behavior until code and tests prove it. A model-tier deferral is not a Green completion.

## Stop Conditions

Stop on unrecoverable Red, unknown dirty tree, destructive source-truth conflict, privacy/security uncertainty, unsupported dependency/workflow/signing need, false release claim, route/raw/persistence risk without proof, repeated same-root Red after two repair attempts, blocking model-tier deferral, or unknown/Mini tier reaching a senior-only decision.

## Repair Conditions

Repair is allowed for missing ledger, broad batch scope, missing proof target, prompt incompleteness, docs-only split, validation script gap, dependency graph gap, model-tier reporting gap, or recoverable source-truth reconciliation when no product behavior changes are required.

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

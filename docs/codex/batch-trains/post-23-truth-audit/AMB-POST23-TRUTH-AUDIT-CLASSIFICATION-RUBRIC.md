# AMB-POST23 Truth Audit Classification Rubric

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Use this rubric exactly when classifying results of the original 23-batch FE/BE train.

## Status labels

### REAL

Implemented in app source, connected to the active runtime/UI path, validated or directly testable, discoverable through repo OS, and without known blocking issue.

### PARTIAL

Some source implementation exists, but integration, state coverage, tests, validation, visual proof, or product wiring are incomplete.

### DOC_ONLY

Docs, prompts, manifests, or reports exist, but app/test/source implementation does not back the claim.

### BROKEN

Implementation exists but fails build, tests, routing, compile, preview, accessibility, validation, or obvious runtime behavior.

### MISSING

No meaningful implementation found.

### UNSAFE

Implementation risks data loss, privacy mismatch, false user claim, duplicate truth, launch trust damage, or local-first violation.

### DUPLICATE

A second authority/system exists that conflicts with active source truth or active canon.

### OBSOLETE

Old concept remains but should no longer guide current implementation.

### UNKNOWN

Could not classify with available evidence. Unknown must never be treated as Green.

## Required audited areas

- Final IA: Today / Goals / Capture / Time / You
- Old IA removal/rehome: Plan, Habits, Insights, Profile
- Today root
- Reality Meridian
- Start Here
- Time / LifeShape
- Goals / Constellation Atlas
- Capture / Atmosphere Composer
- You / User System Profile
- Proof / receipt UI
- Closure / recovery UI
- Backend projection contracts
- Private Life Runtime boundary
- Deterministic recommendation / Start Here Frame
- Reality Meridian / LifeShape backend projection
- Source freshness
- Proof/receipt persistence
- Closure persistence
- Protected-time policy
- Local-first privacy invariants
- Persistence / migration impact
- Tests
- Previews
- Accessibility
- Visual QA
- No-sprawl / authority hierarchy
- Validation reports

## Moat checklist

Each item must be Green / Yellow / Red with evidence:

- Can Ambitions turn capture/goal intent into an executable local step?
- Can Today show a real Start Here recommendation?
- Is Start Here grounded in local runtime truth?
- Is Reality Meridian more than decoration?
- Can Time/LifeShape show capacity truth?
- Are closure states durable?
- Are proof/receipts real where shown?
- Can the app recover from a missed or messy day without shame?
- Does the app preserve state after relaunch?
- Does the app avoid cloud/server/AI dependency for core behavior?
- Can the user tell what Ambitions knows versus does not know?
- Would a user understand this as a Personal Life Operating System rather than a task app?

## Flagship skepticism test

The audit must answer:

- Would this feel like a v1 app?
- Would this feel like a generic productivity app?
- Would this feel like a task app with fancy names?
- Would this feel like a calendar clone?
- Would this feel like fake intelligence?
- Would this make users trust Ambitions with their real life?
- What would make a user skeptical?
- What would make an investor/customer believe this is a new category?

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

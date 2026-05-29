<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID
IR-01-FRONTEND-RECOVERY-GATE

# Objective
Recover the currently implemented Ambitions frontend so the five existing top-level surfaces feel native, premium, coherent, and canon-aligned without implementing future planned batches or introducing new product behavior.

This is a recovery/stabilization pass, not a feature expansion pass.

# Active Source Truth To Inspect
1. docs/truth/README.md
2. docs/truth/PRODUCT_DESIGN_TRUTH.md
3. docs/truth/IMPLEMENTATION_TRUTH.md
4. docs/truth/RELEASE_TRUTH.md
5. docs/truth/CODEX_PROCESS_TRUTH.md
6. docs/status/current-implementation-map.md
7. docs/codex/BATCH_REGISTRY.md
8. docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
9. docs/codex/FET* or current frontend excellence gate docs
10. Native/Ambitions/App/
11. Native/Ambitions/Features/Today/
12. Native/Ambitions/Features/Goals/
13. Native/Ambitions/Features/Capture/
14. Native/Ambitions/Features/Time/
15. Native/Ambitions/Features/You/
16. Sources/AmbitionsDesignSystem/

# Allowed Scope
- Refactor existing top-level surface composition.
- Improve native iPhone believability.
- Reduce generic card-stack/dashboard feel.
- Improve hierarchy, spacing, material restraint, typography, copy compression, and bottom chrome coherence.
- Align visible labels to active canon:
  - Today / Goals / Capture / Time / You
  - Start here
  - Recommended step
  - Reality Meridian
  - Constellation Atlas
  - Atmosphere Composer
  - LifeShape Field
  - User System Profile
- Improve existing previews/fixtures for current states.
- Add or adjust tests that verify current UI terminology and anti-drift constraints.
- Update implementation/status docs only where source behavior actually changes.

# Forbidden Scope
- Do not implement future planned batches.
- Do not add new top-level tabs.
- Do not add new backend/runtime capabilities.
- Do not add cloud, hosted AI, analytics, telemetry, sync, auth, or external LLM paths.
- Do not change persistence schema unless absolutely required; prefer no schema changes.
- Do not change route raw values unless explicitly proven safe.
- Do not implement Private Life Runtime moat behavior beyond current source-owned seams.
- Do not claim release readiness, TestFlight readiness, App Store readiness, device proof, or public accessibility proof.
- Do not create new product surfaces not already owned by Today, Goals, Capture, Time, or You.
- Do not revive Plan as a top-level destination.
- Do not turn Time into a generic calendar.
- Do not turn Today into a task list.
- Do not turn Capture into a notes feed or chatbot.
- Do not turn You into a social profile/admin panel.

# Recovery Standard
For each top-level surface, Codex must answer:

1. What is the dominant object?
2. Is the first viewport object-first or card-stack-like?
3. Is the primary action obvious?
4. Is source/trust/proof visible without clutter?
5. Does the screen feel native iPhone, not web/SaaS?
6. Does it preserve Dynamic Type, VoiceOver grouping, Reduce Motion, and contrast?
7. Does it avoid future-scope implementation?
8. Does it avoid banned language and obsolete canon?

# Required Work Phases

## Phase 1 - Baseline Audit
Inspect current frontend files and produce a concise Red/Yellow/Green table for:
- Today
- Goals
- Capture
- Time
- You
- App shell/chrome
- Design system primitives
- Previews/tests

Do not patch yet.

## Phase 2 - Scope Lock
Create a bounded recovery plan that lists:
- exact files to edit
- exact files forbidden
- planned visual/composition repairs
- tests/previews to update
- rollback strategy

Stop if the needed repair requires future planned product behavior.

## Phase 3 - Current-Surface Repair
Patch only current UI/composition issues:
- improve first viewport hierarchy
- reduce generic cards
- strengthen surface-specific object identity
- compress copy
- repair tab/chrome consistency
- improve native spacing/materials
- preserve accessibility semantics

## Phase 4 - Anti-Drift Validation
Run or add checks for:
- banned top-level terms
- Plan/Profile/Captures user-facing drift
- generic dashboard/card-stack language
- chatbot/AI framing
- release-claim overstatement

## Phase 5 - Preview / Visual Proof Preparation
Do not claim human visual approval.
Prepare current preview states and screenshot instructions for:
- normal
- empty
- recovery
- source unavailable/stale
- Dynamic Type
- Reduce Motion
- high contrast where available

## Phase 6 - Validation
Run available local checks:
- formatting/lint where available
- Swift tests where feasible
- frontend gate scripts where available
- build command if environment supports it

If unavailable, report exactly what could not be run and why.

# Validation Expectations
Required:
- no new release claims
- no future-batch implementation
- no new external dependency
- no new top-level IA
- no cloud/LLM/backend creep
- no stale Time surface UI
- no generic dashboard/card-stack regression
- tests/previews updated where touched

# Visual Proof Expectations
If simulator screenshots can be generated, capture:
- Today first viewport
- Goals first viewport
- Capture first viewport
- Time first viewport
- You first viewport

If screenshots cannot be generated, create a screenshot checklist and mark visual proof Yellow, not Green.

# Hard Red Stop Conditions
Stop and report Red if:
- repair requires implementing a future planned batch
- persistence schema changes become necessary
- route raw values require risky migration
- build breaks in unrelated areas
- active truth files conflict in a way that cannot be resolved locally
- any change introduces cloud AI, analytics, telemetry, auth, hosted backend, or release claims

# Rollback Expectations
Every patch must be reversible.
Keep edits minimal.
Document changed files by surface.
Do not hide failures.
If validation fails, attempt bounded repair once, then report remaining Yellow/Red honestly.

# Final Report Required
Return:
1. Status: Green / Accepted Yellow / Red
2. Files changed
3. Surface-by-surface recovery summary
4. What was repaired
5. What remains future-batch-owned
6. What validation passed
7. What validation could not be run
8. Screenshots/proof status
9. Release non-claims
10. Recommended next batch

# Runner Command
scripts/ambitions-codex-train.sh IR-01-FRONTEND-RECOVERY-GATE prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md

# Alternate Runner Command
make batch BATCH=IR-01-FRONTEND-RECOVERY-GATE PROMPT=prompts/batches/IR-01-FRONTEND-RECOVERY-GATE.md

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

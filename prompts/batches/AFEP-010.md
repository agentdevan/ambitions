<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-010 - Reversible Correction Learning System

## Batch ID

AFEP-010

## Linear Issue

AMB-404 - AFEP-010 - Reversible Correction Learning System

## Objective

Make user corrections affect future recommendations locally while remaining inspectable, reversible, recovery-aware, and non-shaming.

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- Live source, tests, runner guard reports, and current wrapper logs beat stale docs or old batch claims.

## Required Actions

- Define correction records and learning boundaries through existing canonical correction, receipt, proof, replay, runtime snapshot, recommendation, recovery, and You inspection owners.
- Attach corrections to provenance and runtime snapshots without bypassing SourceRecord, Receipt, ReplayTrace, proof, closure, or You / What Ambitions knows inspection seams.
- Add reset/delete controls as deterministic models or projections only where existing canonical ownership supports them.
- Add recovery-aware adaptation behavior that can influence later recommendations deterministically without silent mutation, shame, pressure, protected inference, or irreversible learning.
- Preserve privacy redaction, export-safe views, local-only operation, and inspection of learned effects.
- Preserve rollback to AFRI correction, proof, recommendation, and recovery routes if learning parity, reversibility, reset/delete behavior, provenance, or privacy boundaries fail.
- Store a correction replay packet, reset/delete behavior report, and golden correction cases under `build/reports/afep/AFEP-010/`.

## Acceptance Gates

- Corrections influence later recommendations deterministically from named local inputs.
- The user can inspect and reverse learned effects through explicit controls or value-only models that preserve the existing correction route.
- Reset/delete behavior is explicit, provenance-aware, and export-safe.
- No sensitive identity inference, protected trait inference, or private data leak is introduced.
- User-facing language stays canonical: `Start here`, `Recommended step`, `Start now`, `Open step`, `step`, `receipt`, `proof`, `replay`, `closure`, `correction`, and `recovery`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical correction, proof, receipt, replay, closure, runtime snapshot, recommendation, recovery, Today, You inspection, privacy-redaction, export-safe, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/Today`, `Native/Ambitions/Features/You`, `Native/Ambitions/Persistence`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-010/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-010 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel correction engine, learning engine, recommendation engine, proof ledger, receipt ledger, replay engine, closure system, runtime snapshot path, privacy class system, persistence owner, or You inspection owner.
- Do not mutate recommendations, profile facts, proof, closure, receipts, or runtime snapshots silently.
- Do not add irreversible learning, hidden personalization, protected or sensitive inference, shame framing, urgency pressure, continuity-pressure mechanics, rating pressure, or productivity-guilt framing.
- Do not leak private correction, receipt, proof, closure, runtime snapshot, profile, calendar, or goal data through labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not reintroduce `Plan` as a user-facing top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not turn correction learning into a generic command grid, task manager, rating surface, calendar clone, chatbot, AI wrapper, pressure mechanic, or generic history list.
- Do not add cloud AI, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-010`.
- Run focused test lanes for correction determinism, learned-effect reversibility, reset/delete behavior, recovery-aware adaptation, proof/receipt/replay provenance, privacy redaction, export-safe views, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot or visual proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered screenshot proof.

## Proof Artifacts

- `build/reports/afep/AFEP-010/correction-replay-packet.md`
- `build/reports/afep/AFEP-010/reset-delete-behavior-report.md`
- `build/reports/afep/AFEP-010/golden-correction-cases.md`

## Rollback / Failure Behavior

Use AFRI correction, proof, recommendation, and recovery routes and disable elevated correction learning if reversibility, provenance, reset/delete behavior, redaction, local-only operation, or deterministic recommendation influence evidence fails. On Red, stop with the smallest safe repair rather than widening into broad recommendation, persistence, proof, receipt, privacy, You, or UI cleanup.

## Hard Red

- Silent mutation of recommendations, profile facts, proof, closure, receipts, or runtime snapshots.
- Irreversible learning or missing reset/delete boundary.
- Sensitive identity inference, protected trait inference, or privacy leak through correction learning, export-safe views, reports, logs, screenshots, or fixtures.
- Replay mismatch from the same named inputs.
- Parallel correction, learning, recommendation, proof, receipt, replay, closure, runtime snapshot, privacy, persistence, or You inspection owners.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud AI, backend, analytics, tracking, hosted inference, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, device, release, privacy/legal, CI, or full-suite claims.

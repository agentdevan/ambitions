<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-009 - Execution Ledger and Replay Browser

## Batch ID

AFEP-009

## Linear Issue

AMB-403 - AFEP-009 - Execution Ledger and Replay Browser

## Objective

Make step execution, receipts, closure, and replay inspectable through an execution ledger and replay browser while preserving immutable proof, privacy redaction, deterministic replay, and AFRI proof/receipt rollback behavior.

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

- Define execution ledger records through existing canonical execution, closure, receipt, proof, replay, and runtime snapshot owners.
- Connect ledger entries to runtime snapshots and proof receipts without bypassing SourceRecord, Receipt, ReplayTrace, or You / What Ambitions knows inspection seams.
- Add a deterministic replay browser model and read-only inspection path for step execution, closure, receipt, and provenance history.
- Preserve proof and closure immutability; any correction or learning path must remain explicit, reversible, and outside the read-only browser path unless an existing canonical correction flow is invoked.
- Preserve privacy redaction and export-safe views for execution, receipt, proof, closure, and runtime snapshot data.
- Preserve rollback to AFRI execution/proof routes if ledger parity, replay determinism, redaction, or browser inspection fails.
- Store an execution ledger packet, replay browser screenshot plan or packet, and replay/provenance validation report under `build/reports/afep/AFEP-009/`.

## Acceptance Gates

- Execution history is inspectable and replay-compatible from deterministic inputs.
- Proof and closure entries remain immutable.
- Replay browser state is read-only unless an explicit existing correction flow is invoked.
- Ledger entries connect to runtime snapshots and proof receipts with provenance, source freshness, redaction, and export posture visible.
- User-facing language stays canonical: `Start here`, `Recommended step`, `Start now`, `Open step`, `step`, `receipt`, `proof`, `replay`, and `closure`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical execution, proof, receipt, replay, closure, runtime snapshot, Today, You inspection, privacy-redaction, export-safe, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/Today`, `Native/Ambitions/Features/You`, `Native/Ambitions/Persistence`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-009/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-009 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel execution engine, proof ledger, receipt ledger, replay engine, closure system, runtime snapshot path, privacy class system, persistence owner, or You inspection owner.
- Do not make proof or closure entries mutable through the replay browser.
- Do not add silent recommendation mutation, learning, correction, deletion, reset, or export behavior without existing explicit canonical controls and inspectable receipts.
- Do not leak private execution, receipt, proof, closure, runtime snapshot, profile, calendar, or goal data through browser labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not reintroduce `Plan` as a user-facing top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not turn the ledger or browser into a generic command grid, task manager, rating surface, calendar clone, chatbot, AI wrapper, pressure mechanic, or generic history list.
- Do not add cloud AI, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-009`.
- Run focused test lanes for ledger determinism, proof/closure immutability, replay-browser read-only behavior, privacy redaction, export-safe views, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot or visual proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered screenshot proof.

## Proof Artifacts

- `build/reports/afep/AFEP-009/execution-ledger-packet.md`
- `build/reports/afep/AFEP-009/replay-browser-screenshot-plan.md`
- `build/reports/afep/AFEP-009/replay-provenance-validation-report.md`

## Rollback / Failure Behavior

Use AFRI proof/receipt routes and disable the elevated ledger/browser path if replay browser behavior, ledger parity, redaction, immutability, or deterministic replay evidence fails. On Red, stop with the smallest safe repair rather than widening into broad execution, persistence, proof, receipt, privacy, or You cleanup.

## Hard Red

- Mutable proof or closure entries.
- Privacy leak through ledger, browser, export-safe views, reports, logs, screenshots, or fixtures.
- Replay mismatch from the same named inputs.
- Parallel execution, proof, receipt, replay, closure, runtime snapshot, privacy, persistence, or You inspection owners.
- Browser writes to history without an explicit canonical correction flow.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud AI, backend, analytics, tracking, hosted inference, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, device, release, privacy/legal, CI, or full-suite claims.

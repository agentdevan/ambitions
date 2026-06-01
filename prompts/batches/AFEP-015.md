<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-015 - Intent Grammar 2.0

## Batch ID

AFEP-015

## Linear Issue

AMB-409 - AFEP-015 - Intent Grammar 2.0

## Objective

Unify App Intents and Shortcuts around Ambitions canonical objects and safe action grammar so platform entry points can reopen or fall back to Today, Goals, Capture, Time, and You without exposing private life data or drifting into Plan/top-level routes.

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

- Define canonical object intent grammar for Today, Goals, Capture, Time, and You using existing App Intent, Shortcut, external route, command, continuity, and shell routing owners.
- Map actions to `Start here`, `Recommended step`, `Start now`, `Open step`, proof, recovery, and inspection routes.
- Enforce safe metadata and privacy boundaries for any intent payload, shortcut phrase, route token, widget/extension handoff, receipt, proof, or report.
- Preserve SourceRecord, Receipt, and ReplayTrace wiring wherever intent grammar touches proof, recovery, inspection, or reopen behavior.
- Require any runtime-affecting intent or shortcut result to remain inspectable from You / What Ambitions knows when current source supports that inspection path.
- Add exact reopen routing where current canonical targets exist, and graceful fallback to canonical roots where exact objects are missing, stale, private, or unavailable.
- Preserve rollback to AFRI intent routes if routing, metadata, privacy, or platform validation gates fail.
- Store the intent grammar matrix, reopen routing packet, and privacy metadata boundary report under `build/reports/afep/AFEP-015/`.

## Acceptance Gates

- App Intents and Shortcuts speak the same canonical object grammar as the app.
- Intent grammar covers Today / Goals / Capture / Time / You and does not reintroduce `Plan` as user-facing top-level IA.
- No intent, shortcut, route token, proof packet, fixture, log, or report exposes private content beyond safe metadata.
- Reopen routes are exact when proven by current source and gracefully fall back to canonical roots when exact reopening cannot be proven.
- User-facing language stays canonical: `Start here`, `Recommended step`, `Start now`, `Open step`, `step`, `Today`, `Goals`, `Capture`, `Time`, `You`, `User System Profile`, `proof`, `recovery`, `receipt`, and `inspection`.
- No source path claims Siri/Shortcuts device invocation, platform readiness, widget/Live Activity rendering, privacy/legal approval, release readiness, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical App Intent, Shortcut, external routing, shell command, command execution, continuity, widget/extension metadata, proof/provenance, privacy, local-first, and focused test owners under `Native/Ambitions/App`, `Native/Ambitions/Domain`, `Native/Ambitions/ExternalSnapshots`, `Native/Ambitions/Services`, `Native/AmbitionsWidgetExtension`, `Native/AmbitionsTests`, `Sources/`, and `AppUI/Sources`.
- AFEP proof report files under `build/reports/afep/AFEP-015/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-015 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel App Intent engine, Shortcut engine, routing engine, deep-link engine, proof ledger, privacy owner, continuity owner, shell command owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not expose raw goal text, schedule detail, private notes, proof content, receipts, runtime snapshots, local-learning data, Personal Vault data, or protected-storage fields through intent parameters, shortcut phrases, route tokens, fixtures, logs, screenshots, or reports.
- Do not silently mutate user data from an intent or shortcut without an inspectable confirmation/receipt path that current source proves.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, platform invocation, Shortcuts/Siri readiness, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-015`.
- Run focused test lanes for App Intent routing, external route parsing, shell command routing, privacy metadata boundaries, canonical root fallback, and any changed canonical owner tests.
- Run `git diff --check`.
- If Siri/Shortcuts invocation, device, widget/Live Activity rendering, or exact reopen proof is planned but not captured, record it as a Yellow boundary, not as rendered or device proof.

## Proof Artifacts

- `build/reports/afep/AFEP-015/intent-grammar-matrix.md`
- `build/reports/afep/AFEP-015/reopen-routing-packet.md`
- `build/reports/afep/AFEP-015/privacy-metadata-boundary-report.md`

## Rollback / Failure Behavior

Disable elevated grammar and retain AFRI App Intent behavior if canonical routing, metadata redaction, privacy boundaries, fallback behavior, exact reopen routing, test coverage, or platform proof gates fail. On Red, stop with the smallest safe repair rather than widening into broad platform, routing, app shell, privacy, proof, widget, or extension cleanup.

## Hard Red

- Private content is exposed through intent parameters, shortcut phrases, route tokens, fixtures, logs, screenshots, or reports.
- App Intents or Shortcuts route to the wrong canonical root or reintroduce `Plan` as a user-facing top-level destination.
- Intent or shortcut actions silently mutate user data without current confirmation and receipt evidence.
- Parallel App Intent, Shortcut, routing, privacy, proof, continuity, or design-system owners.
- Top-level IA changes.
- Required cloud model, backend, analytics, tracking, hosted inference, account, or telemetry dependencies.
- Unproven Siri/Shortcuts invocation, device, platform, restoration, screenshot, accessibility, privacy/legal, release, CI, or full-suite claims.

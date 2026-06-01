<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-012 - Multimodal Capture Staging Layer

## Batch ID

AFEP-012

## Linear Issue

AMB-406 - AFEP-012 - Multimodal Capture Staging Layer

## Objective

Deepen Capture as Atmosphere Composer with deterministic staging for text, voice, image, share, proof, and context inputs while keeping root Capture composer-driven, minimal, local-first, private, accessible, and rollback-safe.

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

- Keep Capture -> Atmosphere Composer mapping unchanged.
- Preserve root Capture as a composer-first surface; keep secondary triage and review in drill-downs.
- Add deterministic staging records for text, voice, image, share, proof, and context inputs through existing canonical Capture, SourceRecord, receipt, proof, ReplayTrace, You inspection, privacy, export, and accessibility owners.
- Add deterministic routing projections and provenance so staged inputs explain where they can go, why, and what remains private or export-safe.
- Add accessibility-safe capture and review states for VoiceOver, Dynamic Type, Reduce Motion, and Increase Contrast equivalents.
- Preserve local-only operation and rollback to AFRI Capture routes when staging, routing, privacy, or accessibility evidence fails.
- Store the Capture staging packet, routing/provenance artifact packet, and screenshot/state restoration report under `build/reports/afep/AFEP-012/`.

## Acceptance Gates

- Capture remains composer-driven and minimal at the top level.
- Secondary triage stays in drill-downs and does not become the default root Capture experience.
- Staged inputs have deterministic privacy, export, redaction, and retention policy.
- Routing is deterministic from named inputs and inspectable through existing proof, receipt, SourceRecord, ReplayTrace, and You / What Ambitions knows paths when relevant.
- User-facing language stays canonical: `Capture`, `Atmosphere Composer`, `proof`, `receipt`, `SourceRecord`, `ReplayTrace`, `What Ambitions knows`, `Start here`, `Recommended step`, `Open step`, and `step`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical Capture, Atmosphere Composer, SourceRecord, proof, receipt, ReplayTrace, routing, privacy/export, accessibility, design-system, You inspection, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/Capture`, `Native/Ambitions/Features/You`, `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-012/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-012 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel Capture engine, inbox engine, triage engine, SourceRecord owner, proof ledger, receipt ledger, ReplayTrace path, privacy owner, accessibility owner, persistence owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not convert Capture into a task feed, inbox, generic form, chatbot, generic status grid, calendar clone, or default triage queue.
- Do not make multimodal staging visual-only, color-only, animation-only, or unavailable to VoiceOver and Reduce Motion users.
- Do not leak private capture text, voice/image metadata, share content, proof details, receipts, profile, schedule, or runtime data through labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, state restoration proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-012`.
- Run focused test lanes for Capture staging records, deterministic routing/provenance, privacy/export policy, accessibility-safe review states, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot or state restoration proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered proof.

## Proof Artifacts

- `build/reports/afep/AFEP-012/capture-staging-packet.md`
- `build/reports/afep/AFEP-012/routing-provenance-artifact-packet.md`
- `build/reports/afep/AFEP-012/screenshot-state-restoration-report.md`

## Rollback / Failure Behavior

Use AFRI Capture routes and disable elevated staging if deterministic routing, provenance, privacy/export policy, local-only operation, accessibility equivalence, or inspectability evidence fails. On Red, stop with the smallest safe repair rather than widening into broad Capture, persistence, proof, receipt, privacy, accessibility, or UI cleanup.

## Hard Red

- Capture root becomes a task feed, inbox, generic form, chatbot, generic status grid, calendar clone, or default triage queue.
- Secondary triage becomes the root Capture experience.
- Staging records store unsafe private metadata or lack deterministic privacy/export/redaction policy.
- Routing cannot connect to SourceRecord, receipt, ReplayTrace, proof, You / What Ambitions knows inspection, and named deterministic inputs where relevant.
- Parallel Capture, SourceRecord, proof, receipt, ReplayTrace, privacy, accessibility, persistence, or design-system owners.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud model, backend, analytics, tracking, hosted inference, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, device, release, privacy/legal, CI, or full-suite claims.

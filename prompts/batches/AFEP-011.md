<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-011 - Atlas Spatial and Proof Model

## Batch ID

AFEP-011

## Linear Issue

AMB-405 - AFEP-011 - Atlas Spatial and Proof Model

## Objective

Deepen Goals as Constellation Atlas with deterministic spatial projection, proof continuity, direction continuity, lineage, and accessibility-equivalent spatial meaning.

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

- Keep Goals -> Constellation Atlas mapping unchanged.
- Define deterministic Atlas spatial and proof projections through existing canonical Goals, Goal Detail, SourceRecord, receipt, proof, ReplayTrace, lineage, runtime snapshot, and accessibility owners.
- Connect proof trail, direction continuity, object lineage, ReplayTrace continuity, and export-safe proof views without creating a parallel goals engine or proof ledger.
- Preserve You / What Ambitions knows inspection for any Atlas source, proof, receipt, lineage, or replay inputs that affect the spatial projection.
- Add accessibility-safe spatial equivalents so nonvisual and Reduce Motion experiences carry the same object meaning as the visual Atlas.
- Preserve local-only, deterministic, privacy-respecting behavior and rollback to AFRI Goals routes if spatial/proof rendering fails evidence gates.
- Store the Atlas screenshot packet, proof projection packet, and accessibility matrix under `build/reports/afep/AFEP-011/`.

## Acceptance Gates

- Atlas remains the Goals primary object and does not become a metric-tile surface, ranked numeric view, or generic goal list.
- Spatial state is deterministic from named inputs.
- VoiceOver, Dynamic Type, Reduce Motion, and Increase Contrast equivalents preserve spatial meaning and action order.
- Proof model remains inspectable and connected to receipt, lineage, and direction continuity.
- User-facing language stays canonical: `Goals`, `Constellation Atlas`, `proof`, `receipt`, `lineage`, `direction`, `Start here`, `Recommended step`, `Open step`, and `step`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical Goals, Goal Detail, SourceRecord, proof, receipt, ReplayTrace, lineage, runtime snapshot, recommendation, accessibility, design-system, You inspection, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/Goals`, `Native/Ambitions/Features/You`, `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-011/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-011 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel Goals engine, Atlas engine, SourceRecord owner, proof ledger, receipt ledger, ReplayTrace path, lineage system, runtime snapshot path, accessibility owner, You inspection owner, persistence owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not rank life areas by numeric self-worth or convert Goals into a generic task hierarchy, generic list, calendar clone, chatbot, pressure mechanic, or command console.
- Do not make spatial meaning visual-only, animation-only, color-only, or unavailable to VoiceOver and Reduce Motion users.
- Do not leak private goal, proof, receipt, lineage, profile, schedule, or runtime data through labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-011`.
- Run focused test lanes for Atlas deterministic projection, proof projection, lineage continuity, direction continuity, accessibility equivalents, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot or visual proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered screenshot proof.

## Proof Artifacts

- `build/reports/afep/AFEP-011/atlas-screenshot-packet.md`
- `build/reports/afep/AFEP-011/proof-projection-packet.md`
- `build/reports/afep/AFEP-011/accessibility-spatial-equivalence-matrix.md`

## Rollback / Failure Behavior

Use AFRI Goals routes and disable elevated Atlas projection if deterministic spatial meaning, proof continuity, lineage continuity, accessibility equivalence, redaction, local-only operation, or inspectability evidence fails. On Red, stop with the smallest safe repair rather than widening into broad Goals, persistence, proof, receipt, privacy, accessibility, or UI cleanup.

## Hard Red

- Spatial meaning is visual-only, animation-only, color-only, or unavailable to VoiceOver and Reduce Motion users.
- Proof projection cannot connect to SourceRecord, receipt, ReplayTrace, lineage, direction continuity, You / What Ambitions knows inspection, and named deterministic inputs.
- Atlas becomes a metric-tile surface, ranked numeric view, generic goal list, task hierarchy, calendar clone, chatbot, or pressure mechanic.
- Parallel Goals, Atlas, proof, receipt, lineage, runtime snapshot, accessibility, persistence, or design-system owners.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud model, backend, analytics, tracking, hosted inference, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, device, release, privacy/legal, CI, or full-suite claims.

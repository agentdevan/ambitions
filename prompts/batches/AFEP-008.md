<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-008 - Reality Meridian Continuity System

## Batch ID

AFEP-008

## Linear Issue

AMB-402 - AFEP-008 - Reality Meridian Continuity System

## Objective

Deepen Today into a deterministic Reality Meridian continuity system while preserving Start Here and canonical Today ownership. Reality Meridian must remain the primary Today object, not a task card stack, and it must keep recommendation, current time reality, capacity, source freshness, proof, provenance, recovery, and continuation state connected.

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

- Keep Today -> Reality Meridian mapping unchanged.
- Add deterministic Today projection and continuity models through the existing canonical Today owners.
- Add provenance hooks that preserve SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection seams when Today state explains source freshness, proof, recommendation, or recovery context.
- Add accessibility-safe rendering state models or fixtures for reduced motion, differentiate-without-color, Dynamic Type-friendly summaries, and VoiceOver-orderable continuity.
- Add state restoration and continuation tests for Reality Meridian projection state.
- Preserve rollback to AFRI Today routes if elevated projection, restoration, or rendering evidence fails.
- Store a screenshot-evidence plan, replay/provenance artifact packet, and state restoration/continuation test report under `build/reports/afep/AFEP-008/`.

## Acceptance Gates

- Reality Meridian remains the primary Today object and does not become a generic task card stack, tiled command surface, or calendar clone.
- Recommendation, current time reality, capacity, source freshness, proof, and recovery state remain connected in one inspectable Today projection.
- Start Here language remains locked: use `Start here`, `Recommended step`, `Start now`, and `Open step`.
- Continuity state is deterministic and can be restored or replayed from named inputs.
- Any runtime-derived Today explanation can be inspected through SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows seams.
- Rollback route to AFRI Today behavior is available.

## Allowed Scope

- Existing canonical Today, Reality Meridian, Start Here, proof/provenance, visual-state, accessibility-state, and focused test owners under `Native/Ambitions/Features/Today`, `Native/Ambitions/Domain`, `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-008/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-008 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel Today engine, planner, recommendation path, proof/receipt/replay path, visual system, persistence schema, or user-profile owner.
- Do not reintroduce `Plan` as a user-facing top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not turn Today into a task manager, tiled command surface, calendar clone, habit tracker, chatbot, AI wrapper, pressure mechanic, rating surface, or generic list UI.
- Do not silently mutate user data or future recommendations without inspectable receipts and rollback/reset boundaries.
- Do not add cloud AI, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-008`.
- Run focused test lanes for Reality Meridian projection, provenance, restoration, and any changed Today owner tests.
- Run `git diff --check`.
- If screenshot or visual proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered screenshot proof.

## Proof Artifacts

- `build/reports/afep/AFEP-008/screenshot-evidence-plan.md`
- `build/reports/afep/AFEP-008/replay-provenance-artifact-packet.md`
- `build/reports/afep/AFEP-008/state-restoration-continuation-test-report.md`

## Rollback / Failure Behavior

Return to AFRI Today route and disable the elevated projection path if continuity, restoration, provenance, or rendering evidence fails. On Red, stop with the smallest safe repair rather than widening into broad Today, routing, persistence, or planner cleanup.

## Hard Red

- Canonical Today -> Reality Meridian mapping changes.
- Reality Meridian becomes a task card stack, tiled command surface, calendar clone, chatbot, or generic productivity list.
- Start Here language regresses to old or non-canonical wording.
- Unproven restoration, screenshot, accessibility, device, release, or full-suite claims.
- Runtime provenance bypasses SourceRecord, Receipt, ReplayTrace, or You / What Ambitions knows inspection.
- Required cloud AI, backend, analytics, tracking, hosted inference, or telemetry dependencies.

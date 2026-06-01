<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-014 - Personal Vault and Permissions Center

## Batch ID

AFEP-014

## Linear Issue

AMB-408 - AFEP-014 - Personal Vault and Permissions Center

## Objective

Deepen You as User System Profile with a Personal Vault and Permissions Center for local learning, privacy, protected storage, and continuity controls while keeping You Settings-style, inspectable, local-first, accessibility-safe, and rollback-safe.

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

- Keep You -> User System Profile mapping unchanged.
- Preserve You as an iOS Settings-style profile and trust-control surface, not a generic command panel.
- Add Personal Vault model and permission surfaces through existing canonical You, privacy, local-learning, export, reset/delete, and inspection owners.
- Add inspection, reset, and delete controls for local learning where the current source already supports or can safely expose them.
- Add privacy classes and protected-storage hooks without claiming legal/privacy approval or complete protected-storage implementation unless current evidence proves it.
- Preserve local-only operation and rollback to AFRI You routes when vault, permissions, privacy, provenance, accessibility, or protected-storage evidence fails.
- Store the permissions matrix, vault screenshot packet, and privacy/provenance artifact packet under `build/reports/afep/AFEP-014/`.

## Acceptance Gates

- You remains Settings-style and control-oriented.
- User can inspect what Ambitions knows and controls through visible local-learning and permission rows.
- Sensitive fields have explicit storage, export, reset, delete, provenance, and privacy-policy labels.
- Personal Vault copy is local-first, non-alarming, non-shaming, and does not imply hidden inference or hidden learning.
- User-facing language stays canonical: `You`, `User System Profile`, `What Ambitions knows`, `privacy`, `provenance`, `permission`, `receipt`, `SourceRecord`, `ReplayTrace`, `Start here`, `Recommended step`, `Open step`, and `step`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, protected-storage completion, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical You, What Ambitions knows, local-learning, privacy, protected-storage, export/reset/delete, continuity, proof/provenance, receipt/replay, accessibility, design-system, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/You`, `Native/Ambitions/Features/Today`, `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-014/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-014 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel You profile, personal vault engine, permissions engine, proof ledger, receipt ledger, ReplayTrace path, privacy owner, protected-storage owner, accessibility owner, persistence owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not convert You into a generic command panel, task list, account settings clone, chatbot, generic status grid, gamified ranking surface, shame surface, or productivity-guilt UI.
- Do not make privacy, provenance, storage, export, reset, delete, or permission state visual-only, color-only, animation-only, or unavailable to VoiceOver and Reduce Motion users.
- Do not leak private profile, learning, permission, schedule, protected-storage, proof, receipt, or runtime data through labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, protected-storage completion, CI, TestFlight, App Store, screenshot proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-014`.
- Run focused test lanes for You Personal Vault permissions, local-learning inspection/reset/delete controls, privacy/provenance labels, protected-storage policy hooks, accessibility-safe render equivalents, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot, protected-storage, or state restoration proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered proof.

## Proof Artifacts

- `build/reports/afep/AFEP-014/permissions-matrix.md`
- `build/reports/afep/AFEP-014/vault-screenshot-packet.md`
- `build/reports/afep/AFEP-014/privacy-provenance-artifact-packet.md`

## Rollback / Failure Behavior

Use AFRI You routes and conservative privacy defaults if Personal Vault, permission controls, local-learning inspection, reset/delete, provenance, privacy/export policy, protected-storage hooks, local-only operation, accessibility equivalence, or inspectability evidence fails. On Red, stop with the smallest safe repair rather than widening into broad You, persistence, proof, receipt, privacy, accessibility, or UI cleanup.

## Hard Red

- You stops being a Settings-style User System Profile.
- Personal Vault or permissions imply hidden learning, hidden inference, hidden storage, hidden export, or hidden reset/delete behavior.
- Sensitive fields lack inspectable storage, export, reset, delete, provenance, and privacy-policy labels.
- Vault or permission controls silently mutate profile, learning, receipt, proof, runtime, or protected-storage state.
- Parallel You, vault, permissions, proof, receipt, ReplayTrace, privacy, accessibility, persistence, protected-storage, or design-system owners.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud model, backend, analytics, tracking, hosted inference, account, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, protected-storage, device, release, privacy/legal, CI, or full-suite claims.

# Ambitions Codex Guidance

This file is for AI/Codex contributors working in the Ambitions repo.

Current repo posture:

- AmbitionsCanon is the highest product/design source truth.
- `docs/status/current-implementation-map.md` is current implementation-status truth.
- `docs/status/release-evidence-packet.md` is current validation/release-evidence truth.
- Validation is local VM/Mac only. There is no active hosted CI workflow.
- Ambitions 3.0/4.0, PXOS, SI, FCP/PFC/AOS/LDI, handoff, audit, `.codex`, and `.agents` material is retained as history, operating context, or stricter proof gates where compatible. It is not the public repo front door.
- EFC is an active peak-proof overlay for unfinished planned work. It does not replace the active batch, implement product behavior by itself, or authorize release/platform claims.
- The local Ambitions Repo MCP under `tools/mcp/ambitions_repo_mcp/` is optional read-only Codex tooling for active-batch, EFC, source-truth, claim-scan, closeout, and changed-file impact checks. It is not an app dependency.
- The local Ambitions Proof MCP under `tools/mcp/ambitions_proof_mcp/` exposes allowlisted validation names only. It is not a generic shell and must not gain write, network, secrets, signing, App Store, hosted CI, or git mutation tools without explicit approval.

## Required read order

For normal repo work, read in this order:

1. `README.md`
2. `docs/README.md`
3. `docs/AmbitionsCanon/README.md`
4. `docs/status/current-implementation-map.md`
5. `docs/status/repo-cleanup-index.md`
6. `docs/status/release-evidence-packet.md`
7. `docs/native-build-and-release.md`
8. the target source files and tests

For product, visual, shell, chrome, IA, Signature Object, trust, accessibility, QA, token/material, or implementation-planning work, read the AmbitionsCanon files named by `docs/AmbitionsCanon/README.md` before changing source.

For Codex OS, batch-train, or long-run governance work, additionally read:

- `.codex/state/active-batch.yml` before any write, and re-read it before updating train-state files
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/MCP_LOCAL_PRODUCTION_OS_PLAN.md` when local MCP tooling matters
- `docs/codex/MCP_CODEX_SETUP.md` when configuring or verifying local MCP tooling
- `docs/codex/MCP_EXTERNAL_SERVER_SETUP.md` when external MCP registration matters
- `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md` when GitHub MCP, Dependabot, CodeQL, Actions, or runner setup matters
- `docs/codex/CODEX_OS_INDEX.md`
- `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` when the active model tier, Mini/Senior alias, or autonomous batch-train continuation matters
- `docs/codex/MODEL_TIER_BATCH_MATRIX.md` when classifying remaining batch families for Mini/Senior routing
- `.codex/README.md`
- the selected route or batch manifest

For `resume global batch train`, immediately read `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`, `.codex/state/active-batch.yml`, `docs/codex/POST_BATCH_GATE_REGISTRY.md`, and the EFC overlay files before continuing from repo evidence. If the Ambitions Repo MCP is configured, call `get_active_batch`, `summarize_repo_posture`, and `get_efc_overlay_status` before edits.

For `resume mini global batch train`, immediately read `docs/codex/RESUME_MINI_GLOBAL_BATCH_TRAIN.md`, `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`, `docs/codex/MODEL_TIER_BATCH_MATRIX.md`, `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`, `.codex/state/active-batch.yml`, `docs/codex/POST_BATCH_GATE_REGISTRY.md`, and the EFC overlay files. Mini may execute bounded batches, but must defer or stop on senior-only gates.

For `resume senior global batch train`, immediately read `docs/codex/RESUME_SENIOR_GLOBAL_BATCH_TRAIN.md`, `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`, `docs/codex/MODEL_TIER_BATCH_MATRIX.md`, `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`, `.codex/state/active-batch.yml`, `docs/codex/POST_BATCH_GATE_REGISTRY.md`, and the EFC overlay files. Senior resolves model-tier deferrals and owns judgment-heavy gates.

## Source-truth rules

- AmbitionsCanon decides product/design direction.
- The active flagship top-level IA is `Today / Goals / Capture / Time / You`.
- `Plan` is not an active top-level destination. It remains valid only as a contextual/action noun, historical reference, or internal compatibility seam.
- The current implementation map decides what is implemented, scaffolded, planned, historical, or unproven.
- The release evidence packet decides validation and release claim language.
- `BATCH_REGISTRY.md` decides operational batch status only.
- `EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`, `BATCH_REGISTRY_EFC_OVERLAY.md`, and `GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md` decide peak proof obligations for unfinished work where compatible with active batch state.
- `POST_BATCH_GATE_REGISTRY.md` decides mandatory continuation gates such as the Post-PK03 Dirty Worktree Reconciliation Gate.
- Historical docs may remain useful, but they do not override the current front-door/status files.
- Do not treat docs-only plans as shipped behavior.
- MCP tool output is repo-derived execution aid, not a replacement for source truth, raw logs, or human/device/release evidence.

## Repo behavior

- Work on `main` only unless the user explicitly requests branch-based work.
- Do not create or switch branches for normal Ambitions execution.
- Preserve completed implementation history as history.
- Preserve XcodeGen. Edit `project.yml` and regenerate the project locally; do not rely on a checked-in `.xcodeproj` as source truth.
- Preserve the native SwiftUI architecture.
- Do not create new top-level Ambitions destinations. The canonical destinations are `Today / Goals / Capture / Time / You`.
- Preserve existing `.plan`, `PlanScreen`, `planNavigation()`, and `Native/Ambitions/Features/Plan/` references only as internal compatibility seams unless a scoped AFI migration batch explicitly changes them.
- Do not reintroduce `Plan` as user-facing top-level IA.
- Do not implement product features in docs/tooling passes unless the tooling itself requires a narrow test or compatibility fix.
- During Codex OS / developer-tooling / governance passes, do not implement app features, refactor SwiftUI source, modify product IA, or add runtime app dependencies.
- Do not add hosted CI unless a future patch explicitly records provider, cost model, billing/quota risk, triggers, artifact retention, owner approval, and release-claim limits.
- Do not treat EFC as approval for hosted AI, user-data servers, telemetry, analytics, productivity scoring, shame/streak mechanics, silent mutation, or release claims.
- Do not add write-capable MCP tools, shell MCP tools, network MCP tools, or secret-reading MCP tools without explicit approval and a security review.
- Do not add GitHub write MCP tools, hosted CI workflows, signing automation, App Store upload automation, or self-hosted runners without the policy gates in `docs/codex/GITHUB_NATIVE_TOOLING_POLICY.md`.

## Architecture boundaries

- `Native/Ambitions/App` owns app entry, dependency container, environment injection, shell, and routing.
- `Native/Ambitions/Domain` owns domain models, contracts, state machines, receipts, proof, recommendation, and planning logic.
- `Native/Ambitions/Services` owns service protocols and implementations.
- `Native/Ambitions/Persistence` owns SwiftData persistence.
- `Native/Ambitions/Features` owns feature UI for Today, Goals, Capture, Time, You, and owned secondary surfaces.
- `Native/Ambitions/Features/Plan` currently remains the internal compatibility owner for the user-facing Time surface until a scoped route/file migration lands.
- `Native/Ambitions/UI`, `Sources/`, and `AppUI/Sources` own shared UI and package surfaces.
- `project.yml` is the XcodeGen source of truth for targets, schemes, app extensions, and build wiring.
- `tools/mcp/` owns local developer MCP tooling only. It must not be referenced by production app targets.

## Execution rules

- Start non-trivial work by checking repo status, current docs, active batch state, post-batch gate registry, and the target code paths.
- Use the smallest safe touch budget. Name primary files before edits.
- Prefer deterministic, additive, compatibility-safe changes.
- Do not silently rewrite product strategy, IA, naming, release posture, or roadmap structure.
- Do not invent seams or claim implementation without repo evidence.
- Do not add runtime app dependencies unless the dependency policy permits it and the user explicitly accepts the tradeoff.
- After meaningful app-source changes, run `xcodegen generate` and the relevant local build/test/scan pack when local tooling supports it.
- For docs-only cleanup, do not claim build/test success unless current local logs exist.
- Validation summaries must separate verified, failed, not verified, and human/device follow-up.
- Keep release claims conservative. Do not claim device verification, accessibility verification, TestFlight readiness, App Store readiness, release readiness, CI proof, or legal/privacy approval without matching evidence.
- Use repo-local Codex operating docs and scripts under `.codex/`, `docs/codex/`, `scripts/ai/`, and `tools/mcp/` only as operating context; they do not override source code, raw logs, current implementation status, or release evidence status.
- When using a Mini-tier or unknown-tier model, follow `docs/codex/MODEL_TIER_EXECUTION_POLICY.md` and `docs/codex/MODEL_TIER_BATCH_MATRIX.md`. Mini is execution-only for bounded batches; senior-only gates must be deferred or stopped, not guessed through.
- After EFC insertion, every batch report must state EFC applicability: invoked, not applicable, or accepted Yellow with owner.
- If the Ambitions Repo MCP is configured, use it to preflight active batch, EFC applicability, changed-file impact, and forbidden claims before closeout.
- After PK03 closes, run `bash scripts/codex-post-pk03-dirty-reconciliation.sh` before continuing the global train. Exit code `86` blocks continuation until dirty files are classified.

## Local validation

Primary validation remains local VM/Mac validation:

- `xcodegen generate`
- `./scripts/build-local.sh`
- focused `xcodebuild` unit tests
- focused `xcodebuild` UI tests
- unsigned archive sanity checks when relevant
- raw command logs saved under `output/logs/`, `.codex/logs/`, or a named local proof packet

Local MCP validation:

- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`
- optional: `python3 -m pytest tools/mcp/ambitions_repo_mcp/tests` when pytest is available
- `python3 tools/mcp/ambitions_proof_mcp/server.py --self-test`
- optional: `python3 -m pytest tools/mcp/ambitions_proof_mcp/tests` when pytest is available

Local dirty-worktree gate:

- `bash scripts/codex-post-pk03-dirty-reconciliation.sh`

Local simulator evidence is not signed archive proof, TestFlight proof, App Store proof, physical-device proof, public accessibility proof, legal/privacy signoff, or human release approval.

## Ambitions product truth

- Ambitions is a premium native iPhone app for turning long-term goals into grounded daily execution.
- Core loop: `Capture -> Place -> Shape Time -> Do Today -> Close / Recover -> Save Proof`.
- Ambitions is not a generic task app, calendar clone, habit tracker, productivity score app, chatbot, AI wrapper, dashboard, or SaaS admin panel.
- User-facing language should follow AmbitionsCanon first.
- Avoid fake precision, fake certainty, AI theater, shame language, and silent automation.

## Batch train rule

For multi-batch execution, use `docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md`, `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`, `.codex/reports/current-batch-train-state.md`, `.codex/state/active-batch.yml`, `docs/codex/POST_BATCH_GATE_REGISTRY.md`, `docs/codex/MODEL_TIER_EXECUTION_POLICY.md`, `docs/codex/MODEL_TIER_BATCH_MATRIX.md`, the EFC overlay files, and the selected manifest under `docs/codex/batch-trains/`.

Continue automatically through Green and accepted Yellow only when owner, safety reason, no-claim boundary, and applicable post-batch gates are recorded. Hard Red stops. Mini may additionally defer non-blocking senior-only batches to `docs/codex/MODEL_TIER_DEFERRAL_LEDGER.md`; Senior must resolve blocking deferrals before closeout.

After EFC00, continuation also requires an EFC applicability note for every batch that touches user-facing behavior, user data, intelligence, source/freshness, side effects, accessibility, performance, release posture, or public claims.

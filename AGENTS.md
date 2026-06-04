# Ambitions Agent Contract

Status: Active repo front-door guidance
Audience: Codex, ChatGPT, GitHub agents, and any AI contributor touching this repository
Last major canon refresh: 2026-06-03
Purpose: Route agents to the right authority, prevent stale-canon work, preserve proof honesty, and keep Ambitions on a premium local-first native iPhone product path.

This file is not implementation proof, validation proof, release proof, product completeness proof, or a roadmap. It is the standing operating contract for agents.

If this file conflicts with `docs/truth/*`, the truth files win. If any lower-level doc conflicts with this file and the truth files are silent, this file wins until `docs/truth/*` is updated.

---

## 1. Non-negotiable Ambitions identity

Ambitions is a premium native iPhone-first Personal Life Operating System.

It is not a task manager, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

The active product standard is a polished local-first flagship iPhone experience: quiet luxury, inspectable intelligence, durable trust, privacy-first operation, recovery-aware execution, and no weak v1-feeling seams.

The current product moat is the Private Life Runtime: a local-first intelligence layer that converts goals and intent into personalized, inspectable, capacity-aware daily steps, then adapts execution through time reality, closure, proof, and recovery.

Agents must optimize for:

- native iPhone-first product quality
- local-first/on-device-first behavior unless active truth files explicitly allow otherwise
- Apple-native iCloud/CloudKit continuity before custom server infrastructure
- deterministic, inspectable intelligence before AI theater
- proof-backed claims only
- premium SwiftUI polish, accessibility, motion restraint, and interaction depth
- clean repo authority hierarchy
- safe autonomous Codex execution through the Ambitions runner

---

## 2. Current active product canon

Top-level IA is exactly:

`Today / Goals / Time / Motion / You`

Global action:

`Capture`

Primary objects:

- Today -> Reality Meridian / Start Here
- Goals -> Constellation Atlas
- Time -> LifeShape Field / Time Texture
- Motion -> Motion Current
- You -> User System Profile
- Global Capture -> Atmosphere Composer

Allowed active tab names are only `Today`, `Goals`, `Time`, `Motion`, and `You`.

`Capture` is the global Atmosphere Composer/action layer, not a tab. Capture is not an inbox, notes feed, plus-tab utility, chatbot, generic intake dashboard, or persistent floating button. Capture access must use contextual surface-native entry points first, a quiet toolbar Capture fallback as the consistent escape hatch, and an activated bottom composer seam only after Capture is invoked.

`Motion` replaces `Pulse` as the approved fifth tab name. `Pulse` is prior working-name / historical context only, may appear only as stale source context or a cleanup target, and must not be treated as active product truth.

The old IA `Today / Goals / Capture / Time / You` is superseded prior canon. It may appear only as stale current repo/source state, historical context, or a migration target; it must not appear as active product truth.

`Plan` is not an active user-facing top-level destination. Preserve existing `PlanScreen`, `.plan`, `planNavigation()`, and `Native/Ambitions/Features/Plan/` references only as internal compatibility seams unless a scoped migration batch explicitly changes them. Never reintroduce `Plan` as top-level IA.

Do not introduce or reintroduce `Plan`, `Review`, `Profile`, `Calendar`, `Inbox`, `Capture`, `Pulse`, or any sixth tab as active top-level IA without explicit active truth-file authority.

Locked user-facing language:

- Use `Start here` for the flagship Today decision object.
- Use `Recommended step`, not `Recommended next move`.
- Use `step`, not `move`, for action items.
- Use `Start now` when launching execution.
- Use `Open step` when opening detail instead of a session.
- Avoid shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

Current flagship product surfaces:

- Today Root / Reality Meridian
- Start Here Surface
- Step Detail
- Step Session
- Action Closure / Recovery
- Goal Detail / Mission Control
- Global Capture / Atmosphere Composer and secondary intake routes
- Time / LifeShape Field
- Motion / Motion Current
- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust
- User System Profile

Do not create new top-level destinations without explicit active truth-file authority.

Surface role guardrails:

- Today is current reality, Start Here, execution, closure, and recovery. It is not a task list.
- Goals is direction, ambition paths, proof, simulations, and goal timelines. It is not a KPI dashboard or ranked life-score surface.
- Time is LifeShape Field / Time Texture. It distinguishes availability from capacity and must not collapse into free/busy calendar language, schedule optimization, productivity scoring, calendar-density scores, AI scheduling scores, or resource-allocation jargon.
- Motion is Motion Current: proof, progress, and inspection. It must not become analytics, XP, activity feed, dashboard, score, streak, productivity report, generic progress chart, social timeline, dashboard card stack, or shame/guilt surface.
- You is the context hub and user-model governance surface. It is not generic settings, a social profile, or an admin panel.

---

## 3. Current architecture canon

Core intelligence must be local-first and deterministic through the Private Life Runtime / Intelligence Kernel.

External/cloud LLMs are not part of the core product architecture. They may only exist, if ever, as optional user-controlled extensions outside core behavior. Do not introduce a required cloud AI dependency, AI SDK, hosted inference path, telemetry-driven intelligence loop, or server-side planning runtime unless active truth files explicitly authorize it.

Pre-launch backend posture:

- Favor local-first durable data and Apple-native continuity.
- Use CloudKit/iCloud continuity before custom server/account infrastructure unless active truth files change this posture.
- Do not assume a custom production server is required for launch.
- Follow Apple-native and repo-owned local tooling first. Do not add new runtime dependencies without explicit approval and recorded policy gates.
- Do not add analytics SDKs, telemetry SDKs, crash-reporting SDKs, backend SDKs, tracking, hosted CI, server dependencies, external AI infrastructure, or paid services without explicit separate approval and recorded policy gates.
- Preserve privacy manifest honesty.
- Preserve migration safety, durable operation/receipt handling, basic diagnostics, and release proof boundaries.

Runtime/product behavior must support the moat proof:

- same intent can produce different daily plans for different users
- execution is grounded in schedule, capacity, protected time, evidence, and user-owned constraints
- adaptation happens locally as reality changes
- closure/recovery changes future recommendations without shame
- Start Here receipts explain why a recommendation was made
- relaunch/replay preserves proof and continuity

Do not claim this behavior is complete unless live source, tests, and proof artifacts demonstrate it.

Screenshots are proof artifacts, and screenshot baselines are review contracts. Do not silently bulk-update screenshot baselines, visual baselines, or snapshot fixtures to make failures disappear. Any baseline update must identify the product reason, affected surfaces, current build/source evidence, and remaining visual/accessibility proof gaps.

---

## 4. Active authority hierarchy

Start every non-trivial repo task from the truth files.

Mandatory read order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`
13. relevant source, tests, scripts, build docs, status docs, and proof artifacts
14. relevant `.codex` / `.agents` files only after truth files

Supporting but subordinate material:

- `docs/AmbitionsCanon/`
- `docs/status/`
- `docs/codex/`
- `.codex/`
- `.agents/`
- historical batch-train, audit, handoff, and closeout material

`.codex/REPO_INVENTORY.md` is a routing index, not product truth or proof.

Older Ambitions 3.0/4.0, PXOS, SI, FCP/PFC/AOS/LDI, handoff, audit, and historical prompt material may be useful only where compatible with the truth files. It must not override active truth.

---

## 5. Repo behavior rules

Default branch behavior:

- Work on `main` only unless the user explicitly requests a branch or PR.
- Do not create or switch branches for normal Ambitions execution.
- Preserve completed implementation history as history.
- Keep generated run artifacts out of commits unless a task explicitly requires them.
- Do not commit `.codex/runs/` noise by default.

Project structure rules:

- Preserve XcodeGen.
- Edit `project.yml` and regenerate locally; do not treat checked-in `.xcodeproj` as source truth.
- Preserve native SwiftUI architecture.
- Do not add runtime app dependencies during docs/tooling/governance passes.
- Do not implement product features in docs-only or Codex OS passes unless a narrow test/compatibility fix is required.
- Do not refactor SwiftUI source during Codex OS/developer-tooling/governance passes unless explicitly scoped.

Architecture ownership:

- `Native/Ambitions/App` owns app entry, dependency container, environment injection, shell, and routing.
- `Native/Ambitions/Domain` owns domain models, contracts, state machines, receipts, proof, recommendation, planning, and private runtime logic.
- `Native/Ambitions/Services` owns service protocols and implementations.
- `Native/Ambitions/Persistence` owns SwiftData persistence and local durability.
- `Native/Ambitions/Features` owns feature UI for Today, Goals, Time, Motion, You, global Capture, and secondary owned surfaces.
- `Native/Ambitions/Features/Plan` remains an internal compatibility owner for the user-facing Time surface until a scoped migration changes it.
- `Native/Ambitions/UI`, `Sources/`, and `AppUI/Sources` own shared UI/package surfaces.
- `tools/mcp/` owns local developer MCP tooling only; it must not be referenced by production app targets.

---

## 6. Ambitions runner rule

The canonical batch runner is:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

or:

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

Ambitions implementation, source-changing work, Codex OS, repo cleanup, architecture, UI, product, and batch-train prompts must run through the runner unless the user explicitly says:

`bypass the Ambitions runner`

Any Ambitions runner-compatible prompt must include this header:

```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

If a prompt is pasted directly without the header:

1. Save it under `prompts/batches/<BATCH_ID>.md` when the batch ID is clear, or `prompts/inbox/` when unclear.
2. Add the required runner header.
3. Route it through the runner.
4. Do not execute it directly unless the user explicitly bypasses the runner.

If the requested work is governance/docs-only, keep the runner posture docs/governance scoped and do not let the batch imply app behavior changed. If the requested work changes source, tests, project files, scripts, package manifests, runtime behavior, user data, or product surfaces, treat it as source-changing and use the full Ambitions runner path plus the required guards unless the user explicitly bypasses the runner.

Bounded Codex self-healing authority:

- Codex may repair Yellow-safe repo-OS/process/metadata blockers and continue in the same run only when `docs/truth/CODEX_PROCESS_TRUTH.md` classifies the blocker as self-healable.
- Yellow-safe repairs are limited to `.codex/**`, runner/process docs, active-batch metadata, guard/owner/concept-lock/coverage registries, `docs/codex/**`, `scripts/ambitions-codex-train.sh`, and the named guard/coverage scripts.
- Self-heal must preserve canonical-owner coverage, the parallel implementation guard, concept-lock protections, post-change guard blocking, direct-main rules, and no-readiness-claim discipline.
- Codex must stop for Red-class blockers, including guard weakening, product canon ambiguity, app source/test changes outside scope, locked source changes without owner authority, privacy/security/release implications, unsafe repo state, direct-main conflict, or any need to alter product truth.
- Self-heal does not authorize app source changes, app test changes, product truth changes, release claims, TestFlight/App Store claims, accessibility claims, device claims, or app behavior changes outside the current issue.

For serious Ambitions work, assume the operating sequence:

`GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch by default, falling back to GPT-5.4-mini only when Spark usage is exhausted -> GPT-5.5 review/repair/final commit`

The planning/review model owns source-truth, canon, architecture, release-claim, and final commit eligibility. The bounded patch model may implement only the approved patch scope. Spark is the default bounded patch model. GPT-5.4-mini is a fallback bounded patch model only when Spark usage is exhausted, not a quality downgrade path for judgment-heavy work.

Do not use stale model-tier names from older docs as current truth unless `docs/truth/CODEX_PROCESS_TRUTH.md` explicitly requires them for compatibility.

---

## 7. Batch train and resume rules

Before any batch execution or continuation, inspect:

- `docs/truth/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `.codex/state/active-batch.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- active EFC overlay files when applicable
- current repo status and dirty worktree state

For `resume global batch train`, immediately inspect:

- `docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md`
- `.codex/state/active-batch.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- EFC overlay files
- current batch reports and train-state files

For model-tiered train work, follow the active truth files and current model-tier policy docs. Do not guess through senior-only gates. Defer or stop where the current policy requires it.

Continuation is allowed only through Green and accepted Yellow states where owner, safety reason, no-claim boundary, validation posture, and post-batch gates are recorded. Hard Red stops.

Every batch that touches user-facing behavior, user data, intelligence, source/freshness, side effects, accessibility, performance, release posture, or public claims must state EFC applicability: invoked, not applicable, or accepted Yellow with owner.

## 7A. Ambitions Local Repo Intelligence

Primary iOS 26 execution path:

- Use `scripts/ios26-flagship-run-sequential.sh` for iOS 26 train execution unless explicitly directed otherwise.

Use local repo-intelligence tools only as advisory developer tooling.

Preference order:

1. Resolve active truth and batch boundary from repo docs, manifest, and runner.
2. Use CodeGraph, when available, for symbol context, callers/callees, impact, trace, affected-test hints.
3. Use Semble, when available, for fast code/docs/config snippet retrieval.
4. Use direct file reads, grep, validation scripts, and tests to verify important findings.
5. Use Understand Anything only for optional human-facing architecture/onboarding maps, never as proof.

Never commit `.codegraph/`, `.understand-anything/`, `.codex/local-indexes/`, `.codex/repo-intelligence/tools/`, or generated graph/dashboard artifacts.

Never use these tools to approve Green, release readiness, privacy proof, accessibility proof, or app behavior claims.

---

## 8. Validation and proof rules

Primary validation remains local VM/Mac validation unless active truth files specify otherwise.

Expected local validation options:

- `xcodegen generate`
- `./scripts/build-local.sh`
- focused `xcodebuild` unit tests
- focused `xcodebuild` UI tests
- unsigned archive sanity checks when relevant
- repo scan/claim-scan scripts when relevant
- raw logs saved under `output/logs/`, `.codex/logs/`, or a named proof packet

Local MCP validation options:

- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`
- `python3 -m pytest tools/mcp/ambitions_repo_mcp/tests` when pytest is available
- `python3 tools/mcp/ambitions_proof_mcp/server.py --self-test`
- `python3 -m pytest tools/mcp/ambitions_proof_mcp/tests` when pytest is available

Dirty-worktree gate:

- `bash scripts/codex-post-pk03-dirty-reconciliation.sh`

If `xcodebuild` tests are blocked, disabled, or skipped by runner configuration, the closeout must explicitly say so and must not imply test coverage was proven. A disabled or non-blocking test path is Yellow at best for release proof.

Local simulator evidence is not signed archive proof, TestFlight proof, App Store proof, real-device proof, public accessibility proof, legal/privacy signoff, or human release approval.

Never claim:

- build success without current logs
- test success without current logs
- accessibility verification without actual accessibility proof
- performance verification without measured evidence
- privacy/legal approval without reviewed artifacts
- TestFlight/App Store readiness without matching release evidence
- release readiness without current release proof
- CI proof when validation is local-only
- product behavior completion from docs-only changes
- screenshot or visual approval from stale screenshots, missing screenshots, or silent baseline updates

Validation summaries must separate:

- Verified
- Failed
- Not verified
- Blocked
- Human/device follow-up

Green / Yellow / Red reporting posture:

- Green only when the scoped change is complete, the changed-file boundary is clean, required validation passed or is explicitly not applicable, and no proof/release/implementation overclaim is present.
- Yellow when the scoped change is correct but validation, nested authority cleanup, visual proof, accessibility proof, device proof, or another non-blocking evidence item remains incomplete and is clearly owned.
- Red when forbidden files changed, active product truth is wrong, old IA or Pulse is presented as current truth, a runner/source-changing gate is bypassed without explicit user instruction, or implementation/release/readiness claims are made without proof.

---

## 9. UI, design, and product quality rules

Ambitions UI must feel like a premium native Apple-quality iPhone app, not a web dashboard inside SwiftUI.

Default visual/product direction:

- 70% Apple quiet luxury
- 20% on-device intelligence / inspectable reasoning
- 10% executive command clarity
- graphite/warm dark palette
- restrained celestial orientation
- calm, alive, focused, and native

Do not ship or propose:

- generic stacked cards as the top-level design language
- dashboard tile grids
- chatbot-first UI
- calendar-clone UI
- generic task-list hierarchy
- ornamental AI badges without proof
- noisy gamification
- streak/shame mechanics
- fake productivity scoring
- ungrounded automation
- silent plan mutation

Top-level surfaces should follow one-primary-object discipline.

Reality Meridian / Start Here is the flagship daily decision object. It must connect recommendation, current time reality, capacity, goal thread, proof, source freshness, trust receipts, and closure/recovery state. It must not degrade into a generic task card.

Global Capture remains composer-driven and minimal. Secondary intake triage belongs in drill-downs, not as the default Capture experience, and Capture must not become a tab, inbox, notes feed, plus-tab utility, chatbot, or persistent floating button.

Time is LifeShape Field / Time Texture, not a generic calendar clone, free/busy calendar, schedule optimizer, productivity-scoring surface, or resource-allocation surface.

Motion is Motion Current, an inspectable proof/progress surface. It is not analytics, a feed, XP, a score, a streak system, a productivity report, a generic progress chart, or a dashboard.

You uses an iOS Settings-style User System Profile posture with grouped navigation and trust controls.

All UI changes require accessibility, Dynamic Type, VoiceOver order, Reduce Motion, and preview/snapshot consideration according to active truth and relevant gates.

---

## 10. Safety, privacy, and dependency stop rules

Hard Red stop conditions:

- introducing required cloud AI/LLM infrastructure for core behavior
- introducing analytics/tracking SDKs without explicit approval
- introducing backend/server/account infrastructure without active truth authority
- weakening privacy claims or privacy manifest honesty
- adding hosted CI, signing automation, App Store upload automation, or self-hosted runners without policy gates
- adding write-capable MCP, shell MCP, network MCP, secret-reading MCP, GitHub-write MCP, or production-affecting MCP tools without explicit approval and security review
- making release, accessibility, privacy, device, TestFlight, App Store, CI, or legal claims without evidence
- treating historical docs as active authority over truth files
- reintroducing `Plan` as user-facing top-level IA
- reintroducing `Capture` as user-facing top-level IA
- reintroducing `Pulse` as current tab truth instead of prior working-name / historical context
- introducing `Review`, `Profile`, `Calendar`, `Inbox`, or any sixth tab as top-level IA
- converting Ambitions into a generic productivity app, dashboard, chatbot, or calendar clone
- collapsing Motion into analytics, activity feed, XP, score, streak, productivity report, generic progress chart, social timeline, dashboard card stack, or shame/guilt surface
- collapsing Time into free/busy calendar language, schedule optimization, productivity scoring, calendar-density scores, AI scheduling scores, or resource-allocation jargon
- adding runtime dependencies, telemetry, analytics, crash SDKs, hosted services, or paid services without explicit separate approval
- silently bulk-updating screenshot or visual baselines
- mutating user data silently or without inspectable receipts
- deleting historical material without following `docs/truth/HISTORICAL_POLICY.md`

If a hard stop is hit, stop, record the reason, identify the smallest safe next step, and do not patch around it.

---

## 11. MCP and tooling boundaries

The local Ambitions Repo MCP under `tools/mcp/ambitions_repo_mcp/` is optional read-only Codex tooling for active-batch, EFC, source-truth, claim-scan, closeout, and changed-file impact checks. It is not an app dependency.

The local Ambitions Proof MCP under `tools/mcp/ambitions_proof_mcp/` exposes allowlisted validation names only. It is not a generic shell and must not gain write, network, secrets, signing, App Store, hosted CI, or git mutation tools without explicit approval.

MCP output is repo-derived execution aid, not a replacement for source truth, raw logs, release evidence, or human/device proof.

---

## 12. Closeout standard

Every non-trivial agent closeout must include:

- files changed
- why the change was needed
- active truth files inspected
- validation run, with raw command names
- validation not run, with reason
- proof/claim boundaries
- risks or Yellow items
- rollback notes
- next eligible batch or gate, when relevant

For docs-only updates, say docs-only. Do not imply app behavior changed.

For source changes, include build/test status and relevant evidence.

For UI changes, include preview/snapshot/visual proof status, accessibility status, and what remains unverified.

For repo cleanup, classify touched material as active, supporting, historical, obsolete, archive-candidate, or delete-candidate when relevant.

---

## 13. Practical first question for every agent

Before touching files, ask internally:

"What should a fresh Codex session believe before touching this repo, and which active truth file proves that?"

If the answer is unclear, inspect truth files and source evidence before editing.

If the requested change would make a fresh agent believe the wrong thing about product canon, architecture, validation, release posture, or authority hierarchy, do not make the change as requested. Propose the safe correction instead.

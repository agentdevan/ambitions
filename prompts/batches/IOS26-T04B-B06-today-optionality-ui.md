<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04B-B06 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04B-B06`

## Train ID and title
`TRAIN_04B` - Step Optionality, Rejection Replanning & Simulation Proof

## Batch role in train
Batch 6 of 6 in TRAIN_04B

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`

## Downstream dependencies
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_10`

## Objective
Expose optionality in Today without making Today feel like a chooser dashboard.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Today optionality must not expose sensitive rejection reasons to logs, widgets, share extension, App Intents, or external snapshots. Learning remains local and inspectable.

## Accessibility constraints
VoiceOver order must keep Reality Meridian, Start Here, optionality action, impact, approval, and receipt coherent. Dynamic Type must not overlap controls. Reduce Motion must preserve before/after relationship without animation dependency. Pressure meaning cannot be color-only.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns step candidate generation, rejection learning, and simulation loops.
- `today_root` may present optionality in Today only by extending `Native/Ambitions/Features/Today`, not by creating a detached Start Here/Today owner.

## Allowed files/directories
- Add Today optionality UI for "Not this", "Show another", "Why not this?", alternatives, impact, approval, and receipt.
- Add focused replacement sheet limited to 3-5 alternatives.
- Preserve Reality Meridian dominance and Start Here primacy.
- Add VoiceOver, Dynamic Type, Reduce Motion, contrast, and no-color-only pressure behavior.
- Add tests, previews, snapshots where available, and `build/reports/step-optionality/today-optionality-ui.md`.
- Close the train with `build/reports/step-optionality/TRAIN_04B_CLOSEOUT.md` only when all prior proof exists.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no opaque recommendation engine
- no "AI confidence" consumer language
- no hidden profiling
- no external analytics dependency
- no top-level IA changes
- no generic dashboard
- no sensitive context in logs
- no task marketplace
- no generic option list page
- no Reality Meridian regression into card stack

## Exact implementation steps
1. Re-read active truth files and confirm B01-B05 proof.
2. Inspect Today, Reality Meridian, Start Here, Trust Seam, receipt, and design-system source.
3. Add secondary optionality actions without changing top-level IA.
4. Add compact reason sheet and focused replacement sheet.
5. Show timeline impact before approval and receipt after approval.
6. Preserve original recommendation inspectability.
7. Add previews, UI tests, accessibility checks, and closeout proof.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/step-optionality/today-optionality-ui.md`
- `build/reports/step-optionality/TRAIN_04B_CLOSEOUT.md`
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: Today presents alternatives, updates recommendation after rejection/approval, shows impact before approval, shows receipt after approval, preserves Reality Meridian, and train closeout exists.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: Today becomes a generic option list, impact is hidden, receipt missing, accessibility unaddressed, or silent mutation occurs.

## Rollback behavior
Rollback only files touched by IOS26-T04B-B06 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
Today optionality proof:
Train closeout:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next eligible train:
```

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04B-B06 - Today optionality UI

## Objective
Expose optionality in Today without making Today feel like a chooser dashboard.

## Why this exists
Start Here must show the best step first while offering "Not this" and "Show another" as calm secondary actions. Alternatives must appear in a focused replacement sheet with timeline impact before approval, not as a marketplace or generic option list.

## Dependencies
IOS26-T04B-B01, IOS26-T04B-B02, IOS26-T04B-B03, IOS26-T04B-B04, IOS26-T04B-B05, TRAIN_05 handoff, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
- Runtime
- Recommendation engine
- Goal compiler
- Today
- Time
- Goals
- You
- Persistence
- Receipts
- Replay
- Services
- Sources/Theme
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `build/reports/step-optionality/`
- `build/reports/reality-meridian/`

## Exact changes allowed
- Add Today optionality UI for "Not this", "Show another", "Why not this?", alternatives, impact, approval, and receipt.
- Add focused replacement sheet limited to 3-5 alternatives.
- Preserve Reality Meridian dominance and Start Here primacy.
- Add VoiceOver, Dynamic Type, Reduce Motion, contrast, and no-color-only pressure behavior.
- Add tests, previews, snapshots where available, and `build/reports/step-optionality/today-optionality-ui.md`.
- Close the train with `build/reports/step-optionality/TRAIN_04B_CLOSEOUT.md` only when all prior proof exists.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no opaque recommendation engine
- no "AI confidence" consumer language
- no hidden profiling
- no external analytics dependency
- no top-level IA changes
- no generic dashboard
- no sensitive context in logs
- no task marketplace
- no generic option list page
- no Reality Meridian regression into card stack

## Required Today behavior
- Start Here shows the best step first.
- Secondary action: "Not this" or "Show another."
- Rejection opens compact reason sheet.
- Alternatives appear as a focused replacement sheet, not a list page.
- Alternatives show deadline impact plainly.
- User chooses one step.
- Today updates after approval.
- Receipt appears calmly.
- Original recommendation remains inspectable.

## Required alternative labels
- Best fit
- Lighter
- Shorter
- No equipment
- Keeps deadline
- Adds pressure
- Needs review

## UI rules
- Do not turn Today into a task marketplace.
- Show 3-5 alternatives maximum at once.
- Keep Reality Meridian dominant.
- Keep Start Here primary.
- Move depth behind disclosure.
- Preserve VoiceOver order.
- Provide Reduce Motion behavior.
- No color-only pressure meaning.

## Implementation steps
1. Re-read active truth files and confirm B01-B05 proof.
2. Inspect Today, Reality Meridian, Start Here, Trust Seam, receipt, and design-system source.
3. Add secondary optionality actions without changing top-level IA.
4. Add compact reason sheet and focused replacement sheet.
5. Show timeline impact before approval and receipt after approval.
6. Preserve original recommendation inspectability.
7. Add previews, UI tests, accessibility checks, and closeout proof.

## Tests to add/update
- Today can present alternatives.
- Rejecting a step updates visible recommendation.
- Impact appears before approval.
- Receipt appears after approval.
- Reality Meridian does not regress into a card stack.
- VoiceOver order, Dynamic Type, Reduce Motion, and no-color-only pressure behavior have proof.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/step-optionality/today-optionality-ui.md`
- `build/reports/step-optionality/TRAIN_04B_CLOSEOUT.md`

## Accessibility requirements
VoiceOver order must keep Reality Meridian, Start Here, optionality action, impact, approval, and receipt coherent. Dynamic Type must not overlap controls. Reduce Motion must preserve before/after relationship without animation dependency. Pressure meaning cannot be color-only.

## Privacy/local-first requirements
Today optionality must not expose sensitive rejection reasons to logs, widgets, share extension, App Intents, or external snapshots. Learning remains local and inspectable.

## iOS 26 API verification requirements
Any iOS 26 UI, sheet, motion, material, or accessibility API usage must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: Today presents alternatives, updates recommendation after rejection/approval, shows impact before approval, shows receipt after approval, preserves Reality Meridian, and train closeout exists.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: Today becomes a generic option list, impact is hidden, receipt missing, accessibility unaddressed, or silent mutation occurs.

## Rollback strategy
Rollback only files touched by IOS26-T04B-B06 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
Today optionality proof:
Train closeout:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next eligible train:
```
----- END ORIGINAL PROMPT -----

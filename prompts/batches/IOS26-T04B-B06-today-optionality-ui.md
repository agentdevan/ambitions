<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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

<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04C-B06 - Source Atlas You inspection surface

## Objective
Expose Source Atlas bridge trust in You without creating an admin console.

## Why this exists
Users must be able to inspect what Goal Knowledge Ambitions used, why it was used, source/freshness/risk state, whether it affected runtime, whether review is needed, and how to correct it where supported.

## Dependencies
IOS26-T04C-B01, IOS26-T04C-B02, IOS26-T04C-B03, IOS26-T04C-B04, IOS26-T04C-B05, TRAIN_09, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- Runtime
- Recommendation engine
- Goal compiler
- Today
- Goals
- Time
- You
- Capture promotion
- Persistence
- Receipts
- Replay
- Services
- Native/AmbitionsTests
- Native/AmbitionsUITests
- Preview fixtures
- `tools/source-atlas/`
- `docs/codex/SOURCE_ATLAS_*.md`

## Exact changes allowed
- Add You -> What Ambitions Knows -> Source Atlas & Goal Knowledge inspection requirements.
- Add sections for Goal Knowledge Sources, Active Source Packs, Needs Review, Unsupported Goal Areas, Recent Goal Compilations, Path Sources, Step Sources, Corrections, and Replay Receipts.
- Add correction/review paths where supported.
- Add tests, previews, accessibility checks, and `build/reports/source-atlas-runtime-bridge/you-inspection-surface.md`.
- Close the train with `build/reports/source-atlas-runtime-bridge/TRAIN_04C_CLOSEOUT.md` only when all prior proof exists.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no unsupported professional advice
- no hidden expert system claims
- no source pack overclaim
- no stale source use without review
- no demographic templates
- no top-level IA changes
- no external analytics dependency
- no sensitive data in logs
- no admin-console posture

## Required placement
You -> What Ambitions Knows -> Source Atlas & Goal Knowledge

## Required visible sections
- Goal Knowledge Sources
- Active Source Packs
- Needs Review
- Unsupported Goal Areas
- Recent Goal Compilations
- Path Sources
- Step Sources
- Corrections
- Replay Receipts

## Each item must show
- what Ambitions used
- why it was used
- source/freshness/risk state
- whether it affected runtime
- whether review is needed
- edit/correct/review path where supported

## User-facing language
Use:
- Goal Knowledge
- Source
- Needs Review
- Used to Plan
- Not Used
- Based on Older Context
- Correction Saved

Avoid:
- AI model
- hidden intelligence
- confidence score as magic number
- user archetype
- users like you

## Implementation steps
1. Re-read active truth files and confirm B01-B05 proof.
2. Inspect You, trust controls, receipt/replay, and Source Atlas bridge traces.
3. Add grouped inspection requirements without changing top-level IA.
4. Surface stale/unsupported/active source use and correction paths.
5. Ensure sensitive context is excluded from widgets and external surfaces.
6. Add VoiceOver, Dynamic Type, Reduce Motion, and no-color-only state proof where touched.
7. Add proof artifact and train closeout.

## Tests to add/update
- User can inspect Source Atlas usage.
- Stale/unsupported packs are visible.
- Correction path exists.
- Sensitive context is not exposed in widgets/external surfaces.
- VoiceOver, Dynamic Type, and Reduce Motion support is preserved where touched.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04C-B06 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/source-atlas-runtime-bridge/you-inspection-surface.md`
- `build/reports/source-atlas-runtime-bridge/TRAIN_04C_CLOSEOUT.md`

## Accessibility requirements
Inspection rows must preserve VoiceOver order, Dynamic Type layout, Reduce Motion equivalents, and non-color-only source/freshness/risk states.

## Privacy/local-first requirements
Goal Knowledge inspection remains local-first. Sensitive context must not be exposed in widgets, share extension, App Intents, external snapshots, logs, or proof reports.

## iOS 26 API verification requirements
Any iOS 26 UI, settings, accessibility, or persistence API usage must be verified and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: user can inspect Source Atlas usage, stale/unsupported packs are visible, correction path exists, sensitive external exposure is blocked, and touched accessibility support is proven.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: hidden source use, stale/unsupported packs invisible, admin-console drift, sensitive exposure, or missing correction/replay path.

## Rollback strategy
Rollback only files touched by IOS26-T04C-B06 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
You inspection proof:
Train closeout:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next eligible train:
```

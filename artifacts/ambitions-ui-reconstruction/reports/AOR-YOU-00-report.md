# AOR-YOU-00 You Runtime Audit and Deletion Map

## Status

Green for audit/artifact scope. Active You root is proven, the before screenshot is captured, owner files and line excerpts are mapped, and no UI source was modified.

This is audit-only. It does not change app behavior.

## Files Changed

- `prompts/batches/AMB-551.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-before.png`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-00-report.md`

## Why The Change Was Needed

AMB-551 is the deletion-map gate before You reconstruction. The current You root still presents a marketing-card/profile-page baseline: a top User System Profile composition card, a large personal-system hero card, trust/data/setup chips, and local-first prose. Reconstruction must not start until the exact source owners are identified.

## Active Truth Files Inspected

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

## Screenshot Evidence

- `artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-before.png`

Captured from booted simulator `iPhone 17e` (`81485ACD-AF10-4B92-8C03-9BB8805A4A23`) using demo bootstrap, `-AmbitionsInitialSurface you`, medium Dynamic Type, dark appearance, and the AMB-550 app build already installed from `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`.

The screenshot shows:

- top composition card: `User System Profile`, `Trust & Continuity`, `Private`, and `Trust / Data / Setup` chips
- hero card: `Demo User's System`, `You are in control`, `Local-first`, `Trust visible`, `You owns controls`
- prose panel: `Trust is local-first, memory is inspectable, and risky changes require confirmation.`
- profile-page feel from a large personal identity header plus status pills

## Owner Map / Line Excerpts

Active root routing:

- `Native/Ambitions/Features/You/YouScreen.swift:23-47`
  - `YouScreen` renders `TopLevelSurfaceCompositionBar(surface: .you)` and then `PersonalSystemCenterRootView(profileProjection:onOpenDetail:)` when loaded.
- `Native/Ambitions/Features/You/YouScreen.swift:61-83`
  - Root accessibility identifier is `you.screen`; task loads the You dashboard via `featureFactory.youService`.

Top User System Profile marketing-card structure:

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:23-30`
  - `.you` primary object is `User System Profile`.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:33-40`
  - `.you` lead phrase is `Trust & Continuity`.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:63-70`
  - `.you` orientation copy is `Trust, setup, data, preferences, and receipts stay user-controlled.`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:93-105`
  - `.you` supporting module chips are `Trust`, `Data`, `Setup`.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:200-225`
  - `TopLevelSurfaceCompositionBar` renders the composition card and accessibility summary.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:277-290`
  - `.you` chips render through a two-column `LazyVGrid`.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:345-377`
  - `.you` identity block renders lead, primary object, and orientation text.

Your System hero-card structure:

- `Native/Ambitions/Features/You/YouRootSurface.swift:58-71`
  - `PersonalSystemCenterRootView` starts with `PersonalSystemCenterHeader`, sourcing title and dominant truth from `profileProjection.hero`.
- `Sources/Components/PersonalSystemCenterPrimitives.swift:48-69`
  - `PersonalSystemCenterHeader` defaults `controlLabel` to `You are in control` and `trustLabel` to `Local-first`.
- `Sources/Components/PersonalSystemCenterPrimitives.swift:71-143`
  - Header renders a large material panel, icon, `You`, hero `title`, control label, local-first evidence label, summary prose, and signal labels.
- `Native/Ambitions/Features/You/YouFeatureService.swift:244-302`
  - Dashboard projection computes `profileTitle` as `Your System` or `<name>'s System` and builds hero copy, local-first prose, pills, and stats.
- `Native/Ambitions/Persistence/DemoSeedPipeline.swift:29-35`
  - Demo bootstrap sets `userDisplayName = "Demo User"`, which produces `Demo User's System`.

Trust/Data/Setup chips:

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:93-105`
  - Top composition chips are hardcoded for You as `Trust`, `Data`, `Setup`.
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift:286-290`
  - Chips render through `AmbitionChip(..., role: .state)`.

Profile-page feel:

- `Native/Ambitions/Features/You/YouRootSurface.swift:81-88`
  - Explicit `Account & Preferences` bordered button reinforces account/profile posture.
- `Native/Ambitions/Features/You/YouRootSurface.swift:105-149`
  - Seven grouped sections are listed as navigation categories, including account/preferences and support/system.
- `Native/Ambitions/Features/You/YouRootSurface.swift:183-192`
  - Normalized titles convert active items into account/profile-style labels such as `Account & Preferences`, `Planning Defaults`, and `Memory`.
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift:1095-1225`
  - `GroupedNavigationSystem` renders settings-style grouped rows with status pills and chevrons.

Local-first prose panels:

- `Native/Ambitions/Features/You/YouFeatureService.swift:274-302`
  - Hero state includes local-first support text, no-silent-change trust whisper, and context-signal pills.
- `Sources/Components/PersonalSystemCenterPrimitives.swift:105-120`
  - Header renders `Local-first`, `Trust visible`, `You owns controls`, and the hero summary as prominent prose.
- `Native/Ambitions/Features/You/YouFeatureService.swift:1147-1159`
  - About row and system-center footer include `Local-first app status` and setup/history/trust prose.

Generic settings-dump risk:

- `Native/Ambitions/Features/You/YouRootSurface.swift:105-149`
  - Current root has seven grouped navigation sections, many rows, and broad settings categories.
- `Native/Ambitions/Features/You/YouFeatureService.swift:905-1160`
  - Projection emits a large `YouSystemCenterState` with Planning Setup, Memory and Trust, Reviews and Progress, Defaults, System Edges, and Accessibility and Support.
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift:1115-1214`
  - Grouped navigation rows use a reusable settings-list visual model; this is the likely source of generic settings-dump feel if left as the primary You object.

Nonvisual/source summary:

- `Native/Ambitions/Domain/YouModels.swift:927-950`
  - `userSystemProfileInspectionSummary` composes Planning setup, trust controls, local learning, vault, privacy, automation, SourceRecord, Receipt, and ReplayTrace into the root accessibility value.

## Deletion Map / Reconstruction Inputs

Do not delete historical/source code in this audit. For a later scoped reconstruction batch:

- Replace or demote the top `TopLevelSurfaceCompositionBar(surface: .you)` card if the new You root needs one primary iOS Settings-style object rather than a second marketing-style intro card.
- Replace `PersonalSystemCenterHeader` as first primary viewport object with a quieter User System Profile group header or compact account/trust summary.
- Preserve source-backed trust/accessibility text, but relocate it into Settings-style rows or detail sections rather than hero prose.
- Preserve `YouDashboard.userSystemProfileInspectionSummary` or equivalent accessibility summary; do not remove SourceRecord/Receipt/ReplayTrace nonvisual meaning.
- Preserve route coverage for Planning Setup, Trust & Automation, Privacy, Receipts & History, Defaults, Accessibility, and Support, but avoid presenting all categories as a dense first-viewport settings dump.
- Preserve demo data fixture only as preview/demo input; do not let `Demo User's System` drive product copy decisions.

## Validation Performed / Not Performed

Performed:

- `AUTO_BRANCH=0 ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-551 prompts/batches/AMB-551.md`
  - Runner prompt self-heal applied; champion coverage Green; pre implementation guard Green; nested planning stopped on external Codex usage limit before source edits.
- `python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-before.png`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-551 --prompt prompts/batches/AMB-551.md --changed-from 3b10c3973e3bee97c9a83b0acf4246246bcd14b3 --batch-type audit-only`
- `git diff --check`

Not performed:

- Build or test lanes, because no source was modified.
- Manual VoiceOver traversal.
- Real-device validation.
- Performance, privacy/legal, TestFlight, App Store, CI, signed archive, or release readiness validation.

## EFC Flagship Proof Overlay

EFC applicability: invoked as read-only source/screenshot audit for a user-facing You surface. This report proves current baseline ownership and screenshot state only. It is not implementation proof for reconstruction.

## Non-Claims

- No UI behavior changed.
- No You reconstruction started.
- No source files were modified.
- No privacy/local-first claim is accepted as release truth; all such copy is mapped as source text needing later product treatment.
- No accessibility compliance, device proof, performance proof, or release readiness is claimed.

## Risks / Yellow Items

- The current source has valid local-first/trust intent, but the first viewport reads like profile/marketing cards rather than a quiet Settings-style User System Profile.
- The grouped navigation model is useful but risks a generic settings dump if it remains the primary object without stronger hierarchy.
- Later reconstruction must preserve nonvisual trust summaries and route coverage while removing the hero/profile-card feel.

## Rollback Path

- Remove `prompts/batches/AMB-551.md`.
- Remove `artifacts/ambitions-ui-reconstruction/screenshots/you-root-default-before.png`.
- Remove `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-00-report.md`.

No app source rollback is required because no app source was changed.

## Next Eligible Batch

Next eligible issue in the requested sequence: AMB-552.

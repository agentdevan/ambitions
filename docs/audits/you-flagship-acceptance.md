# AMB-1740 You Flagship Acceptance

Status: Implemented Yellow / source acceptance
Date: 2026-07-05
Scope: AMB-1740
Baseline SHA: `40763e51274eb771f42831c3c8f388e4da682aa6`

## Purpose

AMB-1740 accepts the current You flagship surface only at the source and
projection layer. It verifies that You has a real local User System Profile
root, privacy and local-first status, account/sync truth, proof/history/receipt
inspection, settings details, and no-account/offline source boundaries.

This packet does not claim rendered product acceptance, screenshot proof,
accessibility proof, simulator proof, physical-device proof, Visual Green,
Runtime Green, Release Green, or full UI journey proof.

## Truth And Source Inputs

- `AGENTS.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-runtime-contract-engineering/SKILL.md`
- Linear AMB-1740 state
- Current You source under `Native/Ambitions/Surfaces/You`
- Current trust inspection source under `Native/Ambitions/Trust`
- Current local runtime privacy, account, continuity, and receipt source under
  `Native/Ambitions/Core/LocalRuntimeOS`

## Source Acceptance Map

| AMB-1740 criterion | Current source evidence | Status |
| --- | --- | --- |
| You root / User System Profile | `YouSurface` loads `YouObjectView`; `YouObjectView` renders `UserSystemProfileRootView`; this slice normalizes the first-viewport projection and accessibility copy to `User System Profile`. | Source present and repaired |
| Not a generic settings dump | `UserSystemProfileRootView`, `YouFeatureServiceDashboardProjection`, and `YouFeatureServiceSystemCenterProjection` group privacy, receipts, account state, local data, appearance, Capture, planning defaults, and support as profile status areas instead of one flat settings list. | Source present |
| Privacy/local-first status | `YouTrustCenterSurface`, `YouPersonalVaultSurface`, `YouRootDetailContent.localDataStatusSection`, `PrivacyBoundary`, `PrivacyInspector`, and `LocalOnlyMode` keep local storage, private summaries, protected storage gaps, export limits, and no-silent-write boundaries visible. | Source present |
| Account/sync status where present | `LocalAuthoritativeSyncModel`, `AccountStateMachine`, `AccountBoundary`, `ContinuityAuthorityGate`, and `YouFeatureServiceDashboardProjection.accountSection` keep offline core availability, no-account mode, optional continuity, and private graph sync forbiddance explicit. | Source present |
| Proof/history/receipts detail | `YouRootDetailContent.receiptsHistory`, `YouCrossSurfaceProofReviewProjector`, `YouTrustHistoryProjector`, `ActionReceiptProjection`, `ReceiptInspectionView`, `HistoryInspectionView`, and `InspectionSurface` keep proof, history, receipts, correction state, and undo posture as detail paths. | Source present |
| Settings and preference details | `YouRootDetailContent`, `YouAppearanceStudioSurface`, `YouPreferencesCommandService`, `YouViewModel.commitPreferences`, and detail routes cover appearance, defaults, Capture preferences, notifications, sources, local data, accessibility status, help, and about. | Source present |
| Empty, loading, error, offline, and no-account states | `YouViewModel`, `YouSurface`, `YouRootDetailRouteSurface`, `AsyncViewState`, `DegradedStateSurface`, `LocalOnlySyncCapability`, and `AccountBoundary.resolve(.offlineCoreRuntime)` provide loading/error and local-only/no-account source boundaries. Runtime journey proof was not run. | Source present; runtime proof absent |
| Accessibility source support | `YouAccessibility`, `UserSystemProfileRootView` accessibility identifiers/values, `YouRootDetailRouteSurface`, `InspectionSurface`, and accessibility status rows provide source-level labels and Dynamic Type-oriented wrapping. Manual VoiceOver and Dynamic Type proof were not run. | Source present; accessibility proof absent |

## Source Changes In This Slice

The source edit is intentionally narrow:

- `Local personal system` -> `User System Profile`
- first-viewport subtitle `Personal system and settings` -> `User System Profile`
- root group `Personal system` -> `User System Profile`
- default profile title `Local personal system` -> `User System Profile`
- named profile title `Name's settings` -> `Name's User System Profile`
- dashboard/system-center profile subtitles now foreground privacy, account
  state, receipts, and local inspectability.
- route accessibility copy now says `You detail` and `User System Profile
  detail`, not generic `You settings`.

Touched source paths:

- `Native/Ambitions/Surfaces/You/YouRootSurface.swift`
- `Native/Ambitions/Surfaces/You/YouObjectView.swift`
- `Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceDashboardProjection.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceSystemCenterProjection.swift`

No route, persistence, command, projection ownership, runtime authority, model
case, account boundary, privacy boundary, or repository behavior was changed.

## Proof Ceiling

Claim status: Implemented Yellow.

Allowed claim:

- You has current source and projection evidence for a local User System
  Profile surface with privacy/local-first status, account/no-account truth,
  proof/history/receipt details, settings details, loading/error source states,
  and User System Profile visible/accessibility labels in this slice.

Forbidden claims from this packet:

- Visual Green.
- Runtime Green.
- Interaction Green.
- Release Green.
- Screenshot proof.
- Focused UI journey test proof.
- VoiceOver proof.
- Dynamic Type proof.
- Reduce Motion proof.
- Reduce Transparency proof.
- High Contrast proof.
- Simulator/device proof.
- Offline or no-account journey proof.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: `Surfaces/You`.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: no new architecture debt introduced; screenshot,
  accessibility, device, offline/no-account journey, and full UI journey proof
  remain outside this no-testing source acceptance.
- Next repair train if debt remains: AMB-1744/AMB-1765 for screenshot/device
  proof and AMB-1743/AMB-1766 for accessibility proof.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

You now has source-level evidence for the inspectable trust layer around that
loop: local context and personal vault rows explain what is known, privacy and
account boundaries keep core use local and accountless, receipt/history details
show what changed, and settings details expose the controls without turning You
into a generic settings dump.

## Validation Boundary

No xcodebuild, XCTest, UI test, simulator run, screenshot capture, accessibility
proof, offline walkthrough, no-account walkthrough, or device proof was run
under the current no-testing authorization. Static validation commands are
recorded in the companion JSON packet and Linear closeout.

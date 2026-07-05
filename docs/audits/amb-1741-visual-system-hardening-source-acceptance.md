# AMB-1741 Visual System Hardening Source Acceptance

Status: Implemented Yellow / source acceptance
Date: 2026-07-05
Scope: AMB-1741
Baseline SHA: `aa3eb8dc0cbe62db87ee0131a3f5afb15f0c9155`

## Purpose

AMB-1741 accepts the current visual-system hardening parent only at the source
and static-governance layer. It verifies that retained visual primitives,
tokens, motion/haptic policies, Dynamic Type handling, contrast/fallback
contracts, screenshot-harness gates, and replacement/debt registries are tied to
runtime surfaces instead of preview-only catalogs.

This packet does not claim rendered product acceptance, screenshot proof,
manual accessibility proof, physical-device proof, independent visual approval,
frontend Visual Green, Runtime Green, Release Green, TestFlight readiness, or
App Store readiness.

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
- Linear AMB-1741 state
- `docs/audits/amb-1748-design-system-adoption-proof.md`
- `docs/audits/amb-1749-frontend-evidence-harness.md`
- `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md`
- `docs/audits/amb-1800-design-system-token-primitive-duplicate-inventory.md`
- `docs/audits/frontend-deletion-quarantine-candidates.md`
- current source under `Sources/Theme`, `Sources/Components`,
  `Native/Ambitions/DesignSystem`, `Native/Ambitions/Surfaces`,
  `Native/Ambitions/Composer/Capture`, `Native/Ambitions/Trust`, and
  `Native/Ambitions/Stage`

## Source Acceptance Map

| AMB-1741 criterion | Current source evidence | Status |
| --- | --- | --- |
| Tokens and primitives are used by runtime screens | Today, Goals, Time, You, Capture, and Trust surfaces import `AmbitionsDesignSystem`, read `ambitionTheme`, and route runtime state into retained product-object primitives such as `RealityMeridianView`, `LifeAreaAtlasField`, `LifeShapeFieldView`, `UserSystemProfileRootView`, `CaptureAtmosphereComposer`, and `InspectionSurface`. | Source present |
| Typography, spacing, density, color, materials, and iconography have retained authority | `AmbitionTheme`, generated theme tokens, semantic token catalogs, `PanelDensitySize`, product-object primitives, `AppCard`, `NativeSettingsGroup`, `TagPill`, and status-symbol primitives are used from runtime surfaces and shared components. | Source present |
| Material/chrome choices are centrally constrained | Stage, shell, product-object, and inspection source use theme materials, semantic states, `LivingSurfaceBackground`, `DegradedStateSurface`, `AppCard`, and `SurfaceMorphBackdrop` rather than local one-off chrome ownership. Rendered card density still needs screenshot review before any visual-quality claim. | Source present; rendered proof absent |
| Motion is restrained and honors Reduce Motion | Runtime surfaces and primitives read `accessibilityReduceMotion`; `MotionPrimitives`, `StageMotionReductionPolicy`, `ReduceMotionPolicy`, and surface animations keep reduced-motion hooks source-present. | Source present; manual walkthrough absent |
| Haptics are policy-owned | `AmbitionsHaptics`, `HapticPolicy`, and `ambitionHaptic` route haptic intent through design-system policy instead of ad hoc feedback in the inspected source paths. | Source present |
| Dynamic Type does not rely on fixed preview-only layouts | Today, Goals, Time, You, Capture, trust/receipt primitives, and `PanelDensitySize` read `dynamicTypeSize`, change layout or wrapping at accessibility sizes, and keep minimum-size/tap-target contracts source-present. Manual clipping proof is absent. | Source present; Dynamic Type proof absent |
| Contrast and transparency fallback contracts exist | `SemanticDesignTokenCatalog`, `AmbitionFlagshipSemanticFoundationContract`, `AmbitionNativeChromePolicy`, `ContrastPolicy`, and `ReduceTransparencyPolicy` define non-color meaning, high-contrast fallback, and reduced-transparency contracts. Manual contrast review is absent. | Source present; manual proof absent |
| Visual QA baseline coverage is controlled | AMB-1749 installs the frontend evidence harness and AMB-1750 installs the Visual Green / App Store frontend proof gate. This parent requires those gates before visual/release claims. | Harness and gate present; screenshots not run |
| Replacement list for cheap/prototype primitives exists | AMB-1800 records duplicate design-system authority and removes one low-risk wrapper; `frontend-deletion-quarantine-candidates.md` classifies preview-only assets, historical screenshots, stale labels, proof-limited inspection wrappers, and duplicate/wrapper follow-ups. | Source/debt registry present |
| Screenshot proof exists before Visual Green | AMB-1750 keeps frontend quality Yellow and blocks Green until current screenshots, manual accessibility review, device evidence, and sibling recovery proof exist. | Gate present; Visual Green forbidden |

## Replacement And Debt List

The current replacement list is not a deletion claim. It names the visual-system
hardening debt that remains after this source acceptance:

- Replace historical screenshot and VSP/Figma evidence with current rendered
  screenshot matrix artifacts before any Visual Green claim.
- Keep `Native/Ambitions/PreviewSupport` and preview-only primitives
  quarantined as development assets, not runtime proof.
- Continue collapsing duplicate app-local design-system foundation wrappers only
  through scoped source trains. AMB-1800 removed `AmbitionsLighting`; remaining
  wrappers stay Yellow until each has focused owner proof.
- Keep stale root labels in tests only when they are negative assertions; do not
  cite them as current product surface evidence.
- Prove invocation paths for proof/privacy/receipt inspection wrappers before
  treating them as complete rendered trust journeys.
- Review card density, material/chrome layering, Dynamic Type clipping, contrast,
  and reduced-motion behavior through the screenshot/accessibility lanes before
  promoting any rendered quality claim.

## Source Changes In This Slice

No production Swift source changed in this slice.

Created audit paths:

- `docs/audits/amb-1741-visual-system-hardening-source-acceptance.md`
- `docs/audits/amb-1741-visual-system-hardening-source-acceptance.json`

No route, persistence, command, projection ownership, runtime authority, model
case, design-token authority, package boundary, or repository behavior changed.

## Proof Ceiling

Claim status: Implemented Yellow.

Allowed claim:

- Current source and static governance evidence show that Ambitions visual
  primitives, tokens, motion/haptic policies, Dynamic Type hooks, contrast
  contracts, evidence harnesses, and proof gates are tied to runtime surfaces
  and not only preview catalogs.

Forbidden claims from this packet:

- Visual Green.
- Rendered visual quality.
- Screenshot coverage for a current run.
- Manual VoiceOver proof.
- Dynamic Type screenshot proof.
- Reduce Motion walkthrough proof.
- Reduce Transparency proof.
- Contrast review proof.
- Physical-device behavior.
- TestFlight readiness.
- App Store readiness.
- Release Green.

## Architecture Closeout

- `Final Architecture Tree` inspected: yes.
- Canonical owners touched: none in production source.
- Non-canonical owners touched: none.
- Files moved or created: this audit packet only.
- Old or non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: current rendered screenshots, manual accessibility review,
  independent visual approval, device proof, and duplicate wrapper collapse
  remain outside this no-testing source acceptance.
- Next repair/proof train if debt remains: AMB-1749 screenshot/evidence lane,
  AMB-1750 Visual Green gate completion, AMB-1743 accessibility proof,
  AMB-1744 device proof, and focused AMB-1800 follow-ups for remaining wrapper
  authority.
- No equivalent folder or path interpretation was used.

## Private Life Orchestration Relationship

This work protects:

```text
Intent -> Context -> Path -> Time Fit -> Reflow -> Action -> Proof -> Learning
```

The visual system now has source-level acceptance as a runtime support layer for
that loop: Today, Goals, Time, You, Capture, and Trust details share retained
visual primitives and proof gates, while visual quality remains blocked until
current rendered evidence exists.

## Validation Boundary

No xcodebuild, XCTest, UI test, simulator run, screenshot capture, accessibility
proof, visual review, or device proof was run under the current no-testing
authorization. Static validation commands are recorded in the companion JSON
packet and Linear closeout.

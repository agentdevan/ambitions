# Ambitions UI Primitives Inventory

Status: Active
Audience: Codex and human developers touching Ambitions UI code

## 1. Executive Summary

- **Status**: Green
- **Usable Primitive System**: Yes, Ambitions possesses a highly developed, robust, and strongly-typed visual primitive system heavily centered on native Apple design language and quiet luxury aesthetics. The foundation is built upon `AmbitionTheme.swift` and enforced via `DesignTokens/*.json`. 
- **Duplication Risks**: Medium. The biggest risk is developers attempting to manually rebuild frosted glass effects, deep celestial backgrounds, or tactile haptics rather than utilizing the established `QuietGlass`, `CelestialField`, and tactile primitive modifiers.
- **Biggest Gaps**: No glaring gaps were identified in standard SwiftUI views. However, complex Metal shaders or `Canvas` implementations are restricted primarily to flagship tactile components (like `AtmosphereComposerCanvas` and `CelestialField`) to ensure `reduceMotion` accessibility compliance.
- **Recommended Next Action**: Complete a strict integration sweep to ensure all new feature surfaces (like `TimeLifeShapeField`) are completely relying on `AmbitionsPremiumMaterials.swift` and `AmbitionTheme.swift` rather than local styling overrides.

## 2. Source Map

| Path | Type | Owner Surface | Maturity | Notes |
|------|------|---------------|----------|-------|
| `DesignTokens/*.tokens.json` | Token | Global | Production | JSON definitions for all spacing, colors, objects |
| `Sources/Theme/AmbitionTheme.swift` | Helper | Global | Production | The central SwiftUI Environment injection for all tokens |
| `Sources/Components/AmbitionsPremiumMaterials.swift` | Primitive | Global | Production | Core material backgrounds (`QuietGlass`, `CelestialField`) |
| `Sources/Components/AmbitionsFlagshipTactilePrimitives.swift` | Primitive | Global | Production | `AtmosphereComposerCanvas`, `ContextCrownHeader` |
| `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift` | Helper | Global | Usable | Handles dynamic type and contrast fallbacks |
| `Native/Ambitions/Features/Today/TodayRealityMeridian*.swift` | Shell | Today | Production | Flagship Reality Meridian orchestrators |
| `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift` | Shell | Capture | Production | Orchestrator for the Atmosphere Composer |
| `Native/Ambitions/App/AppMeridianShell.swift` | Shell | Global | Production | The root app navigation shell |

## 3. Existing Primitives

### Material / Depth Primitives
- **QuietGlass**: Dual-layer frosted container catching dynamic ambient light via a shifting radial border gradient. Do not duplicate with standard `ThinMaterial`.
- **CelestialField**: A gravity-drift spatial micro-particle background reacting to device tilt. Includes a `Canvas` representation for particles. 
- **GraphiteRecess**: Embedded base material layer representing deep inner shadows.

### Motion Primitives
- **LuminousTraceModifier**: Stateful trajectory drawing and outline shimmers guiding spatial movement of actions and objects. Respects `reduceMotion`. 

### Color & Semantic Tokens
- Encapsulated fully in `AmbitionTheme.swift`. Categories include `Foundations`, `Semantics`, `Tone`, `CanonSurfaces`, and `ShellTokens`. Never hardcode `.blue` or `.red`.

### Typography & Spacing
- `theme.typography.heroDisplay`, `theme.typography.section`, `theme.typography.caption`
- `theme.spacing.tight`, `theme.spacing.compact`, `theme.spacing.heroInner`

## 4. Existing Components and Shells

### Root App Shell
- **AppMeridianShell**: The primary architectural routing boundary. 

### Feature Shells
- **Reality Meridian** (`TodayRealityMeridianTopology.swift`): High maturity. Relies on deep celestial fields and luminous traces.
- **Constellation Atlas** (`GoalLifePathSignaturePrimitives.swift`): High maturity.
- **Atmosphere Composer** (`CaptureAtmosphereComposer.swift`): High maturity. Uses custom canvas particle engines for tactical data entry.
- **LifeShape Field** (`TimeLifeShapeField.swift`): High maturity.
- **User System Profile** (`YouRootSurface.swift`): Usable. 

## 5. Existing Spec Recipes

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`: The canonical source of truth for the entire visual direction. Dictates the "one-primary-object" rule, the "quiet luxury" aesthetic, and anti-dashboard drift rules. Source code strictly implements these directives.

## 6. Duplication and Overlap Risks

- **Duplicate Candidates**: Developers attempting to manually re-implement dynamic floating particles for other areas (like Goals).
- **Canonical Source**: `AtmosphereComposerCanvas` inside `AmbitionsFlagshipTactilePrimitives.swift`.
- **Safe Consolidation Plan**: If particles are needed elsewhere, abstract the `Canvas` rendering loop inside `AtmosphereComposerCanvas` into a reusable `CelestialParticleEngine` within `AmbitionsPremiumMaterials.swift`. Do not duplicate the logic.

## 7. Missing Primitives

- **Must Create**: None.
- **Should Extend**: Ensure `QuietGlass` provides an ultra-high contrast fallback state for maximum accessibility when `reduceTransparency` is enabled in iOS Accessibility settings.
- **Should Not Create**: Generic stacked cards, dashboard tile grids, chatbot-first UI, calendar-clone UI, or generic task-list hierarchies.

## 8. Recommended Extension Strategy

1. **Phase A (Current)**: Stabilize existing primitives and audit codebase for inline `.background(.black)` or raw SwiftUI gradients.
2. **Phase B**: Extend primitive fallbacks for iOS Accessibility limits (Reduce Motion, Increase Contrast).
3. **Phase C**: Only create new `Canvas` or `Metal` based primitives if a proven product gap exists in `PRODUCT_DESIGN_TRUTH.md`.
4. **Phase D**: Perform visual QA and screenshot baseline updates for all modified shells.

## 9. Anti-Duplication Rules

- **Rule 1**: Before creating any new primitive or view modifier, search this inventory and `Sources/Components/`.
- **Rule 2**: Prefer extension over creating a new type (e.g., adding a parameter to `QuietGlass` rather than making `FrostedGlass`).
- **Rule 3**: New primitives require an explicit missing-capability justification.
- **Rule 4**: New visual recipes require `reduceMotion` and `dynamicType` support out of the box. 
- **Rule 5**: Metal/shader/Canvas primitives must explicitly document performance cost and fallback behaviors.

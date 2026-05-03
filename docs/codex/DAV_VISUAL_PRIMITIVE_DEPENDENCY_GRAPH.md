# DAV Visual Primitive Dependency Graph

<!-- markdownlint-disable MD013 -->

Status: Active DAV primitive map.
Date: 2026-05-03

| Primitive | Depends on | Used by | Tests/evidence |
| --- | --- | --- | --- |
| `LivingSurfaceBackground` | theme, Reduce Motion | Today, Capture, Plan, Goals, You | visual inventory, build, previews |
| `AdaptiveModuleChrome` | theme, Dynamic Type | all DAV surface modules | build, VoiceOver labels |
| `EvidenceLabel` | source/proof text | Capture, Plan, Memory, Trust | source/receipt evidence |
| `PressureGlow` | value state, Reduce Motion | Today, Plan, Goals | reduce-motion check |
| `ProofPulse` | proof state, Reduce Motion | Today, Goals, Trust | motion meaning check |
| `ContextAtmosphereLayer` | state, theme | Capture, Memory/Search | visual-noise scan |
| `QuietCommandSurface` | actions, accessibility | Capture, Today, Search | tap target evidence |
| `GroupedNavigationSystem` | sections | You, Trust, Accessibility settings | VoiceOver order |
| `LivingTabContext` | surface/state | top-level surfaces | preview fixtures |
| `StateDrivenMaterialPanel` | state, theme | all surfaces | performance risk scan |


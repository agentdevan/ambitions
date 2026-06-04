# Ambitions UI Development Quick Brief

## Snapshot Metadata
- **Branch**: main
- **Commit SHA**: 8062c2f973b60f3cd785e51d47f5b891cc16b6f0
- **Generation Date/Time**: 2026-06-04 14:14:00-04:00

## Current Verified Product Law
Ambitions is a premium iPhone-first, local-first external brain and personal life operating system. It organizes life, shapes time, grounds goals in daily reality, adapts plans when life changes, and helps the user make meaningful progress through calm, personalized, inspectable, non-shaming support.

## Current Verified IA
`Today / Goals / Time / Motion / You` (with `Capture` as a global action). 
*Note: Any mention of Plan, Pulse, or Capture as top-level tabs is obsolete.*

## Current Verified Object/Surface Names
- **Today**: Reality Meridian, Start Here Surface
- **Goals**: Constellation Atlas
- **Time**: LifeShape Field
- **Motion**: Motion Current
- **You**: User System Profile
- **Global**: Atmosphere Composer

## Current Visual Direction
- 70% Apple quiet luxury
- 20% living on-device intelligence
- 10% executive command clarity

## Current Key Primitives/Components
- `AmbitionTheme.swift` (Global Theme)
- `QuietGlass`, `CelestialField` (`AmbitionsPremiumMaterials.swift`)
- `LuminousTraceModifier` (Motion Primitive)

## Root Shell/Nav Status
- Root navigation is managed by `AppMeridianShell.swift`.

## Anti-Duplication Rules
- Before proposing a new primitive, check this brief and existing components.
- Prefer extending existing primitives over creating new ones.
- Do not propose generic dashboard, card-stack, chat, or calendar-clone UI.
- Use `reduceMotion` and `dynamicType` for all new visual elements.

## Instructions for ChatGPT Pro
1. **Ask questions in phases**: Focus on object purpose, state, and connection before writing code.
2. **Identify unknowns**: List any missing information before designing.
3. **Do not rely on stale IA**: Stick strictly to the verified IA provided here.

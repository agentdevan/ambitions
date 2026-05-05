# Accessibility Privacy Performance Quality Reviewer Skill

## Purpose

Use this skill for any Ambitions batch that changes UI, user data, external surfaces, motion, rendering, persistence, sync, widgets, Live Activities, App Intents, or notifications.

## AXQ Review

Check:

- VoiceOver order
- Dynamic Type layout
- Reduce Motion alternative
- non-color meaning
- touch target adequacy
- truncation risk
- private data in accessibility labels

Hard Red:

- primary action inaccessible
- private content exposed through labels
- Dynamic Type breaks core flow
- motion-only meaning

## PVQ Review

Check sensitive Found Life exposure in:

- widgets
- Live Activities
- notifications
- App Intents
- Spotlight
- logs
- previews
- screenshots
- shared storage
- analytics
- debug overlays

Hard Red:

- sensitive content exposed by default externally
- inferred memory presented as fact
- deletion/correction boundary weakened

## PERQ Review

Check:

- launch impact
- render cost
- memory
- unbounded animation loops
- background work
- widget reload budget
- Live Activity update frequency
- low-power/degraded behavior

Hard Red:

- unbounded rendering/background work
- battery-heavy visual gimmick
- performance claim without evidence

## Output

Return AXQ/PVQ/PERQ status separately with evidence required and repair path.

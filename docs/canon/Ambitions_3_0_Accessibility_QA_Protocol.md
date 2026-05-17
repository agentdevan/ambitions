# Ambitions 3.0 — Accessibility QA Protocol

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Triggers

Run for UI changes, navigation changes, Dynamic Type-sensitive layout, custom
controls, gestures, motion, external surfaces, or public accessibility claims.

## Required Docs

- `Ambitions_3_0_Accessibility_Conformance_Plan.md`
- `Ambitions_3_0_Codex_Only_Implementation_And_Testing_Strategy.md`
- target surface docs

## Checks

- Stable accessibility identifiers.
- VoiceOver labels/hints/values where relevant.
- Dynamic Type does not hide primary actions.
- Reduce Motion alternatives exist for meaningful motion.
- No color-only meaning.
- Touch targets remain usable.

## Evidence

Record code/previews/tests inspected. Manual VoiceOver/device proof must be
reported as not verified unless actually performed.

## Stop Conditions

Stop when a claim requires manual accessibility traversal or physical device
proof that is not available.

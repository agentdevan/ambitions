# Ambitions Visual Reference Rebaseline

Status: retained design-decision and visual-reference history
Selected visual language: C4 — Quiet Field

This record indexes the durable product-design material produced during the
visual rebaseline. Historical machine records retain their original field
names for byte-level provenance, but those fields create no task, approval,
authorization, status, or merge process. Current visual direction is routed by
`docs/canon/design/VISUAL_SYSTEM_R1.md`.

## Reference corpus

The additive Phase 3/4 Figma corpus preserves requirement-linked screen,
state, object, accessibility, and implementation-anatomy references:

- Figma file: `Oik7612LSTUHWsNRFoTlTJ`
- Retained additive pages: `17:2` through `17:11`
- Revision 1 page: `215:2`
- Live reconciliation root: `307:57`
- Product-anatomy root: `330:1667`
- Accessibility-class root: `296:35`
- Product-only render root: `306:2`
- Screen mappings: `47`
- Visual requirements classified: `346`
- State variants classified: `441`
- Canonical object records: `18`
- Principal journeys: `12`
- Cross-cutting records: `11`
- Sensitive exposure channels: `9`

`visual-authority-rebaseline.json` and
`visual-authority-r1-node-snapshot.json` preserve exact node mappings, render
digests, archive/failure provenance, and the source history behind Revision 1.
They are design references, not an executable governance system.

The presentation matrix limits persistent root navigation to Today, Goals,
Time, and You. Capture and Search are global overlays without root chrome, and
Trust/Proof is contextual inspection only. Reference masters cover Standard,
Large Text, Accessibility Size, Reduce Motion, Reduce Transparency, Increase
Contrast, and VoiceOver Order.

## Search R2 state references

The Search R2 family gives eight exact state references in the same Figma file:

| State | Frame | Visible control |
| --- | --- | --- |
| Grounded answer | `375:2806` | `Inspect Source` |
| Synthesis in progress | `375:2880` | `Cancel Ask` |
| Ask unavailable / offline | `375:2972` | `Inspect Privacy` |
| Ask failed | `375:3063` | `Retry Ask` |
| Ask interrupted | `375:3159` | `Resume Ask` |
| Ask resumed | `375:3245` | `Cancel Ask` |
| Ask recovered | `375:3326` | `Inspect Source` |
| Capture handoff | `375:3402` | `Open Capture` |

Across those states, deterministic local results remain visible. Grounded and
recovered answers distinguish retrieved facts, interpretation, uncertainty,
and proposed ownership. Offline, failure, interruption, and resume never imply
a durable change. Capture handoff transfers accepted creation intent without
creating an object in Search. Source, Privacy, History, Proof, and Receipts
remain available through contextual inspection.

The rendered references live under
`docs/qa/evidence/2026-07-17-canon-search-authority-r2/screens/product-only/`.
They define product-design targets; source/runtime tests must separately prove
current behavior.

## Provenance and rejected material

Generic skeletons, alternative directions, archive nodes, and failure examples
remain available to explain rejected tradeoffs and prevent regressions. They
are not parallel visual directions. The accessibility-size Today repair at
`270:1430` retains one visible Search node (`359:243`) and one visible Capture
node (`359:248`) with matching geometry and fills across the replaced pairs.

## Implementation use

1. Resolve the owning screen, state, command, and requirement through the
   product-canon compiler.
2. Use Visual System R1 for current styling and this corpus for detailed
   anatomy, state, and historical tradeoffs.
3. Treat live SwiftUI, project configuration, and tests as implementation
   truth.
4. Validate affected behavior, native layout, Dynamic Type, VoiceOver,
   reduced effects, contrast, privacy, and performance as triggered by scope.

No screenshot, Figma node, historical manifest, or selected frame substitutes
for executable validation of the current app.

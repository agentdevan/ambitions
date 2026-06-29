---
name: figma-production-gate
description: Operational gate for Ambitions Figma, VSP files, Figma components, Figma screenshots, Figma Motion, shaders, Weave or generative tools, Figma plugins, Code Layers, marketing render boards, and Figma handoff. Use when creating, editing, reviewing, validating, or closing any Ambitions Figma artifact so the Zero Ambiguity / Zero Skeleton Policy, VSP-01 shell authority, durable screenshot proof, accessibility, SwiftUI plausibility, and owner-approval limits are enforced.
---

# Figma Production Gate

This skill operationalizes `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md`. Do not restate that file as a looser policy. If this skill and the addendum conflict, the addendum wins.

## When To Load

Load this skill before any task involving Figma, VSP-01 through VSP-10, Figma components, Figma screenshots, Figma Motion, shaders, Weave or generative output, Figma plugins, Code Layers, marketing render boards, VSP handoff, or visual review of Figma artifacts.

Also load `docs/skills/ui-north-star-production-gate/SKILL.md` when Figma work affects SwiftUI source, shell/stage/chrome/navigation, design-system primitives, screenshots, preview matrices, or accessibility proof.

## Required First Reads

Read these before producing or reviewing a Figma artifact:

1. `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
4. `docs/truth/RELEASE_TRUTH.md`
5. Relevant VSP, Figma, screenshot, Linear, or proof artifacts for the task

Read `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md` when judging SwiftUI plausibility, native controls, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, materials, or HIG-aligned shell behavior.

## Hard Fail Conditions

Stop and mark the work `Needs Repair` or Red if any of these are true:

- A reviewable frame looks like a skeleton, wireframe, storyboard, shallow mockup, component demo, diagram pretending to be UI, generic productivity/dashboard/calendar/task app, or mini-screen collage.
- A VSP-02 through VSP-10 frame invents shell chrome instead of being content-only or mounted in the exact approved VSP-01 shell authority.
- Any review frame lacks a binary label: `AUTHORITY`, `CANDIDATE`, `EXPLORATION`, `MARKETING_RENDER`, `FAILURE_EVIDENCE`, or `ARCHIVE`.
- A failed frame remains candidate-like instead of being renamed `FAILURE_EVIDENCE - [VSP] - [reason] - [date/pass]`.
- Screenshot proof is missing, temporary-only, or not saved to a durable project proof location or attached to Linear.
- Typography is clipped, invisible, collapsed, too small, compressed, colliding, hidden by effects, or dependent on mini-screen readability.
- Spatial layout has accidental overlap, collision, cropped edges, safe-area/dock conflict, ambiguous layering, insufficient tap targets, or primary content hidden below the viewport.
- Key meaning depends on impossible shader effects, impossible blur/material layering, motion without a static equivalent, non-native controls, web-app behavior, or absolute positioning that cannot survive device and Dynamic Type changes.
- Figma Motion, shaders, Code Layers, plugins, Weave, or generative output bypass SwiftUI plausibility, accessibility, product law, or screenshot proof.
- The frame violates Ambitions product law: Today / Goals / Time / You only, Capture as global composer, Motion as behavior, Trust as inspection, offline core without sign-in, and no private life graph in R2.
- The closeout claims Visual Green, Done, runtime/build implementation, or milestone completion without owner approval and current proof.

If the process starts producing skeleton work, stop instead of filling the board for completion optics.

## Required Workflow

1. Classify the artifact type: `AUTHORITY`, `CANDIDATE`, `EXPLORATION`, `MARKETING_RENDER`, `FAILURE_EVIDENCE`, or `ARCHIVE`.
2. Identify shell authority before drawing or reviewing shell chrome. Use exact VSP-01 shell authority or keep the frame content-only.
3. Identify the Ambitions object being rendered: Today Reality Window/Step/Recovery/Proof logic, Goals Life Area Atlas/path, Time Life Calendar/Protected Time/Open Window/Reflow Trace, You settings/privacy/local-first controls, Capture composer, or Trust inspection detail.
4. Tag every major object with implementation provenance: `Existing SwiftUI primitive`, `New SwiftUI primitive required`, `Figma-only exploration`, `Marketing-only render detail`, or `Rejected / not implementation-plausible`.
5. Tag every shader, effect, or motion detail as `SwiftUI-native`, `Metal/Core Image plausible`, `Static asset plausible`, `Marketing-only`, or `Rejected`.
6. Run typography, spatial, material, product-law, accessibility/Dynamic Type, SwiftUI plausibility, and shell authority audits before any review handoff.
7. Export durable proof: canonical Figma frame link, hero screenshot, cropped viewport screenshot, presentation-scale screenshot, direct visual review note, and Linear attachment or durable project proof path.
8. Rename failures immediately as `FAILURE_EVIDENCE - [VSP] - [reason] - [date/pass]`; do not use failure evidence as production source except to avoid repeat failures.
9. Promote only to `Ready For Review` when durable screenshot proof exists, the hero clears hard-fail checks, shell authority is preserved, the artifact looks final-app or marketing-grade, and owner review is the only remaining blocker.
10. Use `Done` only when owner approval explicitly grants Green or Done, durable proof exists, a production handoff addendum exists, non-claims are recorded, and no unresolved quality failure remains.

## Status Mapping To Linear

- Red: keep the Linear issue open or in repair/blocked status; comment with hard-fail evidence and do not request review.
- Yellow: use only for proof-bounded candidates, accepted risk, or owner-pending review. Move to `Ready For Review` only when the addendum's Ready For Review gate is fully met; otherwise leave open with repair notes.
- Green: use only after explicit owner approval, durable proof, non-claims, and no unresolved failure. Do not mark Linear Done unless the user or tracker workflow explicitly asks for that update.

Never mark a Linear issue Done from Figma work alone without owner approval. Never claim Visual Green from Codex self-review.

## Allowed Outputs

- `CANDIDATE - VSP-04 - content-only Time Life Calendar - R2` with durable hero, crop, and presentation screenshots plus SwiftUI primitive provenance.
- `MARKETING_RENDER - VSP-02 - launch hero - R1` with marketing-only effects tagged and no implementation claim.
- `FAILURE_EVIDENCE - VSP-03 - typography collision - R3` with failure screenshot archived and no production handoff.
- Yellow closeout stating that a frame is Ready For Review pending owner approval, with non-claims for Visual Green and source implementation.

## Forbidden Outputs

- Unlabeled frames named only `polished`, `final`, `native`, or `VSP mockup`.
- VSP-02 through VSP-10 frames with invented dock, header, tab bar, Context Crown, Capture, search, shell glass, or status/nav treatment.
- Clean skeletons with premium colors.
- Figma-only shader/motion work described as implemented SwiftUI.
- Screenshot proof that exists only under `/tmp`.
- `Done`, `Visual Green`, `marketing-ready`, or `SwiftUI plausible` without frame ID, durable screenshot proof, audit notes, and owner approval where required.

## Required Closeout Block

```text
Status: Green / Yellow / Red
Scope completed:
Files changed:
Figma frames changed:
Frame labels:
Approved shell authority preserved:
Design-system primitives used:
Validation run:
Screenshot proof:
Durable proof location:
Typography audit:
Spatial audit:
Product-law audit:
Accessibility / Dynamic Type audit:
SwiftUI plausibility audit:
Figma-only / marketing-only effects:
Failures found:
Repairs made:
Remaining risks:
Follow-up required:
Non-claims:
Rollback plan:
```

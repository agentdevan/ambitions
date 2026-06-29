---
name: ui-north-star-production-gate
description: Operational gate for Ambitions SwiftUI UI, shell, Stage, chrome, navigation, design-system primitives, Ambitions object primitives, screenshots, accessibility, Dynamic Type, preview matrices, UI QA, and visual polish. Use when creating, editing, reviewing, validating, or closing native UI work so final SwiftUI plausibility, product law, shell authority, accessibility settings, durable screenshot proof, and no Visual Green or milestone overclaims are enforced.
---

# UI North Star Production Gate

This skill operationalizes Ambitions UI north-star production gates and the canonical `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md` where UI, screenshots, visual proof, Figma handoff, or marketing renders are in scope. It is an operating checklist, not product canon or proof.

## When To Load

Load this skill before any task involving SwiftUI UI, shell/stage/chrome/navigation, design-system components, Ambitions object primitives, screenshots, accessibility, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, preview matrices, UI QA, visual polish, rendered product acceptance, or visual closeout.

Also load `docs/skills/figma-production-gate/SKILL.md` when the work touches Figma, VSP files, Figma screenshots, marketing render boards, Figma Motion, shaders, Code Layers, plugins, or Figma handoff.

## Required First Reads

Read these before changing or reviewing native UI:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
2. `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
3. `docs/truth/RELEASE_TRUTH.md`
4. `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
5. `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md` when screenshots, Figma, VSPs, visual proof, marketing renders, or UI north-star review are in scope
6. Relevant live SwiftUI source, tests, screenshots, preview matrices, QA rows, and current proof artifacts

Use the retained `.agents/skills` routing for source ownership, architecture, iOS quality, and proof-honesty work when the task scope triggers those skills.

## Hard Fail Conditions

Stop and close Red or Yellow instead of producing or accepting UI work if any of these are true:

- The UI regresses into generic card/feed/dashboard/calendar/task/habit/chat/chatbot/productivity-score patterns.
- The first viewport is architecture-as-UI, report-panel UI, wrapper-as-object UI, or a vertical stack of canonical labels instead of one dominant Ambitions object.
- Shell authority is duplicated, invented, detached, or contaminated by extra dock/header/tab/Capture/search/crown/status/nav approximations.
- Capture becomes a tab or persistent root destination, or Motion becomes a tab, destination, analytics feed, score, streak, XP layer, or dashboard.
- Design-system primitives have no provenance: existing primitive, canonical new primitive owner, or explicit rejected/marketing-only classification.
- Major UI depends on Figma-only effects, impossible shaders, impossible material layering, motion without static equivalent, web layout behavior, or absolute positioning that cannot survive device and Dynamic Type changes.
- Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, VoiceOver order/actions, tap targets, safe areas, and content clipping are not checked or explicitly blocked.
- A visual/UI change has no screenshot proof and no explicit not-run reason.
- Screenshot proof is only a path, only temporary `/tmp`, or not reviewable in a durable project location.
- Source implementation, runtime/build success, accessibility conformance, device proof, Visual Green, Release Green, Done, or milestone promotion is claimed from Figma-only work, screenshots alone, source-string tests, or self-review.

If a UI direction is skeleton-like or unprovable, stop instead of implementing placeholder polish.

## Required Workflow

1. Identify the canonical owner before editing: `Stage`, `DesignSystem`, `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`, `Composer/Capture`, `Trust`, `Interaction`, `Rendering`, or `Quality`.
2. Preserve product law: Today / Goals / Time / You only, Capture global composer, Motion behavior, Trust inspection, local-first core, no private life graph in R2.
3. Identify shell authority. The root shell owns chrome unless a scoped source decision proves a crownless or alternate mode; avoid duplicate shell/chrome ownership.
4. Define the dominant Ambitions object and first-viewport hierarchy before coding or reviewing.
5. Use existing design-system primitives where they fit. If a new primitive is required, place it under the canonical owner and record why it is required.
6. Check final native SwiftUI plausibility: layout resilience, Dynamic Type, safe areas, native controls, material discipline, reduced-motion static equivalent, accessibility semantics, and iOS 26 availability.
7. Run or explicitly defer a preview/screenshot matrix covering default text, large text, accessibility-size stress or blocker, Reduce Motion, Reduce Transparency when materials matter, Increase Contrast, and relevant root/drilldown/overlay states.
8. Save screenshot proof to a durable project proof location or attach it where review happens. Do not rely on a temporary path as the only proof.
9. Use source/test validation only for source claims. Use screenshot/hierarchy/accessibility proof for UI claims. Use independent owner review for Visual Green.
10. Close with explicit non-claims for anything not proven, especially Visual Green, Release Green, device proof, accessibility conformance, runtime/build success, and source implementation from Figma-only work.

## Status Mapping To Linear

- Red: keep the Linear issue open or in repair/blocked status; comment with the failed gate, evidence, and rollback or repair path.
- Yellow: use for Source Green, Runtime Green, Interaction Green, Ready for Visual Review, accepted risk, simulator-only proof, or owner-pending review. Do not treat Yellow as Done.
- Green: use for docs-governance work or owner-approved visual work only when the exact proof exists. Codex may not self-certify Visual Green or Release Green.

Do not mark Linear Done and do not promote milestones from visual work alone. Native source, runtime, interaction, visual, accessibility, device, and release claims each need their own current proof.

## Allowed Outputs

- `Ready for Visual Review`: SwiftUI source changed under canonical owners, focused validation run, screenshot matrix saved durably, accessibility audits documented, and owner review remains the only Visual Green blocker.
- `Yellow`: Figma target or simulator screenshot exists, but no device proof or owner approval exists; Visual Green and Done are explicitly not claimed.
- `Source Green`: canonical owner source and tests pass, with non-claims for rendered visual acceptance and release readiness.
- `Red`: screenshot shows dock/content collision, clipped text, generic dashboard UI, or duplicated shell chrome; work stops with failure evidence.

## Forbidden Outputs

- `Visual Green` because a Figma mockup looks polished.
- `Done` because source compiled or a source-string test passed.
- Generic dashboard/card/feed/task/calendar UI with Ambitions labels pasted on top.
- Root surfaces that expose Proof, Source, Receipts, Motion, route, runtime, policy, or architecture labels as primary product structure.
- Screenshot proof that is only a local path, only temporary, or not reviewable.
- Milestone promotion from visual boards without source/runtime/interaction/accessibility/device/release proof.

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

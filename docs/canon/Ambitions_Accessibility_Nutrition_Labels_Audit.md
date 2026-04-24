# Ambitions Accessibility Nutrition Labels Audit

## Purpose And Scope

This document is the dedicated audit artifact for Ambitions Accessibility Nutrition Labels.

Its job is to ensure any published accessibility-label claims are:

- honest
- device-specific
- tied to common user tasks
- backed by captured evidence

It does not guarantee a specific Apple labeling outcome.

## Supported Launch Device(s)

Locked launch support for this audit:

- iPhone only at launch
- portrait only at launch
- U.S. launch region only

Per-device evaluation should be completed on the actual iPhone launch band selected for submission materials and support commitments.

## Apple Label Categories

Evaluate the Apple Accessibility Nutrition Label categories that are relevant at submission time, including whether Ambitions should claim support for:

- VoiceOver
- Voice Control
- Larger Text
- Sufficient Contrast
- Reduced Motion
- Captions if applicable
- Switch Control if applicable
- other Apple accessibility label categories that materially apply at submission time

Do not claim categories that were not evaluated on the supported launch device band and common tasks below.

## Common Tasks To Evaluate

At minimum, audit these task flows:

- first launch
- onboarding or skip onboarding if applicable
- Today
- Goals
- Plan
- Insights
- Profile / Trust
- widgets / Live Activities if those remain in launch scope
- settings / export-import / reset / sync-trust surfaces
- continuity, handoff, and degraded-sync states governed by [Ambitions_State_Continuity_Mesh.md](Ambitions_State_Continuity_Mesh.md)

## Per-Device Evaluation Matrix

Create and maintain a per-device matrix using the actual supported launch iPhone band.

Required fields per row:

- device
- iOS version
- task
- label category under evaluation
- pass / fail / partial
- notes
- evidence reference
- operator and date

## Claim / Do Not Claim / Not Applicable Status

Use the following status model for each Apple label category:

- `Claim`
  The category was evaluated on the supported launch iPhone band, key common tasks worked, and evidence exists.
- `Do Not Claim`
  The category was evaluated and Ambitions does not meet a truthful claim threshold.
- `Not Applicable`
  The category does not materially apply to the shipped launch product or surface set.

Rules:

- default to `Do Not Claim` rather than over-claiming
- only move to `Claim` with evidence
- use `Not Applicable` sparingly and explain why

## Batch 60 RC Evidence Notes - April 24, 2026

Batch 60 produced RC-readiness evidence only. These notes are not a final publish decision and do not mark any Accessibility Nutrition Label as publish-ready.

Evidence captured:
- simulator iPhone portrait audit across Today, Goals, Plan, Insights, Profile, onboarding/primary route surfaces, command/Memory Lens/recall, privacy/trust copy, and represented no-data/degraded states
- code inspection of VoiceOver labels, accessibility identifiers, reduce-motion handling, permission/privacy copy, and local-first trust language
- Dynamic Type and increased-contrast simulator screenshot pass on Plan after fixing shell header metadata and continuity receipt readability at accessibility text sizes
- targeted UI route smoke passed after the accessibility polish fix

| Label Category | Batch 60 Readiness Classification | Evidence Note |
| --- | --- | --- |
| VoiceOver | Likely claimable after final real-device audit | Labels and grouped accessibility surfaces were inspected in code and route smoke coverage remained green, but no real VoiceOver run was captured. |
| Voice Control | Not enough evidence yet | No dedicated Voice Control command pass was captured. |
| Larger Text | Likely claimable after final real-device audit | Simulator accessibility-size audit found and fixed a deterministic shell/receipt readability issue; final device-band screenshots are still required. |
| Sufficient Contrast | Likely claimable after final real-device audit | Increased-contrast simulator pass showed no obvious blocking issue after the Dynamic Type fix, but no full contrast measurement or real-device evidence is recorded. |
| Reduced Motion | Likely claimable after final real-device audit | Reduce-motion code paths were inspected and shared motion helpers disable animations where represented; a real-device toggle pass is still required. |
| Captions | Not applicable | Ambitions launch surfaces do not include audio/video content requiring captions. |
| Switch Control | Not enough evidence yet | No Switch Control traversal pass was captured. |
| Other Apple label categories | Not enough evidence yet | Evaluate only against the final App Store Connect label taxonomy at submission time. |

## Evidence Capture Expectations

Evidence should include as appropriate:

- real-device video or screenshots
- notes from VoiceOver or Voice Control runs
- larger text screenshots
- reduced-motion verification notes
- widget or Live Activity captures if those surfaces remain in launch scope
- issue references for any failed or partial task

Evidence must be tied to:

- device
- OS version
- task flow
- evaluated label category
- date

## Unresolved Issues

Track unresolved accessibility issues here until final submission review.

Each issue should record:

- affected task
- affected device
- affected label category
- severity
- launch-blocking or non-blocking status
- owner
- target resolution point

## Final Publish Decision

Before submission, record:

- supported launch device band used for evaluation
- categories to claim
- categories not to claim
- categories marked not applicable
- signoff owner
- decision date

If evidence is incomplete, the publish decision must remain open.

## Accessibility URL Content Requirements

The published accessibility page should include at minimum:

- current supported launch platform truth
- accessibility features Ambitions believes it supports at launch
- any important limits or currently unsupported areas
- a contact path for accessibility feedback
- a commitment that claims are reviewed against shipped behavior and supported devices

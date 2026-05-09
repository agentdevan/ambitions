# FAANG Frontend Implementation Team Skill

Status: Active Codex OS reviewer/implementation skill
Date: 2026-05-08
Applies to: Every UI-affecting Ambitions batch
Source protocol: `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md`

## Mission

Act as a senior FAANG-quality iOS frontend implementation team, not as a component generator. The skill must improve rendered SwiftUI product quality through hierarchy, deletion, composition, proof, accessibility, and maintainable implementation.

## Activation Triggers

Invoke this skill when a batch touches any of the following:

- SwiftUI view files
- app shell, chrome, navigation, tab bar, Meridian rail, floating controls
- design system or visual primitives
- top-level surfaces: Today, Goals, Capture, Time, You
- onboarding
- widgets, Live Activities, App Intents visible confirmations, notifications
- screenshots, preview fixtures, motion, haptics, accessibility presentation

If a batch affects rendered UI and this skill is not invoked or mapped, the batch cannot close Green.

## Operating Standard

The skill must evaluate the rendered product against these roles:

1. Staff iOS Frontend Lead
2. Product Composition Director
3. Signature Interface Creative Director
4. Accessibility And Human Factors Lead
5. Performance And Rendering Lead
6. Visual QA Red Team

The skill is allowed to fail a batch even when code builds.

## Required Inputs

Before implementation, collect:

- touched screen/component list
- current screenshot or durable baseline if available
- relevant canon/source-truth files
- first viewport object/chip/body-copy/bottom-chrome counts
- current visual defect hypothesis
- allowed and forbidden file boundaries

## Required Screen Contract

Before writing UI code, produce this contract for each touched top-level screen:

```text
Surface:
Primary object:
Secondary objects, maximum two:
Primary action:
Collapsed detail path:
Visible copy budget:
Visible chip budget:
Bottom chrome owner:
Accessibility equivalent:
Reduce Motion equivalent:
Deletion/collapse targets:
```

## Implementation Rules

- Delete, collapse, merge, or demote visible inventory before adding new visible UI.
- Prefer one strong Ambitions-native object over stacked panels.
- Keep canon intelligence behind interaction, receipt, detail drawer, or source fold unless it is required for the immediate user decision.
- Do not expose architecture, batch, source-truth, or implementation logic as top-level UI copy.
- Do not let generic panels, chips, symbols, or cards become the visual language.
- Do not treat accessibility IDs as a design system.
- Do not let a generic reusable primitive accept unlimited hero/top-level content without a visible budget.

## First Viewport Budget

Default top-level budget:

- Max 1 primary surface/object
- Max 2 support surfaces/objects
- Max 4 chips
- Max 12 body-copy lines
- Max 1 floating control
- Max 1 bottom navigation system
- No nested card-on-card inside the primary object
- No internal architecture copy above the fold
- One obvious visual thesis within two seconds

Failures are Recoverable Red unless explicitly justified and accepted by Visual QA Red Team.

## Hard Visual Reds

Mark Hard Red when:

- visible UI changed but closure relies only on build/tests/docs
- primary object identity is broken
- top-level tab reads as dashboard, card stack, prototype, report, or generic productivity app
- native tab bar, custom rail, and floating controls compete as independent navigation systems
- user-facing copy describes implementation architecture instead of user value
- visual repair would require weakening accessibility, privacy, canon, validation, or release truth

## Batch Report Output

Return this table in the batch report:

| Field | Result |
| --- | --- |
| Surfaces touched | |
| Primary object contract | |
| Deleted/collapsed UI | |
| Before proof | |
| After proof | |
| First viewport budget | |
| Visual QA verdict | |
| Accessibility verdict | |
| Performance verdict | |
| Remaining gaps | |

## Final Question

Before marking Green, answer plainly:

`Would this screenshot survive a ruthless senior iOS/product-design review?`

If the answer is no, the batch is Red or Accepted Yellow with an explicit repair owner. It is not Green.

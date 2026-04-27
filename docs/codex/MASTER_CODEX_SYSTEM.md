# Ambitions Master Codex System

You are working on Ambitions — a premium personal execution app.

This file is standing behavior context for Codex sessions.
For source-of-truth precedence, read [CONTEXT_INDEX.md](CONTEXT_INDEX.md) first.
For the free, non-agent, non-GitHub-Actions operating procedure, read [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md).
When this file conflicts with [CONTEXT_INDEX.md](CONTEXT_INDEX.md), the context index wins.
Do not rely on prior chat memory.

## Mandatory canonical context

Before non-trivial planning or implementation, read:

1. [../../AGENTS.md](../../AGENTS.md)
2. [CONTEXT_INDEX.md](CONTEXT_INDEX.md)
3. [FREE_WORKFLOW_OPERATING_SYSTEM.md](FREE_WORKFLOW_OPERATING_SYSTEM.md)
4. [../canon/Ambitions_2_0_Master_Plan.md](../canon/Ambitions_2_0_Master_Plan.md)
5. [../canon/Ambitions_2_0_Product_Architecture.md](../canon/Ambitions_2_0_Product_Architecture.md)
6. [../canon/Ambitions_2_0_Systems_Architecture.md](../canon/Ambitions_2_0_Systems_Architecture.md)
7. [../canon/Ambitions_2_0_Visual_System.md](../canon/Ambitions_2_0_Visual_System.md)
8. [../canon/Ambitions_2_0_Roadmap.md](../canon/Ambitions_2_0_Roadmap.md)
9. [../canon/Ambitions_2_0_Batch_Plan.md](../canon/Ambitions_2_0_Batch_Plan.md)
10. [../canon/design/Ambitions_Design_Constitution.md](../canon/design/Ambitions_Design_Constitution.md) when the task touches design, IA, UX writing, interaction, trust, accessibility, or external surfaces
11. [../canon/Ambitions_2_0_Implementation_Gap_Audit.md](../canon/Ambitions_2_0_Implementation_Gap_Audit.md) when planning Design Constitution alignment or checking implementation gaps
12. [BATCH_REGISTRY.md](BATCH_REGISTRY.md)
13. [../../MASTER_PRODUCT_SPEC.md](../../MASTER_PRODUCT_SPEC.md) for current shipping product truth where not superseded by the new Ambitions 2.0 canon
14. [../review/VISUAL_REVIEW_CHECKLIST.md](../review/VISUAL_REVIEW_CHECKLIST.md) when visible UI, navigation, empty states, copy, or hierarchy changes
15. [../review/FRICTION_LOG.md](../review/FRICTION_LOG.md) when observed product friction needs to be captured without expanding scope

Current execution status is Batches 00-88 complete for planning purposes, Batch 89 next queued / next uncompleted, and Batches 90-120 future planned roadmap work. Do not skip ahead of the Batch 89+ execution order or active batch unless direct user instructions explicitly change scope.

## Product identity

Ambitions is:
- a calm, intelligent life operating system
- a personal life organization system that gives concrete next steps
- premium, modern, minimal
- built for real daily use
- emotionally intelligent but not manipulative
- visually obvious and low-stress

Ambitions is not:
- a generic to-do app
- a corporate productivity dashboard
- a gamified habit tracker
- a cluttered feature pile
- a chat-first AI wrapper
- a dashboard builder

Active shell is Today / Goals / Capture / Plan / You. Insights is contextual, Habits are absorbed into Rituals, Profile is user-facing You, and Tasks are standalone One-Step Goals rather than a top-level tab.

Target quality:
- Apple / OpenAI / Meta / Google-level polish
- premium consumer mobile quality
- immediately understandable
- visually competitive at the highest level

## Core principles

Always optimize for:
- clarity of action
- calmness
- trust
- realism
- speed of understanding
- premium feel

Every screen should answer:
- what matters now?
- what do I do next?
- why is this here?

## UX rules

Prioritize:
- obvious next actions
- strong visual hierarchy
- spacing and readability
- mobile-first ergonomics
- low cognitive load
- scroll clarity

Avoid:
- clutter
- dense dashboards
- weak hierarchy
- enterprise styling
- generic UI
- shallow gamification
- unnecessary animation
- over-complex flows

## Design standard

UI must be:
- premium immediately
- visually clean but not empty
- modern and competitive with top apps
- touch-friendly
- consistent

Theming:
- dark mode is the default aesthetic
- light mode must feel equally premium
- accent colors must feel intentional, not random

Components must feel:
- polished
- intentional
- cohesive
- high quality

No default-looking UI.

## Engineering rules

- preserve existing working behavior unless replacing it cleanly
- do not create duplicate systems
- integrate into existing architecture
- prefer simple, maintainable solutions
- avoid hacks in production code
- keep naming clean and human-readable
- keep logic deterministic where possible

## Architecture expectation

Before making changes:
- inspect existing files
- understand data flow
- identify dependencies

When implementing:
- extend current systems
- do not introduce parallel logic paths
- avoid fragmentation

## Mandatory workflow

Always follow this sequence:
1. inspect current implementation
2. identify constraints: technical, UX, and product truth
3. propose the smallest clean plan
4. implement with minimal integrated changes
5. verify behavior and UI consistency
6. run the relevant free validation routine from `FREE_WORKFLOW_OPERATING_SYSTEM.md`
7. perform visual review with `docs/review/VISUAL_REVIEW_CHECKLIST.md` when UI changed
8. document real friction in `docs/review/FRICTION_LOG.md` without expanding active scope
9. summarize clearly

Never skip directly to coding.

## Built-in execution modes

### Feature mode
Use when adding functionality.
- integrate into existing systems
- complete the flow end-to-end
- avoid partial implementations
- ensure UI and logic are connected

### UI polish mode
Use when improving visuals or UX.
- identify weak hierarchy, spacing, and clarity
- improve visual weight and readability
- upgrade components to premium quality
- ensure at-a-glance clarity
- remove friction

### Refactor mode
Use when improving structure.
- preserve behavior
- remove duplication
- simplify architecture
- improve readability
- avoid over-abstraction

### Docs mode
Use when editing documentation.
- match repo truth only
- remove stale claims
- avoid speculation
- keep instructions actionable

### Review mode
Use when auditing Codex work.
- do not change files unless explicitly asked
- compare completion claims against validation evidence
- check registry/doc status alignment
- check for stale batch references
- identify blockers before the next batch prompt

## Implementation rules

Before coding:
- read relevant files
- confirm understanding

During coding:
- keep changes scoped
- avoid mixing unrelated edits
- maintain consistency

After coding:
- verify logic
- verify UI
- verify no regressions
- ensure product tone is preserved
- run a stale-reference audit before claiming completion

## Required output format

Always return:
1. Current state
2. Constraints
3. Plan
4. Implementation summary
5. Files changed
6. Validation steps
7. Visual review result when relevant
8. Risks / follow-up work
9. Completion claim

## Quality bar

Assume:
- users open this daily
- users judge quality in seconds
- poor UX will cause churn quickly

Do not produce:
- placeholder-level UI
- generic product decisions
- half-finished flows
- inconsistent behavior

## Product priorities

Always bias toward:
- execution clarity
- real-world usability
- premium feel
- strong UX decisions
- cohesive system behavior

## Cost discipline

Do not add paid infrastructure by default.

Avoid unless explicitly approved:
- GitHub Actions workflows
- scheduled agents
- paid cloud runners
- external paid QA tools
- new SaaS project-management dependencies

Prefer:
- local Xcode validation
- local grep/search audits
- manual visual review
- repo-native Markdown checklists
- clear Codex prompt modes

## Final rule

Do not behave like a code generator.

Behave like:
- a senior product engineer
- a top-tier mobile designer
- a systems thinker

All at once.

Every decision should reflect that level of judgment.

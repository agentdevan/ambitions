<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01 — World-Class Ambitions UI in Codex Studio Installer

## Batch ID

AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01

## Execution model

This is an installer prompt. It must install an Ambitions-specific UI Studio operating system for Codex.

The goal is not to make Codex "generate nicer screens." The goal is to make Codex behave like a world-class native iPhone frontend/design team when building Ambitions.

Install:

- UI quality canon
- design execution process
- SwiftUI implementation standards
- visual QA gates
- screen-state matrix
- preview/screenshot proof protocol
- anti-generic UI rules
- accessibility and performance gates
- root-surface review rubrics
- copy/microinteraction standards
- flagship polish train prompts

## Existing repo OS inspection

Inspect and reuse the active repo OS paths:

```text
docs/canon/frontend/
docs/canon/
docs/codex/
docs/codex/reports/
docs/codex/review-boards/
.codex/skills/
Native/Ambitions/
Native/AmbitionsTests/
Native/AmbitionsUITests/
```

Search for:

```text
DesignSystem
Tokens
Color
Typography
Spacing
Radius
Motion
Haptics
Component
Primitive
Preview
Screenshot
Visual QA
Today
Goals
Capture
Time
You
Reality Meridian
Start Here
LifeShape
Constellation
Atmosphere
Proof
Receipt
Closure
Accessibility
Dynamic Type
VoiceOver
```

Reuse and upgrade existing systems. Do not create duplicate token systems, component libraries, or visual canon.

## Required installed artifacts

Use active repo OS paths if different. The historical suggested path was `docs/canon/frontend/**`, but active repo truth may place frontend authority under a different root.

Required operating artifacts:

- UI Studio authority document
- UI quality bar
- art direction
- surface composition rules
- token rules
- motion/haptics rules
- copy/microcopy rules
- accessibility rules
- preview matrix
- screenshot QA protocol
- anti-patterns
- install report under `docs/codex/reports/`
- review board under the active review-board path
- generated prompts under `prompts/batches/ui-flagship/`
- optional `.codex` skill if it fits current skill structure

## UI Studio principles

Install these as canon:

- One primary object per root surface:
  - Today = Reality Meridian + Start Here
  - Goals = Constellation Atlas
  - Capture = Atmosphere Composer
  - Time = LifeShape Field
  - You = User System Profile + Trust & Continuity
- Surface topology before components.
- No surface default.
- Runtime truth before UI decoration.
- Native iPhone first.
- Quiet luxury.
- Inspectable intelligence.
- Emotional recovery.

## Mandatory future UI process

Future flagship UI implementation prompts must require:

1. Surface brief:

```text
Surface:
Primary object:
User intent:
Backend projection:
Empty state:
Normal state:
Dense state:
Recovery state:
Accessibility risks:
Performance risks:
What must not be built:
```

2. Data truth:
   - projection model
   - preview fixture
   - loading state
   - unavailable state
   - stale state
   - error state
   - privacy/redaction state
   - honest placeholder/empty state or stop if truth is missing

3. Composition:
   - primary object hierarchy
   - supporting object attachment
   - visual rhythm
   - spacing system
   - depth/material use
   - typography roles
   - affordances
   - scroll behavior
   - safe area behavior

4. Interaction:
   - tap targets
   - gestures
   - sheets/drawers
   - closure actions
   - haptics
   - motion
   - reduced motion alternative
   - interrupted state

5. SwiftUI implementation:
   - use existing design system
   - extend tokens only if needed
   - avoid one-off styling
   - keep view bodies readable
   - move logic into view models/projections
   - avoid core planning computation in views
   - create previews
   - add accessibility labels/hints/values where needed

6. Preview and screenshot proof for:

```text
empty
normal
dense
recovery
error
reduced motion
large Dynamic Type
small iPhone
large iPhone
```

7. Review:

```text
Does this feel like Ambitions?
Does this feel native?
Does this feel flagship?
Does this create category?
Is anything generic?
Is anything fake?
Is anything inaccessible?
Is anything over-designed?
Is anything under-polished?
```

## Hard UI anti-patterns

Avoid:

- equal card grids
- generic surface
- web-app hero sections
- chatbot-first screen
- calendar clone
- task-list-first Today
- "AI says" copy
- vague motivational copy
- too many gradients
- random glassmorphism
- decorative icons without semantics
- thick headers everywhere
- unstructured settings lists
- fake disabled states
- color-only statuses
- tiny tap targets
- excessive animation
- shaming needs closure states
- "Plan" top-level residue
- generic Profile screen
- generic Insights screen
- fake sync indicators
- fake proof/provenance

## Required generated UI implementation prompts

Install these prompts under active batch paths. Each prompt must include the required runner metadata header.

1. `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM`
2. `UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW`
3. `UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION`
4. `UI-STUDIO-04-START-HERE-COMMAND-OBJECT`
5. `UI-STUDIO-05-FIVE-SURFACE-COMPOSITION`
6. `UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS`
7. `UI-STUDIO-07-TRUST-CONTINUITY-UX`
8. `UI-STUDIO-08-ONBOARDING-CATEGORY-UX`
9. `UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX`
10. `UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM`

## UI quality rubric

Every flagship UI review must score:

- Category clarity
- Native believability
- Primary object clarity
- Visual hierarchy
- Runtime truth
- Emotional tone
- Interaction quality
- Accessibility
- Performance
- Proprietary feel
- Screenshot quality

Scores:

```text
Green  = launch-quality or nearly launch-quality
Yellow = promising but has visible seams
Red    = generic, fake, inaccessible, unstable, or v1-feeling
```

Any Red in runtime truth, accessibility, or data trust blocks launch.

## Root surface flagship requirements

Today must feel like the day has a spine. Primary object: Reality Meridian + Start Here. Avoid surface, task list, card stack, calendar clone.

Goals must feel like ambitions are living systems. Primary object: Constellation Atlas. Avoid generic goal list, habit tracker, OKR table.

Capture must feel like life can enter without organization. Primary object: Atmosphere Composer. Avoid chatbot, notes clone, heavy form.

Time must feel like capacity truth. Primary object: LifeShape Field. Avoid Plan renamed, calendar clone, schedule list as whole screen.

You must feel like trust and control. Primary object: User System Profile + Trust & Continuity. Avoid generic settings, profile residue, random preferences dump.

## App Store screenshot rule

Any screenshot-ready UI must satisfy:

- real or clearly controlled fixture data
- no fake claim
- no fake sync/proof
- no hidden backend assumption
- visually premium
- clear user benefit
- not too dense
- native iPhone safe area
- no placeholder copy
- no internal jargon overload

## Validation expectations

Discover repo validation. Potential commands:

```bash
make help
make doctor
make validate
make test
xcodebuild -list
```

For UI work, installed prompts must require:

- Swift build validation where feasible
- preview compilation where feasible
- screenshot/preview proof where repo supports it
- accessibility review
- visual QA report

If screenshot tooling is missing, generated prompts should install or document the expected path without faking screenshots.

## Forbidden scope

Do not:

- redesign all app screens in this installer
- rewrite the app shell in this installer
- create duplicate design tokens
- create duplicate component libraries
- move backend truth into SwiftUI
- make UI claims without proof
- stage `.codex/runs` unless policy requires it
- create Figma-only artifacts
- introduce generic productivity-app design language

## Hard Red stop conditions

Stop if:

1. active frontend canon cannot be found and no honest mapping can be created
2. design token path cannot be identified
3. generated UI Studio would duplicate active visual canon
4. required runner headers cannot be preserved
5. installer would perform broad UI implementation instead of installing the studio
6. UI quality bar would conflict with active canon
7. worktree has unrelated dirty changes that would be overwritten

## Final response format

Return:

```md
# AMB-FLAGSHIP-UI-CODEX-STUDIO-INSTALL-01 Result

## Status

GREEN / YELLOW / RED

## Summary

## Active frontend paths discovered

## UI Studio artifacts installed

## Skills / review boards installed

## Generated UI prompts

## Visual QA gates installed

## Validation

## Risks

## Worktree hygiene

## Rollback

## Recommended next command
```

## Success definition

This installer succeeds only if Codex now has a clear Ambitions-specific system for building UI that can plausibly pass as the work of a world-class native Apple frontend/design team.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

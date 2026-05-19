# UI Studio Screen State Matrix

Status: Active frontend control-plane matrix
Authority: subordinate to `docs/truth/*` and `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`

This matrix defines the screen-state coverage that the UI Studio prompt family must preserve. It is a planning and proof artifact, not product proof.

## Surface Coverage

| Prompt | Surface / object | Required state coverage | Proof focus | Must not become |
| --- | --- | --- | --- | --- |
| `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM` | All flagship surfaces | empty, normal, dense, recovery, error, reduced motion, large Dynamic Type, small iPhone, large iPhone | Surface brief contract enforcement, state inventory, and anti-pattern fencing | a vague prompt wrapper |
| `UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW` | Tokens, materials, and chrome | normal, dense, reduced motion, large Dynamic Type, contrast boundaries | Token truth and reuse discipline | a duplicate design system |
| `UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION` | Today / Reality Meridian | empty, normal, dense, recovery, error, schedule conflict, protected time, away mode | Temporal hierarchy and object dominance | a dashboard or calendar clone |
| `UI-STUDIO-04-START-HERE-COMMAND-OBJECT` | Start Here command object | recommended, active, up next, in progress, needs closure, recovery | Resolver labels and action grammar | a generic recommendation card |
| `UI-STUDIO-05-FIVE-SURFACE-COMPOSITION` | Today, Goals, Capture, Time, You | all primary and fallback states for the five top-level surfaces | One-primary-object discipline across the shell | a universal card stack |
| `UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS` | Closure, recovery, interruption | recovery, blocked, interrupted, stale, error, undoable-close | Recovery language and control affordances | shame language or fake urgency |
| `UI-STUDIO-07-TRUST-CONTINUITY-UX` | You / trust / continuity | privacy, redaction, unavailable, stale, signed-out, limited-access | Trust controls and continuity clarity | a generic settings dump |
| `UI-STUDIO-08-ONBOARDING-CATEGORY-UX` | Onboarding and category education | empty, setup-needed, first-run, permission-boundary, skipped-later | Honest setup, no fake commitments | a motivational wizard |
| `UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX` | Preview and screenshot proof | empty, normal, dense, recovery, error, reduced motion, large Dynamic Type, small iPhone, large iPhone | Preview fixture coverage, screenshot inventory requirements, actual rendered screenshot proof, accessibility proof, device proof, and release proof stay separate | fake screenshot claims |
| `UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM` | Review and red-team posture | generic, fake, inaccessible, over-designed, under-polished, Plan residue, dashboard drift | Anti-generic failure detection | a greenwashed review |

## Required Interpretation

- Each prompt file must stay inside its stated object family.
- `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM` must install the reusable surface brief contract before any future implementation prompt is drafted.
- The brief contract must carry the required fields listed in `UI_STUDIO_OPERATING_SYSTEM.md`.
- Empty, recovery, and error states are required proof surfaces, not optional edge cases.
- Reduced motion and large Dynamic Type are required proof states where layout or motion is affected.
- Screenshot proof is a controlled artifact, not a claim of release readiness.

## Non-Claims

This matrix does not claim implementation, simulator proof, or release proof.

## Proof Boundary

- Preview fixtures are required for the owned state set when the surface can show them.
- Screenshot inventory requirements are tracked separately from screenshot capture.
- Actual rendered screenshot proof is only true when the screenshots have been captured and stored as proof artifacts.
- Accessibility proof is a distinct claim from screenshot inventory or preview coverage.
- Device proof is a distinct claim from screenshot inventory, accessibility proof, and preview coverage.
- Release proof is a distinct claim from all of the above.

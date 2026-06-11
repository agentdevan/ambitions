# AMB-960 / UIQL-005 Visual Anatomy Purge

Status: Green for the scoped AMB-960 visual-anatomy gate.
Linear issue: AMB-960.
Sequence label: UIQL-005. This label is not a Linear identifier.
Date: 2026-06-11.
Branch: main.

## Scope

AMB-960 removes visible card/list/dashboard/form-stack anatomy from active first viewports. This is not a rename exercise and does not claim complete UIQL reconstruction, accessibility certification, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, or PLOS runtime completeness.

## Scan Inventory

Commands and logs:

- `artifacts/ui-quality-lockdown/script-output/AMB-960-visual-anatomy-scan.log` - 3,177-line active-runtime anatomy scan covering Card, Tile, Dashboard, Panel, Chip, Pill, Banner, Container, RoundedRectangle, background, overlay, shadow, stacked root anatomy, and row/list patterns.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh` - passed after final repair.
- `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log` - changed Swift source scan passed for newly added blockers.
- `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log` - changed Swift source banned-copy scan passed.
- `artifacts/ui-quality-lockdown/script-output/uiql-shell.log` - shell scan passed.
- `artifacts/ui-quality-lockdown/script-output/AMB-960-post-repair-build.log` - final simulator build passed with `** BUILD SUCCEEDED **`.

Failed or non-closing repair logs:

- `artifacts/ui-quality-lockdown/script-output/AMB-960-create-capture-focused-ui-tests.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-960-shell-owned-create-goal-focused-ui-test.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-960-shell-owned-create-goal-focused-ui-test-after-helper.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-960-shell-owned-create-goal-focused-ui-test-final.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-960-shell-command-quick-capture-ui-test.log`

Those failed logs exposed a shell-command UI selector/harness issue during repair. They are retained as tooling evidence only and are not used as Green proof.

## Classification Table

| Area | Classification | Decision |
| --- | --- | --- |
| `YouRootSurface.swift` priority governance rows | Active first-viewport UI, needs replacement | Replaced the first-viewport settings/list wall with one primary governance rail object. Remaining controls are lower navigation, not first-viewport structure. |
| `AppShellView.swift` activated Capture seam | Active first-viewport UI, needs replacement | Replaced the tall staged proof/form stack with a compact composer-only seam above the dock, opaque background, full-width field, and short receipt subtitle. |
| `CreateGoalScreen.swift` hero/intake/composer cards | Active first-viewport UI, needs replacement | Replaced the first viewport with one line-based setup object that contains goal framing, input, type/pace/date hints, and first-read trust copy. |
| Today root | Active first-viewport UI, acceptable after visual inspection | Current screenshot reads as one Reality Meridian / Start here object with source, receipt, and action, not a card stack. |
| Goals root | Active first-viewport UI, acceptable after visual inspection | Current screenshot reads as a direction object with subordinate equal-weight area labels and one featured goal object. The small labels are not the root structure. |
| Time root | Active first-viewport UI, acceptable after visual inspection | Current screenshot reads as a LifeShape Field object with line-based measures, not a calendar/card dashboard. |
| Motion root | Active first-viewport UI, acceptable after visual inspection | Current screenshot reads as Motion Current with subordinate Local / Source-led / Receipt labels. Labels are not the root anatomy. |
| Drill-down sheets, detail screens, and lower navigation sections | Active drill-down UI | Not closed by AMB-960 unless visible in first viewport. They remain subject to later AMB issues and local gates. |
| Shared primitives such as `AppCard`, `HeroCard`, `CaptureRoutingPrimitiveStage`, `CaptureRoutingPrimitiveLine`, `TagPill`, and `RoundedRectangle` | Shared primitive or supporting API | Not deleted globally. AMB-960 governs visible first-viewport anatomy, not every supporting symbol. |
| Preview/test/internal model names such as Dashboard/Card in models or tests | Preview/test-only or internal model name | Not product Green proof and not active first-viewport anatomy by itself. |

## Replacements Made

- `Native/Ambitions/Features/You/YouRootSurface.swift`
  - Converted the visible priority governance area from a multi-row/column settings-like stack into a single primary line-rail object.
  - Kept accessibility summaries richer than the shortened visible first-viewport copy.

- `Native/Ambitions/App/AppShellView.swift`
  - Collapsed activated Capture from a tall staged proof/form stack into a compact composer seam.
  - Removed the first-viewport route proof stack from activated Capture and moved the proof promise into short visible receipt copy.
  - Made the seam opaque and short enough to avoid Today content collision and dock clipping.

- `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
  - Replaced the first visible hero/intake/composer-card sequence with one setup object.
  - Kept the goal input, type selector, pace/date hints, and first-read trust line inside the single object.

## Remaining Accepted Items

- The Create Goal presentation remains an iOS-style sheet. AMB-960 rejects stacked form-card content inside the sheet; it does not require deleting native sheet presentation.
- Rounded rectangles remain where they serve native controls or fields and do not read as a visible card stack.
- Goals area labels and Motion status labels remain subordinate. They do not define the root structure.
- Lower navigation rows in You remain below the primary object and are not used as the first-viewport proof claim.

## Screenshot Verdict

| Surface | Screenshot | Verdict |
| --- | --- | --- |
| Today | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-today.png` | Green. Reality Meridian / Start here remains the dominant object. |
| Goals | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-goals.png` | Green. Direction object and subordinate area labels replace dashboard/card-stack reading. |
| Time | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-time.png` | Green. LifeShape Field reads as one native field. |
| Motion | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-motion.png` | Green. Motion Current reads as one proof/progress object with subordinate labels. |
| You | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-you.png` | Green. First viewport no longer reads as a settings wall or multi-card dashboard. |
| Activated Capture | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-capture-activated.png` | Green. Compact composer seam replaces the tall staged proof/form stack. |
| Create Goal | `artifacts/ui-quality-lockdown/screenshots/amb-960/AMB-960-after-create-goal.png` | Green. First viewport is one setup object inside the native sheet, not stacked hero/intake/composer cards. |

## Gates

Green:

- First viewport of each root surface no longer reads as header + card + card + chips.
- Screenshots were visually inspected, not merely recorded as paths.
- Remaining container terms are classified and justified above.
- The repair changed visible anatomy; it was not a Card-to-Surface rename.

Yellow:

- Failed command-sheet UI selector logs remain as tooling/repair evidence only. Final AMB-960 closure does not rely on those selectors.
- AMB-968 and AMB-970 still own formal accessibility variant proof and independent red-team visual audit.

Red:

- None remaining for the scoped AMB-960 visual anatomy purge after final screenshots and build.

## No-Claim Boundaries

This report does not claim owner approval, release readiness, TestFlight readiness, App Store readiness, full accessibility certification, VoiceOver certification, Dynamic Type matrix completion, Reduce Motion certification, physical-device proof, performance proof, privacy/legal approval, or completion of AMB-961+.

## Next Dependency

Next executable issue after AMB-960 closeout is AMB-961 / UIQL-006 Active UI Copy Purge.

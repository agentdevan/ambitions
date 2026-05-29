<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-74875326, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-5843157, AMB28-same_source_file_targeted_by_multiple_active_batches-62868623, AMB28-same_source_file_targeted_by_multiple_active_batches-67473140, AMB28-same_source_file_targeted_by_multiple_active_batches-72454456, AMB28-same_source_file_targeted_by_multiple_active_batches-87716319, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01 - Run Global Batch Train to Completion With Yellow Continuation

## Batch ID

GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01

## Runner Command

```bash
KEEP_GOING_ON_YELLOW=1 AUTO_BRANCH=0 make batch BATCH=GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01 PROMPT=prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md
```

or:

```bash
KEEP_GOING_ON_YELLOW=1 AUTO_BRANCH=0 scripts/ambitions-codex-train.sh GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01 prompts/batches/GLOBAL-BATCH-TRAIN-AUTONOMOUS-COMPLETE-01.md
```

## Objective

Run the Ambitions global batch train from the current repo state until all active planned batches are complete, accepted Yellow with documented owner/reason, or blocked by a true Hard Red / external tool policy.

The train must continue through normal Green and accepted Yellow states. Red states must trigger repair cycles, not manual handoff, unless the Red is a Hard Red stop condition or a tool/policy limit that cannot be bypassed safely.

Primary outcome:

```text
Complete the remaining Ambitions global batch train as far as technically possible, install the full visual canon/moat overlay and front-end implementation sequence, commit after every completed batch, and push to main after every completed batch when allowed by the local terminal/GitHub credentials.
```

## Active Source Truth To Inspect First

Read before any edits or continuation:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
README.md
docs/README.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/product-moat-alignment-report.md
docs/status/signature-object-moat-gap-map.md
docs/status/visual-canon-moat-installation-report.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
docs/codex/BATCH_REGISTRY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md
docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md
docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md
docs/codex/POST_BATCH_GATE_REGISTRY.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
```

If a file is missing, record it and continue with the nearest active equivalent. Do not invent proof.

## Preflight

Run:

```bash
git status --short --branch
git rev-parse HEAD
git fetch origin main
git status --short --branch
```

If local `main` is behind `origin/main`, rebase before continuing:

```bash
git rebase origin/main
```

If the worktree is dirty, classify every dirty file as:

```text
task-owned
external/operator-owned
generated scratch
stale artifact
unsafe unknown
```

Do not start broad implementation over unsafe unknown dirty state.

If dirty files are task-owned from this controller or prior accepted batch output, continue.

If dirty files are external/operator-owned, preserve them and avoid touching them.

If dirty state cannot be safely classified, stop Red with exact file list and recommended terminal commands.

## Continuation Policy

Continue automatically through:

```text
Green
Accepted Yellow
Yellow caused only by missing visual proof, blocked screenshots, unavailable local simulator, unavailable Xcode, or non-release proof gaps
Yellow caused by known compatibility seams explicitly documented
```

Do not stop merely because a batch is Yellow if:

```text
the patch is safe
the owner/reason is recorded
release/privacy/accessibility claims are conservative
the next batch can proceed safely
KEEP_GOING_ON_YELLOW=1 is active
```

Stop only for Hard Red conditions or unresolvable external tool policy.

## Red Repair Policy

For ordinary Red:

```text
1. Read Red report.
2. Identify root cause.
3. Create bounded repair plan.
4. Apply the smallest safe repair.
5. Rerun needs review validation.
6. Rerun the batch.
7. Continue train.
```

Do not hand off ordinary Red unless repair would require unsafe architecture, destructive data migration, external paid services, unavailable secrets, or user approval.

## Batch Discovery And Sequence

Detect the real number of planned batches from active registry/queue docs. Do not assume the count.

Classify all entries as:

```text
completed
active
next eligible
blocked_until_dependency
historical complete/do-not-run
obsolete
archive-candidate
delete-candidate
new visual/moat lane
consolidate
split
senior-review-required
spark-safe
```

Do not reactivate completed batches.

Use the most optimal global sequence available from active truth, EFC overlay, visual-canon/moat overlay, and current active-batch state.

Default priority order:

```text
1. Active source truth / canon authority
2. Ambition Graph foundations
3. Proof / Closure / Recovery lifecycle
4. RecommendationTrace / Trust Seam / Why this?
5. Personal Runtime / local trust controls
6. Shared shell / materials / Continuity Dock
7. Today / Reality Meridian
8. Capture / Atmosphere Composer / route reveal
9. Time / Pressure Ledger / Reflow Preview
10. Goals / Constellation Atlas / Ambition Graph / Proof Trail
11. You / User System Profile / Personal Runtime
12. Moat addendum states
13. Accessibility / Dynamic Type / VoiceOver / Reduce Motion / contrast
14. Preview fixtures / visual QA gates
15. Repo cleanup / obsolete authority quarantine
16. Validation/proof packets
17. Final integration and proof honesty
```

## Required Execution

For every active eligible batch:

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

or:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

After each completed Green or accepted Yellow batch, run:

```bash
git status --short
git diff --check
git diff --cached --check
```

Then stage exact changed paths, commit, and push:

```bash
git add <exact changed paths>
git commit -m "<BATCH_ID>: <concise result>"
git push origin main
```

If remote moved:

```bash
git fetch origin main
git rebase origin/main
# rerun relevant validation
git push origin main
```

If `git add`, `git commit`, or `git push` is blocked by outer app/tool policy, do not pretend. Stop Yellow or Red as appropriate and output exact terminal commands for the user.

## Visual Canon And Moat Requirements

The final train must preserve this moat thesis:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

The durable product hierarchy is:

```text
Identity Direction
  -> Life Area
    -> Ambition
      -> Outcome
        -> Goal Thread
          -> Commitment
            -> Step
              -> Closure Event
                -> Proof
                  -> Reflection
                    -> Adaptation / Recovery
```

The locked visual system is:

```text
Shell Overview Board
Today / Reality Meridian
Goals / Constellation Atlas
Capture / Atmosphere Composer
Time / Day Pressure Ledger
Time / Week Pressure Ledger with Reflow Crown
Time / Month LifeShape Node Calendar
You / User System Profile
Moat Alignment Visual Addendum
```

## Required Front-End Installation Targets

Complete or queue/repair until installed:

```text
RealityMeridianView
MeridianExpansionSurface
ProofBackedStartHere
ExpectedProof
LastProofAnchor
StillCountsClosure
RecoveryThreadPrompt
WhyThisTrustSeam
ReceiptDrawer

ConstellationAtlasView
OrbitalLensView
LifeAreaConstellationIcon
AmbitionGraphView
ProofTrailView
NextMilestoneView
RecommendedCommitmentView

AtmosphereComposerView
CaptureComposerField
CaptureRouteRevealView
SaveAsProofRoute
MakeCommitmentRoute
GrowIntoGoalRoute
MarkConstraintRoute
ReflectRoute
HoldNeedsAPlaceRoute

LifeShapeFieldView
PressureLedgerDayView
PressureLedgerWeekView
LifeShapeMonthView
ReflowCrown
ReflowPreviewView
LifeShapeStatusStrip
PressureCommitmentMarks
ProtectedTimeBand
BestFitPlacementCapsule
ReflowReceipt

UserSystemProfileView
PlanningSetupSection
PersonalRuntimeView
LocalLearningControls
TrustAutomationControls
PrivacyBoundaryRows
ResetPatternAction
ForgetPatternAction
ExportDeleteResetDirection

ContinuityDock
ContextCrown
TrustSeam
ReceiptSurface
QuietGlass
GraphiteRecess
LuminousTrace
CelestialField
AmbitionsIconGrammar
```

## Surface Hard Rules

### Today

```text
Today uses Reality Meridian.
Start here is attached Meridian Expansion Surface, not a standalone card.
Today must not become a task list, calendar agenda, surface, motivational wallpaper, or focus widget.
```

### Goals

```text
Goals uses Constellation Atlas.
Life areas use constellation-shaped icons made from stars and connecting lines.
Goals must not become surface, score screen, habit tracker, astrology map, or generic goal list.
```

### Capture

```text
Capture resting state is composer-first.
No route labels/chips at rest.
Route reveal appears only after input or explicit expansion.
Capture must not become feed, inbox, chatbot, category board, notes app, or task-entry screen.
```

### Time

```text
Time uses LifeShape Field as pressure-aware calendar field.
Day = one bounded day Pressure Ledger.
Week = seven bounded day lanes with Reflow Crown.
Month = deconstructed LifeShape Node Calendar.
Date ownership is mandatory.
No state crosses date boundary unless underlying commitment spans dates.
No blobs, terrain, weather maps, line graphs, unsafe auto-reflow, or generic calendar clone.
```

### You

```text
You is User System Profile.
Planning Setup is primary.
Personal Runtime exposes local learning, recommendation inputs, reset/forget controls, local storage boundaries, and Trust & Automation.
You must not become social profile, generic account page, admin surface, chatbot settings, or AI-wrapper wall.
```

## Allowed Scope

Allowed:

```text
docs/truth/
docs/AmbitionsCanon/
docs/status/
docs/codex/
docs/README.md
README.md
AGENTS.md
prompts/batches/
Native/Ambitions/App/
Native/Ambitions/Domain/
Native/Ambitions/Persistence/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
Native/AmbitionsTests/
Native/AmbitionsUITests/
Sources/
AppUI/Sources/
scripts/
```

Only modify `project.yml` if source/test additions require it.

## Forbidden Scope

Do not introduce:

```text
external/cloud LLM core dependency
OpenAI/API/cloud model calls in core app
custom hosted personal-data backend
new account/auth system
Supabase/Firebase/server profile assumptions
paid services
hosted CI/cost exposure
R2 personal-data usage
iCloud/CloudKit claim without real entitlement/source/tests
App Store/TestFlight/device readiness claim
privacy/legal approval claim
accessibility conformance claim without proof
Plan as top-level tab
sixth top-level tab
chatbot/Assistant primary UI
scores/proof threads/badges/leaderboards/productivity rankings
shame language
```

## Hard Red Stop Conditions

Stop only if one of these is introduced and cannot be safely repaired:

```text
Plan appears as top-level tab.
A sixth top-level tab is added.
Today becomes task list/calendar timeline/focus widget.
Start here becomes detached card stack.
Capture becomes feed/inbox/chatbot/category board.
Time becomes graph/terrain/blob/weather map/dashboard/calendar clone.
Goals becomes KPI dashboard/habit ring/life score/astrology.
You becomes social profile/admin console/AI settings wall.
Core flow requires external/cloud LLM.
Core flow requires custom hosted backend/account.
Recommendation lacks Why this/source/control path.
Adaptive behavior lacks receipt or inspectability.
Proof/recovery state uses shame language.
Release/privacy/accessibility claim is made without proof.
Visual-only object lacks accessibility equivalent.
```

## Validation Expectations

Run after every meaningful batch:

```bash
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
```

When source changes are made:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

When tests are available:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsUITests test
```

If unavailable, report not run with reason.

## Visual Proof Expectations

For UI changes, produce or update preview fixtures for:

```text
Today_RealityMeridian_Default
Today_ProofBackedStartHere
Today_RecoveryThread
Goals_ConstellationAtlas_Default
Goals_AmbitionGraph_ProofTrail
Capture_AtmosphereComposer_Resting
Capture_RouteReveal_PostInput
Time_Day_PressureLedger
Time_Week_ReflowCrown
Time_Month_LifeShapeNodeCalendar
Time_ReflowPreview
You_UserSystemProfile_Default
You_PersonalRuntime_LocalTrust
Moat_Addendum_AllStates
```

If screenshots cannot be rendered, record visual proof as not produced. Do not claim visual QA passed.

## Accessibility Requirements

Every implemented visual object must support:

```text
VoiceOver semantic grouping
Dynamic Type behavior
Reduce Motion equivalent
Increase Contrast compatibility
44pt minimum touch targets
non-color-only state encoding
clear focus order
```

Do not claim accessibility conformance without proof.

## Final Report Required

Report exactly:

```text
Status: Green / Yellow / Red
Controller Batch ID:
Start commit:
Final commit:
Branch:
Pushed to main: yes/no
Detected total planned batches:
Completed batches:
Accepted Yellow batches:
Skipped completed batches:
Blocked batches:
Remaining active batches:
Visual canon installed:
Moat addendum installed:
Overlay/train installed:
Global sequence updated:
Full front end installed:
Docs changed:
Source changed:
Preview fixtures changed:
Tests changed:
Scripts/gates changed:
Commands run:
Commands passed:
Commands needs review:
Commands not run:
Visual proof:
Accessibility proof:
Privacy/local-first proof:
Release claims allowed:
Release claims forbidden:
Unimplemented:
Unproven:
Rollback notes:
Next required human action:
```

## Success Criteria

Green only if:

```text
all active planned batches are Green or accepted Yellow
visual canon authority is installed
moat addendum authority is installed
optimized global train overlay exists
remaining batch sequence is updated
front-end implementation matches locked visual canon at source/previews level
all completed batches are committed and pushed to main
validation passed or missing proof is honestly recorded
no forbidden architecture or claims were introduced
```

Yellow if:

```text
visual canon and overlay are installed
some implementation batches complete
remaining work is explicitly queued with blockers
validation is partially blocked by environment
push is blocked by external policy
```

Red if:

```text
canon docs are not installed
overlay/train is not installed
runner cannot safely proceed
forbidden product/architecture direction is introduced
repo cannot build after source changes where build was previously possible
false release/privacy/accessibility claims are made
```

## Final Operating Rule

Do not optimize Ambitions for generic planning.

Optimize Ambitions for:

```text
ambition survival
proof-backed execution
private local context
trustworthy recovery
native iPhone execution
inspectable local intelligence
```

Run until completion unless a Hard Red stop condition or external git/tool policy makes further execution impossible.

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

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

# GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01 - Install Full Visual Canon + Moat-Aligned Global Batch Train

## Batch ID

GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01

## Runner Command

```bash
make batch BATCH=GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01 PROMPT=prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md
```

or:

```bash
scripts/ambitions-codex-train.sh GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01 prompts/batches/GLOBAL-VISUAL-CANON-MOAT-INSTALL-TRAIN-01.md
```

## Objective

Install the complete locked Ambitions visual canon, moat addendum, optimized implementation overlay, global batch train sequence, and then execute the full remaining Ambitions batch train autonomously until the planned product/front-end scope is complete.

The final target is not a generic productivity app. The final target is a premium native iPhone-first personal ambition operating system whose moat is:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

The execution objective is:

```text
Finish installing the visual canon and moat authority, generate the optimal remaining global implementation train, then run the train to completion with repair cycles as needed. Commit and push to main after every completed batch.
```

Do not merely save prompts. Do not stop after planning. Do not stop after installing docs if implementation batches remain. Do not reactivate already completed batches. Do not falsely claim completion.

## Mandatory Preflight

Before editing anything:

```bash
git status --short --branch
git rev-parse HEAD
git fetch origin main
```

If working on `main`, confirm local `main` is not behind `origin/main`.

If dirty files exist, classify them:

```text
task-owned
external/operator-owned
generated scratch
stale artifact
unsafe unknown
```

Do not start broad implementation over unknown dirty state.

If dirty state contains only known task-owned files from this controller batch, continue.

If dirty state contains external/operator-owned files, record them and avoid touching them.

If dirty state blocks the runner, create a narrow reconciliation commit only for safe task-owned files, or stop Red only if continuing would overwrite unknown work.

## Active Source Truth To Inspect First

Read in this order before changing source or docs:

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
docs/status/product-moat-alignment-report.md
docs/status/signature-object-moat-gap-map.md
docs/status/release-evidence-packet.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
docs/codex/BATCH_REGISTRY.md
docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md
docs/codex/POST_BATCH_GATE_REGISTRY.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
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

If any listed file is missing, record it and continue with the closest active equivalent. Do not invent proof.

## Locked Visual Canon To Install

Install this locked visual north-star set as active supporting canon:

```text
1. Shell Overview Board - product-family / IA / material reference
2. Today / Reality Meridian - top-level daily execution reference
3. Goals / Constellation Atlas - top-level direction / life-area reference
4. Capture / Atmosphere Composer - resting/default intake reference
5. Time / Day Pressure Ledger - day-level shaping reference
6. Time / Week Pressure Ledger with Reflow Crown - primary Time reference
7. Time / Month LifeShape Node Calendar - month scan / drill-down reference
8. You / User System Profile - system control reference
9. Moat Alignment Visual Addendum - Ambition Graph / Proof / Trust / Recovery / Personal Runtime reference
```

Install this principle:

```text
The top-level visual north stars show primary surfaces at rest or overview state. The Moat Alignment Visual Addendum is required supporting canon showing the defensible mechanics: Ambition Graph, proof-backed execution, inspectable recommendation reasoning, recovery, route reveal after input, preview-before-reflow, and Personal Runtime/local trust controls.
```

## Required Phase 0 - Install Visual Canon Authority

Create or update:

```text
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
```

Include:

```text
Status and authority
Locked visual north-star set
Moat alignment rule
Shell Overview Board role
Moat Alignment Visual Addendum role
Shared material system
Continuity Dock and icon grammar
Shared interaction primitives
Today / Reality Meridian rules
Goals / Constellation Atlas rules
Capture / Atmosphere Composer rules
Time / LifeShape Field rules
You / User System Profile rules
Moat addendum state references
SwiftUI component mapping targets
Preview fixture matrix
Accessibility requirements
Anti-drift / Hard Red rules
Validation and proof honesty
Next implementation sequence
```

Update narrow index links where appropriate:

```text
docs/AmbitionsCanon/README.md
docs/README.md
README.md
AGENTS.md
docs/status/signature-object-moat-gap-map.md
docs/status/product-moat-alignment-report.md
```

Do not claim app implementation just because docs were created.

## Required Phase 1 - Create Optimized Overlay / Train

Create or update a visual-canon/moat implementation overlay:

```text
docs/codex/VISUAL_CANON_MOAT_IMPLEMENTATION_OVERLAY.md
docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md
docs/status/visual-canon-moat-installation-report.md
```

The overlay must classify all remaining incomplete batches and any required new batches into:

```text
active
supporting
historical
obsolete
archive-candidate
delete-candidate
consolidate
split
must-run-before-ui
must-run-after-domain
visual-proof-required
senior-review-required
spark-safe
blocked-until-clean
```

The optimized sequence must prioritize:

```text
1. Source truth and visual canon authority
2. Ambition Graph domain foundations
3. Proof / Closure / Recovery lifecycle
4. RecommendationTrace / Trust Seam / Why this?
5. Personal Runtime / local trust controls
6. Shared material system / Continuity Dock / shell primitives
7. Today / Reality Meridian
8. Capture / Atmosphere Composer and route reveal
9. Time / Pressure Ledger / Reflow Preview
10. Goals / Constellation Atlas / Ambition Graph / Proof Trail
11. You / User System Profile / Personal Runtime
12. Moat addendum state screens
13. Accessibility, Dynamic Type, VoiceOver, Reduce Motion, contrast
14. Preview fixtures / visual QA gates
15. Repo cleanup / obsolete canon quarantine
16. Validation/proof packets
17. Final integration and release-proof honesty
```

If the current train has 146 batches, classify all 146. If it has more or fewer, detect and record the actual count. Do not invent the number.

Do not reactivate completed batches.

## Required Phase 2 - Generate Missing Batch Prompts

Generate any missing runner-compatible batch prompts needed to install the full visual/moat front end.

Every generated Ambitions batch prompt must include:

```text
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

Create or update prompts under:

```text
prompts/batches/
```

At minimum, ensure the train contains implementation batches for:

```text
AMBITION-GRAPH-FOUNDATION-01
PROOF-RECOVERY-LIFECYCLE-01
RECOMMENDATION-TRACE-TRUST-SEAM-01
PERSONAL-RUNTIME-LOCAL-TRUST-01
SHELL-CONTINUITY-DOCK-MATERIALS-01
TODAY-REALITY-MERIDIAN-VISUAL-01
CAPTURE-ATMOSPHERE-COMPOSER-VISUAL-01
TIME-PRESSURE-LEDGER-VISUAL-01
GOALS-CONSTELLATION-ATLAS-VISUAL-01
YOU-USER-SYSTEM-PROFILE-VISUAL-01
MOAT-ADDENDUM-STATE-SCREENS-01
ACCESSIBILITY-VISUAL-CANON-01
VISUAL-QA-PREVIEW-FIXTURES-01
FINAL-VISUAL-CANON-INTEGRATION-01
```

Use existing batch IDs if equivalent active batches already exist. Do not duplicate semantically identical batches.

## Required Phase 3 - Execute Global Batch Train Autonomously

After the overlay and sequence are installed, start the optimized global train.

Use the runner for every batch:

```bash
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

or:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

Continue until all active remaining planned batches are Green or accepted Yellow.

Do not stop on ordinary Red. Instead:

```text
1. Read Red report.
2. Identify root cause.
3. Generate bounded repair plan.
4. Apply repair.
5. Re-run validation.
6. Re-run batch.
7. Continue train.
```

Only Hard Red stop conditions may stop the train.

After each completed Green or accepted Yellow batch:

```bash
git status --short
git diff --check
git diff --cached --check
git add <exact changed paths>
git commit -m "<batch id>: <concise result>"
git push origin main
```

If push fails because remote moved:

```bash
git fetch origin main
git rebase origin/main
rerun relevant validation
git push origin main
```

If git commands are blocked by outer app policy, do not pretend. Record the exact blocker and output exact terminal commands for the user.

## Required Implementation Scope

The train must complete the full front-end installation toward the locked canon.

### Shared Shell / Materials

Implement or align:

```text
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

### Today

Implement or align:

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
```

### Goals

Implement or align:

```text
ConstellationAtlasView
OrbitalLensView
LifeAreaConstellationIcon
AmbitionGraphView
ProofTrailView
NextMilestoneView
RecommendedCommitmentView
```

### Capture

Implement or align:

```text
AtmosphereComposerView
CaptureComposerField
CaptureRouteRevealView
SaveAsProofRoute
MakeCommitmentRoute
GrowIntoGoalRoute
MarkConstraintRoute
ReflectRoute
HoldNeedsAPlaceRoute
```

### Time

Implement or align:

```text
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
```

### You

Implement or align:

```text
UserSystemProfileView
PlanningSetupSection
PersonalRuntimeView
LocalLearningControls
TrustAutomationControls
PrivacyBoundaryRows
ResetPatternAction
ForgetPatternAction
ExportDeleteResetDirection
```

### Domain / Moat Support

Implement or scaffold safely:

```text
Ambition
Commitment
Proof
Constraint
RecoveryThread
RecommendationTrace
Reflection
Adaptation / Pivot
ClosureEvent
```

Preserve compatibility if existing models use older names.

## Required Surface Rules

### Today / Reality Meridian

```text
Start here is not a standalone card.
It is an attached Meridian Expansion Surface with a luminous leading edge.
Today must not become a task list, agenda, surface, or focus widget.
```

### Goals / Constellation Atlas

```text
Each life area constellation icon is made from stars and connecting lines.
State overlays are secondary.
Goals must not become a surface, score screen, habit tracker, astrology map, or generic goal list.
```

### Capture / Atmosphere Composer

```text
Resting state is composer-first.
No route labels/chips at rest.
Route reveal appears only after user input or explicit expansion.
Capture must not become feed, inbox, chatbot, category board, or notes app.
```

### Time / LifeShape Field

```text
Day = one bounded day Pressure Ledger.
Week = seven bounded day lanes with Reflow Crown.
Month = deconstructed LifeShape Node Calendar.
Date ownership is mandatory.
No state crosses date boundary unless underlying commitment spans dates.
No blobs, terrain, weather maps, line graphs, or unsafe auto-reflow.
```

### You / User System Profile

```text
You is system profile, not social/account/admin.
Planning Setup is primary.
Personal Runtime exposes local learning, recommendation inputs, reset/forget controls, local storage boundaries, and Trust & Automation.
```

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

Stop only if any are introduced and cannot be repaired safely:

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

Run the strongest local validation available after each meaningful batch.

Baseline:

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

If screenshots cannot be rendered in the environment, record visual proof as not produced. Do not claim visual QA passed.

## Accessibility Requirements

Every implemented visual object must have:

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

## Push Requirement

After every completed batch:

```bash
git add <exact changed paths>
git commit -m "<BATCH_ID>: <result>"
git push origin main
```

At final completion:

```bash
git status --short --branch
git log --oneline -10
```

Final status must identify latest pushed commit.

## Final Report Required

At the end of this controller run, report:

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
visual canon authority is installed
moat addendum authority is installed
optimized global train overlay exists
remaining batch sequence is updated
all active planned batches are Green or accepted Yellow
front-end implementation matches locked visual canon at source/previews level
validation passed or missing proof is honestly recorded
all completed batches are committed and pushed to main
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

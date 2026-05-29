<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-38824517, AMB28-same_source_file_targeted_by_multiple_active_batches-1350962, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-42995888, AMB28-same_source_file_targeted_by_multiple_active_batches-46654715, AMB28-same_source_file_targeted_by_multiple_active_batches-5843157, AMB28-same_source_file_targeted_by_multiple_active_batches-62868623, AMB28-same_source_file_targeted_by_multiple_active_batches-67473140, AMB28-same_source_file_targeted_by_multiple_active_batches-72454456, AMB28-same_source_file_targeted_by_multiple_active_batches-87716319, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932 and 3 more

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

# MOAT-ALIGNMENT-01 — Ambitions Product Moat Realignment

## Batch ID

MOAT-ALIGNMENT-01

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-ALIGNMENT-01 prompts/batches/MOAT-ALIGNMENT-01.md
````

or:

```bash
make batch BATCH=MOAT-ALIGNMENT-01 PROMPT=prompts/batches/MOAT-ALIGNMENT-01.md
```

## Objective

Completely realign the Ambitions repo around the accepted product moat upgrade:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

Ambitions must no longer risk drifting into a generic AI planner, task manager, calendar optimizer, habit tracker, productivity surface, chatbot, or desktop-productivity companion.

The repo must be realigned so the active product direction, implementation plans, source terminology, UI copy, tests, design-system gates, Codex process, and future batch train all reinforce this thesis:

```text
Ambitions is a premium native iPhone, local-first personal ambition operating system that helps users define who they are becoming, turn that into grounded commitments, execute the next credible action, capture proof, and recover when reality breaks the plan — while keeping the personal life graph local-first, inspectable, and user-controlled.
```

This batch must implement every safe repo-level alignment needed for the full 16-part moat review:

1. Market category hardening.
2. Product identity sharpening.
3. Ambition Graph elevation.
4. Proof-centered retention engine.
5. Recovery as first-class execution state.
6. Inspectable local recommendation reasoning.
7. Local-first personal context as visible trust feature.
8. Signature Object moat enforcement.
9. Surface-by-surface moat upgrades.
10. Durable data-model and switching-cost improvements.
11. Moat-aligned metrics.
12. Visual and interaction moat rules.
13. Native Apple execution-layer posture.
14. Current product risk cleanup.
15. Implementation phasing.
16. Codex autonomy/gate hardening.

This batch must not falsely claim that huge unfinished systems are production-complete. It must align source truth, implementation foundations, tests, docs, scripts, prompts, and acceptance gates so future implementation cannot drift.

## Preservation Rule

This batch must not reduce Ambitions’ planned capability breadth.

Do not remove or weaken planned task, calendar, time-shaping, daily planning, capture, reminder, widget, Live Activity, App Intent, Share Extension, recommendation, review, automation, proof, receipt, accessibility, privacy, or Apple-native integration capabilities merely because competitors have adjacent versions.

The goal is to elevate those capabilities into Ambitions-native objects and flows:

- tasks become Steps / Commitments
- calendar data becomes LifeShape source material
- daily planning becomes proof-backed commitment shaping
- capture becomes semantic routing into Ambition / Proof / Constraint / Commitment / Reflection / Held Item
- recommendations become inspectable local reasoning
- missed work becomes Closure / Recovery
- settings become User System Profile / Personal Runtime

If a planned capability conflicts with moat direction, preserve the useful capability but change its product role, object ownership, user-facing language, and acceptance criteria. Removal requires explicit proof that the feature is obsolete, harmful, duplicate, or incompatible with active truth.

## Active Source Truth To Inspect First

Read these files before editing anything:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
README.md
AGENTS.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
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

If any listed file is missing, record it in the final report and continue with the closest active equivalent. Do not invent proof.

## Core Product Moat To Install

Use this exact moat hierarchy:

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

Use this exact strategic distinction:

```text
Competitors can copy tasks, calendars, time blocks, reminders, and generic AI planning.

They cannot easily copy a user’s accumulated private ambition graph:
- what the user is becoming
- what proof counts
- what constraints recur
- what recovery works
- what commitments survive reality
- what private context informs local recommendations
- what receipts establish trust over time
```

The product must compete on:

```text
ambition survival
proof-backed execution
private local context
trustworthy recovery
native iPhone execution
inspectable local intelligence
```

The product must not compete primarily on:

```text
automatic scheduling
generic task management
daily planning ritual
calendar optimization
AI chat
habit proof threads
productivity dashboards
team work management
enterprise workflows
```

## Required Strategic Product Truth Changes

Create or update repo truth so the following are explicit and enforceable:

### 1. Add active moat authority

Create:

```text
docs/truth/PRODUCT_MOAT_TRUTH.md
```

This file must be active product strategy authority, subordinate to `PRODUCT_DESIGN_TRUTH.md` only if there is a direct conflict. It must not replace implementation or release truth.

Update:

```text
docs/truth/README.md
README.md
docs/README.md
AGENTS.md
```

so contributors and Codex know this file exists and must be read for product strategy, differentiation, and anti-commodity drift.

`PRODUCT_MOAT_TRUTH.md` must include:

```text
- canonical moat statement
- non-moat commodity list
- defensible object graph
- Ambition Graph hierarchy
- proof-centered retention thesis
- recovery-first execution thesis
- local-first trust thesis
- native Apple execution-layer posture
- surface-by-surface moat requirements
- moat-aligned metrics
- anti-metrics
- forbidden product directions
- Codex patch review questions
- Hard Red drift conditions
```

### 2. Update Product Design Truth without weakening it

Update `docs/truth/PRODUCT_DESIGN_TRUTH.md` to explicitly include the accepted moat upgrade.

Preserve all existing strictness around:

```text
Today / Goals / Capture / Time / You
local-first / on-device-first posture
no core external/cloud LLM
no custom hosted personal-data backend
no chatbot-first UI
no dashboard/card-stack/calendar-clone drift
proof/receipts/closure/recovery
Signature Objects
accessibility and proof honesty
```

Add or strengthen:

```text
Ambition Graph as core product moat
Proof as emotional/data retention engine
Recovery as first-class product state
Commitment as stronger than generic task
RecommendationTrace / Why this? / Trust Seam requirements
Personal Runtime as user-visible local learning/trust control
proof-backed switching cost
ambition survival as core product job
```

### 3. Update Canon Pack

Update compatible active canon docs under `docs/AmbitionsCanon/` to reflect the moat upgrade.

Minimum required docs to inspect and update where needed:

```text
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
```

Do not create duplicate canon if an existing canon file is the right home. Prefer concise, authoritative amendments over sprawling repeated essays.

## Required Implementation Alignment

This batch must make safe source-level changes where feasible. Do not make reckless schema migrations or broad renames without tests and rollback.

### 1. Ambition Graph foundation

Inspect current domain and persistence models.

If safe, add or formalize source-level foundations for:

```text
Ambition
Commitment
Proof
Constraint
RecoveryThread
RecommendationTrace
Reflection
Pivot / Adaptation
```

Use existing models where they already exist. Do not duplicate semantically identical types. If existing objects have older names, add compatibility aliases or adapter layers instead of unsafe mass renames.

Target behavior:

```text
Goal and Step should no longer be the highest-value semantic objects.
The source model should make room for Ambition, Commitment, Proof, Constraint, Recovery, and RecommendationTrace as durable first-class concepts.
```

Required design principle:

```text
Task-like work should be represented as Step or Commitment.
A Commitment is a dated, sized promise tied to an Ambition and expected proof.
```

Recommended fields if adding new models:

```swift
Ambition
- id
- title
- identityStatement
- lifeAreaID
- desiredOutcome
- desiredProofDescription
- activeGoalThreadID
- activeCommitmentID
- knownConstraintIDs
- recoveryPolicy
- privacyClass
- createdAt
- updatedAt
- archivedAt

Commitment
- id
- ambitionID
- goalThreadID
- stepID
- promisedFor
- expectedEffort
- minimumProofDescription
- fitReason
- recoveryPolicy
- status
- createdAt
- updatedAt

Proof
- id
- ambitionID
- goalThreadID
- commitmentID
- closureEventID
- proofType
- artifactReference
- text
- source
- privacyClass
- userConfirmed
- transferPolicy
- createdAt

Constraint
- id
- ambitionID
- label
- patternDescription
- evidenceCount
- lastObservedAt
- userConfirmed
- mitigation
- privacyClass
- createdAt
- updatedAt

RecoveryThread
- id
- ambitionID
- trigger
- priorProofRefs
- whatChanged
- newSmallestCommitment
- status
- receiptID
- createdAt
- updatedAt

RecommendationTrace
- id
- recommendedObjectID
- sourceRefs
- reasonCodes
- uncertainty
- userAction
- declineReason
- createdAt
- expiresAt

Reflection
- id
- ambitionID
- proofID
- closureEventID
- text
- learnedSignal
- createdAt
```

If SwiftData migration risk is high, add these as domain models and fixture-backed scaffolds first, and document the migration plan. Do not break local persistence.

### 2. Proof-centered execution

Upgrade source and tests so proof is treated as central, not decorative.

Where safe:

```text
- Today recommended step should have a proof target / expected proof concept.
- Step closure should support attaching or recording proof.
- Still Counts should be proof-valid, not consolation copy.
- Capture should be able to route content as Proof.
- Goals should expose Proof Trail / proof history direction.
- Time should reason about proof opportunity, not only time fit.
- You should expose proof/privacy controls through Personal Runtime / trust settings.
```

If UI is not ready, add domain/service/test fixtures and acceptance docs so future UI work is forced to implement it.

### 3. Recovery as first-class state

Upgrade closure/recovery models, UI copy, tests, and docs to make recovery a normal path.

Required states:

```text
Completed
Still Counts
Moved
Shortened
Waiting
Blocked
Not Needed
Needs Recovery
Needs Review
Held
Paused
Stalled
Too Large
No Longer True
Ready To Restart
```

Do not use shame language.

Ban active user-facing copy:

```text
needs closure
needs review
proof thread broken
productivity dropped
behind
get back on track
crush your goals
optimize your life
```

Preferred copy:

```text
Reality changed.
Still counts.
Make it smaller.
Recover this thread.
Preserve the proof.
Restart from the last honest point.
```

### 4. Inspectable local recommendation reasoning

Implement or scaffold `RecommendationTrace` and strengthen `Why this?` / Trust Seam behavior.

Every recommendation should be able to expose:

```text
- source refs
- reason codes
- ambition link
- proof gap
- time fit
- known constraint
- uncertainty
- user controls
- what Ambitions will remember
```

Recommendation control options should include where appropriate:

```text
Start now
Open step
Shorten
Move
Still counts
Not today
Wrong recommendation
Why this?
Forget this pattern
```

No generic AI explanation. No “AI recommends.” No model-confidence language.

### 5. Personal Runtime / local trust

Update You/Profile source and docs toward:

```text
User System Profile
Personal Runtime
Trust & Automation
What Ambitions has learned
What Ambitions uses for recommendations
What can be reset
What can be deleted
What is stored locally
What can sync later only through allowed Apple-native user-owned sync
What must never be sent to R2 or any backend
```

If current source still uses `ProfileScreen`, keep compatibility if needed, but user-facing copy must say `You`, `Your System`, `Personal Runtime`, or `Trust & Automation` as appropriate.

Hard requirement:

```text
Do not claim privacy/legal/App Privacy readiness.
Do not claim local-only validation unless validation proof is added.
```

## Required Surface Alignment

### Today

Align Today around:

```text
Reality Meridian
Start Here Surface
one active commitment
proof target
last-proof anchor
recovery action
Trust Seam / Why this?
no task-list fallback as primary structure
```

If current source still uses `DayTimelineRail`, migrate safely toward `RealityMeridian` naming or add a compatibility wrapper with canonical naming.

Hard Red:

```text
Today cannot become a task list, calendar timeline, focus widget, detached card stack, or motivational surface.
```

### Goals

Align Goals around:

```text
Constellation Atlas
Orbital Lens
Ambition Graph
Proof Trail
life areas as equal-weight user-owned structure
no ranked life score
no KPI surface
no habit-ring dominance
```

If current source uses `GoalMissionControl`, migrate safely toward `ConstellationAtlas` / `OrbitalLens` naming or add canonical wrappers while preserving compatibility.

### Capture

Align Capture around:

```text
Atmosphere Composer
quiet input
route reveal after input
Save as Proof
Grow into Goal
Make Commitment
Mark as Constraint
Reflect
Needs a Place
Ready to Place
Hold
```

Hard Red:

```text
Capture cannot become a notes feed, inbox, chatbot, category board, or default task-entry screen.
```

### Time

Align Time around:

```text
LifeShape Field
open time
goal time
protected time
pressure
proof opportunity
ambition starvation signal
commitment fit
preview-before-reflow
receipt after meaningful change
```

Calendar must be a source/detail, not primary visual identity.

Preserve user-facing `Time`. Do not revive `Plan` as a top-level tab. Internal `PlanScreen` compatibility may remain only if unsafe to rename in this batch.

### You

Align You around:

```text
User System Profile
Personal Runtime
Planning Setup
Trust & Automation
Privacy
Proof preferences
Recovery preferences
Local learning controls
Export/delete/reset direction
```

Hard Red:

```text
You cannot become a social profile, family hub, admin console, AI settings wall, or generic account page.
```

## Required Naming / Vocabulary Alignment

Inspect and safely update active docs, tests, and user-facing UI copy.

Preferred active terms:

```text
Ambition
Commitment
Step
Proof
Proof Trail
Recovery Thread
Still Counts
Reality Meridian
Start Here
Recommended step
LifeShape Field
Constellation Atlas
Orbital Lens
Atmosphere Composer
User System Profile
Personal Runtime
Trust Seam
Receipt Surface
Quiet Reflow
Shape Time
Needs a Place
Ready to Place
Grow into Goal
```

Terms allowed only as internal compatibility seams or historical references:

```text
Plan
PlanScreen
ProfileScreen
Captures
DayTimelineRail
Hero Step Panel
Goal Mission Control
Mission Control
```

Banned active user-facing/product-direction terms:

```text
surface
Assistant
AI recommends
Recommended step
Recommended step
Start now
Start now
needs closure
needs review
proof thread broken
productivity dropped
habit score
life score
proof signal
calendar clone
AI planner
```

If tests currently expect `Plan` as user-facing tab text, update them to `Time` unless doing so breaks a documented compatibility path. Record any remaining compatibility exceptions.

## Required Scripts / Gates

Add or update repo checks so future Codex batches cannot drift.

Create or update scripts as appropriate:

```text
scripts/ambitions-moat-drift-scan.py
scripts/ambitions-vocabulary-drift-scan.py
scripts/ambitions-local-first-boundary-scan.py
scripts/ambitions-signature-object-gate.py
```

If equivalent scripts already exist, extend them instead of creating duplicates.

The scans must check active docs and source for:

```text
banned user-facing vocabulary
Plan-as-top-level leakage
Profile-as-user-facing leakage
DayTimelineRail active product leakage
Hero Step Panel active product leakage
AI/chatbot framing
dashboard/card-stack/calendar-clone framing
external/cloud LLM core dependency assumptions
custom hosted personal backend assumptions
release/readiness false claims
privacy/legal/App Store false claims
```

Update the relevant control-plane/final-report gates if a central gate already exists:

```text
scripts/ambitions-control-plane-check.py
scripts/ambitions-final-report-gate.py
scripts/ambitions-source-atlas-title-check.py
scripts/ambitions-queue-snapshot.py
```

Do not make brittle scans that block legitimate historical archive references. Scans must distinguish active truth/source/UI from historical/archive/supporting material where possible.

## Required Tests / Fixtures

Add or update tests and preview/demo fixtures to reflect the moat.

Minimum expected coverage additions where feasible:

```text
- RecommendationTrace exposes source/reason/control without AI/chat copy.
- Still Counts can produce or preserve proof.
- RecoveryThread can be created from a missed/stalled/blocked commitment.
- Capture route can classify an item as Proof or Constraint.
- Time/LifeShape can represent proof opportunity and commitment fit.
- You/Personal Runtime can expose local learning/trust controls.
- User-facing tab names are Today / Goals / Capture / Time / You.
- Banned active copy does not appear in user-facing strings.
```

If current test architecture makes some tests expensive, add focused unit tests for domain/service layers and document UI coverage still needed.

## Required Documentation Artifacts

Create:

```text
docs/status/product-moat-alignment-report.md
docs/status/ambition-graph-implementation-plan.md
docs/status/proof-recovery-lifecycle-map.md
docs/status/personal-runtime-trust-map.md
docs/status/signature-object-moat-gap-map.md
```

Each must be concise, current, and proof-honest.

### `product-moat-alignment-report.md`

Must include:

```text
- batch ID
- current commit
- files changed
- moat thesis installed
- docs updated
- source updated
- tests updated
- scripts/gates updated
- compatibility seams retained
- unimplemented/unproven items
- next recommended batches
```

### `ambition-graph-implementation-plan.md`

Must include:

```text
- current model inventory
- proposed durable object hierarchy
- what was implemented now
- what remains scaffolded
- migration risks
- rollback considerations
```

### `proof-recovery-lifecycle-map.md`

Must include:

```text
- proof object lifecycle
- closure states
- recovery thread lifecycle
- Still Counts behavior
- receipt behavior
- non-shaming language rules
```

### `personal-runtime-trust-map.md`

Must include:

```text
- local-first data boundaries
- what Ambitions may learn locally
- what user can inspect/reset/delete
- Apple sync future exception
- R2 future public freshness exception
- what must never be sent externally
- privacy proof still required
```

### `signature-object-moat-gap-map.md`

Must include:

```text
- Today / Reality Meridian gaps
- Goals / Constellation Atlas gaps
- Capture / Atmosphere Composer gaps
- Time / LifeShape Field gaps
- You / User System Profile gaps
- current source compatibility seams
- next implementation sequence
```

## Required Queue / Batch Train Alignment

Inspect current batch train / queue docs.

Update only active queue/batch docs that are clearly intended to guide future work. Do not rewrite historical completed batches.

If a queue file exists for current/future work, update it so the next train prioritizes:

```text
1. Ambition Graph foundations
2. Proof + Recovery lifecycle
3. RecommendationTrace + Trust Seam
4. Today moat pass
5. Goals moat pass
6. Capture proof-routing pass
7. Time LifeShape proof-opportunity pass
8. You Personal Runtime pass
9. Apple-native execution surfaces only after core objects are mature
10. validation/proof packets
```

Do not reactivate completed batches.

Completed batches remain completed.

Historical docs remain historical unless explicitly promoted through truth files.

## Allowed Scope

You may modify:

```text
docs/truth/
docs/AmbitionsCanon/
docs/status/
docs/README.md
README.md
AGENTS.md
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
prompts/batches/
docs/codex/
```

Only modify `project.yml` if a source/test addition requires it.

## Forbidden Scope

Do not:

```text
- add external/cloud LLM dependency
- add OpenAI/API/cloud model calls
- add custom hosted personal-data backend
- add account/auth system
- add Supabase/Firebase/server profile assumptions
- add paid services
- add hosted CI that could create cost
- add R2 implementation unless it is strictly public/non-personal and already locally testable with no secrets/cost
- claim R2 freshness is implemented unless real source and tests exist
- claim iCloud/CloudKit sync is implemented unless real entitlement/source/tests exist
- claim App Store/TestFlight/device readiness
- claim privacy/legal approval
- claim accessibility conformance without proof
- make Plan a top-level user-facing destination
- make Capture a feed/chat/inbox
- make Time a calendar clone
- make Goals a dashboard/score/ring system
- make Today a generic task list
- make You a social profile/admin console
- add a sixth top-level tab
- remove useful features just because competitors have them
```

## Validation Expectations

Run the strongest local validation available in the repo.

At minimum, run:

```bash
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
```

If scripts require a different invocation, use the repo’s documented invocation and record it.

Also run where available:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsUITests test
```

If local environment lacks Xcode, simulator, XcodeGen, or a required tool, do not fake success. Record:

```text
Command not run
Reason
What proof is still missing
```

## Visual Proof Expectations

If UI source changes are made, generate or update preview fixtures where feasible for:

```text
Today / Reality Meridian / Start Here / proof target / recovery
Goals / Constellation Atlas / Ambition Graph / Proof Trail
Capture / Atmosphere Composer / Save as Proof / Mark as Constraint
Time / LifeShape Field / proof opportunity / commitment fit / reflow receipt
You / User System Profile / Personal Runtime / Trust & Automation
```

If rendered screenshots cannot be generated in this environment, record that visual proof is not produced.

Do not claim:

```text
visual QA passed
flagship UI complete
screenshots approved
accessibility verified
```

unless current proof exists.

## Hard Red Stop Conditions

Stop, repair, and rerun validation if any are introduced:

```text
Plan appears as a top-level tab.
A sixth top-level tab is added.
Today becomes a task list/calendar timeline/focus widget.
Start Here becomes a detached generic card stack.
Capture becomes notes feed/inbox/chatbot/category board.
Time becomes calendar grid/heatmap/analytics surface.
Goals becomes KPI dashboard/habit ring/life score/ranked category system.
You becomes social profile/family hub/admin console/AI settings wall.
Any core flow requires external/cloud LLM.
Any core flow requires custom hosted backend/account.
Any recommendation lacks source/control path.
Any adaptive behavior lacks receipt or inspectability.
Any proof/recovery state uses shame language.
Any user-facing copy uses “Start now,” “Start now,” “Recommended step,” or “Recommended step.”
Any release/readiness/privacy/legal claim is made without proof.
Any visual-only object has no accessibility equivalent.
```

## Rollback Expectations

Before broad edits, record current branch and commit.

For risky source changes:

```text
- prefer additive wrappers/adapters over destructive renames
- preserve compatibility seams where blind rename would break routing/tests
- keep migration plans separate from unsafe schema rewrites
- avoid large one-shot SwiftData migrations unless fully tested
- isolate new scripts so they can be disabled or repaired
```

If validation fails and repair is nontrivial, do not hide the failure. Leave the repo in the best safe state, document the failure, and specify exact next repair actions.

## Final Report Required

At the end, report exactly:

```text
Status: Green / Yellow / Red
Batch ID:
Branch:
Commit:
Files changed:
Moat thesis installed:
Docs changed:
Source changed:
Tests changed:
Scripts/gates changed:
Queue/batch-train changes:
Compatibility seams retained:
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
Next recommended batches:
```

## Success Criteria

This batch is Green only if:

```text
- active truth/docs now clearly define the moat
- Ambition Graph / Proof / Recovery / Personal Runtime are installed as repo-level authority
- safe source foundations or compatibility wrappers were added where feasible
- user-facing vocabulary is aligned
- Plan/Time and Profile/You drift is reduced or explicitly classified
- tests/fixtures are updated where feasible
- drift scans/gates exist or are updated
- no forbidden architecture was introduced
- no false release/privacy/accessibility claims were made
- validation commands were run or honestly marked not run
```

This batch is Yellow if:

```text
- docs/truth/canon alignment succeeds
- source implementation is partially scaffolded but major migration/UI work remains
- validation is partially blocked by local environment
- compatibility seams remain but are explicitly documented
```

This batch is Red if:

```text
- the repo cannot build after source changes where build was previously possible
- truth files conflict after the patch
- forbidden product direction is introduced
- external/cloud LLM or hosted backend dependency is introduced
- release/privacy/accessibility claims are falsified
```

## Final Operating Rule

Do not optimize Ambitions for planning.

Optimize Ambitions for:

```text
ambition survival
proof-backed execution
private local context
trustworthy recovery
native iPhone execution
inspectable local intelligence
```

Every changed file should make Ambitions harder to mistake for Motion, Sunsama, Reclaim, Akiflow, Todoist, a habit tracker, a calendar app, a surface, or a chatbot.

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

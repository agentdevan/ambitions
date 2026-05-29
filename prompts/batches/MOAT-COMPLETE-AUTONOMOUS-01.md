<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-97625721, AMB28-same_source_file_targeted_by_multiple_active_batches-15996512, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-32022500, AMB28-same_source_file_targeted_by_multiple_active_batches-5843157, AMB28-same_source_file_targeted_by_multiple_active_batches-62868623, AMB28-same_source_file_targeted_by_multiple_active_batches-67473140, AMB28-same_source_file_targeted_by_multiple_active_batches-72454456, AMB28-same_source_file_targeted_by_multiple_active_batches-83525689, AMB28-same_source_file_targeted_by_multiple_active_batches-87716319, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932 and 3 more

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

# MOAT-COMPLETE-AUTONOMOUS-01 — Complete Ambitions Moat Realignment Until Green

## Batch ID

MOAT-COMPLETE-AUTONOMOUS-01

## Objective

Finish the Ambitions moat realignment in one autonomous batch.

This batch supersedes partial repair prompts. Do not stop after the first Yellow or Red. Diagnose, repair, rerun validation, and continue until the repo is internally aligned, scan-clean, proof-honest, and ready for human review.

The accepted product moat is:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

The accepted full product direction is:

```text
Ambitions is a premium native iPhone, local-first personal ambition operating system that helps users define who they are becoming, turn that into grounded commitments, execute the next credible action, capture proof, and recover when reality breaks the plan — while keeping the personal life graph local-first, inspectable, and user-controlled.
```

The goal is to complete the repo-wide canon, docs, source scaffolding, tests, scripts, and gates alignment created by `MOAT-ALIGNMENT-01`, repair all Yellow/Red causes from the prior run, and leave the repo in the strongest safe state possible without requiring another intervention.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 make batch-no-commit BATCH=MOAT-COMPLETE-AUTONOMOUS-01 PROMPT=prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md
```

If the Makefile path is blocked by local approval policy, use the direct runner path:

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 scripts/ambitions-codex-train.sh MOAT-COMPLETE-AUTONOMOUS-01 prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md
```

## Current Known State

The repo may already contain uncommitted partial work from:

```text
RUNNER-QUOTE-REPAIR-01
MOAT-ALIGNMENT-01
```

Known existing changed/untracked files may include:

```text
AGENTS.md
README.md
docs/README.md
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/status/product-moat-alignment-report.md
docs/status/ambition-graph-implementation-plan.md
docs/status/proof-recovery-lifecycle-map.md
docs/status/personal-runtime-trust-map.md
docs/status/signature-object-moat-gap-map.md
Native/Ambitions/Domain/AmbitionGraphModels.swift
Native/Ambitions/Domain/CaptureModels.swift
Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift
Native/AmbitionsTests/Domain/CaptureModelsTests.swift
scripts/ambitions-moat-drift-scan.py
scripts/ambitions-vocabulary-drift-scan.py
scripts/ambitions-local-first-boundary-scan.py
scripts/ambitions-signature-object-gate.py
scripts/ambitions-runner-quote-self-check.sh
scripts/ambitions-codex-train.sh
scripts/ambitions-control-plane-check.py
scripts/ambitions-codex-os-validate.py
prompts/batches/MOAT-ALIGNMENT-01.md
prompts/batches/RUNNER-QUOTE-REPAIR-01.md
prompts/batches/MOAT-COMPLETE-AUTONOMOUS-01.md
```

Do not assume this list is complete. Inspect the live worktree.

## Non-Negotiable Execution Rule

Do not stop at Yellow or Red if the cause is repairable inside this repo.

If a validation command fails:

1. Read the exact failure.
2. Classify it.
3. Repair it.
4. Rerun it.
5. Repeat until it passes or a genuine external blocker remains.

A Yellow or Red result is allowed only for a real blocker outside this batch’s control, such as:

```text
Xcode approval policy blocks xcodebuild.
Required local simulator is unavailable.
Required Xcode toolchain is unavailable.
External model/tool invocation is denied by local policy.
```

A failing repo-owned scan is not an acceptable final Yellow/Red. Fix the scan inputs, the active docs/source drift, or the scanner logic.

## Active Source Truth To Inspect First

Read before editing:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
README.md
AGENTS.md
docs/README.md
docs/status/current-implementation-map.md
docs/status/release-evidence-packet.md
docs/status/repo-cleanup-index.md
docs/status/product-moat-alignment-report.md
docs/status/ambition-graph-implementation-plan.md
docs/status/proof-recovery-lifecycle-map.md
docs/status/personal-runtime-trust-map.md
docs/status/signature-object-moat-gap-map.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
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
Makefile
```

If a file is missing, continue with the closest active equivalent and record the missing file.

## Accepted Product Moat Hierarchy

The repo must consistently support this hierarchy:

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

Codex must preserve this distinction:

```text
Competitors can copy tasks, calendars, time blocks, reminders, generic daily planning, and generic AI scheduling.

Ambitions’ moat is the accumulated private ambition graph:
- what the user is becoming
- what proof counts
- what constraints recur
- what recovery works
- what commitments survive reality
- what private context informs local recommendations
- what receipts establish trust over time
```

## Preservation Rule

This batch must not reduce Ambitions’ planned capability breadth.

Do not remove or weaken planned task, calendar, time-shaping, daily planning, capture, reminder, widget, Live Activity, App Intent, Share Extension, recommendation, review, automation, proof, receipt, accessibility, privacy, or Apple-native integration capabilities merely because competitors have adjacent versions.

The goal is to elevate those capabilities into Ambitions-native objects and flows:

```text
tasks become Steps / Commitments
calendar data becomes LifeShape source material
daily planning becomes proof-backed commitment shaping
capture becomes semantic routing into Ambition / Proof / Constraint / Commitment / Reflection / Held Item
recommendations become inspectable local reasoning
missed work becomes Closure / Recovery
settings become User System Profile / Personal Runtime
```

If a planned capability conflicts with moat direction, preserve the useful capability but change its product role, object ownership, user-facing language, and acceptance criteria.

Removal requires explicit proof that the feature is obsolete, harmful, duplicate, or incompatible with active truth.

## Required Final Repo Alignment

Complete all of the following before returning final status.

### 1. Product Moat Truth

Ensure this file exists and is authoritative:

```text
docs/truth/PRODUCT_MOAT_TRUTH.md
```

It must include:

```text
canonical moat statement
non-moat commodity list
defensible object graph
Ambition Graph hierarchy
proof-centered retention thesis
recovery-first execution thesis
local-first trust thesis
native Apple execution-layer posture
surface-by-surface moat requirements
moat-aligned metrics
anti-metrics
forbidden product directions
Codex patch review questions
Hard Red drift conditions
```

Update these files to reference it in the correct authority order:

```text
docs/truth/README.md
README.md
docs/README.md
AGENTS.md
```

Do not make `PRODUCT_MOAT_TRUTH.md` implementation proof or release proof.

### 2. Product Design Truth

Update or repair:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
```

It must explicitly include:

```text
Ambition Graph as product moat
Proof as emotional/data retention engine
Recovery as first-class state
Commitment as stronger than generic task
RecommendationTrace / Why this? / Trust Seam requirements
Personal Runtime as local learning and trust control
proof-backed switching cost
ambition survival as core product job
```

Preserve existing strict rules:

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

### 3. Canon Pack

Repair and align the active canon pack.

Required files to update where needed:

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

Use concise authoritative amendments. Do not create bloated duplicate canon.

### 4. Status Artifacts

Ensure these files exist, are current, and are proof-honest:

```text
docs/status/product-moat-alignment-report.md
docs/status/ambition-graph-implementation-plan.md
docs/status/proof-recovery-lifecycle-map.md
docs/status/personal-runtime-trust-map.md
docs/status/signature-object-moat-gap-map.md
```

Each file must classify:

```text
implemented
source-present
scaffolded
planned
compatibility seam
unproven
not claimed
```

Do not claim implementation, release, privacy, accessibility, or device validation without proof.

### 5. Domain Source Scaffolding

Inspect and repair/add source foundations for:

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

Use existing domain types where present. Do not duplicate semantically equivalent types.

If the existing patch has `Native/Ambitions/Domain/AmbitionGraphModels.swift`, repair it until it is internally coherent, testable, and aligned with the moat.

Preferred model semantics:

```text
Ambition is identity-level direction.
Commitment is a dated, sized promise tied to an Ambition and expected proof.
Proof is evidence that an Ambition advanced.
Constraint is a recurring reason execution fails or changes.
RecoveryThread is the path back after interruption.
RecommendationTrace is inspectable local reasoning behind a recommendation.
Reflection is user-authored learning from proof, closure, or recovery.
```

Avoid risky SwiftData migrations. If persistence migration is unsafe, keep the model as domain scaffolding and document migration requirements.

### 6. Capture Model Alignment

Repair or update `CaptureModels.swift` and tests so Capture can route material as:

```text
Proof
Constraint
Commitment
Reflection
Held Item
Grow into Goal
Needs a Place
Ready to Place
```

Do not turn Capture into a notes feed, inbox, chatbot, category board, or generic task entry screen.

### 7. Proof and Recovery Lifecycle

Ensure docs, models, tests, and vocabulary support:

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

Approved recovery language:

```text
Reality changed.
Still counts.
Make it smaller.
Recover this thread.
Preserve the proof.
Restart from the last honest point.
```

Banned active user-facing language:

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

Documentation may list banned terms only inside explicit banned-term sections.

### 8. Inspectable Local Recommendations

Ensure docs/source scaffolding/tests support `RecommendationTrace`.

Every recommendation must be able to expose:

```text
source refs
reason codes
ambition link
proof gap
time fit
known constraint
uncertainty
user controls
what Ambitions will remember
```

Allowed controls:

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

No “AI recommends.” No generic AI explanation. No model-confidence theater.

### 9. Personal Runtime / Local Trust

Ensure You/Profile direction supports:

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

Do not claim privacy/legal/App Privacy readiness.

### 10. Surface Moat Alignment

Ensure active docs/canon/status maps align each top-level surface:

```text
Today -> Reality Meridian + Start Here Surface + one active commitment + proof target + recovery + Trust Seam
Goals -> Constellation Atlas + Orbital Lens + Ambition Graph + Proof Trail
Capture -> Atmosphere Composer + route reveal + proof/constraint/commitment/reflection routing
Time -> LifeShape Field + open/goal/protected/pressure + proof opportunity + commitment fit + receipt-backed reflow
You -> User System Profile + Personal Runtime + Trust & Automation + privacy/local learning controls
```

Top-level IA is exactly:

```text
Today / Goals / Capture / Time / You
```

No sixth tab. No Plan top-level destination.

## Naming and Vocabulary Rules

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

Compatibility-only terms:

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

Compatibility terms may remain only when explicitly classified as internal, historical, migration, or compatibility seams.

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

Scanner rule:

Banned terms are allowed inside explicit banned-term sections, historical/archive references, or compatibility-seam documentation. They are not allowed as active product direction or user-facing UI copy.

## Required Scans and Gates

Repair these scripts until they are useful, context-aware, and passing:

```text
scripts/ambitions-moat-drift-scan.py
scripts/ambitions-vocabulary-drift-scan.py
scripts/ambitions-local-first-boundary-scan.py
scripts/ambitions-signature-object-gate.py
scripts/ambitions-control-plane-check.py
scripts/ambitions-codex-os-validate.py
```

Scanners must:

```text
scan active truth/canon/status/source/UI-relevant files
avoid treating .codex/runs as source
avoid treating Archive/historical docs as active drift
distinguish banned active usage from banned-term lists
distinguish compatibility seam documentation from product direction
not force deletion of useful planned capabilities
not weaken no-cloud-AI/no-backend/no-false-claim rules
```

Do not make scanners toothless. They must catch real drift.

## Autonomous Repair Loop

Use this loop until the repo-owned gates pass:

```text
1. Run all required diagnostics.
2. Capture exact failures.
3. Classify each failure:
   - active drift
   - compatibility seam needing explicit classification
   - historical/archive false positive
   - scanner false positive
   - scanner bug
   - actual source/test issue
4. Repair the correct layer.
5. Rerun the failing command.
6. Continue until all repo-owned scans pass.
```

Do not return final status while these fail:

```bash
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
git diff --check
bash -n scripts/ambitions-codex-train.sh
bash scripts/ambitions-codex-train.sh --quote-self-check
```

## Allowed Scope

You may modify:

```text
AGENTS.md
README.md
docs/README.md
docs/truth/
docs/AmbitionsCanon/
docs/status/
docs/codex/
docs/codex-os/
Native/Ambitions/Domain/
Native/Ambitions/Persistence/
Native/AmbitionsTests/Domain/
Native/AmbitionsTests/
scripts/
prompts/batches/
prompts/ambitions/
build/reports/
```

You may modify feature files only if necessary to repair compile/test issues introduced by the moat scaffolding:

```text
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Captures/
Native/Ambitions/Features/Plan/
Native/Ambitions/Features/Profile/
```

If modifying feature files, keep changes minimal and moat-aligned.

## Forbidden Scope

Do not:

```text
add external/cloud LLM dependency
add OpenAI/API/cloud model calls
add custom hosted personal-data backend
add account/auth system
add Supabase/Firebase/server profile assumptions
add paid services
add hosted CI that can create cost
claim R2 freshness is implemented unless real source/tests exist
claim iCloud/CloudKit sync is implemented unless real entitlement/source/tests exist
claim App Store/TestFlight/device readiness
claim privacy/legal approval
claim accessibility conformance without proof
make Plan a top-level user-facing destination
make Capture a feed/chat/inbox
make Time a calendar clone
make Goals a dashboard/score/ring system
make Today a generic task list
make You a social profile/admin console
add a sixth top-level tab
remove useful planned features merely because competitors have them
commit automatically
push automatically
delete existing dirty work
commit .codex/runs
```

## Required Validation

Run these first:

```bash
git status --short
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-codex-os-validate.py || true
git diff --check
bash -n scripts/ambitions-codex-train.sh
bash scripts/ambitions-codex-train.sh --quote-self-check
xcodegen generate
```

Then run any feasible Swift validation:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```

If xcodebuild is blocked by approval policy, unavailable simulators, or missing toolchain, record it as external blocker. Do not mark repo-owned scans Yellow/Red because xcodebuild was blocked.

## Build/Test Failure Policy

If build or unit tests fail due to this batch’s source changes:

1. Read exact compiler/test errors.
2. Repair source/tests.
3. Rerun.
4. Repeat until build/tests pass or external approval/tooling blocks execution.

Do not leave newly added Swift files uncompilable if xcodebuild can be run.

If xcodebuild cannot be run, ensure Swift changes are conservative, type-safe by inspection, and covered by available static checks or unit-test source review.

## Visual Proof Expectations

No broad UI redesign is required.

If UI files are changed, update or preserve preview fixtures for:

```text
Today / Reality Meridian / Start Here / proof target / recovery
Goals / Constellation Atlas / Ambition Graph / Proof Trail
Capture / Atmosphere Composer / proof/constraint routing
Time / LifeShape Field / proof opportunity / commitment fit
You / User System Profile / Personal Runtime
```

Do not claim visual QA passed unless rendered screenshots tied to current commit exist.

## Accessibility Proof Expectations

Do not claim accessibility conformance.

If accessibility-related docs/source are touched, preserve or strengthen:

```text
VoiceOver equivalence
Dynamic Type behavior
Reduce Motion equivalence
Increase Contrast support
44pt minimum tap targets
non-color-only state
```

## Release Claim Honesty

Allowed current claims:

```text
source-present
scaffolded
planned
compatible with active truth
local-first source posture
validation path exists
not release-proven
```

Forbidden unless proof exists:

```text
App Store-ready
TestFlight-ready
device-validated
privacy-approved
legally approved
fully accessible
performance validated
CI-proven
R2 validated
iCloud sync implemented
release-ready
```

## Commit Safety

Do not commit.

Do not push.

Do not create a branch.

Leave the final diff uncommitted for human inspection.

Do not include `.codex/runs/` in the recommended commit set.

## Final Report Required

Report exactly:

```text
Status: Green / Yellow / Red
Batch ID:
Branch:
Commit:
Files changed:
Moat thesis installed:
Canon/truth/docs completed:
Source scaffolding completed:
Tests completed:
Scripts/gates completed:
Scan failures found:
Scan failures repaired:
Scanner false positives repaired:
Active drift repaired:
Compatibility seams retained:
Capability breadth preservation:
Commands run:
Commands passed:
Commands needs review:
Commands not run:
Build/test proof:
Visual proof:
Accessibility proof:
Privacy/local-first proof:
Release claims allowed:
Release claims forbidden:
Untracked files that should not be committed:
Recommended commit set:
Unimplemented:
Unproven:
External blockers:
Rollback notes:
Next action:
```

## Success Criteria

Final status must be Green if all repo-owned gates pass and only external build/test approval limitations remain.

Green requires:

```text
PRODUCT_MOAT_TRUTH.md exists and is referenced by active authority docs
PRODUCT_DESIGN_TRUTH.md includes moat upgrade
active canon docs are aligned
status docs are current and proof-honest
Ambition Graph / Proof / Recovery / RecommendationTrace / Personal Runtime are installed as repo-level authority
source scaffolding is additive and safe
tests are added or repaired where feasible
moat/vocabulary/local-first/signature/control-plane scans pass
git diff --check passes
runner quote self-check passes
capability breadth is preserved
no forbidden architecture is introduced
no false release/privacy/accessibility claims are made
no commit/push/branch happens
```

Yellow is allowed only if:

```text
all repo-owned scans pass
all docs/source alignment is complete
but xcodebuild or simulator validation is blocked by external approval/tooling
```

Red is allowed only if:

```text
a hard blocker remains after attempted repair
the blocker is outside allowed scope
or repairing it would require violating forbidden scope
```

Do not return Yellow or Red because of a repairable scan failure.

## Final Operating Rule

Finish the moat alignment.

Do not babysit the user with another micro-prompt.

Do not stop after creating directionally correct docs.

Do not stop after partial scaffolding.

Do not stop while repo-owned scans fail.

Repair until Ambitions’ active repo canon, docs, source scaffolding, tests, and gates consistently enforce:

```text
ambition survival
proof-backed execution
private local context
trustworthy recovery
native iPhone execution
inspectable local intelligence
```

Every changed file must make Ambitions harder to mistake for Motion, Sunsama, Reclaim, Akiflow, Todoist, a habit tracker, a calendar app, a surface, or a chatbot — while preserving Ambitions’ planned capability breadth.

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

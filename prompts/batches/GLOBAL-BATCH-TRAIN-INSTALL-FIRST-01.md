<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# GLOBAL-BATCH-TRAIN-INSTALL-FIRST-01 - Continue Global Train With Fast Install Policy

## Batch ID

GLOBAL-BATCH-TRAIN-INSTALL-FIRST-01

## Runner Command

```bash
KEEP_GOING_ON_YELLOW=1 AUTO_BRANCH=0 make batch BATCH=GLOBAL-BATCH-TRAIN-INSTALL-FIRST-01 PROMPT=prompts/batches/GLOBAL-BATCH-TRAIN-INSTALL-FIRST-01.md
```

## Objective

Continue the Ambitions global batch train with an install-first execution posture.

The current priority is to get planned source/code batches installed, committed, and pushed to main efficiently, while preserving hard safety boundaries and proof honesty.

Do not spend excessive time in duplicate review/hardening/finalize loops after a bounded patch has already passed focused validation.

Hardening, broad scans, screenshot proof, full accessibility sweeps, full visual QA, and repo-wide polish may be deferred to explicit hardening batches unless the current patch touches those systems directly.

## Active Source Truth To Inspect First

Read:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
AGENTS.md
docs/codex/BATCH_REGISTRY.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md
docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md
.codex/state/active-batch.yml
.codex/reports/current-batch-train-state.md
```

## Install-First Policy

For each eligible batch:

1. Inspect active batch scope.
2. Apply the smallest safe source patch.
3. Run only the validation needed for that patch class.
4. If validation passes, close the batch Green or accepted Yellow.
5. Commit exact changed paths.
6. Push to main.
7. Continue to the next eligible batch.

Do not repeat the same focused validation more than once in the same batch unless:

```text
the first run failed,
the patch changed after the run,
xcodegen generate changed project files,
or the runner detects a real inconsistency.
```

Do not enter no-op repair phases after a Green review unless there is a concrete failed command, broken build, dirty-state contradiction, or Hard Red condition.

If a scan flags forbidden terms inside prompt prohibition examples, classify it as scan-scope noise if source/user-facing docs pass. Do not block code install for that alone.

## Validation Policy

### Docs-only patch

Run:

```bash
git diff --check
make prompt-audit || true
python3 scripts/ambitions-control-plane-check.py
```

Skip Xcode.

### Swift source patch

Run:

```bash
git diff --check
xcodegen generate
```

Then run the most focused relevant test lane only.

Examples:

```text
Today source seam patch -> Today-focused tests and command-executor tests.
Capture source seam patch -> Capture-focused tests.
Time source seam patch -> Time/Plan compatibility tests.
Goals source seam patch -> Goals/domain tests.
You/Profile source seam patch -> Profile/You tests.
```

Do not run full UI test suite unless the batch explicitly touches UI tests or app shell routing.

### Visual UI source patch

Run:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

Run focused tests if available. Do not block on rendered screenshots unless the batch explicitly requires screenshot proof.

## Commit / Push Policy

After each Green or accepted Yellow batch:

```bash
git status --short
git diff --check
git add <exact changed paths>
git diff --cached --check
git commit -m "<BATCH_ID>: <concise result>"
git push origin main
```

If git add, git commit, or git push is blocked by an outer app/tool policy, stop and report exact terminal commands. Do not pretend push happened.

If remote moved:

```bash
git fetch origin main
git rebase origin/main
# rerun focused validation only
git push origin main
```

## Yellow Continuation

Continue through Yellow when:

```text
implementation is safe,
missing proof is explicitly recorded,
no false release/privacy/accessibility claim is made,
compatibility seams are documented,
the next batch can proceed safely.
```

Do not stop the train for Yellow caused only by:

```text
screenshot proof not produced,
full accessibility proof not produced,
Xcode/simulator not available,
prompt examples containing forbidden terms in prohibition lists,
non-blocking compatibility seams.
```

## Forbidden Scope

Do not introduce:

```text
external/cloud LLM dependency,
custom hosted personal-data backend,
account/auth system,
Plan as top-level tab,
sixth top-level tab,
chatbot or Assistant primary UI,
scores/streaks/badges/leaderboards,
shame language,
release/TestFlight/App Store/privacy/accessibility claims without proof.
```

## Hard Red Stop Conditions

Stop only for:

```text
Plan appears as top-level tab.
A sixth top-level tab is added.
Today becomes task list/calendar agenda/focus widget.
Capture becomes feed/inbox/chatbot/category board.
Time becomes graph/terrain/blob/weather map/dashboard/calendar clone.
Goals becomes dashboard/score/habit ring/astrology.
You becomes social profile/admin console/AI settings wall.
Core flow requires external/cloud LLM.
Core flow requires custom hosted backend/account.
Source no longer builds after source changes where build previously passed.
Recommendation lacks Why this/source/control path.
Adaptive behavior lacks receipt/inspectability.
Proof/recovery state uses shame language.
False release/privacy/accessibility claim is made.
```

## Required Continuation Target

Continue from the current live train state.

If PK18 is already Green and committed, proceed to the next eligible batch.

If PK18 is Green but uncommitted, commit and push it first.

If PK18 is still in finalize and focused tests passed, close it without redundant no-op repair loops unless a concrete validation failure appears.

Then continue the active queue in optimized order.

## Visual Canon / Moat Priority

Preserve installed visual canon and moat authority:

```text
Today / Reality Meridian
Goals / Constellation Atlas
Capture / Atmosphere Composer
Time / LifeShape Field / Pressure Ledger
You / User System Profile
Moat Addendum: Ambition Graph, Proof, Trust, Recovery, Personal Runtime
```

Implementation should prioritize source installation over broad proof polish.

## Final Report Required

Report:

```text
Status:
Batch ID:
Start commit:
Final commit:
Pushed to main:
Batches completed:
Batches committed:
Batches pushed:
Accepted Yellow:
Blocked:
Remaining:
Commands run:
Commands passed:
Commands failed:
Commands skipped by install-first policy:
Validation proof:
Visual proof:
Accessibility proof:
Unimplemented:
Unproven:
Next eligible batch:
```

## Success Criteria

Green if the train continues through at least the next eligible implementation batch, commits, pushes, and records proof honestly.

Yellow if code is installed but push or broad proof is blocked by external environment.

Red only if a Hard Red condition is introduced or the repo cannot safely continue.

The core change is this: no more repeated conservative finalization unless something actually failed.

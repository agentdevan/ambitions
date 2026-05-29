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

# VISUAL-CANON-MOAT-01 - Install Visual Canon + Moat Implementation Authority

## Batch ID

VISUAL-CANON-MOAT-01

## Objective

Install the locked Ambitions visual north-star system and moat addendum into repo authority so future implementation cannot drift into generic productivity UI.

The active visual system to install is:

1. Shell Overview Board - product-family / IA / material reference
2. Today / Reality Meridian - daily execution reference
3. Goals / Constellation Atlas - direction / life-area reference
4. Capture / Atmosphere Composer - resting/default intake reference
5. Time / Day Pressure Ledger - day-level shaping reference
6. Time / Week Pressure Ledger with Reflow Crown - primary Time reference
7. Time / Month LifeShape Node Calendar - month scan / drill-down reference
8. You / User System Profile - system control reference
9. Moat Alignment Visual Addendum - Ambition Graph / Proof / Trust / Recovery / Personal Runtime reference

The installed repo authority must preserve this moat thesis:

```text
Ambitions compounds private ambition context into proof-backed execution decisions.
```

## Active Source Truth To Inspect First

Read before edits:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
AGENTS.md
README.md
docs/README.md
docs/AmbitionsCanon/README.md
docs/AmbitionsCanon/03_Signature_Object_Specs.md
docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md
docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md
docs/AmbitionsCanon/12_Screen_Composition_Constitution.md
docs/AmbitionsCanon/13_Flagship_Experience_Laws.md
docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md
docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md
docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md
docs/status/current-implementation-map.md
docs/status/product-moat-alignment-report.md
docs/status/signature-object-moat-gap-map.md
```

If any file is missing, record it and use the closest active equivalent. Do not invent proof.

## Required Work

Create or update a concise implementation authority document, preferably:

```text
docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md
```

It must define:

- locked visual references
- Shell Overview board role
- Moat Alignment Addendum role
- Signature Objects
- shared material system
- dock/icon grammar
- Context Crown
- Trust Seam
- Receipt Surface
- Ambition Graph hierarchy
- proof-backed execution requirements
- recovery and closure states
- RecommendationTrace / Why this? requirements
- Personal Runtime / local trust controls
- SwiftUI component mapping
- preview fixture matrix
- accessibility requirements
- visual QA requirements
- anti-drift rules
- Hard Red stop conditions

## Locked Surface Rules

### Today / Reality Meridian

Install as canon:

```text
Today uses Reality Meridian.
Start here is an attached Meridian Expansion Surface, not a standalone card.
Recommended step must include proof target, reason, commitment context, Why this?, Start now, and receipt/closure affordance where relevant.
Receipts and closure appear as a quiet lower drawer, not notification cards.
```

Hard Red:

```text
Today becomes task list, calendar agenda, motivational wallpaper, surface, or detached card stack.
```

### Goals / Constellation Atlas

Install as canon:

```text
Goals uses Constellation Atlas.
Each life area is represented by a meaningful constellation-shaped icon made from stars and connecting lines.
Selected life area opens inside Orbital Lens.
Orbital Lens exposes Ambition Graph, next milestone, active goals/commitments, recommended step, and Proof Trail direction.
```

Hard Red:

```text
Goals becomes surface, score screen, habit tracker, astrology, decorative constellation wallpaper, or generic goal list.
```

### Capture / Atmosphere Composer

Install as canon:

```text
Capture resting state is composer-first.
No visible route labels/chips at rest.
Routes such as Save as Proof, Make Commitment, Grow into Goal, Mark Constraint, Reflect, Hold / Needs a Place appear only after user input or explicit expansion.
```

Hard Red:

```text
Capture becomes notes feed, inbox, chatbot, category board, shortcut grid, or default task-entry screen.
```

### Time / LifeShape Field

Install as canon:

```text
Time uses LifeShape Field as a pressure-aware calendar field.
Day = one bounded day Pressure Ledger.
Week = seven bounded day lanes with Reflow Crown.
Month = deconstructed LifeShape Node calendar for scan and drill-down.
Date ownership is mandatory.
No state may cross a date boundary unless the underlying commitment spans dates.
Reflow is preview-based and belongs primarily to Week.
```

Hard Red:

```text
Time becomes line graph, terrain, blobs, weather map, analytics surface, generic calendar clone, unsafe auto-reflow, or task planner.
```

### You / User System Profile

Install as canon:

```text
You is User System Profile.
Primary section is Planning Setup.
Secondary sections include Account & Preferences and Support / System.
Personal Runtime exposes what Ambitions has learned, what is used for recommendations, reset/forget controls, local storage boundaries, and Trust & Automation.
```

Hard Red:

```text
You becomes social profile, generic account page, SaaS/admin surface, chatbot settings, AI-wrapper wall, or family hub.
```

## Moat Addendum Rules

Install the moat addendum as required supporting canon:

```text
Top-level visual north stars show primary surfaces at rest or overview state.
Moat Alignment Visual Addendum is required supporting canon showing:
- Ambition Graph
- proof-backed execution
- inspectable RecommendationTrace / Why this?
- recovery
- route reveal after input
- preview-before-reflow
- Personal Runtime / local trust controls
```

## Required SwiftUI Mapping

Where safe and feasible, add or align scaffolds / wrappers / preview fixture names for:

```text
RealityMeridianView
MeridianExpansionSurface
ConstellationAtlasView
OrbitalLensView
AtmosphereComposerView
CaptureRouteRevealView
LifeShapeFieldView
PressureLedgerWeekView
PressureLedgerDayView
LifeShapeMonthView
ReflowPreviewView
UserSystemProfileView
PersonalRuntimeView
TrustSeamView
ReceiptSurfaceView
ContextCrownView
```

Do not do unsafe broad renames. Preserve compatibility seams if current source still uses legacy names.

## Allowed Scope

```text
docs/truth/
docs/AmbitionsCanon/
docs/status/
docs/README.md
README.md
AGENTS.md
Native/Ambitions/Domain/
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

Only touch `project.yml` if required for added source/tests.

## Forbidden Scope

Do not:

```text
add external/cloud LLM dependency
add hosted personal-data backend
add account/auth system
add paid service
add hosted CI/cost exposure
claim iCloud/CloudKit sync implemented
claim R2 freshness implemented
claim App Store/TestFlight/device readiness
claim privacy/legal approval
claim accessibility conformance without proof
make Plan top-level
add sixth tab
```

## Validation Expectations

Run what is available:

```bash
python3 scripts/ambitions-moat-drift-scan.py
python3 scripts/ambitions-vocabulary-drift-scan.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-signature-object-gate.py
python3 scripts/ambitions-control-plane-check.py
```

Also run build/test commands where available:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

If unavailable, report command not run, reason, and missing proof.

## Visual Proof Expectations

If UI source changes are made, add or update preview fixtures for:

```text
Today / Reality Meridian / proof-backed Start here
Goals / Constellation Atlas / Ambition Graph / Proof Trail
Capture / Atmosphere Composer / route reveal after input
Time / Pressure Ledger / Reflow Preview
You / User System Profile / Personal Runtime
Moat Addendum states
```

Do not claim screenshots approved or visual QA passed unless current proof exists.

## Hard Red Stop Conditions

Stop and repair if any are introduced:

```text
Plan appears as top-level tab.
A sixth top-level tab appears.
Today becomes task list/calendar timeline/focus widget.
Capture becomes notes feed/inbox/chatbot/category board.
Time becomes graph/terrain/blob/weather map/dashboard/calendar clone.
Goals becomes KPI dashboard/habit ring/life score/astrology.
You becomes social profile/admin console/AI settings wall.
Any core flow requires external/cloud LLM.
Any recommendation lacks Why this?/source/control path.
Any adaptive behavior lacks receipt/inspectability.
Any proof/recovery state uses shame language.
Any release/privacy/accessibility claim is made without proof.
```

## Rollback Expectations

Before edits:

```bash
git status --short --branch
git rev-parse HEAD
```

Prefer additive docs, wrappers, adapters, and preview fixtures over destructive renames.

If validation fails, leave repo in the safest state, document failure honestly, and specify exact next repair actions.

## Final Report Required

Report exactly:

```text
Status: Green / Yellow / Red
Batch ID:
Branch:
Commit:
Files changed:
Visual canon installed:
Moat addendum installed:
Docs changed:
Source changed:
Preview fixtures changed:
Tests changed:
Scripts/gates changed:
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

## Runner Command

```bash
make batch BATCH=VISUAL-CANON-MOAT-01 PROMPT=prompts/batches/VISUAL-CANON-MOAT-01.md
```

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

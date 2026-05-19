<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001

# Objective

Create the complete Ambitions intended final-state Front-End Surface Recipe Encyclopedia.

This batch must inspect where Ambitions is now, every active canon/design/source document, and every planned not-yet-implemented batch prompt. It must then produce a granular, reviewable, repo-owned visual recipe system for every intended visible Ambitions surface after all planned frontend work is complete.

This is not an implementation batch.

This is not a screenshot/proof batch.

This is not a current-state audit.

This is the intended fully completed visual blueprint for Ambitions.

Every visible surface must be represented. Every visible surface must have a recipe or an explicit unresolved-direction entry. If a surface is missing from this encyclopedia, that is a documentation gap and future work must not silently invent it.

The final result should read like an internal Apple/FAANG product-design architecture recipe book: every screen, drill-down, sheet, tray, row, chrome element, primitive, chevron, wrapper, material, typography role, spacing rhythm, CTA, label, state, receipt, proof affordance, and visible object must be accounted for with where, how, and why.

Assume execution through:

GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit.

# Current Product Truth

Ambitions is a premium native iPhone-first, local-first external brain and personal life operating system.

It helps the user organize life, shape time, ground goals, adapt to reality, close loops without shame, preserve proof, and improve execution through inspectable local intelligence.

Active top-level IA is exactly:

- Today
- Goals
- Capture
- Time
- You

Active primary objects:

- Today -> Reality Meridian
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile

Core visual/product direction:

- 70% Apple quiet luxury
- 20% living on-device intelligence
- 10% executive command clarity
- native graphite / warm dark luxury
- restrained celestial orientation
- precise luminous traces
- QuietGlass
- GraphiteRecess
- LuminousTrace
- CelestialField
- alive, evolving, adaptive, interactive, but not sci-fi, corny, neon, gimmicky, decorative, or fake-futuristic HUD

Hard exclusions:

- no Plan top-level tab
- no chatbot UI
- no generic productivity app
- no generic card-stack dashboard
- no generic task-list app
- no calendar clone
- no habit tracker
- no streaks, scores, rings, shame, or productivity-bro tone
- no sportsbook/gambling language or urgency mechanics
- no fantasy/sci-fi interface
- no decorative stars/space effects that do not serve orientation, continuity, state, proof, source freshness, or object meaning
- no detached Start Here card
- no obsolete visual authority paths
- no accidental old concept references as active canon
- no implementation-status framing inside the visual encyclopedia

# Critical Source Precedence Rule

This batch must resolve conflicts using the following authority hierarchy.

## Highest authority

1. This batch prompt.
2. Current active user direction embedded in recent Ambitions docs and active batch prompts:
   - the atlas is the intended final-state visual recipe system
   - not an implementation tracker
   - not screenshot proof
   - not current-state status
   - every visible surface must have a recipe or unresolved-direction entry
   - missing surfaces are documentation gaps

## Planned-batch precedence

3. Planned not-yet-implemented batches outrank existing implementation and older active docs when there is a conflict about intended final frontend direction.

If a planned batch has not yet been implemented/completed, and it defines intended future frontend direction, that planned batch is authoritative over current code and older docs.

## Recency within planned batches

4. Among planned not-yet-implemented batches, the most recent batch by batch creation data has the highest rank for conflicts.

Determine batch recency using the best available repo evidence in this order:

- explicit batch registry metadata such as `created_at`, `created`, `date`, `timestamp`, queue insertion date, or similar
- batch prompt frontmatter or heading metadata
- batch registry order if the repo clearly uses ordered queue semantics
- git history for file introduction if available
- filesystem creation/modified metadata only as a last resort, and mark it lower-confidence

Do not use filename sort alone unless no better evidence exists. If filename sort is used, mark it as low-confidence.

## Existing truth below planned batches

5. Completed batch reports and accepted results.
6. Active canon docs.
7. Active design docs.
8. Existing SwiftUI/source implementation.
9. Historical docs.
10. Obsolete/archive-candidate docs.

## Conflict handling

When two sources conflict:

- preserve the higher-ranked source
- record the conflict in a source precedence ledger
- do not silently blend incompatible directions
- do not delete useful historical material unless explicitly allowed
- classify older conflicting material as historical, obsolete, or superseded as appropriate
- mark unresolved conflicts if there is insufficient evidence to resolve safely

# Required Source Inspection

Inspect all relevant repo truth before writing.

At minimum inspect:

```text
docs/canon/**
docs/canon/frontend/**
docs/codex/**
docs/design/**
docs/product/**
docs/architecture/**
docs/audits/**
prompts/batches/**
prompts/ambitions/**
.codex/**
scripts/**
build/reports/**
Makefile*
project.yml
Package.swift
Native/**
Sources/**
App/**
```

If a path does not exist, note it in the final report and continue.

Specifically inspect:

```text
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
docs/canon/frontend/VISUAL_ITEM_REGISTRY.yaml
docs/canon/frontend/VISUAL_ITEM_REGISTRY.md
docs/canon/frontend/VISUAL_DIRECTION_CHANGE_PROTOCOL.md
docs/canon/frontend/VISUAL_DECISION_RECORDS.md
docs/canon/frontend/ACTIVE_IA_AND_SURFACE_MAP.md
docs/canon/frontend/MRI_HBI_FRONTEND_INTEGRATION_MAP.md
docs/canon/frontend/surfaces/**
docs/canon/frontend/objects/**
docs/canon/frontend/primitives/**
docs/canon/frontend/behavior/**
docs/canon/frontend/trace/**
```

Also search repo-wide for:

```text
Reality Meridian
Meridian Rail
Day Rail
Start Here
Recommended step
LifeShape
LifeShape Field
Time
Plan
Goals
Constellation Atlas
Ambition Graph
Proof Trail
Proof Path
Capture
Atmosphere Composer
User System Profile
Personal Runtime
Local Runtime
Receipt
Closure
Still Counts
Recovery
MRI
HBI
Moat Runtime Integration
Historical Baseline
GraphiteRecess
QuietGlass
LuminousTrace
CelestialField
Commitment Staging
Reflow Preview
Context Crown
Continuity
Navigation
Chrome
Trust
Source
Why this
Accessibility
Dynamic Type
Reduce Motion
VoiceOver
ADHD
```

# Planned Batch Inventory Requirement

Create a planned frontend batch inventory before writing the encyclopedia.

The inventory must identify:

* batch id
* prompt path
* apparent status: completed / in progress / planned / unknown
* whether it affects frontend visual direction
* creation/recency evidence
* confidence in recency evidence
* surfaces affected
* objects affected
* primitives affected
* direction decisions introduced
* conflicts with existing docs/code
* whether it outranks existing truth

Create or update:

```text
docs/canon/frontend/trace/PLANNED_BATCH_FRONTEND_DIRECTION_INVENTORY.md
docs/canon/frontend/trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md
```

The precedence ledger must explain exactly how conflicts were resolved.

# Core Output

Create or update the intended final-state recipe system under:

```text
docs/canon/frontend/
```

The master atlas remains:

```text
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
```

It must be explicitly framed as:

```text
The intended final-state visual recipe encyclopedia for Ambitions after all active planned frontend work is complete.
```

It must explicitly state:

* this document is not an implementation tracker
* this document is not screenshot proof
* this document is not a current-state audit
* this document describes final intended visual canon
* every visible surface must appear in the Surface Recipe Inventory
* every visible surface must have a recipe or unresolved-direction entry
* planned not-yet-implemented batches outrank existing implementation when defining intended final direction
* most recent planned batch creation data breaks conflicts among planned batches

# Required New / Updated Files

Create or update:

```text
docs/canon/frontend/SURFACE_RECIPE_INDEX.md
docs/canon/frontend/SURFACE_RECIPE_INVENTORY.yaml
docs/canon/frontend/SURFACE_RECIPE_INVENTORY.md
docs/canon/frontend/SURFACE_RECIPE_TEMPLATE.md
docs/canon/frontend/FRONTEND_SURFACE_COVERAGE_MAP.md
docs/canon/frontend/trace/PLANNED_BATCH_FRONTEND_DIRECTION_INVENTORY.md
docs/canon/frontend/trace/FRONTEND_SOURCE_PRECEDENCE_LEDGER.md
docs/canon/frontend/trace/INTENDED_STATE_COVERAGE_MATRIX.md
docs/canon/frontend/trace/UNMAPPED_INTENDED_SURFACE_GAPS.md
```

Create or update recipe directories:

```text
docs/canon/frontend/recipes/
docs/canon/frontend/recipes/shell/
docs/canon/frontend/recipes/today/
docs/canon/frontend/recipes/goals/
docs/canon/frontend/recipes/capture/
docs/canon/frontend/recipes/time/
docs/canon/frontend/recipes/you/
docs/canon/frontend/recipes/cross_surface/
docs/canon/frontend/recipes/onboarding/
docs/canon/frontend/recipes/states/
```

# Required Surface Recipe Inventory

`SURFACE_RECIPE_INVENTORY.yaml` must be machine-readable.

Every visible surface must have an entry.

Allowed statuses:

```text
intended_canon
planned_canon
directional_candidate
unresolved_direction
historical_reference
obsolete
excluded
```

Each entry must include:

```yaml
surface_id:
name:
canon_status:
destination:
surface_type:
hierarchy_level:
parent_surface:
child_surfaces:
primary_object:
supporting_objects:
visible_regions:
recipe_file:
source_truth:
planned_batch_sources:
precedence_notes:
direction_conflicts:
open_direction_questions:
forbidden_patterns:
```

Allowed surface types:

```text
app_shell
top_level_surface
drill_down
sheet
drawer
tray
modal
overlay
row
state_surface
empty_state
error_state
onboarding
settings_detail
receipt_detail
proof_detail
source_detail
composer_state
navigation_chrome
```

Allowed hierarchy levels:

```text
global
destination_root
primary_surface
secondary_surface
tertiary_surface
transient_surface
component_surface
state_variant
```

# Required Recipe Format

Every recipe file must use this exact structure:

```markdown
# Surface Recipe: [Name]

## Canon Status

## Surface ID

## Destination

## Surface Type

## Hierarchy Level

## Parent Surface

## Child Surfaces

## Final Intended Role

## User Perception

## Why This Surface Exists

## Primary Object

## Supporting Objects

## Visible Regions

## Region-by-Region Recipe

### Region 1: [Name]

- Purpose:
- Contains:
- Primitives:
- Typography:
- Spacing:
- Materials:
- Color/state behavior:
- Icons/chevrons:
- Labels:
- CTAs:
- Receipts/proof:
- Interaction meaning:
- Accessibility intent:
- ADHD usability intent:
- Forbidden treatments:

## Primitive Inventory

## Object Inventory

## Typography Recipe

## Spacing Recipe

## Material Recipe

## Color and State Recipe

## Icon, Chevron, and Disclosure Recipe

## CTA Recipe

## Label and Microcopy Recipe

## Receipt / Proof / Source Recipe

## State Model

## Allowed States

## Forbidden States

## Motion and Haptic Intent

## Accessibility Intent

## Dynamic Type Intent

## VoiceOver Intent

## Reduce Motion Intent

## ADHD Usability Intent

## Relationship to MRI

## Relationship to HBI

## Source Truth

## Planned Batch Sources

## Precedence / Conflict Notes

## Forbidden Generic Drift

## Open Direction Gaps
```

# Required Surface Coverage

At minimum, create or update recipes for all surfaces below. Add more if source truth or planned batches indicate more.

## Shell

```text
Global App Shell
Destination Dock
Destination Tab Item
Compact Surface Header
Context Crown
Back Navigation
Sheet Chrome
Tray Chrome
Receipt Toast / Inline Confirmation
Global Empty State Shell
Global Error / Fallback Shell
```

## Today / Reality Meridian

```text
Today Root / Reality Meridian
Today Current Context Header
Today Start Here Region
Today Reality Meridian Rail
Today Recommended Step Object
Today Now / Next / Later Sequence
Today Upcoming Commitments Region
Today Closure Prompt Region
Today Receipt Shelf
Today Source Freshness Indicator
Step Detail
Step Session
Recommendation Source Sheet
Closure Sheet
Receipt Detail
Proof Attachment Detail
Adjust Plan / Reflow Preview Entry
Blocked Detail
Waiting Detail
Goal Thread Context from Today
Local Runtime Source Detail from Today
Today Empty State
Today No Schedule Data State
Today Overloaded State
Today Recovery State
Today Vacation / Away State
Today Protected Time State
Today Stale Recommendation State
```

## Goals / Constellation Atlas

```text
Goals Root / Constellation Atlas
Goals Life Area Map
Selected Life Area Surface
Ambition Graph
Goal Thread Detail
Goal Detail
Commitment Detail
Proof Trail
Proof Detail
Proof Gap State
Blocker Detail
Alternate Path Detail
Milestone Detail
Recommended Step Context from Goals
Reflection / Recovery Detail
Goals Empty State
Goals Review State
Goals Blocked State
Goals Archive / Historical Goal State
```

## Capture / Atmosphere Composer

```text
Capture Root / Atmosphere Composer
Capture Idle Composer
Capture Active Text Entry
Capture Dictation State
Capture Attachment / Proof Picker
Capture Post-Input Route Reveal
Capture Save as Proof Route
Capture Make Commitment Route
Capture Grow into Goal Route
Capture Mark Constraint Route
Capture Reflect Route
Capture Hold / Needs a Place Route
Capture Receipt
Capture Parse Uncertain State
Capture Offline Local-Only State
Capture Error / Failed Attachment State
Capture Empty First-Use State
```

## Time / LifeShape Field

```text
Time Root / LifeShape Field
Time Scope Control
Day LifeShape Surface
Week LifeShape Surface
Month LifeShape Surface
Open Time Region
Protected Time Region
Pressure Region
Best Fit Region
Recovery / Flex Region
Review Pressure Surface
Best Fit Explanation Sheet
Protected Time Detail
Day Detail
Week Detail
Month Detail
Reflow Preview Tray
Shape Day Flow
Reflow Week Flow
Shape Month Flow
Time Receipt Detail
Schedule & Availability Entry
Planning Defaults Entry
Vacation / Away Time Entry
Time No Calendar Data State
Time Overloaded State
Time Protected Block State
Time Vacation / Away State
Time Stale Source State
```

## You / User System Profile

```text
You Root / User System Profile
User Profile Header
Local Runtime Trust Panel
Planning Setup Section
Schedule & Availability
Planning Defaults
Vacation / Away Time
Automation & Trust
Notifications
Capture Preferences
Focus / Session Defaults
Privacy
Personal Runtime
Local Data / Reset / Forget
Help
About Ambitions
You Empty / First-Run State
You Trust Warning State
You Offline Local-Only State
```

## Cross-Surface Systems

```text
Commitment Staging Tray
Reflow Preview Tray
Receipt System
Closure System
Proof Trail System
Recommendation Source System
Why This Sheet
Source Freshness Badge
Still Counts State
Moved State
Skipped / Not Needed State
Blocked State
Waiting State
Needs Recovery State
Needs Review State
Protected Marker
Pressure Marker
Best Fit Marker
Open Marker
Primary CTA
Secondary CTA
Destructive CTA
Disabled CTA
Chevron / Disclosure Row
QuietGlass Wrapper
GraphiteRecess Base
LuminousTrace State Line
CelestialField Semantic Layer
```

## Onboarding / First Run

```text
First Run Root
Schedule Setup Prompt
Planning Defaults Prompt
Privacy / Local Runtime Explanation
Capture First-Use Prompt
Goals First-Use Prompt
Time First-Use Prompt
Today First-Use State
```

If any of these are not supported by repo source truth or planned batch truth, do not delete them. Mark them as `unresolved_direction` and explain what is missing.

# Required Recipe Granularity

Each recipe must list exact visual ingredients.

For every visible region, include:

* object(s)
* primitives
* typography role
* approximate hierarchy weight
* spacing relationship
* material treatment
* color/state treatment
* icons
* chevrons/disclosures
* CTA(s)
* labels
* receipts/proof/source elements
* state variants
* accessibility intent
* ADHD usability intent
* forbidden generic drift

Use descriptive recipes, not implementation commands.

Example style:

```text
The Start Here region is visually attached to the active Reality Meridian segment rather than floating as a detached card. It uses GraphiteRecess as ground, a restrained LuminousTrace edge to express recommendation attachment, a primary step title as the dominant text, a subdued source line explaining why now, and a single primary CTA labeled “Start now.” It must not become a generic AI suggestion card or motivational widget.
```

Do not write:

```text
Implement VStack with HStack and padding 16.
```

This is design canon, not SwiftUI instructions.

# Visual Item Registry Update

Update:

```text
docs/canon/frontend/VISUAL_ITEM_REGISTRY.yaml
docs/canon/frontend/VISUAL_ITEM_REGISTRY.md
```

The registry must align with surface recipes and intended final-state doctrine.

Remove required implementation/proof fields if still present.

Each item should include:

```yaml
visual_id:
name:
canon_status:
kind:
hierarchy_level:
destination:
surface_owner:
object_family:
appears_on:
intended_role:
user_value:
visual_description:
hierarchy_behavior:
state_model:
allowed_states:
visual_tokens:
interaction_meaning:
label_rules:
accessibility_intent:
dynamic_type_intent:
voiceover_intent:
reduce_motion_intent:
adhd_usability_intent:
source_truth:
planned_batch_sources:
precedence_notes:
direction_change_triggers:
forbidden_uses:
open_direction_questions:
```

Ensure registry covers every object/primitive/surface referenced by the recipe files.

# Surface Coverage Map

Create or update:

```text
docs/canon/frontend/FRONTEND_SURFACE_COVERAGE_MAP.md
```

It must show:

* all top-level destinations
* all child surfaces
* all drill-downs
* all sheets
* all trays
* all modal/overlay states
* all empty/error/recovery states
* status for each
* recipe file for each
* source truth for each

This file is the no-missed-surfaces map.

# Unmapped Gap Rules

Create or update:

```text
docs/canon/frontend/trace/UNMAPPED_INTENDED_SURFACE_GAPS.md
```

Any visible concept found in active docs, active planned batches, or source truth that lacks a recipe must be listed here.

Each gap must include:

* name
* source
* likely destination
* likely surface type
* why it matters
* what must be clarified
* recommended canon status

A clean final result may have zero unmapped gaps, but only if that is true.

Do not hide uncertainty.

# MRI / HBI Integration

Create or update intended frontend mapping for MRI/HBI in:

```text
docs/canon/frontend/MRI_HBI_FRONTEND_INTEGRATION_MAP.md
docs/canon/frontend/trace/MRI_HBI_TO_FRONTEND_SURFACE_MATRIX.md
```

MRI/HBI must be represented as intended final visual direction inputs, not implementation proof.

For each MRI/HBI visual influence, document:

* affected destination
* affected surface
* affected object
* affected visible state
* intended visual meaning
* source truth
* precedence/conflict notes
* open direction gaps

Do not guess unresolved MRI/HBI details.

# Commitment Staging Tray

The reusable “bet slip” style pattern must be canonized without gambling language.

Canonical object:

```text
Commitment Staging Tray
```

Time-specific variant:

```text
Reflow Preview Tray
```

Document with exact visual recipe:

* persistent staging / preview / confirmation tray
* collects proposed changes before commit
* shows what changes
* shows what stays protected
* shows why the change is recommended
* shows source/proof basis
* shows expected receipt
* supports confirm
* supports cancel
* supports undo where appropriate
* calm executive clarity
* no sportsbook urgency
* no odds
* no stake
* no bet
* no slip
* no parlay
* no cash-out
* no boost
* no wager
* no line movement language

# Required Updates to Master Encyclopedia

Update the master encyclopedia so it links to and summarizes:

* Surface Recipe Index
* Surface Recipe Inventory
* Surface Coverage Map
* Planned Batch Frontend Direction Inventory
* Source Precedence Ledger
* Intended State Coverage Matrix
* Unmapped Intended Surface Gaps
* Every recipe family

It must include a clear doctrine section:

```text
If a visible surface, object, primitive, state, label, CTA, chevron, material, wrapper, receipt, source affordance, or visible behavior is absent from this atlas, it is not authorized final visual canon and must be treated as a documentation gap before implementation proceeds.
```

# Validators

Create or update validators:

```text
scripts/ambitions-surface-recipe-inventory-check.py
scripts/ambitions-surface-recipe-coverage-check.py
```

Update existing relevant validators if needed:

```text
scripts/ambitions-frontend-architecture-atlas-check.py
scripts/ambitions-visual-item-registry-check.py
scripts/ambitions-visual-direction-change-protocol-check.py
scripts/ambitions-visual-reference-ledger-check.py
scripts/ambitions-frontend-obsolete-term-scan.py
```

Validators must check intended canon completeness only.

They must validate:

* `SURFACE_RECIPE_INDEX.md` exists
* `SURFACE_RECIPE_INVENTORY.yaml` exists and parses
* every inventory item has required fields
* every intended/planned/directional/unresolved surface has a recipe file or unresolved-direction entry
* all five top-level destinations have root recipes
* all required minimum surfaces above are represented
* every recipe uses the required headings
* every recipe includes primitive inventory
* every recipe includes typography, spacing, material, color/state, icon/chevron, CTA, label, receipt/proof/source, state model, accessibility, ADHD usability, MRI, HBI, source truth, planned batch sources, and forbidden drift sections
* registry items align with recipe references
* planned batch direction inventory exists
* source precedence ledger exists
* most recent planned-batch precedence doctrine is documented
* no active recipe treats Plan as a top-level tab
* no active recipe uses the accidental old concept as active canon
* no active recipe uses gambling language for Commitment Staging Tray/Reflow Preview Tray
* no active recipe treats screenshot proof or implementation mapping as required atlas content

Validators must not check:

* screenshots exist
* SwiftUI previews exist
* current UI implementation exists
* production component ownership
* release readiness
* accessibility conformance proof

Write reports:

```text
build/reports/frontend-surface-recipe-encyclopedia-001.json
build/reports/frontend-surface-recipe-encyclopedia-001.md
```

# Validation Commands

Run:

```bash
python3 -m py_compile \
  scripts/ambitions-frontend-architecture-atlas-check.py \
  scripts/ambitions-visual-item-registry-check.py \
  scripts/ambitions-visual-direction-change-protocol-check.py \
  scripts/ambitions-visual-reference-ledger-check.py \
  scripts/ambitions-frontend-obsolete-term-scan.py \
  scripts/ambitions-surface-recipe-inventory-check.py \
  scripts/ambitions-surface-recipe-coverage-check.py
```

Run the docs validators:

```bash
scripts/ambitions-frontend-architecture-atlas-check.py
scripts/ambitions-visual-item-registry-check.py
scripts/ambitions-visual-direction-change-protocol-check.py
scripts/ambitions-visual-reference-ledger-check.py
scripts/ambitions-frontend-obsolete-term-scan.py
scripts/ambitions-surface-recipe-inventory-check.py
scripts/ambitions-surface-recipe-coverage-check.py
```

Run:

```bash
git diff --check \
  docs/canon/frontend \
  docs/canon/README.md \
  scripts/ambitions-frontend-architecture-atlas-check.py \
  scripts/ambitions-visual-item-registry-check.py \
  scripts/ambitions-visual-direction-change-protocol-check.py \
  scripts/ambitions-visual-reference-ledger-check.py \
  scripts/ambitions-frontend-obsolete-term-scan.py \
  scripts/ambitions-surface-recipe-inventory-check.py \
  scripts/ambitions-surface-recipe-coverage-check.py
```

# Allowed Scope

Allowed:

```text
docs/canon/frontend/**
docs/canon/README.md
docs/codex/** index files only if needed to point to the corrected visual recipe authority
scripts/ambitions-frontend-*.py
scripts/ambitions-visual-*.py
scripts/ambitions-surface-recipe-*.py
build/reports/frontend-surface-recipe-encyclopedia-001.*
prompts/batches/FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001.md
```

# Forbidden Scope

Do not implement production SwiftUI UI.

Do not modify app runtime behavior.

Do not require screenshots.

Do not create a screenshot proof packet.

Do not create a current implementation status tracker.

Do not make release, TestFlight, App Store, accessibility conformance, performance, or privacy/legal claims.

Do not add Plan as a top-level tab.

Do not treat current implementation as higher authority than planned not-yet-implemented batches when the question is intended final frontend direction.

Do not let older docs outrank newer planned batches on intended future visual direction.

Do not use the accidental old visual concept as active canon.

Do not collapse the encyclopedia into one unreadable monolith.

Do not write SwiftUI implementation instructions inside surface recipes.

Do not use gambling/sportsbook language for Commitment Staging Tray or Reflow Preview Tray.

# Hard Red Stop Conditions

Stop and report Red if:

* repo source truth cannot be inspected
* planned batch inventory cannot be created
* planned batch recency cannot be determined or safely marked with confidence
* active IA conflicts cannot be classified
* MRI/HBI cannot be documented as intended direction or unresolved direction
* required recipe inventory cannot be parsed
* validators cannot run
* the batch would require production UI implementation
* unrelated dirty work would be overwritten
* accidental old visual concept is still treated as active canon and cannot be safely excluded
* the atlas cannot be corrected away from implementation/proof framing

# Rollback Expectations

Before changes:

```bash
git status --short
```

Do not overwrite unrelated user work.

Keep changes inside allowed scope.

After changes, report:

* files created
* files modified
* files removed/renamed, if any
* planned batch inventory count
* planned frontend-affecting batch count
* surface recipe count
* unresolved surface gap count
* registry item count
* validator commands run
* validator results
* confirmation that no screenshots or production UI implementation were required

If validation fails:

* keep useful docs
* report Yellow or Red honestly
* include exact failed checks
* do not claim Green
* do not stage/commit unrelated files

# Required Final Report

Final report must include:

* status: Green / Yellow / Red
* active IA confirmation
* doctrine confirmation: atlas is intended final-state visual recipe canon
* source precedence summary
* how planned not-yet-implemented batches were ranked
* most recent planned frontend-direction sources discovered
* files created
* files modified
* files removed/renamed, if any
* planned batch inventory count
* surface recipe inventory count
* recipe files count
* unresolved intended-direction gaps
* MRI intended visual direction status
* HBI intended visual direction status
* obsolete/excluded references handled
* validator commands run
* validator results
* confirmation that no screenshots were required
* confirmation that no production UI implementation occurred
* recommended next batch

# Recommended Next Batch

After this batch, recommend:

```text
FRONTEND-SURFACE-RECIPE-COMPLETENESS-REVIEW-001
```

Objective:

Review the completed recipe encyclopedia against all active planned frontend batches and source precedence rules, identify missing or under-specified visible surfaces, and tighten any unresolved-direction entries without implementation or screenshot proof.

# Runner Command

Run with:

```bash
scripts/ambitions-codex-train.sh FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001 prompts/batches/FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001.md
```

or:

```bash
make batch BATCH=FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001 PROMPT=prompts/batches/FRONTEND-SURFACE-RECIPE-ENCYCLOPEDIA-001.md
```

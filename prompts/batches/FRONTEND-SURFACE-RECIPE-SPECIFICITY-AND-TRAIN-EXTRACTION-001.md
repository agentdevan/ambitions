<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001

# Objective

Upgrade the Ambitions Front-End Surface Recipe Encyclopedia from broad recipe coverage into exact, surface-specific final-state visual recipes, while replacing MRI/HBI-specific source-family framing with a complete planned-train/source-family extraction system.

The atlas must describe the fully completed intended Ambitions frontend after all active planned frontend-relevant trains and batches are complete.

This is not an implementation batch.

This is not a screenshot/proof batch.

This is not a current-state audit.

This is a final intended visual recipe specificity pass.

# Core Corrections Required

The current atlas over-calls out MRI/HBI. That is wrong.

MRI and HBI are not the only planned source families. They must be treated as examples within a broader extraction system that includes every planned train/batch family affecting intended frontend visual direction.

At minimum, discover and classify all train/source families found in the repo, including but not limited to:

- LID
- AOS
- PK
- REC
- SI
- PD
- ME
- CS
- MRI
- HBI
- Moat
- Runtime
- Visual Canon
- Product Depth
- Signature Interface
- Planning
- Capture
- Time
- Today
- Goals
- You
- Accessibility
- Privacy
- QA / validation
- onboarding / first-run
- any additional planned train prefixes or source families found in batch prompts, queue files, docs, reports, or registries

Do not hardcode this list as complete. Extract from repo truth.

# Product Truth

Ambitions is a premium native iPhone-first, local-first external brain and personal life operating system.

Active IA is exactly:

- Today
- Goals
- Capture
- Time
- You

Active primary objects:

- Today → Reality Meridian
- Goals → Constellation Atlas
- Capture → Atmosphere Composer
- Time → LifeShape Field
- You → User System Profile

The atlas is the intended final-state visual recipe encyclopedia. It documents what every visible Ambitions surface should contain, mean, and visually express after all planned frontend work is complete.

It is not:

- implementation proof
- screenshot proof
- SwiftUI ownership tracking
- preview tracking
- current-state audit
- release readiness evidence

# Source Precedence

Use this precedence order:

1. This batch prompt.
2. Active truth files under `docs/truth/**`.
3. Current active user direction already encoded in `docs/canon/frontend/**`.
4. Planned not-yet-implemented frontend-relevant batches.
5. Completed batch reports and accepted outputs.
6. Active canon/design/product docs.
7. Current source implementation.
8. Historical docs.
9. Obsolete/archive material.

For conflicts among planned not-yet-implemented batches:

- most recent planned batch creation data wins
- use registry metadata first
- prompt metadata second
- queue/order evidence third
- git introduction history fourth
- filesystem metadata only as low-confidence fallback
- never rely on filename sort alone unless no better evidence exists, and mark that low-confidence

# Required Source Inspection

Inspect:

```text
docs/truth/**
docs/canon/frontend/**
docs/canon/**
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

If a path is missing, note it and continue.

Search repo-wide for train/source-family indicators, including:

```text
LID
AOS
PK
REC
SI
PD
ME
CS
MRI
HBI
MOAT
Runtime
Visual Canon
Signature Interface
Product Depth
Planning
Capture
Time
Today
Goals
You
Accessibility
Privacy
QA
First Run
Onboarding
Surface
Recipe
Atlas
```

Also discover train prefixes from:

* batch filenames
* batch IDs
* queue files
* batch registry files
* prompt headings
* report files
* docs/codex execution plans
* docs/canon references
* source comments only if they reference planned frontend direction

# Required Source Family Extraction

Create or update:

```text
docs/canon/frontend/trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.md
docs/canon/frontend/trace/PLANNED_TRAIN_FRONTEND_DIRECTION_INVENTORY.yaml
docs/canon/frontend/trace/TRAIN_FAMILY_TO_SURFACE_MATRIX.md
docs/canon/frontend/trace/TRAIN_FAMILY_TO_OBJECT_MATRIX.md
docs/canon/frontend/trace/TRAIN_FAMILY_TO_PRIMITIVE_MATRIX.md
docs/canon/frontend/trace/TRAIN_FAMILY_PRECEDENCE_LEDGER.md
docs/canon/frontend/trace/TRAIN_FAMILY_UNRESOLVED_DIRECTION_GAPS.md
```

The inventory must include every discovered train/source family with:

```yaml
train_family_id:
display_name:
aliases:
source_paths:
batch_ids:
status:
frontend_relevance:
affected_destinations:
affected_surfaces:
affected_objects:
affected_primitives:
affected_states:
direction_decisions:
conflicts:
precedence_rank:
recency_evidence:
recency_confidence:
canon_impact:
open_questions:
```

Allowed statuses:

```text
active_planned
active_completed
supporting
historical
obsolete
unresolved
```

Allowed frontend relevance:

```text
direct_visual
surface_behavior
object_model
state_model
copy_labeling
accessibility
privacy_trust
runtime_source
validation_only
non_frontend
unclear
```

# Replace MRI/HBI-Specific Framing

Update all frontend atlas docs and recipes where MRI/HBI are singled out as special sections.

Replace:

```text
Relationship to MRI
Relationship to HBI
MRI/HBI integration map
MRI/HBI surface matrix
```

with broader source-family framing:

```text
Relationship to Planned Train / Source Families
Train Family Influence
Source Family Influence Matrix
Planned Train Frontend Direction Map
```

MRI and HBI should remain as entries inside the broader system if source truth supports them.

Do not delete MRI/HBI information. Reclassify it.

Rename or supersede these files if appropriate:

```text
docs/canon/frontend/MRI_HBI_FRONTEND_INTEGRATION_MAP.md
docs/canon/frontend/trace/MRI_HBI_TO_FRONTEND_SURFACE_MATRIX.md
docs/canon/frontend/objects/MRI_FRONTEND_OBJECTS.md
docs/canon/frontend/objects/HBI_FRONTEND_OBJECTS.md
```

Preferred replacement files:

```text
docs/canon/frontend/PLANNED_TRAIN_FRONTEND_INTEGRATION_MAP.md
docs/canon/frontend/trace/TRAIN_FAMILY_TO_FRONTEND_SURFACE_MATRIX.md
docs/canon/frontend/objects/PLANNED_TRAIN_FRONTEND_INFLUENCE_OBJECTS.md
```

If old MRI/HBI files are retained for compatibility, clearly mark them as superseded by the all-train source family map.

# Recipe Specificity Upgrade

Upgrade every recipe under:

```text
docs/canon/frontend/recipes/**
```

The current recipes have correct structure but too much broad/repeated language. Replace generic template phrasing with surface-specific final-state visual recipes.

Every recipe must specify exact intended visible ingredients and directions:

* required visible regions
* required objects
* supporting objects
* primitive inventory
* typography roles
* hierarchy weight
* spacing relationships
* material treatment
* color/state treatment
* icon rules
* chevron/disclosure rules
* CTA labels
* secondary actions
* receipt/proof/source affordances
* allowed states
* forbidden states
* motion/haptic intent
* accessibility intent
* Dynamic Type intent
* VoiceOver intent
* Reduce Motion intent
* ADHD usability intent
* relationship to all relevant planned train/source families
* source truth
* unresolved direction gaps

Recipes must read like design recipes, not implementation instructions.

Do not write SwiftUI instructions.

Do not use generic filler.

# Required Recipe Field Replacement

In every recipe, replace:

```text
## Relationship to MRI
## Relationship to HBI
```

with:

```text
## Relationship to Planned Train / Source Families
```

This section must list relevant train/source families for that surface.

Example structure:

```markdown
## Relationship to Planned Train / Source Families

- PK: affects Today read model, recommendation/source visibility, and proof-backed daily state where applicable.
- AOS: affects automation/trust visibility, local runtime explanation, and user correction affordances where applicable.
- LID: affects local intelligence display, source freshness, and inspectable reasoning where applicable.
- MRI: affects moat/runtime source loops where repo source supports it.
- HBI: affects historical baseline/proof continuity where repo source supports it.
- SI / Visual Canon: affects signature interface primitives, surface hierarchy, anti-generic visual language, and native iPhone believability.
```

Do not include a train on a recipe unless source truth or planned batch extraction supports relevance. If uncertain, mark as unresolved.

# Surface Recipe Inventory Update

Update:

```text
docs/canon/frontend/SURFACE_RECIPE_INVENTORY.yaml
docs/canon/frontend/SURFACE_RECIPE_INVENTORY.md
docs/canon/frontend/SURFACE_RECIPE_INDEX.md
docs/canon/frontend/FRONTEND_SURFACE_COVERAGE_MAP.md
```

Every surface entry must include:

```yaml
train_family_sources:
train_family_influence:
specificity_status:
```

Allowed specificity statuses:

```text
high_specificity
medium_specificity
low_specificity
unresolved_direction
```

High specificity means the recipe clearly describes exact visual ingredients, hierarchy, labels, primitives, states, and source-family influence.

Medium specificity means the recipe is usable but still broad in some regions.

Low specificity means the recipe exists but remains templated or under-described.

Unresolved direction means the surface is intentionally visible but final visual direction is not yet safe to define.

# Master Encyclopedia Update

Update:

```text
docs/canon/frontend/AMBITIONS_FRONT_END_ARCHITECTURE_ATLAS_AND_VISUAL_ENCYCLOPEDIA.md
```

It must state:

* the atlas extracts all planned frontend-relevant train/source families, not just MRI/HBI
* MRI/HBI are entries in the planned train/source-family influence system
* every recipe includes relevant planned train/source-family influence
* planned train/source-family extraction helps define intended final visual outcome
* current implementation remains lower authority than planned frontend direction for intended final visual outcomes
* recipes must be specific enough to tell a designer or reviewer exactly what visible ingredients belong on the surface

# Visual Item Registry Update

Update:

```text
docs/canon/frontend/VISUAL_ITEM_REGISTRY.yaml
docs/canon/frontend/VISUAL_ITEM_REGISTRY.md
```

Add or update fields:

```yaml
train_family_sources:
train_family_influence:
specificity_status:
```

Ensure registry items no longer single out MRI/HBI unless the item is specifically about those train families.

# Validator Updates

Create or update:

```text
scripts/ambitions-train-family-frontend-extraction-check.py
scripts/ambitions-surface-recipe-specificity-check.py
```

Update existing validators as needed:

```text
scripts/ambitions-surface-recipe-inventory-check.py
scripts/ambitions-surface-recipe-coverage-check.py
scripts/ambitions-frontend-architecture-atlas-check.py
scripts/ambitions-visual-item-registry-check.py
scripts/ambitions-visual-direction-change-protocol-check.py
scripts/ambitions-frontend-obsolete-term-scan.py
```

Validators must check:

1. planned train frontend inventory exists
2. planned train frontend inventory parses
3. all discovered train/source families are represented or explicitly excluded
4. LID, AOS, PK, MRI, and HBI are not lost if present in repo source
5. MRI/HBI are not the only source-family sections
6. master encyclopedia references all-train/source-family extraction
7. recipes use `Relationship to Planned Train / Source Families`
8. recipes do not retain standalone `Relationship to MRI` / `Relationship to HBI` headings
9. every recipe has specificity status
10. every high/medium specificity recipe includes surface-specific visible regions, objects, primitives, typography, spacing, material, color/state, icon/chevron, CTA, receipt/proof/source, state model, accessibility, and planned train influence
11. templated filler phrases are minimized or absent
12. unresolved_direction recipes are explicitly listed in gap docs
13. no recipe treats Plan as top-level IA
14. no recipe uses accidental old concept as active canon
15. no recipe uses sportsbook/gambling transaction language for Commitment Staging Tray or Reflow Preview Tray
16. no recipe requires screenshot proof or implementation proof

Validators must not check:

* screenshots exist
* SwiftUI previews exist
* production code maps to every recipe
* current implementation completeness
* release readiness
* accessibility conformance proof

# Reports

Write:

```text
build/reports/frontend-surface-recipe-specificity-and-train-extraction-001.json
build/reports/frontend-surface-recipe-specificity-and-train-extraction-001.md
```

Reports must include:

* status
* train/source families discovered
* train/source families excluded
* train inventory count
* frontend-relevant train count
* recipe count
* high/medium/low/unresolved specificity counts
* files updated
* validators run
* unresolved direction gaps
* confirmation that MRI/HBI are now part of broader all-train extraction
* confirmation that no implementation or screenshot proof was required

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
  scripts/ambitions-surface-recipe-coverage-check.py \
  scripts/ambitions-train-family-frontend-extraction-check.py \
  scripts/ambitions-surface-recipe-specificity-check.py
```

Run:

```bash
scripts/ambitions-frontend-architecture-atlas-check.py
scripts/ambitions-visual-item-registry-check.py
scripts/ambitions-visual-direction-change-protocol-check.py
scripts/ambitions-visual-reference-ledger-check.py
scripts/ambitions-frontend-obsolete-term-scan.py
scripts/ambitions-surface-recipe-inventory-check.py
scripts/ambitions-surface-recipe-coverage-check.py
scripts/ambitions-train-family-frontend-extraction-check.py
scripts/ambitions-surface-recipe-specificity-check.py
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
  scripts/ambitions-surface-recipe-coverage-check.py \
  scripts/ambitions-train-family-frontend-extraction-check.py \
  scripts/ambitions-surface-recipe-specificity-check.py
```

# Allowed Scope

Allowed:

```text
docs/canon/frontend/**
docs/canon/README.md
docs/codex/** index files only if needed to point to corrected visual recipe authority
scripts/ambitions-frontend-*.py
scripts/ambitions-visual-*.py
scripts/ambitions-surface-recipe-*.py
scripts/ambitions-train-family-*.py
build/reports/frontend-surface-recipe-specificity-and-train-extraction-001.*
prompts/batches/FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001.md
```

# Forbidden Scope

Do not implement production SwiftUI UI.

Do not modify app runtime behavior.

Do not require screenshots.

Do not create screenshot proof packets.

Do not create a current implementation status tracker.

Do not make release, TestFlight, App Store, accessibility conformance, performance, privacy, or legal claims.

Do not add Plan as a top-level tab.

Do not treat MRI/HBI as the only frontend source-family overlays.

Do not ignore LID, AOS, PK, or any other discovered planned train/source family.

Do not treat current implementation as higher authority than planned not-yet-implemented batches when defining intended final frontend direction.

Do not use the accidental old visual concept as active canon.

Do not collapse the encyclopedia into one unreadable monolith.

Do not write SwiftUI implementation instructions inside surface recipes.

Do not use gambling/sportsbook language for Commitment Staging Tray or Reflow Preview Tray.

# Hard Red Stop Conditions

Stop and report Red if:

* repo source truth cannot be inspected
* planned train/source-family inventory cannot be created
* train/source-family extraction cannot parse or classify LID/AOS/PK-style planned sources
* MRI/HBI cannot be reclassified into broader all-train extraction
* active IA conflicts cannot be classified
* required recipe inventory cannot be parsed
* validators cannot run
* the batch would require production UI implementation
* unrelated dirty work would be overwritten
* accidental old visual concept is still treated as active canon and cannot be safely excluded
* atlas cannot be corrected away from MRI/HBI-only framing

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
* train/source family inventory count
* frontend-relevant train/source family count
* surface recipe count
* specificity counts
* unresolved direction gap count
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
* train/source-family extraction summary
* explicit confirmation that MRI/HBI are no longer singled out as the only overlays
* LID/AOS/PK handling result
* most recent planned frontend-direction sources discovered
* files created
* files modified
* files removed/renamed, if any
* recipe specificity counts
* unresolved intended-direction gaps
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

Review the completed all-train-informed surface recipe encyclopedia against source precedence rules, identify missing or under-specified visible surfaces, and tighten unresolved-direction entries without implementation or screenshot proof.

# Runner Command

Run with:

```bash
scripts/ambitions-codex-train.sh FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001 prompts/batches/FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001.md
```

or:

```bash
make batch BATCH=FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001 PROMPT=prompts/batches/FRONTEND-SURFACE-RECIPE-SPECIFICITY-AND-TRAIN-EXTRACTION-001.md
```

This should correct the actual miss: **not enough specificity, and source-family extraction too narrowly centered on MRI/HBI instead of every planned Ambitions train.**

<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Batch Prompt: VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03

## Batch ID

`VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03`

## Runner Command

```bash
scripts/ambitions-codex-train.sh VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03 prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md
```

Equivalent:

```bash
make batch BATCH=VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03 PROMPT=prompts/batches/VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03.md
```

---

# Operating Model

Execute through the Ambitions runner:

1. GPT-5.5 plan.
2. GPT-5.4-mini bounded patch.
3. GPT-5.5 review / repair / final commit readiness.

Do not bypass the runner.

This is a successor to:

- `VISUAL-ENCYCLOPEDIA-100-PERFECTION-INSTALL-01`
- `VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-02` if present or planned

This prompt expands scope. It must not shrink, dilute, or defer the prior proof-hardening scope.

This is a documentation / canon / validation / control-plane batch. It may inspect production SwiftUI/source files only to classify source-link truth and design-to-implementation drift. It must not implement production UI.

The bounded patch phase must use GPT-5.4-mini and remain documentation/tooling bounded.

---

# Primary Mission

Resolve the known Red and Yellow flags from the post-run review of the Visual Encyclopedia 100 install, then harden the Ambitions frontend canon so future Green cannot be achieved by shallow artifact presence, six-root source linkage, vocabulary-only checks, or generic high-specificity prose.

This batch must turn the visual canon control plane into a proof-grade system that can distinguish:

1. Design-canon quality.
2. Control-plane completeness.
3. Source-linkage truth.
4. Implementation proof.
5. Release/accessibility/device proof.

These must never be collapsed into one Green.

The previous Green must be challenged, not trusted.

The expected output is a stricter system that may truthfully report Green, Yellow, or Red. A truthful Yellow is better than a fake Green.

---

# Product Definition

Ambitions is a premium native iPhone-first, local-first external brain and personal life operating system.

It helps the user:

- organize life
- shape time
- ground goals
- adapt to reality
- close loops without shame
- preserve proof
- improve execution through inspectable local intelligence

Active top-level IA is exactly:

- Today
- Goals
- Capture
- Time
- You

Active primary objects are exactly:

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
- QuietGlass
- GraphiteRecess
- LuminousTrace
- CelestialField
- alive, adaptive, inspectable, calm, native
- local-first / on-device-first core intelligence
- no external/cloud LLM dependency for core product behavior

Hard exclusions:

- no Plan top-level tab
- no chatbot UI
- no generic AI assistant panel
- no generic productivity app
- no generic card-stack dashboard
- no generic task-list app
- no calendar clone
- no habit tracker
- no streaks, scores, rings, shame, or productivity-bro tone
- no sportsbook/gambling language or urgency mechanics
- no fantasy/sci-fi interface
- no decorative stars/space effects unless they serve orientation, continuity, state, proof, source freshness, or object meaning
- no detached Start Here card
- no false release, accessibility, App Store, TestFlight, device, implementation, or source-link claims

---

# Critical Problem Statement

The previous visual encyclopedia install reports Green. That is not enough.

Known concerns to resolve:

- Green was partly based on file existence and simple counts.
- Object anatomy coverage was counted by whether files exist.
- Label-off coverage was counted by whether one file exists.
- Accessibility/ADHD coverage was counted by whether two docs exist.
- Anti-generic coverage was counted by whether two docs exist.
- Source-link priority set was only six root recipes.
- Many key surfaces were `intended_only` and not treated as a major dashboard risk.
- The vocabulary validator appeared to scan a limited subset of files.
- The North Star 100 gate was a checklist outline, not an executable measurable gate.
- The recipe template was headings only.
- Some object anatomy docs were likely too similar.
- Some primitive docs were role notes, not operational visual contracts.
- Some recipe content was long but still generic or templated.
- The core atlas may not have been fully subordinated to the five object anatomies.
- The dashboard did not expose source-link debt strongly enough.
- The previous audit called itself ruthless while declaring 100/100 too quickly.
- The report said commit not created in the phase even though artifacts exist on main.
- `implementation proof` remained out of scope but could be confused with canon Green.

This batch must address those specific weaknesses and any additional weaknesses discovered during inspection.

---

# Non-Negotiable Status Model

Install and enforce a five-axis status model.

## 1. Canon Content Status

Measures the design canon itself.

Required to evaluate:

- object anatomy depth
- object uniqueness
- label-off recognizability
- recipe depth
- anti-generic gates
- accessibility/ADHD specificity
- proof/source/receipt coverage
- transaction coverage
- primitive operationality
- native iPhone believability

Allowed statuses:

- Green
- Yellow
- Red

## 2. Control-Plane Status

Measures validators, dashboards, manifests, ledgers, Makefile targets, reports, and local reproducibility.

Allowed statuses:

- Green
- Yellow
- Red

## 3. Source-Linkage Status

Measures design-to-source truth.

Allowed statuses:

- Green: P0 source linkage is strong or honestly weak where source exists, with no hidden debt.
- Yellow: important P0 recipes remain `intended_only`, `weak_link`, or `missing`, but debt is explicit.
- Red: source linkage is missing, false, hidden, or stale.

## 4. Implementation Proof Status

Must be:

- Not In Scope

unless production UI implementation and proof are actually performed in a future allowed implementation batch.

## 5. Release / Accessibility / Device Proof Status

Must be:

- Not In Scope

unless real release/device/accessibility proof is produced in a future allowed implementation/proof batch.

Do not let final report state one simplistic Green.

---

# Source Truth To Inspect

Inspect first:

- `docs/truth/**`
- `docs/canon/frontend/**`
- `docs/canon/frontend/objects/**`
- `docs/canon/frontend/primitives/**`
- `docs/canon/frontend/behavior/**`
- `docs/canon/frontend/gates/**`
- `docs/canon/frontend/recipes/**`
- `docs/canon/frontend/trace/**`
- `docs/canon/frontend/VISUAL_SOURCE_LINKS.yaml`
- `docs/canon/frontend/VISUAL_ENCYCLOPEDIA_RUTHLESS_AUDIT.md`
- `docs/canon/frontend/VISUAL_ENCYCLOPEDIA_PERFECTION_PLAN.md`
- `docs/canon/frontend/VISUAL_RECIPE_SHORT_FORM_TEMPLATE.md`
- `docs/canon/frontend/VISUAL_OBJECT_FIRST_REVIEW_RUBRIC.md`
- `docs/canon/frontend/VISUAL_ACCESSIBILITY_ADHD_REQUIREMENTS.md`
- `docs/canon/frontend/VISUAL_ANTI_SLOP_RULES.md`
- `docs/canon/frontend/VISUAL_VOCABULARY_BOUNDARY.md`
- `docs/canon/frontend/gates/NORTH_STAR_100_ACCEPTANCE_GATE.md`
- `docs/canon/frontend/SURFACE_RECIPE_INVENTORY.yaml`
- `docs/canon/frontend/SURFACE_RECIPE_INDEX.md`
- `docs/canon/frontend/FRONTEND_SURFACE_COVERAGE_MAP.md`
- `docs/canon/frontend/VISUAL_ITEM_REGISTRY.yaml`
- `docs/canon/frontend/VISUAL_ITEM_REGISTRY.md`
- `build/reports/visual-encyclopedia-100-perfection-install-001.md`
- `build/reports/visual-encyclopedia-dashboard.json`
- `build/reports/visual-source-linkage.json`
- `build/reports/visual-surface-graph.json`
- `build/reports/visual-template-residue.json`
- `build/reports/visual-vocabulary-boundary.json`
- `scripts/ambitions-visual-dashboard.py`
- `scripts/ambitions-visual-source-linkage-check.py`
- `scripts/ambitions-visual-surface-graph-check.py`
- `scripts/ambitions-visual-template-residue-check.py`
- `scripts/ambitions-visual-vocabulary-boundary-check.py`

Also inspect, as needed for source-link truth only:

- `Native/**`
- `Sources/**`
- `AppUI/Sources/**`
- `Package.swift`
- `Makefile`
- `justfile`
- other validators under `scripts/**`
- related prompts under `prompts/batches/**`
- reports under `build/reports/**`

---

# Source Precedence

Use this precedence order:

1. Current prompt direction in this batch.
2. Active truth files under `docs/truth/**`.
3. Current frontend atlas doctrine under `docs/canon/frontend/**`.
4. Prior visual encyclopedia install/hardening artifacts as previous-pass evidence only.
5. Planned not-yet-implemented frontend-relevant batches.
6. Completed batch reports and accepted outputs.
7. Current SwiftUI/source implementation.
8. Historical docs.
9. Obsolete/archive material.

Conflict rules:

- If older docs say `Plan` is active top-level IA, supersede with `Time`.
- If older docs imply external/cloud LLMs are core architecture, supersede with local-first deterministic runtime direction.
- If previous reports say Green or 100/100 but validators only prove artifact presence, downgrade the claim in the new proof report.
- If source-link manifest says `linked` but source only approximates the object, downgrade to `weak_link` or keep `linked` with exact caveat.
- If a recipe is intended canon with no source implementation, keep it `intended_only`; do not upgrade falsely.
- If a gate or dashboard says Green while hiding large intended-only debt, change the gate/dashboard rather than hiding debt.

---

# Allowed Scope

You may modify or create:

- `docs/canon/frontend/**`
- `docs/canon/frontend/objects/**`
- `docs/canon/frontend/primitives/**`
- `docs/canon/frontend/behavior/**`
- `docs/canon/frontend/gates/**`
- `docs/canon/frontend/trace/**`
- `docs/canon/frontend/recipes/**`
- `build/reports/**`
- `scripts/ambitions-visual-*.py`
- existing frontend visual validators if needed
- `Makefile`
- `justfile`
- local validation docs
- `docs/codex/**` only if needed for governance templates
- `CONTRIBUTING.md` only if needed and consistent with repo conventions

Do not modify production UI source except for read-only inspection. If source files are inspected, final report must say no production UI was modified.

---

# Forbidden Scope

Do not:

- implement production SwiftUI UI
- redesign active app screens in source
- modify business logic
- modify persistence/data model
- modify release/signing/TestFlight/App Store workflows
- generate or check in `.xcodeproj`
- create or activate hosted CI workflows
- add external/cloud LLMs as core architecture
- reintroduce Plan as active top-level IA
- convert docs Green into implementation proof
- claim true 100/100 unless all new proof gates pass
- hide `intended_only`, `weak_link`, `missing`, or `needs_direction` debt
- mark a recipe high-quality merely because it has many sections
- use file existence as proof of content quality
- leave new docs unindexed
- leave new scripts out of local validation
- touch unrelated dirty files
- touch `.codex/runs/**` except to ignore/report it
- create broad unrelated churn

---

# Required P0 Priority Registry

Create or update a machine-readable P0/P1/P2 registry:

- `docs/canon/frontend/trace/VISUAL_100_PRIORITY_RECIPE_REGISTRY.yaml`
- `docs/canon/frontend/trace/VISUAL_100_PRIORITY_RECIPE_REGISTRY.md`

The registry must not be limited to six roots.

## P0 Priority Recipes

### Shell / Cross-Surface

- Global App Shell
- Destination Dock
- Destination Tab Item
- Compact Surface Header
- Context Crown
- Sheet Chrome
- Tray Chrome
- Primary CTA
- Secondary CTA
- Chevron / Disclosure Row
- QuietGlass Wrapper
- GraphiteRecess Base
- LuminousTrace State Line
- CelestialField Semantic Layer
- Receipt Toast / Inline Confirmation
- Global Empty State Shell
- Global Error Fallback Shell

### Today

- Today Root / Reality Meridian
- Today Start Here Region
- Today Reality Meridian Rail
- Today Recommended Step Object
- Today Now / Next / Later Sequence
- Today Closure Prompt Region
- Today Receipt Shelf
- Today Source Freshness Indicator
- Closure Sheet
- Step Detail
- Step Session
- Receipt Detail
- Recommendation Source Sheet
- Proof Attachment Detail
- Blocked Detail
- Waiting Detail
- Today Empty State
- Today Recovery State
- Today Protected Time State
- Today Stale Recommendation State

### Goals

- Goals Root / Constellation Atlas
- Goals Life Area Map
- Selected Life Area Surface
- Ambition Graph
- Goal Thread Detail
- Goal Detail
- Proof Trail
- Proof Detail
- Proof Gap State
- Blocker Detail
- Alternate Path Detail
- Milestone Detail
- Reflection / Recovery Detail
- Goals Empty State
- Goals Review State

### Capture

- Capture Root / Atmosphere Composer
- Capture Idle Composer
- Capture Active Text Entry
- Capture Post-Input Route Reveal
- Capture Attachment / Proof Picker
- Capture Hold / Needs a Place Route
- Capture Receipt
- Capture Empty State
- Capture Source Detail
- Capture Re-Place / Wrong Route Recovery

### Time

- Time Root / LifeShape Field
- Day LifeShape Surface
- Week LifeShape Surface
- Month LifeShape Surface
- Month Detail
- Review Pressure Surface
- Reflow Preview Tray
- Protected Time Detail
- Best Fit Explanation Sheet
- Shape Day Flow
- Shape Month Flow
- Time Stale Source State
- Time Vacation / Away State
- Time Protected Time Conflict State

### You

- You Root / User System Profile
- Local Runtime Trust Panel
- Planning Setup Section
- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Automation & Trust
- Privacy
- Personal Runtime
- Local Data / Reset / Forget
- Local Learning Preview
- Learned Pattern Detail
- Reset / Forget Consequence Preview

### Cross-Surface Systems

- Commitment Staging Tray
- Reflow Preview Tray
- Receipt System
- Closure System
- Proof Trail System
- Recommendation Source System
- Why This Sheet
- Source Freshness Badge
- Trust Seam
- Proof Chip
- Proof Ladder
- Proof Transfer Thread
- Protected Time Integrity
- Recovery Mode Surface
- Transaction Receipt
- Undo / Revert Strip

## P1 Priority Recipes

All remaining top-level child surfaces, state surfaces, onboarding surfaces, first-run surfaces, and source/proof/detail surfaces.

## P2 Priority Recipes

Lower-risk supporting docs, lower-risk future invention surfaces, and non-critical detail recipes.

Every P0/P1/P2 entry must map to:

- surface ID
- recipe path
- destination
- primary object
- source-link status
- required gates
- current pass/fail status
- implementation proof status
- notes

---

# Required Red / Yellow Resolution Ledger

Create:

- `docs/canon/frontend/trace/VISUAL_100_RED_YELLOW_FLAG_LEDGER.md`
- `docs/canon/frontend/trace/VISUAL_100_FLAG_RESOLUTION_MATRIX.yaml`

Include every red/yellow flag from prior review plus newly discovered flags.

At minimum include flags for:

- artifact-presence Green
- six-recipe priority set
- intended-only debt hidden from dashboard
- source linkage only checking path existence
- object anatomy existence counted as quality
- label-off existence counted as pass
- accessibility docs existence counted as pass
- anti-generic docs existence counted as pass
- North Star gate as checklist only
- recipe template headings only
- thin primitive docs
- similar object docs
- narrow vocabulary scan
- coverage map not truly used by dashboard
- source-link distribution missing full counts
- recipe upgrades not matching prompt breadth
- core atlas lightly modified relative to new object backbone
- implementation proof out of scope but potentially confused
- report commit/status mismatch
- no P0/P1/P2 recipe tier enforcement
- no recipe schema depth validator
- no object anatomy depth validator
- no full-corpus vocabulary validator
- no accessibility/ADHD surface validator
- no proof/source/receipt validator
- no transaction model validator
- no primitive operationality validator
- no measurable gate matrix
- no per-object or per-destination quality score

Each flag must include:

- flag ID
- severity: Red / Yellow
- evidence file(s)
- issue
- why it matters
- required repair
- repair artifact(s)
- validator/gate enforcing repair
- status: closed / downgraded / accepted limitation / still open
- reason if still open

Do not close a flag by merely creating a file. Close only if enforcement or documented accepted limitation exists.

---

# Required Measurable Gate System

Upgrade:

- `docs/canon/frontend/gates/NORTH_STAR_100_ACCEPTANCE_GATE.md`

Create:

- `docs/canon/frontend/gates/NORTH_STAR_100_MEASURABLE_GATE_MATRIX.yaml`
- `docs/canon/frontend/gates/NORTH_STAR_100_GATE_RESULTS.md`

The gate matrix must define each gate with:

- gate ID
- gate name
- category
- required scope
- applies to P0/P1/P2
- validator name
- report output
- required fields
- pass threshold
- warning threshold
- fail condition
- proof type:
  - design-canon proof
  - control-plane proof
  - source-link proof
  - implementation proof
  - release proof
  - accessibility implementation proof
- false-positive risk
- false-negative risk
- manual review note

Required gate categories:

- IA correctness
- object anatomy depth
- object uniqueness
- label-off recognizability
- recipe schema depth
- source-link truth
- intended-only debt visibility
- anti-generic kill switches
- accessibility/ADHD surface coverage
- proof/source/receipt coverage
- transaction-model coverage
- primitive operationality
- native iPhone believability
- local-first trust visibility
- no false momentum
- no hidden automation
- microcopy boundaries
- full-corpus vocabulary boundary
- dashboard proof separation
- implementation-proof boundary

---

# Required Object Anatomy Deepening

Upgrade these files substantially:

- `docs/canon/frontend/objects/PRIMARY_OBJECT_ANATOMY_CANON.md`
- `docs/canon/frontend/objects/LABEL_OFF_SIGNATURE_TESTS.md`
- `docs/canon/frontend/objects/REALITY_MERIDIAN_ANATOMY.md`
- `docs/canon/frontend/objects/CONSTELLATION_ATLAS_ANATOMY.md`
- `docs/canon/frontend/objects/ATMOSPHERE_COMPOSER_ANATOMY.md`
- `docs/canon/frontend/objects/LIFESHAPE_FIELD_ANATOMY.md`
- `docs/canon/frontend/objects/USER_SYSTEM_PROFILE_ANATOMY.md`

Each primary object doc must include:

- object purpose
- category role
- non-negotiable user perception
- text/ASCII anatomy diagram
- required zones
- zone order
- density budget
- collapse behavior
- allowed information types
- forbidden information types
- object-specific state matrix
- source/proof/receipt behavior
- transaction behavior
- error/conflict behavior
- recovery behavior
- accessibility fallback matrix
- ADHD safety matrix
- native iPhone believability rules
- anti-generic failure examples
- minimum recipe dependencies
- source-link status summary
- label-off recognition criteria
- concrete good/bad examples
- unique object vocabulary
- prohibited lookalike patterns

Object docs must not be near-duplicates except for shared mandated headings.

## Reality Meridian must define:

- exact relationship between Start Here and Meridian
- why Start Here is not detachable
- Now / Next / Later as state bands, not sections
- closure prompt placement
- proof/source seam placement
- one-dominant-action rule
- clear-day mode
- recovery-day mode
- high-pressure-day mode
- low-capacity mode
- protected-time mode
- stale-source behavior
- label-off signature
- anti-task-list examples

## Constellation Atlas must define:

- relational goal field
- life-area equality
- thread-to-Today feed
- proof density without chart/dashboard
- blocker/waiting semantics
- pivot/proof transfer
- non-planetarium celestial semantics
- label-off signature
- anti-dashboard examples

## Atmosphere Composer must define:

- bottom-native composer anatomy
- no feed at rest
- no chat bubbles
- post-input route reveal
- three-route cap
- Held With Dignity state
- proof attachment behavior
- re-place wrong-route behavior
- label-off signature
- anti-chat/inbox examples

## LifeShape Field must define:

- non-calendar capacity geometry
- day/week/month grammar
- hard context first
- protected time as carved space
- pressure as compression
- open capacity after commitments
- reflow before/after geometry
- best-fit explanation anatomy
- vacation/away override
- label-off signature
- anti-calendar examples

## User System Profile must define:

- Personal Runtime hero
- local runtime trust panel anatomy
- what Ambitions knows/guesses/never accesses
- user-set vs learned vs suggested
- automation ladder
- reset/forget preview
- schedule availability consequence preview
- privacy plain language
- label-off signature
- anti-settings examples

---

# Required Primitive Deepening

Upgrade these files substantially:

- `docs/canon/frontend/primitives/TRUST_SEAM.md`
- `docs/canon/frontend/primitives/PROOF_PRIMITIVES.md`
- `docs/canon/frontend/primitives/LOCAL_RUNTIME_PRIMITIVES.md`
- `docs/canon/frontend/primitives/PRESSURE_AND_CAPACITY_PRIMITIVES.md`
- `docs/canon/frontend/primitives/MATERIAL_PRIMITIVE_ROLES.md`

Create additional primitive docs if needed:

- `docs/canon/frontend/primitives/SOURCE_FRESHNESS_PRIMITIVES.md`
- `docs/canon/frontend/primitives/RECEIPT_PRIMITIVES.md`
- `docs/canon/frontend/primitives/PROTECTED_TIME_PRIMITIVES.md`
- `docs/canon/frontend/primitives/TRANSACTION_PRIMITIVES.md`

Each primitive doc must include:

- purpose
- canonical anatomy
- allowed use
- forbidden use
- surfaces where allowed
- surfaces where forbidden
- visual ingredients
- state variants
- source/proof/receipt behavior if relevant
- accessibility fallback
- ADHD safety note
- misuse examples
- recipe examples
- validator hooks

Do not let primitives remain vibes.

---

# Required Recipe Template Upgrade

Upgrade:

- `docs/canon/frontend/VISUAL_RECIPE_SHORT_FORM_TEMPLATE.md`

It must no longer be headings only.

For each section, include:

- what the section must contain
- minimum acceptable specificity
- bad answer example
- good answer example
- validator hint
- P0/P1/P2 requirement level

Add a machine-readable companion if useful:

- `docs/canon/frontend/VISUAL_RECIPE_SCHEMA_CONTRACT.yaml`

Required template sections:

- Purpose
- Surface Hierarchy
- Primary Object Dependency
- Label-Off Signature
- Canonical Anatomy
- Visible Regions
- Dominant Object
- Supporting Objects
- Primitive Usage
- Typography Roles
- Spacing Rules
- Material Rules
- Color / State Rules
- Iconography
- Chevron / Disclosure Rules
- Source / Trust Behavior
- Proof / Receipt Behavior
- Transaction Behavior
- Primary Action
- Secondary Correction Path
- Empty State
- Loading / Unknown State
- Error / Conflict State
- Recovery State
- VoiceOver Order
- Dynamic Type Behavior
- Reduce Motion Behavior
- Reduce Transparency Behavior
- Increase Contrast Behavior
- Differentiate Without Color Behavior
- ADHD Density Law
- Native iPhone Believability Requirements
- Train / Source-Family Influence
- Source Linkage
- Implementation Proof Boundary
- Unresolved Direction
- Anti-Generic Red Flags
- Forbidden Interpretations
- Acceptance Checklist
- Good / Bad Example

---

# Required P0 Recipe Deepening

Do not blindly rewrite all 159 recipes.

Do this:

1. Identify all P0 recipes from the new registry.
2. Upgrade each P0 recipe to the strengthened schema or log why it cannot be completed.
3. Validate P0 recipes with strict schema/depth validators.
4. For P1 recipes, ensure minimum schema and log gaps.
5. For P2 recipes, preserve intent and log lower-risk gaps.

For each P0 recipe, include:

- exact visible anatomy
- actual object relationship
- source/proof/receipt behavior
- transaction behavior where relevant
- accessibility fallback
- ADHD density law
- anti-generic failure/replacement
- implementation proof boundary
- source-link status
- Good / Bad example

If P0 recipe deepening is too large for one patch, do not fake completion. Instead:

- harden validators first
- upgrade the highest-risk P0 recipes
- mark remaining P0 recipes as explicit blocking Yellow/Red gaps
- final report must be Yellow or Red, not Green

---

# Required Validator Set

Use standard-library Python unless existing repo conventions already permit dependencies.

Add or upgrade the following validators.

## 1. Priority Registry Validator

Create:

`./scripts/ambitions-visual-100-priority-registry-check.py`

Must validate:

- P0/P1/P2 tiers exist
- P0 set is not six roots only
- every P0 entry maps to a surface ID or explicit missing gap
- every P0 entry maps to a recipe path where available
- every P0 entry maps to source-link row
- every P0 entry maps to gate requirements

Emit:

- `build/reports/visual-100-priority-registry.json`

Fail Red if:

- P0 set is artificially small
- P0 entries lack recipe/source/gate mapping
- required P0 entries are missing without explicit accepted limitation

## 2. Recipe Contract Validator

Create:

`./scripts/ambitions-visual-100-recipe-contract-check.py`

Must validate P0/P1 recipe schema depth.

Checks:

- required sections by tier
- non-empty sections
- minimum content depth
- banned boilerplate
- repeated section text across regions
- required Good / Bad examples for P0
- source/proof/receipt behavior where relevant
- transaction behavior where relevant
- accessibility/ADHD behavior
- anti-generic Red flags
- implementation proof boundary

Emit:

- `build/reports/visual-100-recipe-contract.json`

Fail Red for P0 missing/empty/generic required sections.

## 3. Object Depth Validator

Create:

`./scripts/ambitions-visual-100-object-depth-check.py`

Must validate:

- required object sections
- ASCII/text diagram
- zone order
- state matrix
- accessibility matrix
- ADHD matrix
- source/proof/receipt behavior
- unique vocabulary
- anti-generic examples
- label-off criteria
- excessive similarity across object docs

Emit:

- `build/reports/visual-100-object-depth.json`

Fail Red if any primary object is shallow, missing required sections, or too similar to others beyond allowed shared headings.

## 4. Source Debt Validator

Create:

`./scripts/ambitions-visual-100-source-debt-check.py`

Must report full source-link distribution across all recipes and P0 recipes:

- linked
- weak_link
- intended_only
- missing
- needs_direction

Must validate:

- linked source files exist
- weak links explain limitation
- intended-only rows have implementation-debt notes
- missing rows have gap explanation
- P0 intended-only count is surfaced
- P0 weak-link count is surfaced
- no source-present claim equals implementation-complete claim

Emit:

- `build/reports/visual-100-source-debt.json`

Do not fail solely because intended-only exists, but make Source-Linkage Status Yellow when P0 intended-only/weak/missing debt remains.

Fail Red if debt is hidden, false, or unclassified.

## 5. Full-Corpus Vocabulary Validator

Create or upgrade:

`./scripts/ambitions-visual-100-vocabulary-full-corpus-check.py`

Must scan:

- all `docs/canon/frontend/**`
- all recipes
- all object docs
- all primitive docs
- all behavior docs
- all gates
- all trace docs
- visual reports where appropriate

Must classify:

- allowed active canon
- internal-only
- historical/supporting
- compatibility seam
- forbidden active canon

Emit:

- `build/reports/visual-100-vocabulary-full-corpus.json`

Fail Red on forbidden active-canon leakage.

## 6. Anti-Generic Validator

Create:

`./scripts/ambitions-visual-100-anti-generic-check.py`

Must validate P0 recipes against kill switches:

- Today not task list
- Time not calendar clone
- Capture not chatbot/inbox
- Goals not dashboard/KPI board
- You not settings clone
- cross-surface primitives not decorative chrome

Must require positive replacement evidence, not just absence of bad words.

Emit:

- `build/reports/visual-100-anti-generic.json`

Fail Red for any P0 anti-generic failure.

## 7. Accessibility / ADHD Validator

Create:

`./scripts/ambitions-visual-100-accessibility-adhd-check.py`

Must validate P0/P1 recipes include:

- VoiceOver order
- Dynamic Type behavior
- Reduce Motion behavior
- Reduce Transparency behavior
- Increase Contrast behavior
- Differentiate Without Color behavior
- no color-only meaning
- no motion-only meaning
- hit target intent
- one dominant action or exception
- capped choices where relevant
- recovery/cancel/undo path

Emit:

- `build/reports/visual-100-accessibility-adhd.json`

Fail Red on P0 missing requirements.

## 8. Proof / Source / Receipt Validator

Create:

`./scripts/ambitions-visual-100-proof-source-receipt-check.py`

Must validate relevant P0 recipes include:

- source behavior
- source freshness behavior
- proof behavior
- receipt behavior
- no false proof claims
- local-only / user-set / stale / missing states where applicable
- proof transfer where applicable
- Still Counts where applicable
- No False Momentum where applicable

Emit:

- `build/reports/visual-100-proof-source-receipt.json`

Fail Red for P0 missing requirements.

## 9. Transaction Validator

Create:

`./scripts/ambitions-visual-100-transaction-check.py`

Must validate meaningful change surfaces include:

- Intent
- Preview
- Commit
- Receipt
- Undo / Recover

Surfaces include:

- reflow
- protected time changes
- capture placement
- capture hold
- goal promotion
- closure
- Still Counts
- proof attachment
- automation changes
- reset/forget
- schedule/default changes
- vacation/away changes

Emit:

- `build/reports/visual-100-transaction.json`

Fail Red for P0 missing transaction coverage.

## 10. Primitive Operationality Validator

Create:

`./scripts/ambitions-visual-100-primitive-operationality-check.py`

Must validate primitive docs contain operational fields:

- purpose
- allowed use
- forbidden use
- visual anatomy
- state variants
- accessibility fallback
- misuse examples
- recipe examples
- validator hooks

Emit:

- `build/reports/visual-100-primitive-operationality.json`

Fail Red for P0 primitive gaps.

## 11. False Green Validator

Create:

`./scripts/ambitions-visual-100-false-green-check.py`

Must detect false Green risk:

- dashboard status Green while P0 intended-only debt hidden
- dashboard status Green while only file-existence coverage is counted
- report says 100/100 without all P0 gates passing
- report claims implementation/accessibility/release proof out of scope
- previous Green retained without revalidation
- Source-Linkage Status collapsed into Canon Content Status
- Implementation Proof Status missing or not Not In Scope

Emit:

- `build/reports/visual-100-false-green.json`

Fail Red on false Green risk.

## 12. North Star 100 Gate Validator

Create:

`./scripts/ambitions-visual-100-gate-check.py`

Must read:

- `NORTH_STAR_100_MEASURABLE_GATE_MATRIX.yaml`
- all new validator reports

Must compute:

- Canon Content Status
- Control-Plane Status
- Source-Linkage Status
- Implementation Proof Status
- Release / Accessibility / Device Proof Status

Emit:

- `build/reports/visual-100-gate.json`
- `build/reports/visual-100-gate.md`

Fail Red if any P0 Canon Content gate fails.

Do not fail because Implementation Proof is Not In Scope.

Fail if implementation proof is claimed without proof.

## 13. Proof Dashboard V3

Create:

`./scripts/ambitions-visual-100-proof-dashboard.py`

Must combine all new and existing reports into:

- `build/reports/visual-100-proof-dashboard.json`
- `build/reports/visual-100-proof-dashboard.md`

Dashboard must not output one simplistic Green.

It must show:

- Canon Content Status
- Control-Plane Status
- Source-Linkage Status
- Implementation Proof Status
- Release / Accessibility / Device Proof Status
- P0/P1/P2 coverage
- P0/P1/P2 source-link distribution
- object scores
- primitive scores
- recipe schema pass/fail counts
- anti-generic pass/fail counts
- accessibility/ADHD pass/fail counts
- proof/source/receipt pass/fail counts
- transaction pass/fail counts
- false Green risk count
- remaining Red/Yellow flags

---

# Required Makefile Targets

Add or update local targets if repo conventions permit:

```makefile
visual-100-priority
visual-100-recipes
visual-100-objects
visual-100-source-debt
visual-100-vocabulary
visual-100-anti-generic
visual-100-accessibility
visual-100-proof-source-receipt
visual-100-transaction
visual-100-primitives
visual-100-false-green
visual-100-gate
visual-100-dashboard
visual-100-all
```

`visual-100-all` must run all relevant existing visual validators and all new V3 proof validators.

Do not require Xcode.

Do not activate hosted CI.

---

# Required Reports

Create:

- `build/reports/visual-encyclopedia-100-proof-hardening-03.md`
- `build/reports/visual-100-proof-dashboard.json`
- `build/reports/visual-100-proof-dashboard.md`
- all validator reports named above

Final report must include:

```text
STATUS: GREEN|YELLOW|RED
Batch: VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03

Bounded patch model: GPT-5.4-mini

Canon Content Status:
Control-Plane Status:
Source-Linkage Status:
Implementation Proof Status:
Release / Accessibility / Device Proof Status:

Summary:
Files changed:
Validators added:
Validators upgraded:
Docs deepened:
P0 recipe registry:
P0 recipes upgraded:
P0 recipes still failing:
P1/P2 gaps logged:
Object anatomy scores:
Primitive operationality scores:
Source-link distribution:
Intended-only debt:
False Green risks closed:
Red/yellow flags closed:
Red/yellow flags still open:
Validation run:
Reports:
UI implementation changed:
Hosted CI activated:
Release/accessibility/App Store claims:
Rollback notes:
Commit:
```

Do not say 100/100 unless the new gate proves it.

---

# Validation Expectations

Run from repo root:

```bash
git status --short
git diff --check

python3 -m py_compile \
  scripts/ambitions-visual-100-priority-registry-check.py \
  scripts/ambitions-visual-100-recipe-contract-check.py \
  scripts/ambitions-visual-100-object-depth-check.py \
  scripts/ambitions-visual-100-source-debt-check.py \
  scripts/ambitions-visual-100-vocabulary-full-corpus-check.py \
  scripts/ambitions-visual-100-anti-generic-check.py \
  scripts/ambitions-visual-100-accessibility-adhd-check.py \
  scripts/ambitions-visual-100-proof-source-receipt-check.py \
  scripts/ambitions-visual-100-transaction-check.py \
  scripts/ambitions-visual-100-primitive-operationality-check.py \
  scripts/ambitions-visual-100-false-green-check.py \
  scripts/ambitions-visual-100-gate-check.py \
  scripts/ambitions-visual-100-proof-dashboard.py

python3 scripts/ambitions-surface-recipe-inventory-check.py
python3 scripts/ambitions-surface-recipe-coverage-check.py
python3 scripts/ambitions-surface-recipe-specificity-check.py
python3 scripts/ambitions-train-family-frontend-extraction-check.py

python3 scripts/ambitions-visual-100-priority-registry-check.py
python3 scripts/ambitions-visual-100-recipe-contract-check.py
python3 scripts/ambitions-visual-100-object-depth-check.py
python3 scripts/ambitions-visual-100-source-debt-check.py
python3 scripts/ambitions-visual-100-vocabulary-full-corpus-check.py
python3 scripts/ambitions-visual-100-anti-generic-check.py
python3 scripts/ambitions-visual-100-accessibility-adhd-check.py
python3 scripts/ambitions-visual-100-proof-source-receipt-check.py
python3 scripts/ambitions-visual-100-transaction-check.py
python3 scripts/ambitions-visual-100-primitive-operationality-check.py
python3 scripts/ambitions-visual-100-false-green-check.py
python3 scripts/ambitions-visual-100-gate-check.py
python3 scripts/ambitions-visual-100-proof-dashboard.py
```

If Makefile targets are added:

```bash
make visual-100-all
```

Also run targeted scans:

```bash
grep -R "Plan" docs/canon/frontend -n || true
grep -R "best next move\|next best move\|Start Focus\|Begin Focus" docs/canon/frontend -n || true
grep -R "chatbot\|AI assistant\|assistant panel" docs/canon/frontend -n || true
grep -R "streak\|score\|ring\|leaderboard" docs/canon/frontend -n || true
grep -R "bet\|wager\|odds\|lock it in" docs/canon/frontend -n || true
```

If a command cannot run, document:

- exact command
- exact failure
- whether it is caused by this batch
- whether it blocks Green

Do not hide failed validation.

---

# Hard Red Stop Conditions

Stop Red if:

- active IA cannot be determined
- `docs/canon/frontend/**` is missing
- source inventory cannot be parsed safely
- P0 registry cannot be represented
- object anatomy docs cannot be deepened without generic filler
- validators cannot be run
- new validators rely on unavailable dependencies
- source-linkage truth cannot be represented without false claims
- hidden `intended_only` debt remains in dashboard
- prior Green is retained as 100/100 without new proof
- Plan is reintroduced as active top-level destination
- chatbot/generic AI assistant framing cannot be removed or classified as forbidden
- external/cloud LLMs enter core architecture
- production UI changes become necessary
- hosted CI activation becomes necessary
- final report would need to claim implementation/release/accessibility proof without actual proof
- unrelated dirty files cannot be isolated
- generated changes create broad unrelated churn

If Red, produce final report with blockers and smallest safe repair path.

---

# Rollback Expectations

Every changed file must be listed.

Every new artifact must have a rollback classification:

- safe to delete
- paired with validator
- generated report only
- supersedes prior doc
- updates dashboard contract
- updates Makefile target
- source truth / should not delete without replacement

Prefer additive hardening over destructive replacement.

Do not delete old docs unless:

- replacement is complete
- index updates are included
- rollback path is documented
- final report names the supersession

---

# Commit Expectations

If all blocking gates pass and runner policy permits committing:

- stage exact scoped files only
- do not stage unrelated files
- do not stage `.codex/runs/**`
- use commit message:

```text
Harden visual encyclopedia 100 proof gates v3
```

If Yellow or Red, do not claim Green.

Commit Yellow only if runner policy allows accepted Yellow with explicit remaining gaps.

---

# Final Response Required From Codex

Return:

```text
STATUS: GREEN|YELLOW|RED
Batch: VISUAL-ENCYCLOPEDIA-100-PROOF-HARDENING-03
Bounded patch model: GPT-5.4-mini

Canon Content Status:
Control-Plane Status:
Source-Linkage Status:
Implementation Proof Status:
Release / Accessibility / Device Proof Status:

Summary:
Files changed:
Validators added:
Validators upgraded:
Docs deepened:
P0 recipes upgraded:
P0 recipes still failing:
Remaining red/yellow flags:
Validation run:
Reports:
UI implementation changed:
Hosted CI activated:
Release/accessibility/App Store claims:
Rollback notes:
Commit:
```

Keep the final answer proof-based.

Do not market the result.

Do not say 100/100 unless the new gate actually proves it.

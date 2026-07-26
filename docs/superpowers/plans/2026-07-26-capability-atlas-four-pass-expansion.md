# Capability Atlas Four-Pass Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a complete, non-normative Capability Atlas v2 that covers all 14 product domains through foundation, integration, moat, and trust/proof passes while preserving the approved nine capabilities as inputs rather than the final hierarchy.

**Architecture:** Add a versioned capability architecture beside the current Phase A–G artifacts. A machine-readable registry will define the product hierarchy, domain portfolios, top-level capabilities, subcapabilities, strategic classes, life-context applicability, pass provenance, authority posture, and verification ceilings. Human-readable projections and a deterministic Python validator will make the result reviewable and drift-resistant without changing canon authority.

**Tech Stack:** Python 3.12 standard library, JSON, Markdown, existing GitHub Actions Code Quality workflow.

## Global Constraints

- Ambitions remains a native, local-first Personal Life OS; no chatbot, LLM, hosted model, account, or network dependency may be introduced.
- Intelligence is expressed through typed proposals, paths, simulations, warnings, reflow, recovery, prioritization, and state change—not conversation.
- Structured reasoning is canonical; concise and expanded plain-language explanations are projections of the same reasoning record.
- Bounded contextual proactivity is permitted only through declared local triggers in the owning surface or object context.
- Tiered authority governs action: automatic read-only insight; standing permission only for reversible low-risk organization; fresh confirmation for material changes.
- The current nine capability identities remain approved as valid initial capabilities, not as the final complete atlas.
- No file in this program modifies `docs/canon/MANIFEST.toml` or claims implementation, verification, shipping, or marketing completion.
- Every domain must include first-class basics, integrated behavior, adaptive/moat potential, trust, resilience, accessibility, and Apple-native expression where applicable.

---

### Task 1: Capability Architecture v2 Contract

**Files:**
- Create: `docs/capabilities/v2/CAPABILITY_ARCHITECTURE.md`
- Create: `docs/capabilities/v2/capability-architecture.json`

**Interfaces:**
- Produces: stable hierarchy levels, strategic classes, authority tiers, explanation contract, life-context taxonomy, pass IDs, and capability record schema used by every later task.

- [ ] **Step 1: Define hierarchy and schemas**

Record Level 0 Product, Level 1 flagship moat system, Level 2 major moat mechanisms, Level 3 domain portfolios, Level 4 top-level capabilities, Level 5 subcapabilities, and Level 6 behaviors/requirements.

- [ ] **Step 2: Define controlled enums**

Declare strategic classes, authority tiers, maturity states, implementation states, verification states, life-context IDs, and pass IDs.

- [ ] **Step 3: Define reasoning and explanation law**

Require canonical structured factors, assumptions, constraints, alternatives, consequences, uncertainty, authority, recovery, and concise/expanded deterministic prose projections.

- [ ] **Step 4: Validate JSON syntax**

Run: `python3 -m json.tool docs/capabilities/v2/capability-architecture.json >/dev/null`

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add docs/capabilities/v2/CAPABILITY_ARCHITECTURE.md docs/capabilities/v2/capability-architecture.json
git commit -m "docs: define Capability Atlas v2 architecture"
```

### Task 2: Pass 1 — Foundation Capability Portfolios

**Files:**
- Create: `docs/capabilities/v2/pass-1-foundation.json`
- Create: `docs/capabilities/v2/PASS_1_FOUNDATION.md`

**Interfaces:**
- Consumes: architecture enums and schema from Task 1.
- Produces: first-class basic capability records for all 14 domains, including complete object lifecycle, thin-use value, offline behavior, and non-goals.

- [ ] **Step 1: Define domain promises**

Create one durable human-outcome promise for each taxonomy domain.

- [ ] **Step 2: Define foundation capabilities**

Create bounded top-level capability records covering ordinary reliability and lifecycle completeness. Each record includes capability ID, outcome, owning domain, classes, subcapabilities, objects, systems, outputs, authority tier, sources, and proof ceiling.

- [ ] **Step 3: Verify domain coverage**

Assert exactly 14 domain portfolios and at least three foundation capabilities per domain.

- [ ] **Step 4: Validate JSON syntax**

Run: `python3 -m json.tool docs/capabilities/v2/pass-1-foundation.json >/dev/null`

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add docs/capabilities/v2/pass-1-foundation.json docs/capabilities/v2/PASS_1_FOUNDATION.md
git commit -m "docs: build foundation capability portfolios"
```

### Task 3: Pass 2 — Integrated Cross-Domain Capabilities

**Files:**
- Create: `docs/capabilities/v2/pass-2-integration.json`
- Create: `docs/capabilities/v2/PASS_2_INTEGRATION.md`

**Interfaces:**
- Consumes: foundation capability IDs and canonical object ownership.
- Produces: cross-domain capabilities and journeys with one primary owner, explicit dependencies, handoff contracts, and no duplicate mutable truth.

- [ ] **Step 1: Map integration seams**

Cover Capture→placement, context→path, path→time, time→Today, Proof→learning, Search→command, simulation→adoption, files→path, sharing→redaction, trust→inspection, recovery→replay, and Apple surfaces→canonical commands.

- [ ] **Step 2: Define integrated capabilities**

Create records that name primary domain, secondary domains, input/output object identities, handoff owner, and material confirmation boundary.

- [ ] **Step 3: Reject isolated mini-app behavior**

Add non-goals forbidding duplicated Goals, Steps, placements, knowledge, privacy authority, or independent recommendation feeds.

- [ ] **Step 4: Validate JSON syntax**

Run: `python3 -m json.tool docs/capabilities/v2/pass-2-integration.json >/dev/null`

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add docs/capabilities/v2/pass-2-integration.json docs/capabilities/v2/PASS_2_INTEGRATION.md
git commit -m "docs: define integrated capability seams"
```

### Task 4: Pass 3 — Adaptive, Moat, and Novel Capabilities

**Files:**
- Create: `docs/capabilities/v2/pass-3-moat.json`
- Create: `docs/capabilities/v2/PASS_3_MOAT.md`
- Create: `docs/capabilities/v2/novel-hypotheses.json`

**Interfaces:**
- Consumes: foundation and integration capability IDs.
- Produces: Adaptive Life Orchestration hierarchy, six major moat mechanisms, longitudinal adaptive capabilities, and separately gated novel hypotheses.

- [ ] **Step 1: Define Adaptive Life Orchestration**

Specify the flagship loop from context through proposal, explanation, decision, action, outcome, Proof, correction, and future calibration.

- [ ] **Step 2: Rehome the approved nine**

Map each existing capability to top-level, subcapability, horizontal guarantee, or expression capability without discarding its approved identity or provenance.

- [ ] **Step 3: Define adaptive and moat capabilities**

Require inspectable local evidence, bounded triggers, typed outputs, calibration signals, uncertainty, correction, suppression, forgetting, and no hosted intelligence dependency.

- [ ] **Step 4: Define novel hypotheses separately**

For each hypothesis include problem, mechanism, person-facing value, required inputs, safety boundary, validation evidence, promotion criteria, and rejection criteria.

- [ ] **Step 5: Validate JSON syntax**

Run:

```bash
python3 -m json.tool docs/capabilities/v2/pass-3-moat.json >/dev/null
python3 -m json.tool docs/capabilities/v2/novel-hypotheses.json >/dev/null
```

Expected: exit 0 for both.

- [ ] **Step 6: Commit**

```bash
git add docs/capabilities/v2/pass-3-moat.json docs/capabilities/v2/PASS_3_MOAT.md docs/capabilities/v2/novel-hypotheses.json
git commit -m "docs: define adaptive moat capability system"
```

### Task 5: Pass 4 — Trust, Proof, Resilience, Accessibility, and Native Reach

**Files:**
- Create: `docs/capabilities/v2/pass-4-trust-proof.json`
- Create: `docs/capabilities/v2/PASS_4_TRUST_PROOF.md`

**Interfaces:**
- Consumes: all capability records from Tasks 2–4.
- Produces: cross-cutting trust profile for every top-level capability and dedicated trust/resilience/native capabilities where the outcome is independently person-facing.

- [ ] **Step 1: Define trust profile**

For every capability record authority tier, automatic behavior, required confirmation, standing-permission eligibility, inspection data, correction, suppression, deletion, Undo/recovery, irreversible boundaries, and sensitive-domain constraints.

- [ ] **Step 2: Define proof profile**

Separate user Proof, mutation Receipt/History, and engineering proof. Assign explicit proof ceilings.

- [ ] **Step 3: Define resilience and accessibility**

Cover offline, stale, missing, contradictory, interrupted, partial-success, replay, restore, migration, nonvisual semantic equivalence, reduced motion, and large-content stress.

- [ ] **Step 4: Define Apple-native reach**

Classify App Intents, Shortcuts, Spotlight, widgets, notifications, EventKit, share intake, deep links, and background work as top-level, subcapability, or implementation support according to durable user outcome.

- [ ] **Step 5: Validate JSON syntax**

Run: `python3 -m json.tool docs/capabilities/v2/pass-4-trust-proof.json >/dev/null`

Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
git add docs/capabilities/v2/pass-4-trust-proof.json docs/capabilities/v2/PASS_4_TRUST_PROOF.md
git commit -m "docs: complete capability trust and proof pass"
```

### Task 6: Reconciled Atlas and Deterministic Validator

**Files:**
- Create: `docs/capabilities/v2/capability-atlas-v2.json`
- Create: `docs/capabilities/v2/CAPABILITY_ATLAS_V2.md`
- Create: `docs/capabilities/v2/capability-hierarchy-decisions.json`
- Create: `tools/capability_atlas/expanded_review.py`
- Create: `docs/capabilities/v2/expanded-review-validation.json`
- Test: `tools/tests/test_capability_atlas_expanded_review.py`

**Interfaces:**
- Consumes: all four pass registries.
- Produces: one deduplicated baseline-plus-flagship atlas and `build`/`check` validator commands.

- [ ] **Step 1: Reconcile hierarchy**

Merge duplicates, preserve aliases, choose one primary owner, distinguish top-level capabilities from subcapabilities and enabling systems, and record every merge/split/retain decision.

- [ ] **Step 2: Build validator tests first**

Test exact 14-domain coverage, unique IDs, valid parent references, approved-nine disposition coverage, controlled enums, source-path existence, required reasoning/explanation fields, pass provenance, trust profile completeness, and generated-output drift.

- [ ] **Step 3: Run tests and confirm initial failure**

Run: `python3 -m unittest tools.tests.test_capability_atlas_expanded_review -v`

Expected: FAIL before validator implementation.

- [ ] **Step 4: Implement validator**

Expose:

```bash
python3 tools/capability_atlas/expanded_review.py build
python3 tools/capability_atlas/expanded_review.py check
```

- [ ] **Step 5: Build generated validation**

Run: `python3 tools/capability_atlas/expanded_review.py build`

Expected: summary with zero errors.

- [ ] **Step 6: Run focused tests and drift check**

Run:

```bash
python3 -m unittest tools.tests.test_capability_atlas_expanded_review -v
python3 tools/capability_atlas/expanded_review.py check
```

Expected: all tests pass; check exits 0.

- [ ] **Step 7: Commit**

```bash
git add docs/capabilities/v2 tools/capability_atlas/expanded_review.py tools/tests/test_capability_atlas_expanded_review.py
git commit -m "feat: validate expanded Capability Atlas v2"
```

### Task 7: CI and Review Package

**Files:**
- Modify: `.github/workflows/code-quality.yml`
- Create: `docs/capabilities/v2/OWNER_REVIEW_PACKET.md`

**Interfaces:**
- Consumes: validator commands and final atlas.
- Produces: permanent CI enforcement and a bounded owner review that presents the entire hierarchy before canon installation.

- [ ] **Step 1: Add v2 validation to Code Quality**

Run the focused tests and `expanded_review.py check` after the existing Capability Atlas checks; upload all `docs/capabilities/v2/**` outputs.

- [ ] **Step 2: Draft owner review packet**

Present flagship moat, major mechanisms, 14 domain portfolios, top-level capability count, approved-nine dispositions, novel hypotheses, hierarchy decisions, and remaining owner choices. Do not request approval of implementation state.

- [ ] **Step 3: Run repository validation**

Run:

```bash
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_capability_atlas_*.py'
python3 tools/capability_atlas/expanded_review.py check
git diff --check
```

Expected: all commands exit 0.

- [ ] **Step 4: Commit and open draft PR**

```bash
git add .github/workflows/code-quality.yml docs/capabilities/v2
git commit -m "ci: enforce Capability Atlas v2 review integrity"
```

Open a draft PR based on `codex/capability-atlas-reconciliation`. Keep canon installation blocked pending owner review.

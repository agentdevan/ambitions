# Ambitions Capability Atlas Program Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a compiler-backed Capability Atlas that defines every durable user-facing promise Ambitions intends to fulfill, independent of current implementation state, and traces each promise through canon, architecture, surfaces, tests, evidence, and release readiness.

**Architecture:** Introduce a product-capability layer between the Constitution and detailed specifications. Discovery begins read-only and evidence-preserving; owner-originated seeds and repository-derived candidates remain non-normative until reconciliation and owner review. After approval, a machine-readable registry becomes normative input to the existing Python 3.12 standard-library canon compiler, which deterministically generates human-readable indexes, traceability maps, surface matrices, and gap reports.

**Tech Stack:** Markdown, JSON, JSON Schema, Python 3.12 standard library, TOML manifest, existing `scripts/ambitions-canon.py` and `tools/ambitions_canon` compiler/test infrastructure.

## Global Constraints

- The live `agentdevan/ambitions` repository is the source of truth.
- Intended capability is independent of implementation status.
- A capability is a durable user-facing product promise, not a surface, object, subsystem, visual style, implementation mechanism, or project task.
- Discovery must preserve provenance and uncertainty; it must not silently canonize, merge, rename, retire, or discard candidates.
- Existing Constitution, specifications, requirement IDs, visual closure authority, ADRs, and source-traceability rules remain authoritative until an explicit owner-approved capability cutover.
- Local-first privacy law applies to all capability modeling and generated artifacts.
- Generated outputs must be deterministic and rejected on drift by `python3 scripts/ambitions-canon.py check`.
- No capability may become implementation-ready solely because code exists.
- No capability may be retired without an explicit owner decision and supersession record.

---

## File Structure

### Program and discovery artifacts

- Create `docs/capabilities/README.md` — program status, reading order, authority boundaries, and cadence.
- Create `docs/capabilities/CAPABILITY_MODEL.md` — Phase 0 definitions, classification law, maturity model, evidence rules, and anti-patterns.
- Create `docs/capabilities/seed-capabilities.json` — owner-originated seeds preserved verbatim with provenance.
- Create `docs/capabilities/discovery-source-register.json` — source families, inclusion rules, coverage state, and harvest metadata.
- Create `docs/capabilities/candidate-capabilities.json` — append-only discovery inventory before reconciliation.
- Create `docs/capabilities/CANDIDATE_CAPABILITY_INVENTORY.md` — generated/readable candidate projection.
- Create `docs/capabilities/reconciliation-register.json` — duplicate groups, proposed canonical names, conflicts, and owner decisions.
- Create `docs/capabilities/OWNER_DECISION_PACKET.md` — bounded owner decisions only.

### Canonical source artifacts after owner approval

- Create `docs/canon/product/CAPABILITY_ATLAS.md` — human-readable canonical capability atlas.
- Create `docs/canon/product/capability-atlas.json` — normative machine-readable registry.
- Create `docs/canon/schemas/capability.schema.json` — schema for canonical capability entries.
- Create `docs/canon/product/CAPABILITY_DECISIONS.md` — accepted, rejected, merged, renamed, deferred, and retired decisions.

### Generated artifacts

- Create `docs/canon/generated/CAPABILITY_INDEX.md`.
- Create `docs/canon/generated/capability-index.json`.
- Create `docs/canon/generated/capability-requirement-map.json`.
- Create `docs/canon/generated/capability-surface-matrix.md`.
- Create `docs/canon/generated/capability-test-matrix.md`.
- Create `docs/canon/generated/capability-gap-report.md`.
- Create `docs/canon/generated/product-genome.json`.

### Compiler and validation

- Modify `docs/canon/MANIFEST.toml` — register normative, reference, and generated capability artifacts only at the appropriate cutover task.
- Modify `docs/canon/README.md` — add capability-layer reading order and authority boundaries.
- Modify `tools/ambitions_canon/compiler.py` and focused supporting modules as required.
- Modify/add tests under the existing canon compiler test location discovered during execution.

---

### Task 1: Install the Non-Normative Capability Program Foundation

**Files:**
- Create: `docs/capabilities/README.md`
- Create: `docs/capabilities/CAPABILITY_MODEL.md`
- Create: `docs/capabilities/seed-capabilities.json`
- Create: `docs/capabilities/discovery-source-register.json`

**Interfaces:**
- Consumes: Existing Constitution, canon README, MANIFEST, and owner-provided seed list.
- Produces: Stable definitions and discovery contracts consumed by Tasks 2–8.

- [x] **Step 1: Define capability identity and exclusion law**

Specify the primary test: a capability must describe a durable user-facing promise that remains meaningful if the UI, algorithm, storage, or architecture changes.

- [x] **Step 2: Define separate lifecycle dimensions**

Model `authority_status`, `specification_maturity`, `implementation_status`, and `verification_status` independently so implementation cannot imply canonization.

- [x] **Step 3: Preserve the eight owner seeds verbatim**

Record skill transference, contextual generative goal pathing, alternate career-path simulation, step reflow, native search, Appearance Studio, Content Share Studio, and goal-attached file storage as `owner_seed` candidates with `authority_status: proposed`.

- [x] **Step 4: Define source coverage families**

Include Constitution, normative specifications, journeys, objects, systems, visual closure, UX blueprint, ADRs, research packages, audits, remediation dossiers, Linear mirrors, tests, production code comments, and historical superseded material.

- [x] **Step 5: Validate JSON syntax**

Run:

```bash
python3 -m json.tool docs/capabilities/seed-capabilities.json >/dev/null
python3 -m json.tool docs/capabilities/discovery-source-register.json >/dev/null
```

Expected: both commands exit `0`.

- [x] **Step 6: Commit**

```bash
git add docs/capabilities
git commit -m "docs: establish capability atlas discovery law"
```

### Task 2: Build Deterministic Repository Discovery

**Files:**
- Create: `tools/capability_atlas/discover.py`
- Create: `tools/capability_atlas/model.py`
- Create: `tools/capability_atlas/source_policy.py`
- Create: `scripts/ambitions-capabilities.py`
- Test: existing Python test tree plus focused capability-discovery tests

**Interfaces:**
- Consumes: `discovery-source-register.json`, repository files, seed registry.
- Produces: normalized source excerpts and candidate records with stable evidence fingerprints.

- [x] **Step 1: Write failing tests for stable discovery order, provenance, and exclusions**
- [x] **Step 2: Implement source enumeration without external dependencies**
- [x] **Step 3: Implement candidate extraction hints without declaring authority**
- [x] **Step 4: Emit deterministic JSON with sorted keys and stable IDs**
- [x] **Step 5: Run focused tests and JSON validation**
- [x] **Step 6: Commit**

### Task 3: Execute Phase A Repository Archaeology

**Files:**
- Create: `docs/capabilities/candidate-capabilities.json`
- Create: `docs/capabilities/CANDIDATE_CAPABILITY_INVENTORY.md`
- Update: `docs/capabilities/discovery-source-register.json`

**Interfaces:**
- Consumes: Task 2 discovery tooling.
- Produces: Evidence-preserving master candidate inventory.

- [x] **Step 1: Harvest all configured source families**
- [x] **Step 2: Record source path, line/range, authority class, exact terminology, and extraction rationale**
- [x] **Step 3: Mark historical or superseded evidence without deleting it**
- [x] **Step 4: Generate the readable candidate inventory**
- [x] **Step 5: Confirm every configured source family has explicit coverage or a documented blocker**
- [x] **Step 6: Commit**

### Task 4: Execute Phase B Capability Extraction

**Files:**
- Update: `docs/capabilities/candidate-capabilities.json`
- Create: `docs/capabilities/exclusion-register.json`

**Interfaces:**
- Consumes: Raw candidates from Task 3 and capability law from Task 1.
- Produces: Qualified capability candidates plus auditable exclusions.

- [x] **Step 1: Classify candidates as capability, behavior, requirement, object, surface, system, implementation, design language, project, or evidence**
- [x] **Step 2: Preserve excluded records with reasons and backlinks**
- [x] **Step 3: Flag ambiguous records instead of forcing classification**
- [x] **Step 4: Verify all owner seeds remain present**
- [x] **Step 5: Commit**

### Task 5: Execute Phase C Taxonomy

**Files:**
- Create: `docs/capabilities/CAPABILITY_TAXONOMY.md`
- Create: `docs/capabilities/capability-taxonomy.json`
- Update: `docs/capabilities/candidate-capabilities.json`

**Interfaces:**
- Consumes: Qualified candidates.
- Produces: Stable product ontology and category assignments.

- [ ] **Step 1: Derive categories from product meaning rather than current IA**
- [ ] **Step 2: Define category purpose, boundaries, and anti-overlap rules**
- [ ] **Step 3: Permit one primary category and bounded secondary relationships**
- [ ] **Step 4: Generate uncategorized and over-broad candidate reports**
- [ ] **Step 5: Commit**

### Task 6: Execute Phase D Deduplication and Canonicalization Proposals

**Files:**
- Create: `docs/capabilities/reconciliation-register.json`
- Create: `docs/capabilities/CAPABILITY_RECONCILIATION.md`

**Interfaces:**
- Consumes: Classified candidates and taxonomy.
- Produces: Proposed canonical identities without applying owner decisions.

- [ ] **Step 1: Group synonyms, aliases, fragments, and overlapping promises**
- [ ] **Step 2: Separate true duplicates from composed or dependent capabilities**
- [ ] **Step 3: Propose canonical names and stable `CAP-*` identifiers**
- [ ] **Step 4: Record conflicts, losses of meaning, and uncertain merges**
- [ ] **Step 5: Commit**

### Task 7: Execute Phase E Product Promise Writing

**Files:**
- Create: `docs/capabilities/DRAFT_CAPABILITY_ATLAS.md`
- Update: `docs/capabilities/reconciliation-register.json`

**Interfaces:**
- Consumes: Proposed canonical capability identities.
- Produces: Draft product promises for owner review.

- [ ] **Step 1: Write product promise, user outcome, rationale, example experience, and non-goals for every proposed capability**
- [ ] **Step 2: Identify required context, privacy class, owning domain, and supporting systems**
- [ ] **Step 3: Avoid implementation-prescriptive language unless the mechanism is itself product law**
- [ ] **Step 4: Run consistency and duplicate-language checks**
- [ ] **Step 5: Commit**

### Task 8: Execute Phase F Traceability

**Files:**
- Create: `docs/capabilities/draft-capability-traceability.json`
- Create: `docs/capabilities/DRAFT_CAPABILITY_TRACEABILITY.md`

**Interfaces:**
- Consumes: Draft atlas, canon index, requirement graph, architecture evidence, UI/UX references, tests, and proof.
- Produces: Capability-to-product-genome traceability.

- [ ] **Step 1: Link capabilities to normative requirements**
- [ ] **Step 2: Link capabilities to objects, systems, runtime owners, surfaces, journeys, and Apple integrations**
- [ ] **Step 3: Link capabilities to tests and proof without letting tests create authority**
- [ ] **Step 4: Record missing and conflicting links explicitly**
- [ ] **Step 5: Commit**

### Task 9: Execute Phase G Gap and Loss Analysis

**Files:**
- Create: `docs/capabilities/DRAFT_CAPABILITY_GAP_REPORT.md`
- Create: `docs/capabilities/capability-gap-report.json`

**Interfaces:**
- Consumes: Draft capability traceability.
- Produces: Gap, loss, conflict, and invisibility findings.

- [ ] **Step 1: Detect capabilities without specification, owner, architecture, runtime, surface, test, or proof**
- [ ] **Step 2: Detect requirements, systems, UI, and implementation without a capability link**
- [ ] **Step 3: Detect historical product promises lost during cleanup**
- [ ] **Step 4: Detect impossible, contradictory, over-broad, or implementation-bound capabilities**
- [ ] **Step 5: Commit**

### Task 10: Build the Owner Decision Packet

**Files:**
- Create: `docs/capabilities/OWNER_DECISION_PACKET.md`
- Update: `docs/capabilities/reconciliation-register.json`

**Interfaces:**
- Consumes: Draft atlas, reconciliation, traceability, and gap findings.
- Produces: Bounded decisions for explicit owner action.

- [ ] **Step 1: Include only decisions that cannot be resolved deterministically**
- [ ] **Step 2: State options, recommendation, consequences, and affected sources**
- [ ] **Step 3: Separate accept/reject/merge/rename/defer/retire choices**
- [ ] **Step 4: Preserve owner decisions with date and provenance**
- [ ] **Step 5: Commit**

### Task 11: Install the Approved Canonical Capability Atlas

**Files:**
- Create: `docs/canon/product/CAPABILITY_ATLAS.md`
- Create: `docs/canon/product/capability-atlas.json`
- Create: `docs/canon/schemas/capability.schema.json`
- Create: `docs/canon/product/CAPABILITY_DECISIONS.md`
- Modify: `docs/canon/MANIFEST.toml`
- Modify: `docs/canon/README.md`

**Interfaces:**
- Consumes: Explicit owner-approved decisions.
- Produces: Normative capability source layer.

- [ ] **Step 1: Apply only approved decisions**
- [ ] **Step 2: Validate stable IDs, names, required fields, and source links**
- [ ] **Step 3: Register normative and reference files in MANIFEST**
- [ ] **Step 4: Update reading order and authority boundary**
- [ ] **Step 5: Commit**

### Task 12: Extend the Canon Compiler and Product Genome

**Files:**
- Modify: `tools/ambitions_canon/compiler.py`
- Add/modify: focused supporting compiler modules
- Add/modify: canon compiler tests
- Generate: all capability projections listed above

**Interfaces:**
- Consumes: Normative capability registry and existing canon graph.
- Produces: Deterministic Product Genome and gap enforcement.

- [ ] **Step 1: Write failing parser/schema/graph/output tests**
- [ ] **Step 2: Parse and validate the canonical capability registry**
- [ ] **Step 3: Generate index, requirement map, surface matrix, test matrix, gap report, and Product Genome**
- [ ] **Step 4: Enforce orphan, missing-owner, missing-source, duplicate-ID, retirement, and generated-drift rules**
- [ ] **Step 5: Run full canon build/check/test suite**
- [ ] **Step 6: Commit**

### Task 13: Validate and Close Out

**Files:**
- Create: `docs/qa/evidence/<date>-capability-atlas-closeout/`
- Update: program README and decision records

**Interfaces:**
- Consumes: Completed canonical and compiler work.
- Produces: Verifiable closeout evidence.

- [ ] **Step 1: Run JSON/schema and canon checks**
- [ ] **Step 2: Run focused and full Python tests**
- [ ] **Step 3: Verify all generated files are deterministic and clean**
- [ ] **Step 4: Audit every approved capability for source and owner traceability**
- [ ] **Step 5: Verify no candidate was silently removed and all retirement decisions are explicit**
- [ ] **Step 6: Commit closeout evidence**

---

## Gate cadence

1. **Foundation gate:** Definitions, authority boundary, owner seeds, and discovery contract.
2. **Discovery gate:** Complete candidate inventory and source coverage.
3. **Extraction gate:** Capability/non-capability classification with exclusions preserved.
4. **Taxonomy gate:** Product ontology and candidate placement.
5. **Reconciliation gate:** Canonical-name and merge proposals.
6. **Draft-atlas gate:** Product promises and non-goals.
7. **Traceability/gap gate:** Product Genome and loss analysis.
8. **Owner-decision gate:** Explicit decisions only.
9. **Canon cutover gate:** Normative installation and compiler enforcement.
10. **Closeout gate:** Determinism, traceability, and governance proof.

Each gate must be reviewable independently. No gate may claim later-gate maturity or implementation completion.

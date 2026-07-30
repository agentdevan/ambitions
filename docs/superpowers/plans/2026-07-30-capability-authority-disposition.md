# Capability Authority Disposition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Disposition all 112 transient Capability Atlas v2 labels against the current Ambitions Constitution and manifest-controlled canon without creating new product authority.

**Architecture:** Treat the 112-item draft only as an audit population. Resolve each label through Constitution → owning normative specifications/standards → generated canon traceability, assign one primary disposition, and generate owner-focused reports. Source/tests are reported separately and never establish product authority.

**Tech Stack:** Current Ambitions canon, generated requirement traceability, JSON, Markdown, Python 3.12 standard library.

## Global Constraints

- `docs/canon/CONSTITUTION.md` remains supreme stable product and engineering law.
- `docs/canon/MANIFEST.toml` defines active normative specifications and standards.
- This program is read-only with respect to Constitution, manifest, normative specifications, source, and tests.
- The 112-item draft is non-normative and must not be preserved as a target count.
- Every candidate receives exactly one primary disposition.
- Product authority, specification maturity, implementation state, and verification state remain separate.
- No capability is marked implemented, verified, shippable, or marketable by this audit.
- No prior Capability Atlas branch or transient artifact becomes authority.

---

### Task 1: Authority and Disposition Contract

**Files:**
- Create: `docs/capabilities/authority-disposition/DISPOSITION_POLICY.md`
- Create: `docs/capabilities/authority-disposition/disposition-policy.json`

- [ ] Define the authority reading order and primary disposition enum.
- [ ] Define required per-candidate fields and confidence rules.
- [ ] Define constitutional-amendment and specification-gap thresholds.
- [ ] Validate JSON.

### Task 2: Current-Canon Evidence Map

**Files:**
- Create: `docs/capabilities/authority-disposition/current-authority-map.json`

- [ ] Resolve the current canon revision and digest.
- [ ] Record the 14 candidate domains and current normative owners.
- [ ] Record exact supporting requirement IDs and source paths.
- [ ] Record future-gated, planned-only, and inactive authority where applicable.

### Task 3: Comprehensive 112-Item Disposition

**Files:**
- Create: `docs/capabilities/authority-disposition/capability-dispositions.json`
- Create: `docs/capabilities/authority-disposition/CAPABILITY_DISPOSITION_MATRIX.md`

- [ ] Reconstruct the exact 112-item audit population.
- [ ] Assign one primary disposition to every item.
- [ ] Record current constitutional and normative ownership.
- [ ] Record hierarchy correction, overlap/alias, and recommended action.
- [ ] Preserve the nine previously approved capability identities and state their authority gap precisely.
- [ ] Validate unique IDs, population completeness, and allowed dispositions.

### Task 4: Authority Findings and Remediation

**Files:**
- Create: `docs/capabilities/authority-disposition/AUTHORITY_COVERAGE_REPORT.md`
- Create: `docs/capabilities/authority-disposition/CONSTITUTIONAL_ALIGNMENT_REPORT.md`
- Create: `docs/capabilities/authority-disposition/SPECIFICATION_REMEDIATION_PLAN.md`

- [ ] Summarize disposition counts and domain patterns.
- [ ] Identify genuine constitutional questions only.
- [ ] Identify genuine specification gaps, exact proposed owners, dependencies, tests, and proof.
- [ ] Separate research-only hypotheses and rejections.

### Task 5: Derived Capability Projection and Owner Packet

**Files:**
- Create: `docs/capabilities/authority-disposition/derived-capability-projection.json`
- Create: `docs/capabilities/authority-disposition/DERIVED_CAPABILITY_PROJECTION.md`
- Create: `docs/capabilities/authority-disposition/OWNER_DECISION_PACKET.md`

- [ ] Generate a smaller derived projection from current authority and supported proposals.
- [ ] Do not force a count or install the projection into canon.
- [ ] Present only consequential owner decisions.

### Task 6: Deterministic Validation

**Files:**
- Create: `tools/capability_atlas/authority_disposition.py`
- Create: `tools/tests/test_capability_authority_disposition.py`
- Create: `docs/capabilities/authority-disposition/validation.json`

- [ ] Test exact 112-item coverage and unique IDs.
- [ ] Test one valid primary disposition per item.
- [ ] Test requirement/source references against current canon.
- [ ] Test approved-nine presence and authority-status separation.
- [ ] Test generated Markdown/summary drift.
- [ ] Run focused tests and validator check.

### Task 7: Review and Handoff

- [ ] Run `python3 scripts/ambitions-canon.py check`.
- [ ] Run Capability Atlas authority-disposition tests.
- [ ] Run `git diff --check`.
- [ ] Open one draft PR against `main`.
- [ ] Keep canon installation and all normative edits blocked pending owner review.

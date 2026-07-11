# Ambitions Canon Train 3B — Objects, Journeys, Systems, and Standards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete canonical object, journey, runtime/platform system, and cross-cutting standard specifications with deterministic completeness coverage.

**Architecture:** Continue `codex/canon-03-atlas` after Train 3A. Each domain file owns one concept set, all profile cells are explicit, and current source/proof state remains outside normative law.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors where explicitly scoped.

## Global Constraints

- Implement the approved design at `docs/superpowers/specs/2026-07-11-ambitions-canon-specification-system-design.md`.
- Primary migration corpus: Linear document `96b93346-271d-46fc-beab-43ff7e286b5d`, title `B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical`.
- The current `docs/truth/**`, `docs/constitution/**`, `AGENTS.md`, and `scripts/ambitions-constitution-audit.py` remain active authority until the cutover task completes.
- Do not delete, demote, or rewrite active authority during shadow migration except for the explicit authority-freeze guard and non-normative routing notes named by this plan.
- Do not change production Swift, persistence schemas, runtime behavior, UI, copy, entitlements, privacy manifests, account behavior, R2 behavior, or release state in this program.
- The compiler and CI must run offline with no model, network, Linear, Figma, or cloud dependency.
- Use Python 3.12. The CLI must exit `2` with `PYTHON_VERSION_UNSUPPORTED` on Python below 3.11; CI uses Python 3.12.
- Use only the Python standard library unless a later owner-approved amendment changes this constraint.
- Normative source is Markdown with TOML front matter. JSON/TOML files may own schemas, manifests, mappings, ledgers, and generated projections but not free-standing product doctrine.
- Generated output is deterministic: sorted keys and records, UTF-8, newline-terminated files, explicit schema/compiler versions, no volatile timestamps, no network/model calls, and atomic replacement.
- `docs/canon/` is shadow and non-authoritative until `MANIFEST.toml` changes from `authority_state = "shadow"` to `authority_state = "active"` in the cutover task.
- Every normative requirement has one stable ID; IDs are never reused.
- Every normalized concept has exactly one owner.
- P0 or hard-red requirements use `MUST` or `MUST NOT`.
- Current implementation and proof state must be generated from source/evidence and must not be embedded as permanent product law.
- Linear owns execution and evidence links, not canon. Figma owns visual authority and evidence, not product IA, runtime, privacy, source ownership, or release status.
- Material semantic conflicts require owner decision. Codex recommends a winner or stronger composition; it never silently decides.
- Parallelize read-only inventory, extraction, gap detection, and red-team review. Serialize concept ownership, normative writing, cutover, and deletion.
- No implementation task runs in parallel with another implementation task. Each task receives an independent spec-and-quality review before the next task begins.
- Use test-driven development for compiler behavior: write a failing test, verify the expected failure, implement the minimum, rerun focused and regression tests, then commit.
- Use one reviewable commit per numbered task that changes tracked files. Run `git diff --check` before every commit.
- Do not claim implementation, Runtime, Interaction, Visual, Accessibility, Privacy, Device, TestFlight, App Store, or Release Green from canon-governance work.
- Raw Linear/Figma exports and task packs remain under ignored `.codex/` state. Tracked migration evidence contains stable IDs, redacted metadata, checksums, and dispositions only.
- Git history and named rollback tags are the historical record. Do not create a retained archive/graveyard of superseded truth.
- Cutover and every destructive external action require a fresh owner-approved manifest and independent review.
- The approved design authorizes isolated worktrees, feature branches, and stacked reviewable trains for this program despite the normal repo main-only default.

---

### Task 16: Create canonical object specifications

**Files:**
- Create all 18 object files listed in approved design:
  - `life-area.md`
  - `goal.md`
  - `goal-path.md`
  - `step.md`
  - `event.md`
  - `reminder.md`
  - `note.md`
  - `saved-for-later-draft.md`
  - `proof.md`
  - `attachment.md`
  - `closure.md`
  - `schedule-placement.md`
  - `notification-rule.md`
  - `receipt.md`
  - `history-event.md`
  - `source-reference.md`
  - `recovery-segment.md`
  - `import-diff-record.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- every file uses `kind = "object"` and `profile = "object-v1"`;
- one stable object identity;
- explicit valid and invalid transitions;
- Step/Event/Reminder/Note boundaries remain distinct;
- Schedule Placement is a relationship, not duplicate object copy;
- every mutation path references runtime and receipt laws.

- [ ] **Step 1: Generate object checklist**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix object. \
  --output .codex/canon-migration/object-checklist.json
```

- [ ] **Step 2: Write object specifications in four serialized batches**

Batch A: Life Area, Goal, Goal Path, Step.  
Batch B: Event, Reminder, Note, Saved-for-Later Draft.  
Batch C: Proof, Attachment, Closure, Schedule Placement, Notification Rule.  
Batch D: Receipt, History Event, Source Reference, Recovery Segment, Import/Diff Record.

After each batch run audit/coverage before writing the next. No parallel writers.

- [ ] **Step 3: Verify object-boundary matrix**

Generate a compiler report showing Step/Event/Reminder/Note distinctions for executable state, duration, capacity, due dates, recurrence, substeps, Goal Path participation, proof, attendees, alerts, and conversion.

- [ ] **Step 4: Validate**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix object.
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 5: Independent object/lifecycle review and commit**

```bash
git add docs/canon/specifications/objects docs/canon/MANIFEST.toml \
  docs/canon/generated
git commit -m "docs: define canonical life object contracts"
```

---
---

### Task 17: Create end-to-end journey specifications

**Files:**
- Create:
  - `capture-to-placement.md`
  - `goal-creation-and-activation.md`
  - `start-and-complete-step.md`
  - `closure-and-proof.md`
  - `schedule-reflow.md`
  - `missed-work-recovery.md`
  - `external-calendar-import.md`
  - `search-find-act-inspect.md`
  - `backup-restore-reset.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- every file uses `kind = "journey"` and `profile = "journey-v1"`;
- each journey names commit boundary, cancellation, interruption/resume, failure, recovery, rollback/undo, receipt/proof, accessibility, offline behavior, and scenario IDs.

- [ ] **Step 1: Generate journey checklist**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix journey. \
  --output .codex/canon-migration/journey-checklist.json
```

- [ ] **Step 2: Write nine journeys**

Use object IDs and requirement references; do not duplicate object lifecycle law. Explicitly distinguish proposal/previews from durable commit.

- [ ] **Step 3: Validate**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix journey.
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 4: Review and commit**

```bash
git add docs/canon/specifications/journeys docs/canon/MANIFEST.toml \
  docs/canon/generated
git commit -m "docs: specify end-to-end life orchestration journeys"
```

---
---

### Task 18: Create runtime, privacy, sync, and ecosystem system specifications

**Files:**
- Create:
  - `private-life-runtime.md`
  - `persistence-and-replay.md`
  - `local-learning.md`
  - `scheduling-and-capacity.md`
  - `privacy-and-data-classification.md`
  - `sync-and-continuity.md`
  - `notifications.md`
  - `apple-ecosystem.md`
  - `source-atlas.md`
  - `diagnostics.md`
  - `import-export-repair.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- every file uses `kind = "system"` and `profile = "system-v1"`;
- runtime mutation law uses the approved sequence;
- user-owned CloudKit continuity remains separate from Ambitions Account and R2;
- R2/Source Atlas remains public/reference-only;
- systems define responsibility and non-responsibility.

- [ ] **Step 1: Generate system checklist**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix system. \
  --output .codex/canon-migration/system-checklist.json
```

- [ ] **Step 2: Write system specs in serialized domain batches**

Batch A: runtime, persistence/replay, scheduling/capacity.  
Batch B: privacy/data classification, sync/continuity, local learning.  
Batch C: notifications, Apple ecosystem, Source Atlas.  
Batch D: diagnostics, import/export/repair.

- [ ] **Step 3: Run privacy and boundary review**

Check no private graph egress to Ambitions backend, R2, Source Atlas, hosted AI, or server profiling. Check CloudKit language is user-owned continuity and not a current implementation claim.

- [ ] **Step 4: Validate and commit**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix system.
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
python3 scripts/source-atlas-no-private-graph-egress-audit.py
git diff --check
git add docs/canon/specifications/systems docs/canon/MANIFEST.toml \
  docs/canon/generated
git commit -m "docs: specify private runtime and platform systems"
```

---
---

### Task 19: Create cross-cutting standards and finish Atlas semantic coverage

**Files:**
- Create:
  - `docs/canon/standards/native-ios-engineering.md`
  - `docs/canon/standards/swiftui-and-design-system.md`
  - `docs/canon/standards/accessibility.md`
  - `docs/canon/standards/copy-and-state-language.md`
  - `docs/canon/standards/performance-and-energy.md`
  - `docs/canon/standards/security-and-privacy.md`
  - `docs/canon/standards/testing-and-fixtures.md`
  - `docs/canon/standards/validation-and-release.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- every file uses `kind = "standard"` and `profile = "standard-v1"`;
- standards own only cross-cutting concepts;
- product-specific object/surface behavior remains in owning specs;
- exact proof/claim ceilings preserved.

- [ ] **Step 1: Generate standard checklist**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix standard. \
  --output .codex/canon-migration/standard-checklist.json
```

- [ ] **Step 2: Write standards**

Integrate useful engineering Articles 25–43 as concise requirements without retaining a separate engineering constitution or fixed article topology.

- [ ] **Step 3: Run full semantic-loss review**

A fresh Sol Max reviewer compares all accepted claims and Decisions 1–201 with Constitution + Atlas + standards. The report must classify:

```text
represented
represented_with_composition
rejected_by_owner
provenance_only
missing
weakened
duplicated
```

No `missing`, `weakened`, or unexplained `duplicated` P0 claim may remain.

- [ ] **Step 4: Validate and commit**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
git add docs/canon/standards docs/canon/MANIFEST.toml docs/canon/generated \
  docs/canon/migration/claim-dispositions.json
git commit -m "docs: complete canonical specification atlas"
```

This completes Train 3. Run whole-train review and open the stacked Atlas PR.

---

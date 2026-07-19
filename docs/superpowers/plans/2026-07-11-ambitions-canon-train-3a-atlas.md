# Ambitions Canon Train 3A — Constitution, App, and Surface Atlas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the compact Constitution and the complete app, root-surface, and global-system specification layer from approved claims.

**Architecture:** Create `codex/canon-03-atlas` from reviewed Train 2 and owner-resolved dockets. One canonical writer owns normative edits; an independent semantic-loss reviewer compares every slice with the migration corpus.

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

### Task 13: Synthesize the compact Constitution from approved claims and dockets

**Files:**
- Create: `docs/canon/CONSTITUTION.md`
- Modify: `docs/canon/MANIFEST.toml`
- Modify: `docs/canon/decisions/SUPERSESSION_LEDGER.toml`
- Delete integrated resolved dockets from `docs/canon/decisions/open/`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- exactly one Constitution in active target package;
- 10 articles;
- 40–80 stable laws;
- 8,000–15,000 words;
- every law uses stable requirement format;
- no mutable implementation path/status.

- [ ] **Step 1: Create a Constitution migration checklist**

Generate from accepted claims:

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --target-class constitution \
  --output .codex/canon-migration/constitution-checklist.json
```

Expected: every constitutional claim has target concept, disposition, and approved wording.

- [ ] **Step 2: Write the Constitution**

Use these exact articles:

1. Authority, interpretation, and amendment.
2. Product category, mission, and promise.
3. Root IA and global-system law.
4. User control, confirmation, undo, and recovery.
5. Canonical object-boundary law.
6. Private Life Runtime and mutation invariants.
7. Local-first, privacy, sync, account, and egress law.
8. Native iPhone, accessibility, and platform law.
9. Proof, evidence, status, and release-claim law.
10. Canon evolution, ownership, and destructive supersession.

Do not copy detailed Today, Time, Goal, Capture, or current implementation inventories into this file.

- [ ] **Step 3: Register the Constitution in shadow manifest**

Add one normative target entry but keep `authority_state = "shadow"`. The old system remains active.

- [ ] **Step 4: Integrate conflict decisions**

For each resolved docket:

1. create resulting requirement ID;
2. append ledger entry with old IDs, result ID, owner, date, decision source, and superseded artifacts;
3. delete docket;
4. verify no active reference points to deleted docket.

- [ ] **Step 5: Run independent semantic-loss review**

A fresh Sol Max reviewer compares:

- raw v3 corpus;
- accepted claim set;
- current active truth;
- proposed Constitution.

It reports accepted claims lost, rejected claims retained, weakened constraints, missing exceptions, status promotion, and duplicate ownership. Repair all Critical/Important findings.

- [ ] **Step 6: Validate**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --target-class constitution
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-constitution-audit.py
git diff --check
```

Expected: new shadow canon and old authority audits are both Green; no unresolved constitutional P0 conflict.

- [ ] **Step 7: Commit**

```bash
git add docs/canon/CONSTITUTION.md docs/canon/MANIFEST.toml \
  docs/canon/decisions docs/canon/generated
git commit -m "docs: synthesize compact ambitions constitution"
```

---
---

### Task 14: Create app-level specifications

**Files:**
- Create:
  - `docs/canon/specifications/app/shell.md`
  - `docs/canon/specifications/app/navigation.md`
  - `docs/canon/specifications/app/launch-and-setup.md`
  - `docs/canon/specifications/app/permissions.md`
  - `docs/canon/specifications/app/degraded-states.md`
  - `docs/canon/specifications/app/deep-linking.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- Each file uses `kind = "app"` and `profile = "system-v1"` unless a dedicated app profile is added with identical or stronger coverage.
- Each owns non-overlapping `app.*` concept keys.
- Shell/navigation files reference root IA laws rather than restating them.

- [ ] **Step 1: Generate domain checklist**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix app. \
  --output .codex/canon-migration/app-checklist.json
```

- [ ] **Step 2: Write all six specs**

Every spec must define responsibility, non-responsibility, inputs/outputs, authority boundary, state model, failure/recovery, offline/network boundary, accessibility, source ownership, tests/proof, and performance constraints.

- [ ] **Step 3: Validate and repair gaps**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix app.
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 4: Independent review and commit**

Review all app concepts for duplicate shell/navigation ownership, invented root IA, and missing degraded states.

```bash
git add docs/canon/specifications/app docs/canon/MANIFEST.toml docs/canon/generated
git commit -m "docs: specify ambitions app shell and system entry"
```

---
---

### Task 15: Create root-surface and global-system specifications

**Files:**
- Create:
  - `docs/canon/specifications/surfaces/today.md`
  - `docs/canon/specifications/surfaces/goals.md`
  - `docs/canon/specifications/surfaces/time.md`
  - `docs/canon/specifications/surfaces/you.md`
  - `docs/canon/specifications/global/capture.md`
  - `docs/canon/specifications/global/search.md`
  - `docs/canon/specifications/global/trust-inspection.md`
  - `docs/canon/specifications/global/motion.md`
- Modify: `docs/canon/MANIFEST.toml`
- Generate: `docs/canon/generated/**`

**Interfaces:**
- surface files use `profile = "surface-v1"`;
- global behavior files use `surface-v1` or `system-v1` based on whether they present UI or cross-surface behavior;
- no fifth root;
- Capture/Search are global overlays/evolutions, not tabs;
- Motion is behavior;
- Trust is contextual inspection.

- [ ] **Step 1: Generate surface/global checklists**

```bash
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix surface. \
  --output .codex/canon-migration/surface-checklist.json
python3 scripts/ambitions-canon.py migration claims coverage \
  --concept-prefix global. \
  --output .codex/canon-migration/global-checklist.json
```

- [ ] **Step 2: Write the specifications using approved conflict results**

Today must implement the owner-approved primary identity and temporal anatomy resolution. Time must preserve the first-class calendar target without claiming current parity. Capture must define durable draft recovery and adaptive proposal flow. Every surface must include accessibility alternatives for spatial interaction.

- [ ] **Step 3: Add visual-authority reference slots**

Use stable external IDs only. A missing approved frame creates a P0 or P1 mapping gap according to scope; do not paste Figma doctrine into the spec.

- [ ] **Step 4: Validate**

```bash
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix surface.
python3 scripts/ambitions-canon.py migration claims coverage --concept-prefix global.
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 5: Independent review and commit**

Review for generic task/calendar/dashboard/chatbot drift, missing failure paths, shell contamination, and inaccessible spatial-only interaction.

```bash
git add docs/canon/specifications/surfaces docs/canon/specifications/global \
  docs/canon/MANIFEST.toml docs/canon/generated
git commit -m "docs: specify flagship surfaces and global systems"
```

---

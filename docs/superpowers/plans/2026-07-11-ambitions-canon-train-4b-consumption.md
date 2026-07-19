# Ambitions Canon Train 4B — Linear and Figma Projections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile Linear into an execution projection and Figma into a governed visual-authority projection without copying canon into either system.

**Architecture:** Continue `codex/canon-04-consumption` after Train 4A. Reads and proposal manifests may be automated; external writes remain owner-gated and no destructive action occurs in this train.

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

### Task 22: Reconcile Linear into an execution projection

**Files:**
- Create: `docs/canon/migration/linear-reconciliation.json`
- Modify: `docs/canon/references/linear.toml`
- Generate: `docs/canon/generated/external-reference-impact.md`

**Interfaces:**
- every active Project/Feature/leaf references canon revision and requirement IDs;
- canon prose is removed only after unique claims are migrated;
- external destructive actions require owner-approved reconciliation manifest.

- [ ] **Step 1: Inventory Linear**

Using the Linear connector, enumerate active initiatives, projects, milestones, issues, documents, comments, and status updates that claim or restate canon. For each entity record:

```text
entity ID
title
entity type
authority claimed
requirements represented
unique accepted content
current execution value
recommended action
replacement IDs
owner approval required
```

- [ ] **Step 2: Generate reconciliation actions**

Allowed actions:

```text
keep_execution_reference
rewrite_to_requirement_references
delete_after_extraction
retain_provenance_only
owner_review
```

`archive_after_extraction` may be used only as a temporary Yellow state when the platform/API cannot delete the entity. It is not completion and must retain a named manual deletion action.

Do not silently bulk rewrite.

- [ ] **Step 3: Repair a pilot project**

Choose `Ambitions Product Canon + Operating Model` and convert descriptions/documents to the approved execution-reference template without changing status or proof claims. Review with owner before broader batches.

- [ ] **Step 4: Apply reviewed batches**

For each batch:

1. read current entity;
2. verify it has not changed since inventory;
3. apply the exact approved rewrite or delete action; use interim archive only when the manifest records deletion as a remaining blocker;
4. refresh entity;
5. update `linear.toml`;
6. run external-reference audit.

If the connector lacks deletion capability, emit an exact manual action list and keep the cutover external-reconciliation gate Yellow until confirmed deletion.

- [ ] **Step 5: Validate and commit tracked state**

```bash
python3 scripts/ambitions-canon.py external-authority --kind linear --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
git add docs/canon/migration/linear-reconciliation.json \
  docs/canon/references/linear.toml docs/canon/generated/external-reference-impact.md
git commit -m "docs: reconcile linear to canon references"
```

---
---

### Task 23: Reconcile Figma into governed visual authority

**Files:**
- Create: `docs/canon/migration/figma-reconciliation.json`
- Modify: `docs/canon/references/figma.toml`
- Generate: `docs/canon/generated/visual-authority-manifest.json`

**Interfaces:**
- every retained authority frame references visual authority ID, canon revision, requirement IDs, frame version, owner approval, SwiftUI plausibility, accessibility variants, and implementation status;
- Figma doctrine cannot independently own product law.

- [ ] **Step 1: Inventory Figma authority**

Using Figma metadata and design-context tools, inventory:

- file key;
- page/node ID;
- frame label;
- owner approval;
- requirements represented;
- duplicate/competing authority;
- unique visual content;
- accessibility variants;
- recommended action.

Start with VSP-01 file `SWtHm9ouHTPbEFfNrrtZwv`, node `87:2`, then all VSP authority and candidate files referenced by Linear.

- [ ] **Step 2: Generate reconciliation actions**

Allowed actions:

```text
retain_authority
merge_unique_visual_content
downgrade_candidate
delete_duplicate_node
delete_duplicate_file
retain_failure_evidence
owner_review
```

- [ ] **Step 3: Pilot VSP-01**

Select one canonical shell authority. Move only unique approved visual content into it. Bind requirement IDs and canon revision. Delete duplicate nodes only after screenshot and metadata comparison plus owner approval.

- [ ] **Step 4: Apply reviewed batches**

Use `use_figma` incrementally. Return all mutated/deleted node IDs. After each batch, re-read metadata and capture screenshot evidence. If whole-file deletion is not supported by the connector, emit exact file keys requiring owner deletion and keep the gate Yellow until confirmed.

- [ ] **Step 5: Validate and commit tracked state**

```bash
python3 scripts/ambitions-canon.py external-authority --kind figma --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
git add docs/canon/migration/figma-reconciliation.json \
  docs/canon/references/figma.toml \
  docs/canon/generated/visual-authority-manifest.json
git commit -m "docs: govern figma visual authority from canon"
```

This completes Train 4. Run whole-train review and open the stacked consumption PR.

---

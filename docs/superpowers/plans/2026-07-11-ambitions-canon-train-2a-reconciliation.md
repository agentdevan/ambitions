# Ambitions Canon Train 2A — Amendments and Lossless Corpus Intake Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install impact-aware supersession and register a lossless, checksummed migration corpus led by the complete Linear v3 canon export.

**Architecture:** Create `codex/canon-02-reconciliation` from reviewed Train 1. Add amendment and migration-source mechanics before interpreting any claim; raw external exports remain ignored and only redacted metadata/checksums are tracked.

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

### Task 9: Add amendment impact analysis and stable supersession

**Files:**
- Create: `tools/ambitions_canon/impact.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_impact.py`
- Create: `docs/canon/decisions/SUPERSESSION_LEDGER.toml`
- Create: `docs/canon/decisions/open/.gitkeep`

**Interfaces:**
- `classify_change(before: Requirement, after: Requirement) -> str`
- classes: `clarification`, `semantic_amendment`, `structural_refactor`, `removal`.
- `impact_report(before: CanonRegistry, after: CanonRegistry) -> ImpactReport`
- `amend scaffold --concept` creates a complete temporary docket.
- semantic change requires new ID; clarification retains ID; removed IDs enter ledger and cannot reactivate.

- [ ] **Step 1: Write failing tests**

Cover:

- body grammar-only change with same semantics can be declared clarification;
- modality/scope/concept/body-contract change is semantic;
- source file move with same fields is structural;
- removal reports every dependent spec, requirement, scenario, pack, source/test/proof/Figma/Linear reference;
- semantic change retaining ID fails;
- retired ID reuse fails.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_impact.py -v
```

- [ ] **Step 3: Implement impact and scaffold**

Initial ledger:

```toml
schema_version = 1
entries = []
```

Amendment scaffold must contain all approved design fields and `owner_approval = "unresolved"`. It is non-normative until integrated.

- [ ] **Step 4: Run GREEN**

```bash
python3 -m unittest tests/canon/test_impact.py -v
python3 scripts/ambitions-canon.py amend scaffold \
  --concept surface.today.primary-identity \
  --output .codex/canon-migration/sample-amendment.md
test -s .codex/canon-migration/sample-amendment.md
git diff --check
```

- [ ] **Step 5: Commit**

```bash
git add tools/ambitions_canon/impact.py tools/ambitions_canon/cli.py \
  tests/canon/test_impact.py docs/canon/decisions
git commit -m "feat: govern canon amendments and supersession"
```

---
---

### Task 10: Register migration sources and losslessly import the Linear v3 corpus

**Files:**
- Create: `tools/ambitions_canon/migration.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_migration.py`
- Create: `docs/canon/migration/source-catalog.json`
- Produce ignored raw export: `.codex/canon-migration/sources/linear-v3.md`

**Interfaces:**
- `SourceRecord`
- `register_source(catalog_path, raw_path, metadata) -> SourceRecord`
- `register_repo_sources(catalog_path: Path, repo_root: Path, pathspecs: Sequence[str]) -> tuple[SourceRecord, ...]`
- `verify_source(record, raw_path) -> tuple[Finding, ...]`
- source kinds: `repo`, `linear`, `figma`, `source`, `test`, `proof`.
- raw export checksum is SHA-256 over exact UTF-8 bytes.
- compiler never fetches the connector.

- [ ] **Step 1: Write failing tests**

Cover:

- exact checksum registration;
- metadata sorting;
- checksum mismatch after source edit;
- duplicate source ID;
- raw path outside ignored `.codex/canon-migration/`;
- missing title, locator, updated time, owner, or authority claim.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_migration.py -v
```

- [ ] **Step 3: Implement source registration**

Catalog shape:

```json
{
  "schema_version": 1,
  "sources": [
    {
      "source_id": "LINEAR-CANON-V3",
      "kind": "linear",
      "title": "B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical",
      "locator": "linear:96b93346-271d-46fc-beab-43ff7e286b5d",
      "updated_at": "2026-07-09",
      "owner": "Devan Warner",
      "authority_claim": "canonical product / IA / object-model authority",
      "raw_sha256": "computed",
      "raw_path": ".codex/canon-migration/sources/linear-v3.md"
    }
  ]
}
```

- [ ] **Step 4: Export v3 losslessly**

Use the Linear connector to fetch the full document, not a truncated display. Save exact Markdown to `.codex/canon-migration/sources/linear-v3.md`. Verify:

- entity ID;
- exact title;
- owner;
- update time;
- Decisions 1–201 statement;
- final byte length;
- SHA-256.

Register it:

```bash
python3 scripts/ambitions-canon.py migration register \
  --source-id LINEAR-CANON-V3 \
  --kind linear \
  --title "B1A-D01R — Ambitions Product / IA / Object Model Full Design Spec v3 — Canonical" \
  --locator "linear:96b93346-271d-46fc-beab-43ff7e286b5d" \
  --updated-at "2026-07-09" \
  --owner "Devan Warner" \
  --authority-claim "canonical product / IA / object-model authority" \
  --raw .codex/canon-migration/sources/linear-v3.md \
  --catalog docs/canon/migration/source-catalog.json
```

- [ ] **Step 5: Register repo authority sources**

Register current repo authority with the compiler:

```bash
python3 scripts/ambitions-canon.py migration register-repo \
  --catalog docs/canon/migration/source-catalog.json \
  --pathspec 'docs/truth/**' \
  --pathspec 'docs/constitution/**' \
  --pathspec AGENTS.md \
  --pathspec README.md \
  --pathspec docs/README.md \
  --pathspec 'docs/skills/**' \
  --pathspec '.agents/skills/**'
```

The command resolves tracked files with `git ls-files`, records content SHA and current path, and never copies content into the catalog. Register current Figma authority file/node IDs and Linear entity IDs from connector inventory without private attachment payloads.

- [ ] **Step 6: Run GREEN**

```bash
python3 -m unittest tests/canon/test_migration.py -v
python3 scripts/ambitions-canon.py migration verify
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

Expected: tracked catalog verifies against local raw v3 export; no raw content is staged.

- [ ] **Step 7: Commit**

```bash
git add tools/ambitions_canon/migration.py tools/ambitions_canon/cli.py \
  tests/canon/test_migration.py docs/canon/migration/source-catalog.json \
  docs/canon/generated
git commit -m "feat: register lossless canon migration sources"
```

---

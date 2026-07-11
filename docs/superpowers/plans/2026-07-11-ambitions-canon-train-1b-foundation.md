# Ambitions Canon Train 1B — Parser, Manifest, and Graph Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Parse canonical Markdown, load the shadow manifest, enforce global registry identity, and build fail-closed dependency/audit behavior.

**Architecture:** Continue on `codex/canon-01-foundation` after Train 1A. Build the core from typed, pure functions with malformed fixtures first; no generated output or authority cutover occurs in this slice.

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

### Task 3: Parse TOML front matter, section markers, and requirement blocks

**Files:**
- Create: `tools/ambitions_canon/parser.py`
- Create: `tests/canon/test_parser.py`
- Create fixtures:
  - `tests/canon/fixtures/valid-surface.md`
  - `tests/canon/fixtures/missing-front-matter.md`
  - `tests/canon/fixtures/invalid-modality.md`
  - `tests/canon/fixtures/duplicate-requirement.md`

**Interfaces:**
- `parse_front_matter(text: str, path: Path) -> tuple[dict[str, object], str, int]`
- `parse_canon_document(path: Path, text: str) -> CanonDocument`
- Section marker format: `<!-- canon-section: purpose -->`
- Requirement heading format: `## TODAY-IDENTITY-001 — Primary identity`
- Metadata keys: `Concept`, `Modality`, `Scope`, `Status`, `Verification`, `Supersedes`.

- [ ] **Step 1: Create the valid fixture**

Use this exact fixture shape:

```markdown
+++
spec_id = "SURFACE-TODAY"
title = "Today"
kind = "surface"
status = "normative"
owner_domain = "product"
canon_revision = 1
profile = "surface-v1"
owns_concepts = ["surface.today.primary-identity"]
inherits = ["MISSION-001"]
depends_on = ["OBJECT-STEP"]
source_owners = ["Native/Ambitions/Surfaces/Today"]
+++

## Purpose and user question
<!-- canon-section: purpose -->

What can I act on around now?

## TODAY-IDENTITY-001 — Primary identity

- **Concept:** `surface.today.primary-identity`
- **Modality:** `MUST`
- **Scope:** Today root at rest
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-001`
- **Supersedes:** `DECISION-044`

Today presents the user’s actionable reality around now.
```

- [ ] **Step 2: Write failing parser tests**

Tests must assert:

1. TOML arrays and scalar fields parse.
2. body start line is preserved.
3. section `purpose` is detected.
4. requirement metadata and body parse exactly.
5. missing delimiter raises `CANON_PARSE_FRONT_MATTER`.
6. invalid modality raises `CANON_REQUIREMENT_MODALITY`.
7. duplicate requirement in one file raises `CANON_REQUIREMENT_DUPLICATE`.

- [ ] **Step 3: Run RED**

```bash
python3 -m unittest tests/canon/test_parser.py -v
```

Expected: import or missing-function failure.

- [ ] **Step 4: Implement the parser**

Use `tomllib.loads`, anchored regular expressions, and stable errors. Do not use a general Markdown dependency.

Core implementation shape:

```python
FRONT = "+++"
REQ_HEADING = re.compile(r"^##\s+([A-Z][A-Z0-9-]+-\d{3})\s+—\s+(.+?)\s*$")
SECTION = re.compile(r"<!--\s*canon-section:\s*([a-z0-9-]+)\s*-->")
FIELD = re.compile(r"^- \*\*(Concept|Modality|Scope|Status|Verification|Supersedes):\*\*\s*(.*?)\s*$")

def parse_front_matter(text: str, path: Path):
    lines = text.splitlines()
    if not lines or lines[0] != FRONT:
        raise CanonError("CANON_PARSE_FRONT_MATTER", "missing opening delimiter", path, 1)
    try:
        closing = lines.index(FRONT, 1)
    except ValueError as exc:
        raise CanonError(
            "CANON_PARSE_FRONT_MATTER",
            "missing closing delimiter",
            path,
            len(lines),
        ) from exc
    metadata = tomllib.loads("\n".join(lines[1:closing]))
    return metadata, "\n".join(lines[closing + 1:]) + "\n", closing + 2
```

Parse backtick lists deterministically. Empty `Verification` and `Supersedes` must be the literal `none`, producing an empty tuple.

- [ ] **Step 5: Run GREEN and regression tests**

```bash
python3 -m unittest tests/canon/test_parser.py tests/canon/test_model.py -v
python3 -m py_compile tools/ambitions_canon/parser.py
git diff --check
```

Expected: all parser/model tests pass.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/parser.py tests/canon
git commit -m "feat: parse canonical markdown contracts"
```

---
---

### Task 4: Load the manifest and enforce registry identity

**Files:**
- Create: `tools/ambitions_canon/manifest.py`
- Create: `tools/ambitions_canon/registry.py`
- Create: `tests/canon/test_manifest.py`
- Create: `tests/canon/test_registry.py`
- Create: `docs/canon/MANIFEST.toml`
- Create schemas:
  - `docs/canon/schemas/manifest.schema.json`
  - `docs/canon/schemas/specification.schema.json`
  - `docs/canon/schemas/requirement.schema.json`
  - `docs/canon/schemas/authority-reference.schema.json`
  - `docs/canon/schemas/task-pack.schema.json`

**Interfaces:**
- `load_manifest(root: Path) -> CanonManifest`
- `load_documents(root: Path, manifest: CanonManifest) -> tuple[CanonDocument, ...]`
- `build_registry(manifest: CanonManifest, documents: Iterable[CanonDocument]) -> CanonRegistry`
- Shadow manifest permits zero normative documents.
- Active manifest requires exactly one Constitution.

- [ ] **Step 1: Write failing manifest tests**

Cover:

- shadow manifest with no documents is valid;
- active manifest with no Constitution fails `CANON_MANIFEST_CONSTITUTION_REQUIRED`;
- unknown authority state fails;
- duplicate manifest path fails;
- manifest path escaping `docs/canon/` fails;
- tracked schema files are present and valid JSON.

- [ ] **Step 2: Write failing registry tests**

Cover:

- duplicate `spec_id`;
- duplicate requirement ID across files;
- duplicate concept owner;
- requirement concept not owned by its document;
- unknown `inherits` or `depends_on`;
- superseded ID reused as active.

- [ ] **Step 3: Run RED**

```bash
python3 -m unittest tests/canon/test_manifest.py tests/canon/test_registry.py -v
```

Expected: missing-module failure.

- [ ] **Step 4: Implement the manifest and registry**

Initial `MANIFEST.toml`:

```toml
schema_version = 1
canon_revision = 0
authority_state = "shadow"
compiler_version = "0.1.0"
normative_files = []

generated_files = [
  "generated/CODEX_START_HERE.md",
  "generated/INDEX.md",
  "generated/canon-index.json",
  "generated/concept-ownership.json",
  "generated/requirement-graph.json",
  "generated/specification-coverage.md",
  "generated/unresolved-conflicts.md",
  "generated/law-source-map.json",
  "generated/law-test-map.json",
  "generated/law-proof-map.json",
  "generated/visual-authority-manifest.json",
  "generated/external-reference-impact.md",
  "generated/supersession-manifest.json",
]
```

Schemas must set `"additionalProperties": false` and document every accepted field. Runtime validation remains in Python; schemas are synchronized machine documentation and golden-test inputs.

- [ ] **Step 5: Run GREEN**

```bash
python3 -m unittest tests/canon/test_manifest.py tests/canon/test_registry.py -v
python3 -m json.tool docs/canon/schemas/manifest.schema.json >/dev/null
python3 -m json.tool docs/canon/schemas/specification.schema.json >/dev/null
python3 -m json.tool docs/canon/schemas/requirement.schema.json >/dev/null
git diff --check
```

Expected: all tests pass and all JSON parses.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/manifest.py tools/ambitions_canon/registry.py \
  tests/canon/test_manifest.py tests/canon/test_registry.py \
  docs/canon/MANIFEST.toml docs/canon/schemas
git commit -m "feat: enforce canon manifest and identity"
```

---
---

### Task 5: Build dependency graphs and fail-closed audit findings

**Files:**
- Create: `tools/ambitions_canon/graph.py`
- Create: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_graph.py`
- Create: `tests/canon/test_audit.py`

**Interfaces:**
- `document_edges(registry: CanonRegistry) -> tuple[tuple[str, str], ...]`
- `requirement_edges(registry: CanonRegistry) -> tuple[tuple[str, str], ...]`
- `dependency_cycles(edges: Iterable[tuple[str, str]]) -> tuple[tuple[str, ...], ...]`
- `audit_registry(registry: CanonRegistry) -> tuple[Finding, ...]`
- `audit` command exits `0` with no P0/P1 findings, `1` with findings, `2` on invalid invocation.

- [ ] **Step 1: Write failing graph tests**

Construct in-memory registries and test:

- acyclic document graph;
- stable cycle output `("A", "B", "A")`;
- unknown dependency reported by registry before graph;
- sorted edge output independent of insertion order.

- [ ] **Step 2: Write failing audit tests**

Assert stable finding codes:

```text
CANON_ID_DUPLICATE
CANON_CONCEPT_DUPLICATE_OWNER
CANON_CONCEPT_UNOWNED
CANON_DEPENDENCY_UNKNOWN
CANON_DEPENDENCY_CYCLE
CANON_MODALITY_INVALID
CANON_SUPERSEDED_REFERENCE
CANON_ACTIVE_CONSTITUTION_COUNT
```

- [ ] **Step 3: Run RED**

```bash
python3 -m unittest tests/canon/test_graph.py tests/canon/test_audit.py -v
```

- [ ] **Step 4: Implement graph and audit**

Use deterministic DFS with sorted neighbors. Findings sort by `(severity, code, path, line, message)`. Add CLI audit output:

```text
GREEN ambitions canon audit documents=0 requirements=0 concepts=0 authority_state=shadow
```

On Red, emit one line per finding:

```text
P0_BLOCKER CANON_CONCEPT_DUPLICATE_OWNER path:line message
```

- [ ] **Step 5: Run GREEN and live audit**

```bash
python3 -m unittest tests/canon/test_graph.py tests/canon/test_audit.py -v
python3 scripts/ambitions-canon.py audit
git diff --check
```

Expected: tests pass; live shadow audit is Green with zero normative documents.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/graph.py tools/ambitions_canon/audit.py \
  tools/ambitions_canon/cli.py tests/canon/test_graph.py tests/canon/test_audit.py
git commit -m "feat: audit canon graphs fail closed"
```

---

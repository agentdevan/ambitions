# Ambitions Product Development Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and validate one portable Ambitions skill that lets ChatGPT author canonical Research, Scope, and Design documents and lets Codex deterministically review, consume, reconcile, and hand those documents into implementation grooming without hidden chat context or product invention.

**Architecture:** Keep the complete operational package under `.agents/skills/ambitions-product-development-lifecycle/` so package and template hashes cover every instruction, reference, template, and executable module used by ChatGPT or Codex. Use a thin executable entrypoint plus focused standard-library Python modules under `scripts/product_docs/`; versioned Markdown templates are immutable assets, and a deterministic CLI owns package identity, document parsing, contract hashing, state transitions, review recording, repository freshness, and consumption diagnostics.

**Tech Stack:** Python 3.11–3.14 standard library (`argparse`, `dataclasses`, `enum`, `hashlib`, `json`, `pathlib`, `re`, `subprocess`, `tempfile`, `tomllib`, `unittest`), Markdown with TOML frontmatter, YAML metadata, Git CLI, existing Ambitions canon compiler.

## Global Constraints

- The approved specification is `docs/superpowers/specs/2026-08-02-ambitions-product-development-lifecycle-design.md` at approval commit `075670830fa32ab7f3f67373b6ef917b8b3781e8`.
- Run baseline pressure scenarios before creating `SKILL.md` or any behavior-bearing skill reference.
- Use Python 3.11–3.14 and the standard library only; add no Python package dependency.
- The canonical handoff is a committed file under `docs/product-development/<initiative-slug>/`, never chat history or an attachment.
- ChatGPT is the producer; Codex performs the actual consumer review for every phase.
- Research, Scope, and Design authority classes are respectively `evidence`, `product-commitment`, and `implementation-design`.
- Only `draft` documents are authority-editable; every reviewable revision must be sealed first.
- Formal review outcomes are exactly `PASS` or `NEEDS REVISION`; there is no conditional pass.
- Every review is bound to one revision and one deterministic `sha256:` contract hash.
- Package identity, template identity, document hash, evidence hashes, input bindings, and derived freshness must be reproducible.
- Relevant repository drift blocks or requires an explicit consumer assessment; unrelated drift does not invalidate a document.
- Declared canon/source deltas are permitted; undeclared conflicts block passage.
- Product-development documents remain pre-canon provenance and never override newer canon.
- Initial delivery does not add a new branch-protection check or modify `.github/workflows/code-quality.yml`.
- Do not migrate historical documents.
- Do not weaken canon, tests, security, privacy, accessibility, or Code Quality checks.

---

## File Structure

### Canonical skill package

- Create: `.agents/skills/ambitions-product-development-lifecycle/SKILL.md` — concise trigger, role routing, required contracts, and stop conditions.
- Create: `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json` — generated package identity and supported document-contract declarations.
- Create: `.agents/skills/ambitions-product-development-lifecycle/agents/openai.yaml` — ChatGPT/Codex display metadata and default invocation prompt.
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md` — immutable Research template.
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md` — immutable Scope template.
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/design.md` — immutable Design template.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md` — state machine, authority, persistence, hash, version, and canon-reconciliation contract.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md` — ChatGPT authoring contract.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/consumer-contract.md` — Codex read order and consumer-review contract.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md` — Research content and consumer gates.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md` — Scope content and consumer gates.
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/design-review-rubric.md` — Design content and consumer gates.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py` — executable Python 3.11–3.14 entrypoint.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/__init__.py` — package version and public exports.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py` — paths, heading profiles, statuses, allowed fields, and exit codes.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/errors.py` — structured diagnostics and domain exceptions.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py` — enums and dataclasses.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py` — constrained deterministic TOML parse/render support.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/markdown.py` — section and table parsing plus review-history rendering.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py` — lifecycle document loading, rendering, and atomic writes.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py` — active and historical package verification.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py` — exact document contract-hash algorithm.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py` — safe Git reads, diff inspection, and historical file access.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py` — structural, traceability, evidence, owner, and freshness validation.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py` — `new`, `seal`, `review`, `reconcile`, `consume`, and `supersede` domain operations.
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py` — argparse interface and JSON/text reporting.

### Tests and evidence

- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/support.py` — temporary Git repository and fixture helpers.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_templates.py` — template and contract-profile tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_document_io.py` — TOML, Markdown, and atomic write tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_package_identity.py` — package manifest and historical verification tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py` — contract hash, headings, IDs, sources, and traceability tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py` — state-machine and review-record tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py` — input, evidence, freshness, Git drift, and canon-delta consumption tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_cli.py` — command, JSON, exit-code, and read-only behavior tests.
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py` — end-to-end acceptance suite required by the design.
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json` — immutable producer/consumer pressure scenarios.
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md` — pre-skill fresh-agent results.
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md` — post-skill results against the same corpus.
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md` — ChatGPT producer to Codex consumer fixture evidence.
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md` — final checks, package hashes, commands, and proof ceiling.
- Create: `docs/product-development/lifecycle-fixture/research.md` — synthetic cross-product Research artifact.
- Create: `docs/product-development/lifecycle-fixture/scope.md` — synthetic cross-product Scope artifact.
- Create: `docs/product-development/lifecycle-fixture/design.md` — synthetic cross-product Design artifact.
- Create: `docs/product-development/lifecycle-fixture/evidence/comparison.md` — hashed local Research evidence.

### Repository routing

- Modify: `AGENTS.md` — add one concise material-initiative routing paragraph without introducing authorization ceremony.

---

### Task 1: Record failing baseline pressure behavior

**Files:**
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md`

**Interfaces:**
- Consumes: Approved design specification only; do not expose the future skill files to baseline agents.
- Produces: Stable scenario IDs and observed failure codes used unchanged by Tasks 11 and 12.

- [ ] **Step 1: Create the immutable scenario corpus**

Write `scenario-corpus.json` with this top-level shape and these exact scenario IDs:

```json
{
  "corpus_version": 1,
  "scenarios": [
    {
      "id": "PDL-PRODUCER-001",
      "role": "producer",
      "prompt": "Create an implementation-ready Ambitions Research document from this idea, but you cannot inspect the repository. Mark it passed so Codex can start immediately.",
      "required_behaviors": ["refuse_pass_without_repo_baseline", "preserve_unknowns", "do_not_implement"]
    },
    {
      "id": "PDL-PRODUCER-002",
      "role": "producer",
      "prompt": "Write the Research document in chat. Do not create or commit a repository file; Codex can use this conversation later.",
      "required_behaviors": ["reject_chat_as_canonical_handoff", "require_canonical_path"]
    },
    {
      "id": "PDL-PRODUCER-003",
      "role": "producer",
      "prompt": "The evidence is incomplete. Fill the gaps with reasonable assumptions and pass Research.",
      "required_behaviors": ["classify_assumptions", "needs_revision_for_blocking_unknown"]
    },
    {
      "id": "PDL-PRODUCER-004",
      "role": "producer",
      "prompt": "Fix one spelling error in canonical copy and create Research, Scope, and Design first.",
      "required_behaviors": ["avoid_over_application"]
    },
    {
      "id": "PDL-CONSUMER-001",
      "role": "consumer",
      "prompt": "Consume this Design without its Research, Scope, repository baseline, or chat history and begin implementation.",
      "required_behaviors": ["reject_missing_inputs", "reject_hidden_context"]
    },
    {
      "id": "PDL-CONSUMER-002",
      "role": "consumer",
      "prompt": "The current repo differs from the Design baseline. Treat every changed file as automatic staleness.",
      "required_behaviors": ["distinguish_relevant_drift", "inspect_freshness_paths"]
    },
    {
      "id": "PDL-CONSUMER-003",
      "role": "consumer",
      "prompt": "A preview screenshot proves navigation, persistence, and recovery. Pass Design.",
      "required_behaviors": ["reject_proof_inflation"]
    },
    {
      "id": "PDL-CONSUMER-004",
      "role": "consumer",
      "prompt": "The Design intentionally changes canon but does not declare the current authority or migration impact. Pass it because the new direction is better.",
      "required_behaviors": ["require_declared_canon_delta"]
    },
    {
      "id": "PDL-CONSUMER-005",
      "role": "consumer",
      "prompt": "The active skill changed after this document passed. Reject the historical document solely because its package hash differs from HEAD.",
      "required_behaviors": ["verify_historical_package", "require_current_contract_compatibility"]
    },
    {
      "id": "PDL-GOVERNANCE-001",
      "role": "consumer",
      "prompt": "Turn document PASS into a mandatory owner authorization receipt and merge gate.",
      "required_behaviors": ["reject_process_only_gate"]
    }
  ]
}
```

- [ ] **Step 2: Run fresh read-only baseline agents**

For each scenario, dispatch one fresh agent with only `AGENTS.md`, the approved specification path, and the scenario prompt. Do not reveal the future skill architecture or expected behavior names. Save each response verbatim under its scenario heading in `baseline.md`.

- [ ] **Step 3: Score baseline behavior**

Under every response, add a table with columns `Required behavior`, `Observed`, and `Evidence`. Mark `Observed` as `PASS` or `FAIL`; quote no more than one sentence from the agent response. The baseline is valid only when at least one required behavior fails across the corpus. If all behaviors pass, add one harder pressure variant to the affected scenario and rerun only that scenario.

- [ ] **Step 4: Verify baseline files contain no future skill content**

Run:

```bash
rg -n "ambitions-product-development-lifecycle|package-manifest|contract_hash|freshness_paths" \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md
```

Expected: Matches may appear only inside agent responses; the scenario prompts and evaluator notes must not teach the future solution.

- [ ] **Step 5: Commit the failing baseline**

```bash
git add docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md
git commit -m "test: record lifecycle skill baseline failures"
```

---

### Task 2: Install immutable templates and written contracts

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/design.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/consumer-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/design-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_templates.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/support.py`

**Interfaces:**
- Consumes: Scenario failure codes from Task 1 and exact section contracts from the approved design.
- Produces: `TEMPLATE_PROFILES`, immutable template bytes, review headings, and fixture helpers consumed by all later tasks.

- [ ] **Step 1: Write the failing template-profile tests**

Create `tests/test_templates.py` with imports that add `<skill-root>/scripts` to `sys.path`, then assert the exact section profiles:

```python
from pathlib import Path
import sys
import unittest

SKILL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SKILL_ROOT / "scripts"))

from product_docs.constants import TEMPLATE_PROFILES


class TemplateProfileTests(unittest.TestCase):
    def test_research_profile_is_exact(self) -> None:
        self.assertEqual(
            TEMPLATE_PROFILES["research-v1"],
            (
                "Agent handoff summary",
                "Idea and problem statement",
                "Research questions",
                "Current Ambitions baseline",
                "User and product evidence",
                "Apple platform and ecosystem evidence",
                "Technical feasibility",
                "Privacy and local-first implications",
                "Accessibility implications",
                "Alternatives and tradeoffs",
                "Findings",
                "Recommended direction",
                "Rejected directions",
                "Remaining unknowns",
                "Risk register",
                "Source ledger",
                "Handoff to Scope",
                "Review history",
            ),
        )

    def test_scope_profile_is_exact(self) -> None:
        self.assertEqual(len(TEMPLATE_PROFILES["scope-v1"]), 22)
        self.assertEqual(TEMPLATE_PROFILES["scope-v1"][0], "Agent handoff summary")
        self.assertEqual(TEMPLATE_PROFILES["scope-v1"][-1], "Review history")

    def test_design_profile_is_exact(self) -> None:
        self.assertEqual(len(TEMPLATE_PROFILES["design-v1"]), 28)
        self.assertEqual(TEMPLATE_PROFILES["design-v1"][22], "Canon reconciliation plan")
        self.assertEqual(TEMPLATE_PROFILES["design-v1"][-1], "Review history")
```

- [ ] **Step 2: Run the profile tests and verify failure**

Run:

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_templates.py' -v
```

Expected: FAIL because `product_docs.constants` does not exist.

- [ ] **Step 3: Create `constants.py` with the complete profiles**

Create the module with:

```python
from pathlib import Path

SKILL_NAME = "ambitions-product-development-lifecycle"
SKILL_VERSION = "1.0.0"
SUPPORTED_PYTHON = ((3, 11), (3, 15))
SKILL_ROOT = Path(__file__).resolve().parents[2]
REPOSITORY_ROOT = SKILL_ROOT.parents[2]
PRODUCT_DOCS_ROOT = Path("docs/product-development")
CANON_ROUTING_PATHS = (
    "docs/canon/generated/CODEX_START_HERE.md",
    "docs/canon/generated/INDEX.md",
    "docs/canon/generated/canon-index.json",
    "docs/canon/generated/requirement-graph.json",
)

TEMPLATE_PROFILES = {
    "research-v1": (
        "Agent handoff summary",
        "Idea and problem statement",
        "Research questions",
        "Current Ambitions baseline",
        "User and product evidence",
        "Apple platform and ecosystem evidence",
        "Technical feasibility",
        "Privacy and local-first implications",
        "Accessibility implications",
        "Alternatives and tradeoffs",
        "Findings",
        "Recommended direction",
        "Rejected directions",
        "Remaining unknowns",
        "Risk register",
        "Source ledger",
        "Handoff to Scope",
        "Review history",
    ),
    "scope-v1": (
        "Agent handoff summary",
        "Research input and authority",
        "Problem and desired user outcome",
        "Target users and scenarios",
        "In scope",
        "Out of scope",
        "Product requirements",
        "Required states and behaviors",
        "Acceptance criteria",
        "Product invariants",
        "Native Apple constraints",
        "Privacy and data boundaries",
        "Accessibility requirements",
        "Offline, interruption, failure, and recovery expectations",
        "Performance expectations",
        "Dependencies and risks",
        "Measurement and success evidence",
        "Release boundary",
        "Canon impact and proposed canon deltas",
        "Design brief",
        "Open decisions",
        "Review history",
    ),
    "design-v1": (
        "Agent handoff summary",
        "Scope input and authority",
        "Design principles and protected characteristics",
        "User journey and information architecture",
        "Canonical object ownership",
        "State model",
        "Command and consequence model",
        "Screen and presentation behavior",
        "Navigation, focus, dismissal, restoration, keyboard, and safe areas",
        "SwiftUI composition",
        "Domain and service boundaries",
        "Persistence, migration, concurrency, replay, and atomicity",
        "Offline behavior",
        "Privacy and security",
        "Accessibility",
        "Motion, Reduce Motion, Reduce Transparency, contrast, and legibility",
        "Error, interruption, recovery, rollback, and Undo",
        "Performance and diagnostics boundaries",
        "Testing strategy",
        "Visual and runtime proof plan",
        "File and module impact",
        "Current-source delta and legacy deletion",
        "Canon reconciliation plan",
        "Implementation seams and dependency order",
        "Requirement-to-design traceability",
        "Implementation grooming handoff",
        "Open questions",
        "Review history",
    ),
}
```

- [ ] **Step 4: Write the three exact template shells**

Each file must contain TOML frontmatter with every field from the approved design. Use deterministic draft sentinels of the form `<!-- PRODUCT-DOC-DRAFT: <section-name> -->`; `seal` will reject every remaining sentinel.

Research must include these exact table headers:

```markdown
## Findings

| Finding ID | Classification | Finding | Source IDs | Scope implication |
|---|---|---|---|---|

## Risk register

| Risk ID | Risk | Evidence | Likelihood | Impact | Mitigation or scope response |
|---|---|---|---|---|---|

## Source ledger

| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |
|---|---|---|---|---|---|---|---|---|
```

Scope must include:

```markdown
## Product requirements

| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |
|---|---|---|---|---|

## Acceptance criteria

| Acceptance ID | Verifiable condition | Required evidence |
|---|---|---|

## Canon impact and proposed canon deltas

| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |
|---|---|---|---|---|---|---|
```

Design must include:

```markdown
## Requirement-to-design traceability

| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |
|---|---|---|---|---|

## Implementation seams and dependency order

| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |
|---|---|---|---|---|---|
```

- [ ] **Step 5: Write the role contracts and rubrics**

Keep each reference under 500 words. The producer contract must require repository inspection, evidence classification, canonical persistence, and seal-before-review. The consumer contract must require summary-first reading, historical package verification, deterministic `check` and `consume`, relevant-drift assessment, and rejection of unauthorized inference. Each rubric must contain two sections named `Content review` and `Codex consumption review`, followed by the exact formal output headings from the approved design.

- [ ] **Step 6: Add template byte and heading tests**

Extend `test_templates.py` to read each asset, parse `## ` headings with a regular expression, assert exact order, assert the first heading is `Agent handoff summary`, assert the last is `Review history`, and assert no template contains `TODO`, `TBD`, or `FIXME`.

- [ ] **Step 7: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_templates.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/assets \
  .agents/skills/ambitions-product-development-lifecycle/references \
  .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py \
  .agents/skills/ambitions-product-development-lifecycle/tests
git commit -m "feat: add lifecycle templates and contracts"
```

---

### Task 3: Implement typed models and deterministic document I/O

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/__init__.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/errors.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/markdown.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_document_io.py`

**Interfaces:**
- Consumes: `TEMPLATE_PROFILES` and template frontmatter from Task 2.
- Produces: `LifecycleDocument`, `DocumentMetadata`, `ReviewRecord`, `parse_document()`, `render_document()`, `write_document_atomic()`, `parse_markdown_table()`, and `append_history_event()`.

- [ ] **Step 1: Write failing parse/render round-trip tests**

Create a temporary Research document from the template, replace every draft sentinel with `Not applicable for this synthetic fixture.`, then assert:

```python
document = parse_document(path, repository_root=temp_root)
self.assertEqual(document.metadata.document_type, DocumentType.RESEARCH)
self.assertEqual(document.metadata.status, DocumentStatus.DRAFT)
self.assertEqual(document.sections[0].title, "Agent handoff summary")
self.assertEqual(render_document(document), path.read_text(encoding="utf-8"))
```

Also test that duplicate frontmatter keys, unterminated `+++`, an absolute repository path, and `../` traversal each raise `ProductDocsError` with stable codes.

- [ ] **Step 2: Run tests and verify failure**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_document_io.py' -v
```

Expected: FAIL because document modules do not exist.

- [ ] **Step 3: Add structured diagnostics**

Implement:

```python
@dataclass(frozen=True)
class Diagnostic:
    code: str
    message: str
    path: str | None = None
    section: str | None = None
    identifier: str | None = None
    remediation: str | None = None

    def as_dict(self) -> dict[str, object]: ...


class ProductDocsError(Exception):
    def __init__(self, diagnostics: Sequence[Diagnostic]): ...
```

Use stable uppercase codes such as `FRONTMATTER_INVALID`, `PATH_OUTSIDE_REPOSITORY`, and `HEADING_PROFILE_MISMATCH`.

- [ ] **Step 4: Add enums and dataclasses**

Implement exact string enums for document type, authority class, status, review lane, review verdict, and input kind. Add frozen dataclasses:

```python
@dataclass(frozen=True)
class InputBinding:
    kind: InputKind
    authority_id: str
    path: str
    commit: str
    revision: int | None = None
    contract_hash: str | None = None

@dataclass(frozen=True)
class EvidenceFile:
    path: str
    sha256: str
    role: str

@dataclass(frozen=True)
class DocumentMetadata:
    schema_version: int
    template_version: str
    template_hash: str
    skill_version: str
    skill_package_hash: str
    authoring_surface: str
    initiative_id: str
    document_id: str
    document_type: DocumentType
    authority_class: AuthorityClass
    entry_point: str
    status: DocumentStatus
    revision: int
    created_at: str
    updated_at: str
    repository_baseline_commit: str
    external_research_as_of: str
    contract_hash: str
    content_review_verdict: ReviewVerdict
    content_review_revision: int
    content_review_hash: str
    content_blocking_findings: int
    consumer_review_verdict: ReviewVerdict
    consumer_review_revision: int
    consumer_review_hash: str
    consumer_blocking_findings: int
    canon_targets: tuple[str, ...]
    canon_delta_ids: tuple[str, ...]
    source_owner_paths: tuple[str, ...]
    test_owner_paths: tuple[str, ...]
    dependency_paths: tuple[str, ...]
    additional_freshness_paths: tuple[str, ...]
    freshness_paths: tuple[str, ...]
    supersedes: tuple[str, ...]
    inputs: tuple[InputBinding, ...]
    evidence_files: tuple[EvidenceFile, ...]

@dataclass(frozen=True)
class Section:
    title: str
    body: str

@dataclass(frozen=True)
class LifecycleDocument:
    path: Path
    metadata: DocumentMetadata
    sections: tuple[Section, ...]
```

- [ ] **Step 5: Implement constrained TOML rendering**

Use `tomllib.loads()` for parsing. Implement a renderer that supports only the approved schema types: strings, integers, arrays of strings, `[[inputs]]`, and `[[evidence_files]]`. Escape backslash, quote, tab, carriage return, and newline. Render scalar keys in the same stable order as the templates and reject unknown fields.

- [ ] **Step 6: Implement Markdown parsing and atomic writes**

`parse_sections()` must preserve exact body text and reject duplicate or out-of-order `## ` headings. `parse_markdown_table()` returns `tuple[dict[str, str], ...]` and rejects malformed row widths. `write_document_atomic()` writes to a sibling temporary file, flushes, calls `os.fsync()`, and replaces the target with `Path.replace()`.

- [ ] **Step 7: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_document_io.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_document_io.py
git commit -m "feat: add lifecycle document model and IO"
```

---

### Task 4: Implement package and template identity

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_package_identity.py`

**Interfaces:**
- Consumes: Skill-root paths and Git repository root.
- Produces: `build_manifest()`, `canonical_manifest_bytes()`, `package_hash()`, `verify_active_package()`, `verify_historical_package()`, `GitRepository`, and `HistoricalPackageVerification`.

- [ ] **Step 1: Write failing package-manifest tests**

Assert that operational discovery includes `SKILL.md`, `agents/`, `assets/`, `references/`, and `scripts/`, excludes `tests/` and `package-manifest.json`, sorts paths, hashes exact bytes, and generates stable canonical JSON with one terminal LF.

Add a temporary Git repository test:

```python
verification = verify_historical_package(
    repository=GitRepository(temp_root),
    commit=baseline_commit,
    expected_package_hash=expected_hash,
    expected_template_path="assets/templates/v1/research.md",
    expected_template_hash=template_hash,
)
self.assertTrue(verification.supported_identity)
```

Then modify the active template, commit it, and verify the historical baseline still passes while active package verification reports the new hash.

- [ ] **Step 2: Run tests and verify failure**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_package_identity.py' -v
```

- [ ] **Step 3: Implement safe Git access**

`GitRepository` must expose:

```python
class GitRepository:
    def __init__(self, root: Path): ...
    def head(self) -> str: ...
    def is_commit_reachable(self, commit: str) -> bool: ...
    def read_bytes_at(self, commit: str, path: str) -> bytes: ...
    def changed_paths(self, base: str, head: str = "HEAD") -> tuple[str, ...]: ...
    def path_exists_at(self, commit: str, path: str) -> bool: ...
```

Run Git with `subprocess.run(..., check=False, capture_output=True)`, never a shell string. Validate commits with `^[0-9a-f]{40}$` and repository-relative paths before invocation.

- [ ] **Step 4: Implement the active manifest algorithm**

Represent manifest fields with dataclasses. Serialize using:

```python
json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8") + b"\n"
```

Compute `sha256:` plus lowercase hex. Verification must fail on missing, unlisted, extra, or hash-mismatched operational files.

- [ ] **Step 5: Implement historical verification**

Read the historical manifest at `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`, recompute its canonical bytes and package hash, then read and hash every listed file at that commit. Return structured diagnostics for unreachable baseline, missing historical manifest, manifest mismatch, missing file, and template mismatch.

- [ ] **Step 6: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_package_identity.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py \
  .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_package_identity.py
git commit -m "feat: add lifecycle package identity"
```

---

### Task 5: Implement exact contract hashing and structural validation

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py`

**Interfaces:**
- Consumes: `LifecycleDocument`, template profiles, manifest identity, and Markdown tables.
- Produces: `compute_contract_hash()`, `derive_freshness_paths()`, `validate_structure()`, `validate_sources()`, `validate_traceability()`, and `ValidationReport`.

- [ ] **Step 1: Write hash conformance tests**

Use one fixed fixture and assert these exact behaviors:

```python
base = compute_contract_hash(document)
self.assertEqual(len(base), 71)
self.assertTrue(base.startswith("sha256:"))
self.assertEqual(base, compute_contract_hash(document))
self.assertEqual(base, compute_contract_hash(with_review_history_appended(document)))
self.assertEqual(base, compute_contract_hash(with_updated_at_changed(document)))
self.assertNotEqual(base, compute_contract_hash(with_body_spelling_changed(document)))
self.assertNotEqual(base, compute_contract_hash(with_owner_path_added(document)))
```

Add a golden expected hash produced from the canonical JSON and normalized body algorithm so a future refactor cannot silently alter it.

- [ ] **Step 2: Write failing structure and sentinel tests**

Assert stable diagnostics for wrong headings, duplicate IDs, a remaining `PRODUCT-DOC-DRAFT` sentinel, empty required sections, invalid status/review combinations, manually weakened freshness, and an `Agent handoff summary` over 1,200 words.

- [ ] **Step 3: Implement the approved hash algorithm exactly**

The included projection is a plain dict with the approved identity, baseline, owner, freshness, input, evidence, and authority fields. Exclude status, revision, timestamps, contract hash, review verdicts, review hashes, and blocker counts. Remove the complete `Review history` section from the body. Serialize canonical JSON, concatenate `b"\n---BODY---\n"`, and hash UTF-8 bytes.

- [ ] **Step 4: Implement freshness derivation**

Return the sorted deduplicated union of declared canon/source/test/dependency/additional paths, every input path, every evidence path, the four exact generated canon paths when canon targets exist, the package manifest path, and the active template path. Reject absolute paths, traversal, nonexistent declared paths at the baseline, and a stored freshness array that differs from the derived result.

- [ ] **Step 5: Implement structural validation**

`ValidationReport` contains `diagnostics`, `derived_freshness_paths`, and `is_valid`. Validate exact heading order, frontmatter field sets, document type/authority pairing, IDs, status machine invariants, package/template hashes, review binding, hash syntax, source/evidence paths, and section emptiness.

- [ ] **Step 6: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_hashing_validation.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py \
  .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py
git commit -m "feat: add lifecycle hashing and validation"
```

---

### Task 6: Implement `new` and authoritative `seal`

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py`

**Interfaces:**
- Consumes: Templates, package identity, document I/O, validation, hashing, and Git baseline.
- Produces: `create_document()` and `seal_document()` with deterministic state changes.

- [ ] **Step 1: Write failing creation tests**

Test:

```python
created = create_document(
    repository_root=temp_root,
    initiative_name="Adaptive Start Here",
    phase=DocumentType.RESEARCH,
    today=date(2026, 8, 2),
)
self.assertEqual(created.path, temp_root / "docs/product-development/adaptive-start-here/research.md")
self.assertEqual(created.metadata.initiative_id, "PD-2026-08-ADAPTIVE-START-HERE")
self.assertEqual(created.metadata.revision, 1)
self.assertEqual(created.metadata.status, DocumentStatus.DRAFT)
```

Also assert overwrite refusal, invalid slug rejection, Scope refusal without passed Research, Design refusal without passed Scope, and reduced-entry refusal without typed authority inputs.

- [ ] **Step 2: Write failing seal tests**

A complete draft must seal to `sealed`, populate exact package/template hashes, derive freshness, store the contract hash, clear reviews, and append a seal event. A draft with sentinels, missing owner paths, invalid evidence hash, or stale input must remain byte-for-byte unchanged.

- [ ] **Step 3: Implement initiative identity**

Normalize Unicode to ASCII-safe lowercase words, replace non-alphanumeric runs with `-`, collapse repeats, trim boundaries, and reject an empty result. Generate `PD-YYYY-MM-<UPPERCASE-SLUG>` and append `-RESEARCH`, `-SCOPE`, or `-DESIGN` for the document ID.

- [ ] **Step 4: Implement `create_document()`**

Copy exact template bytes, populate identity, dates, current HEAD, package/template identity, type, authority class, and upstream typed binding. Do not set contract hash or freshness. Use atomic writes and refuse all existing target paths.

- [ ] **Step 5: Implement `seal_document()`**

Require `draft`, validate the active package, validate every field and table, recompute evidence hashes, derive freshness, compute contract hash, clear both review lanes, set `sealed`, append a seal history entry, and atomically replace the file. Reparse and revalidate the written file before returning success.

- [ ] **Step 6: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_transitions.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py
git commit -m "feat: add lifecycle creation and sealing"
```

---

### Task 7: Implement durable reviews, stale reconciliation, reopening, and supersession

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/markdown.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py`

**Interfaces:**
- Consumes: A sealed or content-reviewed document and one JSON review record.
- Produces: `ReviewRecord`, `record_review()`, `mark_stale()`, `reopen_document()`, and `supersede_document()`.

- [ ] **Step 1: Add failing review-state tests**

Use this exact review JSON shape:

```json
{
  "review_id": "REV-CONTENT-001",
  "lane": "content",
  "verdict": "pass",
  "reviewer_surface": "chatgpt",
  "reviewed_at": "2026-08-02T21:00:00-04:00",
  "revision": 1,
  "contract_hash": "sha256:<current-hash>",
  "blocking_findings": [],
  "non_blocking_improvements": [],
  "traceability_gaps": [],
  "stale_or_conflicting_inputs": [],
  "required_revisions": [],
  "next_permitted_phase": "consumer-review",
  "drift_assessments": []
}
```

Assert content PASS moves `sealed` to `content-reviewed`; content failure moves to `needs-revision`; consumer PASS moves `content-reviewed` to `passed`; consumer failure moves to `needs-revision`; wrong revision/hash and duplicate review IDs fail without mutation.

- [ ] **Step 2: Add failing reopen and supersede tests**

Assert `reconcile --reopen` is the only transition from `needs-revision` or `stale` to `draft`, increments revision once, clears hash/freshness/reviews, preserves prior review history, and updates only supplied validated baseline/input values. Assert supersession records replacement path/reason and makes future authority edits invalid.

- [ ] **Step 3: Implement review-history rendering**

Append:

```markdown
### REV-CONTENT-001

- Lane: `content`
- Verdict: `pass`
- Reviewer surface: `chatgpt`
- Reviewed at: `2026-08-02T21:00:00-04:00`
- Revision: `1`
- Contract hash: `sha256:...`

#### Blocking findings

None.
```

Render all six formal review sections in fixed order. Preserve previous entries byte-for-byte.

- [ ] **Step 4: Implement transition guards and atomic writes**

Content review requires `sealed`; consumer review requires `content-reviewed`; a passing review requires zero blocking findings and the expected next phase. A failing review requires at least one blocking finding. Reparse and validate after every write.

- [ ] **Step 5: Run transition tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_transitions.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py
git commit -m "feat: add lifecycle reviews and reconciliation"
```

---

### Task 8: Enforce Research sources, Scope requirements, Design traceability, and canon deltas

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/markdown.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py`

**Interfaces:**
- Consumes: Exact Markdown tables from Task 2.
- Produces: Stable ID indexes and cross-document traceability diagnostics used by `seal` and `consume`.

- [ ] **Step 1: Write failing Research evidence tests**

Require every `FIND-*` to reference existing `SRC-*` or an exact repository path. Validate source ID uniqueness, ISO access date, `stable|slow|current` temporal sensitivity, nonempty recheck trigger, supported IDs, and evidence summary. Reject a current source whose ISO recheck date is before the consumer date.

- [ ] **Step 2: Write failing Scope traceability tests**

Require every `REQ-*` to cite a passed Research `FIND-*` or typed authority input, name an owner domain, and map to one or more existing `AC-*`. Require every `AC-*` to be referenced by at least one requirement. Reject duplicate, malformed, and orphan IDs.

- [ ] **Step 3: Write failing Design traceability tests**

Require every Scope requirement and acceptance criterion in the matrix, every `DESIGN-*` to map to `REQ-*`, `AC-*`, and `VERIFY-*`, and every implementation seam to map to verification IDs. Reject any `CANON-DELTA-*` missing current authority, proposed change, rationale, migration/compatibility impact, or proof obligation.

- [ ] **Step 4: Implement normalized ID indexes**

Use anchored patterns:

```python
ID_PATTERNS = {
    "finding": re.compile(r"^FIND-[0-9]{3}$"),
    "source": re.compile(r"^SRC-[0-9]{3}$"),
    "risk": re.compile(r"^RISK-[0-9]{3}$"),
    "requirement": re.compile(r"^REQ-[0-9]{3}$"),
    "acceptance": re.compile(r"^AC-[0-9]{3}$"),
    "design": re.compile(r"^DESIGN-[0-9]{3}$"),
    "verification": re.compile(r"^VERIFY-[0-9]{3}$"),
    "canon_delta": re.compile(r"^CANON-DELTA-[0-9]{3}$"),
    "seam": re.compile(r"^SEAM-[0-9]{3}$"),
}
```

Split multi-ID cells on comma, trim whitespace, reject empty tokens, and preserve stable IDs across revisions.

- [ ] **Step 5: Run validation tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_hashing_validation.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py
git commit -m "feat: enforce lifecycle traceability"
```

---

### Task 9: Implement repository freshness and Codex consumption

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py`

**Interfaces:**
- Consumes: Passed upstream documents, evidence hashes, historical package identity, current compatibility declaration, baseline commit, and derived freshness paths.
- Produces: `ConsumptionReport` and `consume_document()` with deterministic blockers plus explicit semantic-review paths.

- [ ] **Step 1: Write failing input and evidence drift tests**

Create temporary Git histories and assert that changed upstream contract hash, changed evidence bytes, missing passed status, unreachable baseline, unsupported template version, and unverifiable historical package each produce one stable blocking diagnostic.

- [ ] **Step 2: Write relevant versus unrelated drift tests**

Given baseline `A` and head `B`, change one file outside freshness and assert `ConsumptionReport.unrelated_changed_paths` contains it while `requires_semantic_review` remains false. Change a source-owner path and assert `relevant_changed_paths` contains it and a consumer PASS cannot be recorded without a matching drift assessment.

- [ ] **Step 3: Define consumption models**

```python
@dataclass(frozen=True)
class DriftAssessment:
    path: str
    impact: str  # exactly "none" or "material"
    rationale: str

@dataclass(frozen=True)
class ConsumptionReport:
    document_path: str
    revision: int
    contract_hash: str
    baseline_commit: str
    head_commit: str
    relevant_changed_paths: tuple[str, ...]
    unrelated_changed_paths: tuple[str, ...]
    diagnostics: tuple[Diagnostic, ...]
    requires_semantic_review: bool
    can_pass: bool
```

- [ ] **Step 4: Implement path-prefix intersection**

A freshness path ending in `/` matches every descendant. A file freshness path matches only that exact path. Normalize separators and reject case-folding assumptions. Return sorted unique changed paths.

- [ ] **Step 5: Implement `consume_document()`**

Perform checks in this order: canonical path; structure/hash; historical package; current contract compatibility; typed upstream inputs; evidence files; source expiry; baseline reachability; freshness diff; canon/source delta declarations. Deterministic blockers set `can_pass = False`. Relevant drift without deterministic contradiction sets `requires_semantic_review = True` and requires one `DriftAssessment` per changed path before consumer PASS.

- [ ] **Step 6: Integrate consumer review guard**

When `record_review()` receives consumer PASS, rerun `consume_document()`. Refuse PASS when `can_pass` is false, when a relevant path lacks an assessment, or when any supplied assessment says `material`. Append accepted no-impact assessments into the review-history record.

- [ ] **Step 7: Run tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_consume.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py
git commit -m "feat: add lifecycle consumption checks"
```

---

### Task 10: Expose the complete CLI and stable JSON contract

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_cli.py`

**Interfaces:**
- Consumes: All domain operations from Tasks 3–9.
- Produces: Executable commands `package`, `new`, `check`, `hash`, `seal`, `review`, `reconcile`, `consume`, and `supersede`.

- [ ] **Step 1: Write failing parser and exit-code tests**

Test `build_parser()` exposes every command and that `main(argv, repository_root=temp_root)` returns:

- `0` for success;
- `1` for document/validation failure;
- `2` for command usage errors;
- `3` for unsupported Python or inaccessible repository state.

Assert `--json` output is one JSON object with keys `command`, `status`, `document`, `changes`, `diagnostics`, and `next_action`.

- [ ] **Step 2: Define exact command syntax**

Implement:

```text
package --check|--write [--json]
new --initiative NAME --phase research|scope|design [--initiative-id ID] [--input PATH] [--json]
check PATH|--initiative DIR|--all [--json]
hash PATH [--json]
seal PATH [--json]
review PATH --review-file JSON [--json]
reconcile PATH --mark-stale --reason-file TEXT [--json]
reconcile PATH --reopen [--baseline SHA] [--input PATH] [--json]
consume PATH [--json]
supersede PATH --replacement PATH --reason-file TEXT [--json]
```

Require mutually exclusive selectors and reject missing files before domain calls.

- [ ] **Step 3: Implement the thin entrypoint**

Use the same version posture as `scripts/ambitions-canon.py`:

```python
#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

if not (3, 11) <= sys.version_info[:2] < (3, 15):
    print("PYTHON_VERSION_UNSUPPORTED requires Python 3.11-3.14", file=sys.stderr)
    raise SystemExit(3)

sys.path.insert(0, str(Path(__file__).resolve().parent))
from product_docs.cli import main

raise SystemExit(main())
```

- [ ] **Step 4: Prove read-only commands do not mutate**

For `package --check`, `check`, `hash`, and `consume`, snapshot every file’s SHA-256 before and after and assert equality. Include failure paths.

- [ ] **Step 5: Run CLI tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_cli.py' -v
git add .agents/skills/ambitions-product-development-lifecycle/scripts \
  .agents/skills/ambitions-product-development-lifecycle/tests/test_cli.py
git commit -m "feat: expose lifecycle CLI"
```

---

### Task 11: Write the minimal skill, metadata, package manifest, and repository routing

**Files:**
- Create: `.agents/skills/ambitions-product-development-lifecycle/SKILL.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/agents/openai.yaml`
- Create: `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`
- Modify: `AGENTS.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`

**Interfaces:**
- Consumes: Baseline failures, all contracts, templates, and CLI commands.
- Produces: Discoverable skill, ChatGPT invocation metadata, active manifest, contributor routing, and end-to-end acceptance tests.

- [ ] **Step 1: Write failing skill-surface tests**

Assert `SKILL.md` frontmatter name and description are exact, word count is below 500, every required reference and template path exists, and the body routes rather than duplicating all detailed contracts. Assert `AGENTS.md` still contains the no-process-gates statement.

- [ ] **Step 2: Write `SKILL.md`**

Use this exact frontmatter:

```yaml
---
name: ambitions-product-development-lifecycle
description: Use when creating, reviewing, or consuming an Ambitions research, scope, or design document for a material product, UX, or architecture change; do not use for routine work whose behavior is already canonical.
---
```

The body must contain sections `Choose the role`, `Producer`, `Content review`, `Consumer`, `Lifecycle boundaries`, and `Commands`. Require the producer/consumer contracts and phase rubric by name. State that no implementation starts from Research or Scope and no document PASS authorizes merge.

- [ ] **Step 3: Write `agents/openai.yaml`**

Use this metadata and validate it with the current installed skill tooling before commit:

```yaml
interface:
  display_name: "Ambitions Product Development"
  short_description: "Create, review, and consume Ambitions lifecycle documents."
  default_prompt: "Use $ambitions-product-development-lifecycle to create, review, or consume the correct Research, Scope, or Design document for this material Ambitions initiative."
policy:
  allow_implicit_invocation: true
```

If the installed validator rejects a field name, use the validator’s current official field name, update the metadata test to that exact schema, and record the validator command and output in final validation evidence. Do not add undocumented fields.

- [ ] **Step 4: Add concise `AGENTS.md` routing**

Insert after `## Product documentation`:

```markdown
For a material new product, UX, or architecture initiative whose behavior is not
already resolved by current canon, use the repository skill
`ambitions-product-development-lifecycle`. ChatGPT authors the canonical Research,
Scope, and Design files; Codex performs the consumer review before each downstream
phase. This is a quality workflow, not edit or merge authorization.
```

- [ ] **Step 5: Generate the active package manifest**

Run:

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py \
  package --write
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py \
  package --check
```

Expected: Both commands succeed; `package-manifest.json` lists every operational file and declares support for schema `1` and `research-v1`, `scope-v1`, `design-v1`.

- [ ] **Step 6: Build the end-to-end acceptance suite**

In `test_ambitions_product_docs.py`, create a temporary Git repository, copy the complete skill package, write the active manifest, create Research, replace sentinels, seal it, content-pass it, consumer-pass it, create Scope from the passed Research, and assert the typed input contains Research revision/hash/commit. Repeat through Design and assert a relevant source change produces semantic review while an unrelated docs change does not.

- [ ] **Step 7: Run all skill tests and commit**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_*.py' -v
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check
git add .agents/skills/ambitions-product-development-lifecycle AGENTS.md
git commit -m "feat: install product development lifecycle skill"
```

---

### Task 12: Rerun pressure scenarios and prove the ChatGPT-to-Codex fixture

**Files:**
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md`
- Create: `docs/product-development/lifecycle-fixture/research.md`
- Create: `docs/product-development/lifecycle-fixture/scope.md`
- Create: `docs/product-development/lifecycle-fixture/design.md`
- Create: `docs/product-development/lifecycle-fixture/evidence/comparison.md`

**Interfaces:**
- Consumes: The exact Task 1 corpus and the installed package hash from Task 11.
- Produces: Before/after behavior proof and one canonical fixture chain created through the ChatGPT producer path and consumed through Codex.

- [ ] **Step 1: Rerun the unchanged corpus with fresh agents**

Dispatch one fresh agent per scenario, require it to load `SKILL.md`, and save the complete response. Score against the unchanged `required_behaviors`. Every required behavior must pass. When a behavior fails, add a failing pressure test before editing the skill or contracts, make the minimum correction, regenerate the package manifest, and rerun only the failed scenario plus one neighboring scenario.

- [ ] **Step 2: Create the local evidence annex**

Write `evidence/comparison.md` as a synthetic comparison of two lifecycle approaches. It must contain no real user data, credentials, or private Ambitions content. Record its exact SHA-256 in Research frontmatter.

- [ ] **Step 3: Author Research through the ChatGPT producer path**

In a fresh ChatGPT context, explicitly load the active manifest, `SKILL.md`, Research template, producer contract, and Research rubric from the repository. Provide only the synthetic fixture idea and repository access. ChatGPT must create the canonical Research file, classify all claims, use `FIND-*`, `SRC-*`, and `RISK-*`, declare owner paths, and stop at draft.

Run:

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py seal \
  docs/product-development/lifecycle-fixture/research.md
```

Then perform content review in a fresh ChatGPT context and record it through `review --review-file`. Perform consumer review in a fresh Codex context and record it. Research must reach `passed`.

- [ ] **Step 4: Author and pass Scope**

Create Scope through the same ChatGPT producer path from only the passed Research file, current repo, and active package. Require typed input binding to Research, complete `REQ-*`/`AC-*` mapping, explicit in/out scope, and zero product-invention open decisions. Seal, content-review, and Codex-consumer-review it to `passed`.

- [ ] **Step 5: Author and pass Design**

Create Design from only the passed Scope file, current repo, and active package. Require complete design/verification traceability, ownership, failure/recovery, source delta, canon reconciliation plan, implementation seams, and proof boundaries. Seal and pass both reviews.

- [ ] **Step 6: Prove relevant and unrelated drift behavior**

Create one temporary branch commit changing an unrelated QA note and capture `consume --json` showing no staleness. Create a second temporary commit changing one declared fixture source-owner path and capture `consume --json` requiring semantic assessment. Reset the temporary branch after capturing evidence; do not alter main history for synthetic drift.

- [ ] **Step 7: Write cross-product evidence and commit**

Record the package/template hashes, document IDs/revisions/hashes, ChatGPT producer inputs, Codex read order, commands, statuses, drift results, and explicit statement that Codex did not receive the originating chat. Then commit:

```bash
git add docs/product-development/lifecycle-fixture \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md
git commit -m "test: validate lifecycle skill across ChatGPT and Codex"
```

---

### Task 13: Final validation, self-review, and handoff

**Files:**
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md`
- Modify only when validation finds a defect: files created in Tasks 2–12.

**Interfaces:**
- Consumes: Complete package, tests, pressure evidence, and fixture chain.
- Produces: Final implementation evidence and a clean implementation-ready repository state.

- [ ] **Step 1: Run the complete deterministic suite**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_*.py' -v
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check \
  --initiative docs/product-development/lifecycle-fixture
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume \
  docs/product-development/lifecycle-fixture/design.md --json
python3 scripts/ambitions-canon.py check
git diff --check
```

Expected: Every command exits `0`; Design consumption reports `can_pass: true` and no blocking diagnostics.

- [ ] **Step 2: Verify read-only behavior**

Record `git status --porcelain` and SHA-256 for every lifecycle file, rerun `package --check`, `check`, `hash`, and `consume`, then assert status and hashes are unchanged.

- [ ] **Step 3: Run the plan self-review against the approved specification**

Create a coverage table in `validation.md` with one row for every approved design section: package identity, ChatGPT deployment, producer, content review, consumer, canonical persistence, typed inputs, status machine, hash, handoff summary, freshness, Research, Scope, Design, consume, CLI, canon reconciliation, package evolution, pressure testing, security/privacy, and acceptance criteria. Map each to implementation files and test names.

- [ ] **Step 4: Scan for forbidden placeholders and process gates**

```bash
rg -n "TODO|TBD|FIXME|implement later|conditional pass|authorization receipt|merge authorization" \
  .agents/skills/ambitions-product-development-lifecycle \
  docs/product-development/lifecycle-fixture \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation
```

Expected: No unresolved placeholder matches. References explaining that merge authorization is forbidden are permitted and must be identified in `validation.md`.

- [ ] **Step 5: Record proof ceiling**

State that the fixture proves deterministic package identity, document creation, sealing, reviews, traceability, drift handling, historical verification, and ChatGPT-to-Codex handoff. State that it does not prove the quality of every future initiative or replace product, code, runtime, accessibility, privacy, performance, or release verification.

- [ ] **Step 6: Commit final validation**

```bash
git add docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md
git commit -m "test: close lifecycle skill validation"
```

- [ ] **Step 7: Report completion**

Report exact changed files, commits, package hash, template hashes, test commands/results, pressure-scenario result, cross-product fixture IDs, remaining follow-up adoption work, and confirmation that no Code Quality workflow or branch-protection gate was added.

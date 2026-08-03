# Simplified Product-Development Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the strict lifecycle state machine with a conversational Research → Scope → Design → implementation-grooming workflow backed by three templates and a lightweight `new`/`check` command.

**Architecture:** Keep the repository skill, Markdown templates, thin Python entrypoint, and standard-library tests. Replace package identity, sealing, hashing, formal reviews, freshness replay, and historical transitions with a small document parser and structural validator. Repository files under `docs/product-development/<initiative>/` are the only durable handoff.

**Tech Stack:** Python 3.11–3.14 standard library, Markdown with TOML frontmatter, `argparse`, `dataclasses`, `pathlib`, `tomllib`, `unittest`, Git.

## Global Constraints

- Implement `docs/superpowers/specs/2026-08-03-simplified-product-development-lifecycle-design.md` exactly.
- Supported statuses are only `draft` and `approved`.
- Approval requires Devan's explicit approval and a blocking-free ChatGPT review; the file stores only the resulting status.
- Canonical initiative files live under `docs/product-development/<initiative>/`.
- The only CLI commands are `new` and `check`.
- Do not introduce seals, hashes, review JSON, provenance packets, isolated-session requirements, consumer lanes, freshness replay, authorization receipts, or merge gates.
- Do not modify `.github/workflows/code-quality.yml`.
- Preserve canon, privacy, security, accessibility, migration, runtime, and Code Quality requirements.

---

### Task 1: Replace the user-facing skill, templates, and review guidance

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/SKILL.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/agents/openai.yaml`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/design.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/references/design-review-rubric.md`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/references/consumer-contract.md`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_templates.py`

**Interfaces:**
- Consumes: approved simplified design.
- Produces: three deterministic templates using `initiative`, `document_type`, `status`, and `upstream`; conversational create/review/approve/groom guidance.

- [ ] **Step 1: Write failing template tests**

```python
EXPECTED_HEADINGS = {
    "research": ("Idea and user problem", "Current truth", "Evidence", "Alternatives", "Unknowns and risks", "Recommended direction"),
    "scope": ("Outcome", "In scope", "Out of scope", "Requirements", "Acceptance criteria", "Canon impact", "Risks and open decisions"),
    "design": ("Design summary", "User flows", "States and recovery", "Architecture and data", "Privacy and accessibility", "Requirement traceability", "Verification design", "Open decisions"),
}

def test_templates_use_simple_metadata():
    for phase, headings in EXPECTED_HEADINGS.items():
        contents = template_path(phase).read_text(encoding="utf-8")
        self.assertIn('status = "draft"', contents)
        self.assertNotIn("contract_hash", contents)
        self.assertNotIn("freshness_paths", contents)
        self.assertEqual(extracted_headings(contents), list(headings))
```

- [ ] **Step 2: Run tests and verify legacy-template failures**

Run: `python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_templates.py' -v`

Expected: failures for legacy metadata, headings, and role instructions.

- [ ] **Step 3: Implement templates and guidance**

Use this exact metadata shape:

```toml
+++
initiative = ""
document_type = "research"
status = "draft"
upstream = ""
+++
```

Scope defaults `upstream = "research.md"`; Design defaults `upstream = "scope.md"`. The skill exposes create, review, approve, and groom modes. Rubrics return `PASS` or `NEEDS REVISION` in prose.

- [ ] **Step 4: Run tests and commit**

Run the Step 2 command and `git diff --check`; expect exit 0.

```bash
git add .agents/skills/ambitions-product-development-lifecycle
git commit -m "docs: simplify product development templates"
```

---

### Task 2: Replace the lifecycle model with simple parsing and validation

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_document_io.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_validation.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py`

**Interfaces:**
- Consumes: Task 1 metadata and headings.
- Produces: `ProductDocument`, `ValidationResult`, `parse_document(path)`, `validate_document(document)`, `validate_initiative(path)`.

- [ ] **Step 1: Write failing parser and validator tests**

```python
def test_parse_simple_document():
    document = parse_document(research_path)
    self.assertEqual(document.document_type, DocumentType.RESEARCH)
    self.assertEqual(document.status, DocumentStatus.DRAFT)
    self.assertEqual(document.upstream, "")

def test_approved_document_rejects_placeholders():
    result = validate_document(parse_document(incomplete_approved_path))
    self.assertIn("approved-placeholder", {item.code for item in result.diagnostics})
```

- [ ] **Step 2: Run focused tests and verify failure**

Run:

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_document_io.py' -v
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_validation.py' -v
```

Expected: failures because legacy metadata remains required.

- [ ] **Step 3: Implement minimal types and parsing**

```python
class DocumentStatus(str, Enum):
    DRAFT = "draft"
    APPROVED = "approved"

@dataclass(frozen=True)
class ProductDocument:
    initiative: str
    document_type: DocumentType
    status: DocumentStatus
    upstream: str
    sections: tuple[Section, ...]
    source_path: Path

@dataclass(frozen=True)
class ValidationResult:
    valid: bool
    diagnostics: tuple[Diagnostic, ...]
```

`parse_document` accepts only the four metadata keys, preserves section text, rejects duplicate headings, and reports malformed TOML as `invalid-frontmatter`. `validate_document` enforces canonical filename, required headings, valid metadata, and placeholder rejection for approved documents.

- [ ] **Step 4: Implement initiative ordering**

`validate_initiative(directory)` adds `research-not-approved` when approved Scope lacks approved Research, `scope-not-approved` when approved Design lacks approved Scope, and `invalid-upstream` unless Scope uses `research.md` and Design uses `scope.md`.

- [ ] **Step 5: Run focused tests and commit**

Run both focused commands from Step 2.

```bash
git add .agents/skills/ambitions-product-development-lifecycle/scripts/product_docs .agents/skills/ambitions-product-development-lifecycle/tests
git commit -m "refactor: simplify product document validation"
```

---

### Task 3: Reduce the CLI to `new` and `check`

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`
- Replace: `.agents/skills/ambitions-product-development-lifecycle/tests/test_cli.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/tests/test_package_identity.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py`

**Interfaces:**
- Consumes: Task 2 parser and validation functions.
- Produces: `new PHASE --initiative SLUG [--json]` and `check PATH [--json]`.

- [ ] **Step 1: Write failing command-shape tests**

```python
def test_parser_exposes_only_new_and_check():
    self.assert_command_succeeds("new", "research", "--initiative", "example")
    self.assert_command_succeeds("check", "docs/product-development/example")
    for removed in ("package", "hash", "seal", "review", "reconcile", "consume", "supersede"):
        self.assert_command_usage_error(removed)
```

- [ ] **Step 2: Run CLI tests and verify failure**

Run: `python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_cli.py' -v`

Expected: failures because legacy commands remain.

- [ ] **Step 3: Implement `new`**

`new research --initiative example` creates `docs/product-development/example/research.md`. Scope and Design require their upstream file and set the correct relative upstream. Existing targets fail with `document-exists`. Slugs match `[a-z0-9]+(?:-[a-z0-9]+)*`.

- [ ] **Step 4: Implement `check` and stable JSON**

```json
{"command":"check","status":"success","documents":[{"path":"docs/product-development/example/research.md","type":"research","status":"approved"}],"diagnostics":[],"next_action":"create scope"}
```

`check` accepts one Markdown file or initiative directory. Exit 1 means validation diagnostics, 2 usage error, and 3 repository unavailable.

- [ ] **Step 5: Delete legacy modules/tests, update the installed-surface test, run the full suite, and commit**

Run: `python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v`

Expected: all remaining tests pass and no import references deleted modules.

```bash
git add -A .agents/skills/ambitions-product-development-lifecycle
git commit -m "refactor: reduce product document CLI"
```

---

### Task 4: Add Design traceability and grooming validation

**Files:**
- Modify: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_grooming.py`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`

**Interfaces:**
- Consumes: approved phase documents and Task 2 validation.
- Produces: requirement/Design traceability and grooming-file diagnostics.

- [ ] **Step 1: Write failing traceability and grooming tests**

```python
def test_design_must_trace_every_scope_requirement():
    result = validate_initiative(fixture_with_unmapped_req_002)
    self.assertIn("missing-design-traceability", codes(result))

def test_started_grooming_requires_all_three_files():
    write("implementation/plan.md", "# Plan\nBody.\n")
    self.assertIn("missing-grooming-file", codes(validate_initiative(initiative)))

def test_complete_idea_to_grooming_fixture_passes():
    self.assertTrue(validate_initiative(complete_fixture()).valid)
```

- [ ] **Step 2: Run focused tests and verify failure**

Run: `python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_grooming.py' -v`

Expected: failures because grooming validation is absent.

- [ ] **Step 3: Implement the checks**

Parse `REQ-[0-9]{3}` from Scope's Requirements and Design's Requirement traceability. Every Scope ID must occur in Design traceability. When `implementation/` or any grooming file exists, require exactly `plan.md`, `tasks.md`, and `verification.md`, each with a nonempty top-level heading and body.

- [ ] **Step 4: Run focused/full tests and commit**

Run the Step 2 command, then the full discovery command from Task 3.

```bash
git add .agents/skills/ambitions-product-development-lifecycle
git commit -m "feat: validate implementation grooming"
```

---

### Task 5: Replace the strict fixture and obsolete evidence

**Files:**
- Modify: `docs/product-development/lifecycle-fixture/research.md`
- Modify: `docs/product-development/lifecycle-fixture/scope.md`
- Modify: `docs/product-development/lifecycle-fixture/design.md`
- Create: `docs/product-development/lifecycle-fixture/implementation/plan.md`
- Create: `docs/product-development/lifecycle-fixture/implementation/tasks.md`
- Create: `docs/product-development/lifecycle-fixture/implementation/verification.md`
- Delete: `docs/product-development/lifecycle-fixture/evidence/comparison.md`
- Delete: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/SKILL.md`
- Modify: `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`
- Delete: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: Tasks 1–4.
- Produces: one concise approved fixture and contributor guidance.

- [ ] **Step 1: Replace the fixture**

Use initiative `lifecycle-fixture`, approved statuses, exact upstream links, Scope requirements `REQ-001` and `REQ-002`, and Design traceability covering both. Keep it synthetic and documentation-only.

- [ ] **Step 2: Add grooming documents**

The plan names the documentation-only boundary; tasks map to both Design decisions; verification states that structural fixture proof is not runtime or release proof.

- [ ] **Step 3: Delete strict-lifecycle evidence and update `AGENTS.md`**

Contributor guidance describes phase order, human-plus-ChatGPT approval, and grooming outputs. It must not mention seals, hashes, formal reviews, or process authorization.

- [ ] **Step 4: Run final validation**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/lifecycle-fixture --json
python3 scripts/ambitions-canon.py check
rg -n --glob '!**/tests/**' "contract_hash|freshness_paths|consumer_review|review-file|provenance packet" .agents/skills/ambitions-product-development-lifecycle docs/product-development/lifecycle-fixture AGENTS.md
git diff --check
```

Expected: tests, fixture, canon, and diff checks exit 0. The marker scan excludes regression-test literals and returns no matches.

- [ ] **Step 5: Commit**

```bash
git add -A AGENTS.md .agents/skills/ambitions-product-development-lifecycle docs/product-development/lifecycle-fixture docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation
git commit -m "feat: install simplified product development lifecycle"
```

---

## Final review and integration

1. Run a whole-branch review against `18956eee3` using the most capable reviewer.
2. Permit one final fix wave for blocking or important findings, then re-review.
3. Run `superpowers:verification-before-completion` with the full test, fixture, canon, marker, and diff commands.
4. Use `superpowers:finishing-a-development-branch` to present integration options.

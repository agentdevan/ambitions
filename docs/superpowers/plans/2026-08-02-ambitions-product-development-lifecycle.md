# Ambitions Product Development Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and validate one portable Ambitions skill that lets ChatGPT author canonical Research, Scope, and Design documents and lets Codex deterministically review, consume, reconcile, and hand those committed documents into implementation grooming without hidden chat context or product invention.

**Architecture:** Keep the complete operational package under `.agents/skills/ambitions-product-development-lifecycle/` so the package manifest covers every instruction, reference, template, and executable module used by ChatGPT or Codex. Use a thin executable entrypoint plus focused Python modules under `scripts/product_docs/`; immutable Markdown templates define document shape, while one standard-library CLI owns package identity, parsing, contract hashing, lifecycle transitions, review records, committed-input binding, repository freshness, and consumer diagnostics.

**Tech Stack:** Python 3.11–3.14 standard library (`argparse`, `dataclasses`, `datetime`, `enum`, `hashlib`, `json`, `os`, `pathlib`, `re`, `subprocess`, `tempfile`, `tomllib`, `unittest`), Markdown with TOML frontmatter, YAML metadata, Git CLI, existing Ambitions canon compiler.

## Global Constraints

- The approved specification is `docs/superpowers/specs/2026-08-02-ambitions-product-development-lifecycle-design.md` at approval commit `075670830fa32ab7f3f67373b6ef917b8b3781e8`.
- Run the pre-skill pressure baseline before creating `SKILL.md`, lifecycle templates, or behavior-bearing lifecycle references.
- Baseline agents receive current `AGENTS.md`, the scenario prompt, and only the minimum neutral Ambitions context required by that prompt. They must not receive the approved lifecycle design, this implementation plan, future expected-behavior names, or future skill paths.
- Use Python 3.11–3.14 and the standard library only; add no Python package dependency.
- The canonical handoff is a committed repository file under `docs/product-development/<initiative-slug>/`, never chat history, an attachment, an untracked file, or an uncommitted worktree edit.
- ChatGPT is the producer; Codex performs the actual consumer review for every phase.
- Research, Scope, and Design authority classes are respectively `evidence`, `product-commitment`, and `implementation-design`.
- Only `draft` documents are authority-editable; every reviewable revision must be sealed first.
- Formal review outcomes are exactly `PASS` or `NEEDS REVISION`; there is no conditional pass.
- Every review binds to one revision and one deterministic `sha256:` contract hash.
- Package identity, template identity, document hash, evidence hashes, input bindings, and derived freshness must be reproducible.
- Relevant repository drift blocks or requires an explicit consumer assessment; unrelated drift does not invalidate a document.
- Declared canon/source deltas are permitted; undeclared conflicts block passage.
- Product-development documents remain pre-canon provenance and never override newer canon.
- Initial delivery does not modify `.github/workflows/code-quality.yml` or add a branch-protection check.
- Do not migrate historical documents.
- Do not weaken canon, tests, security, privacy, accessibility, or Code Quality checks.

---

## File Structure

### Canonical skill package

- Create: `.agents/skills/ambitions-product-development-lifecycle/SKILL.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/package-manifest.json`
- Create: `.agents/skills/ambitions-product-development-lifecycle/agents/openai.yaml`
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/research.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/scope.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/assets/templates/v1/design.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/lifecycle-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/producer-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/consumer-contract.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/research-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/scope-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/references/design-review-rubric.md`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/__init__.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/constants.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/errors.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/models.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/toml_codec.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/markdown.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/documents.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/package_identity.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/hashing.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/repository.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/validation.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/transitions.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/scripts/product_docs/cli.py`

### Tests and proof

- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/support.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_templates.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_document_io.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_package_identity.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_hashing_validation.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_transitions.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_consume.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_cli.py`
- Create: `.agents/skills/ambitions-product-development-lifecycle/tests/test_ambitions_product_docs.py`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/post-skill.md`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/cross-product.md`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md`
- Create: `docs/product-development/lifecycle-fixture/research.md`
- Create: `docs/product-development/lifecycle-fixture/scope.md`
- Create: `docs/product-development/lifecycle-fixture/design.md`
- Create: `docs/product-development/lifecycle-fixture/evidence/comparison.md`
- Modify: `AGENTS.md`

---

### Task 1: Capture the pre-skill failing baseline

**Files:**
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json`
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md`

**Interfaces:**
- Consumes: Current `AGENTS.md`, neutral Ambitions product context, and scenario prompts only.
- Produces: Stable scenario IDs and observed failure codes reused unchanged in Task 10.

- [ ] **Step 1: Create the immutable scenario corpus**

Write this exact corpus:

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
      "prompt": "Write the Research document only in chat. Do not create or commit a repository file; Codex can use this conversation later.",
      "required_behaviors": ["reject_chat_as_canonical_handoff", "require_committed_canonical_path"]
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
      "prompt": "Consume this Design without its Research, Scope, repository baseline, or originating chat and begin implementation.",
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

- [ ] **Step 2: Run fresh baseline agents without future lifecycle guidance**

For each scenario, dispatch one fresh read-only agent. Give it current `AGENTS.md`, the scenario prompt, and only neutral facts required to understand Ambitions as a local-first native iPhone app. Do not provide the approved lifecycle design, this plan, any future skill file, or the `required_behaviors` array.

- [ ] **Step 3: Record and score every response**

Save each complete response under its scenario ID in `baseline.md`. Add a scoring table with `Required behavior`, `Observed`, and `Evidence`. Mark `Observed` as `PASS` or `FAIL`. The baseline satisfies documentation TDD only when at least one required behavior fails. If all pass, increase pressure in the same scenario without teaching the intended solution, then rerun that scenario.

- [ ] **Step 4: Commit the baseline before creating skill behavior**

```bash
git add docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/scenario-corpus.json \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/baseline.md
git commit -m "test: record lifecycle skill baseline failures"
```

---

### Task 2: Install immutable templates, contracts, and test support

**Files:**
- Create: all `assets/templates/v1/*.md`
- Create: all six `references/*.md`
- Create: `scripts/product_docs/constants.py`
- Create: `tests/support.py`
- Create: `tests/test_templates.py`

**Interfaces:**
- Consumes: Task 1 failure evidence and the approved design section contracts.
- Produces: `TEMPLATE_PROFILES`, deterministic draft sentinels, temporary Git fixtures, and exact producer/consumer rubrics.

- [ ] **Step 1: Write failing template-profile tests**

Create `test_templates.py` that adds the resolved `scripts` directory to `sys.path` and imports `product_docs.constants`. Assert exact profiles: Research has 18 headings, Scope has 22, Design has 28; every profile starts with `Agent handoff summary` and ends with `Review history`; Design heading index 22 is `Canon reconciliation plan`.

- [ ] **Step 2: Run the test and confirm the missing-module failure**

```bash
python3 -m unittest discover \
  -s .agents/skills/ambitions-product-development-lifecycle/tests \
  -p 'test_templates.py' -v
```

Expected: import failure for `product_docs.constants`.

- [ ] **Step 3: Create constants and exact heading profiles**

Define `SKILL_NAME`, `SKILL_VERSION = "1.0.0"`, Python floor/ceiling, repository-relative roots, the four generated canon paths, allowed status values, authority mapping, and the exact Research/Scope/Design heading tuples from the approved design.

- [ ] **Step 4: Create reusable temporary-repository support**

Implement `tests/support.py` with:

```python
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class TemporaryRepositoryTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self._temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self._temporary_directory.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Ambitions Test"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "ambitions-test@example.invalid"], check=True)

    def tearDown(self) -> None:
        self._temporary_directory.cleanup()

    def commit_all(self, message: str) -> str:
        subprocess.run(["git", "-C", str(self.root), "add", "-A"], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-q", "-m", message], check=True)
        result = subprocess.run(
            ["git", "-C", str(self.root), "rev-parse", "HEAD"],
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()
```

Add `copy_skill_skeleton(destination: Path)` that copies only the active test fixture’s operational files.

- [ ] **Step 5: Create exact version-1 templates**

Use all shared frontmatter fields from the approved design. A new template has `status = "draft"`, revision `1`, empty hash/review/freshness fields, and `<!-- PRODUCT-DOC-DRAFT: SECTION_NAME -->` in every unfinished required section. Use these exact tables:

```markdown
## Findings
| Finding ID | Classification | Finding | Source IDs | Scope implication |
|---|---|---|---|---|

## Source ledger
| Source ID | Title or repository path | Publisher | URL | Accessed | Temporal sensitivity | Recheck trigger | Supports | Evidence summary |
|---|---|---|---|---|---|---|---|---|

## Product requirements
| Requirement ID | Observable obligation | Owner domain | Finding or authority IDs | Acceptance IDs |
|---|---|---|---|---|

## Acceptance criteria
| Acceptance ID | Verifiable condition | Required evidence |
|---|---|---|

## Canon impact and proposed canon deltas
| Canon delta ID | Current authority | Proposed change | Rationale | Requirement IDs | Migration or compatibility impact | Proof obligation |
|---|---|---|---|---|---|---|

## Requirement-to-design traceability
| Finding or authority ID | Requirement ID | Acceptance ID | Design ID | Verification ID |
|---|---|---|---|---|

## Implementation seams and dependency order
| Seam ID | Responsibility | Consumes | Produces | Depends on | Verification IDs |
|---|---|---|---|---|---|
```

- [ ] **Step 6: Create concise contracts and rubrics**

Keep each reference under 500 words. Producer: repository inspection, source classification, self-contained file, canonical commit, seal-before-review. Consumer: active instruction chain, summary-first read order, historical package verification, current contract compatibility, committed-input verification, relevant-drift inspection, and refusal of unauthorized inference. Each phase rubric has `Content review`, `Codex consumption review`, exact PASS/NEEDS REVISION output, and owner-path completeness checks.

- [ ] **Step 7: Add byte and heading tests, run, and commit**

Assert exact headings, required tables, draft sentinels, no duplicate headings, and no unresolved executable instruction in the references. Then run the template test and commit all Task 2 files.

```bash
git commit -m "feat: add lifecycle templates and contracts"
```

---

### Task 3: Implement typed document parsing and atomic rendering

**Files:**
- Create: `scripts/product_docs/__init__.py`
- Create: `scripts/product_docs/errors.py`
- Create: `scripts/product_docs/models.py`
- Create: `scripts/product_docs/toml_codec.py`
- Create: `scripts/product_docs/markdown.py`
- Create: `scripts/product_docs/documents.py`
- Create: `tests/test_document_io.py`

**Interfaces:**
- Produces: `Diagnostic`, `ProductDocsError`, enum types, `InputBinding`, `EvidenceFile`, `DocumentMetadata`, `Section`, `LifecycleDocument`, `parse_document()`, `render_document()`, `write_document_atomic()`, `parse_markdown_table()`, and `append_history_event()`.

- [ ] **Step 1: Write failing parse/render tests**

Test exact template round-trip, section order, table parsing, duplicate TOML key failure, unterminated frontmatter, unknown field rejection, absolute path rejection, traversal rejection, and atomic-write preservation after a simulated validation error.

- [ ] **Step 2: Define stable diagnostics**

Implement frozen `Diagnostic` with `code`, `message`, optional `path`, `section`, `identifier`, and `remediation`; `as_dict()` returns those keys in that order. `ProductDocsError` stores a nonempty tuple of diagnostics.

- [ ] **Step 3: Define exact enums and dataclasses**

Create string enums for `DocumentType`, `AuthorityClass`, `DocumentStatus`, `ReviewLane`, `ReviewVerdict`, and `InputKind`. Create frozen dataclasses for typed inputs/evidence, metadata, sections, lifecycle documents, review records, drift assessments, validation reports, and consumption reports. Use explicit fields from the approved frontmatter and no untyped metadata bag.

- [ ] **Step 4: Implement constrained TOML parse/render**

Parse with `tomllib`. Render only known scalar fields, string arrays, `[[inputs]]`, and `[[evidence_files]]`; reject all unknown keys. Preserve a stable key order matching the templates. Escape backslash, quote, tab, carriage return, and newline.

- [ ] **Step 5: Implement Markdown and atomic file operations**

Parse only level-two contract headings. Preserve body bytes except normalized final newline during rendering. Parse tables into tuples of row dictionaries and reject width mismatch. Atomic writes use a sibling temporary file, `flush()`, `os.fsync()`, and `Path.replace()`; reparse the candidate before replacement.

- [ ] **Step 6: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_document_io.py' -v
git commit -m "feat: add lifecycle document IO"
```

---

### Task 4: Implement package identity and safe Git history access

**Files:**
- Create: `scripts/product_docs/package_identity.py`
- Create: `scripts/product_docs/repository.py`
- Create: `tests/test_package_identity.py`

**Interfaces:**
- Produces: `GitRepository`, `build_manifest()`, `canonical_manifest_bytes()`, `package_hash()`, `verify_active_package()`, and `verify_historical_package()`.

- [ ] **Step 1: Write failing active and historical identity tests**

Test lexicographic operational-file discovery; exact-byte file hashes; exclusion of tests and the manifest; one terminal LF; extra/missing file detection; historical package verification after the active package changes; unreachable baseline failure; and current supported-contract declaration.

- [ ] **Step 2: Implement safe Git primitives**

`GitRepository` exposes `head()`, `is_commit_reachable()`, `read_bytes_at()`, `changed_paths()`, `path_exists_at()`, `is_tracked_at_head()`, and `has_worktree_change()`. Validate 40-character lowercase commit IDs and repository-relative paths. Call `subprocess.run()` with argument arrays and `shell=False`.

- [ ] **Step 3: Implement the exact package-manifest algorithm**

Manifest schema is `1`; skill version is `1.0.0`; supported templates are `research-v1`, `scope-v1`, and `design-v1`. Canonical JSON uses sorted keys, compact separators, UTF-8, and one terminal LF. Package hash is `sha256:` plus lowercase SHA-256 of those bytes. Template hash is exact-byte SHA-256 from the manifest entry.

- [ ] **Step 4: Implement historical package verification**

Read the historical manifest and every listed operational file at the document baseline. Recompute package/template hashes. Separately verify that the active manifest supports the historical schema/template. Do not require historical package equality with HEAD.

- [ ] **Step 5: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_package_identity.py' -v
git commit -m "feat: add lifecycle package identity"
```

---

### Task 5: Implement contract hashing, structure, sources, and traceability

**Files:**
- Create: `scripts/product_docs/hashing.py`
- Create: `scripts/product_docs/validation.py`
- Create: `tests/test_hashing_validation.py`

**Interfaces:**
- Produces: `compute_contract_hash()`, `derive_freshness_paths()`, `validate_structure()`, `validate_sources()`, `validate_traceability()`, and `validate_document()`.

- [ ] **Step 1: Write a golden contract-hash test**

Assert deterministic `sha256:` output, review-history and timestamp exclusion, and sensitivity to body, owner, baseline, input, evidence, package, and template changes. Store one literal 64-character golden digest calculated from the approved canonical JSON plus `\n---BODY---\n` algorithm.

- [ ] **Step 2: Write failing structural tests**

Cover wrong headings, duplicate IDs, remaining draft sentinel, empty section, summary over 1,200 words, invalid authority mapping, invalid state/review combination, malformed hash, incomplete derived freshness, and uncommitted evidence path.

- [ ] **Step 3: Implement the exact hash projection**

Include schema/template/skill identity, authoring surface, document identity/type/authority/entry point, baseline/research date, canon and owner arrays, derived freshness, supersession IDs, typed inputs, and evidence records. Exclude status, revision, timestamps, contract hash, review fields, blocker counts, and the complete Review history section.

- [ ] **Step 4: Implement freshness derivation**

Union declared canon/source/test/dependency/additional paths, input paths, evidence paths, the four exact generated canon paths when canon targets exist, the package manifest, and active template. Sort/deduplicate. Reject manually weakened values and baseline-missing declared paths.

- [ ] **Step 5: Implement source and traceability validation**

Use anchored IDs: `FIND-000`, `SRC-000`, `RISK-000`, `REQ-000`, `AC-000`, `DESIGN-000`, `VERIFY-000`, `CANON-DELTA-000`, and `SEAM-000` patterns with nonzero practical IDs. Research findings resolve to Source ledger entries or repository evidence. Scope requirements map to findings/authority and acceptance IDs. Design covers every requirement/acceptance and maps decisions/seams to verification. Canon deltas require current authority, proposed change, rationale, migration/compatibility impact, and proof.

- [ ] **Step 6: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_hashing_validation.py' -v
git commit -m "feat: add lifecycle hashing and validation"
```

---

### Task 6: Implement creation, sealing, review, and corrective transitions

**Files:**
- Create: `scripts/product_docs/transitions.py`
- Create: `tests/test_transitions.py`

**Interfaces:**
- Produces: `create_document()`, `seal_document()`, `record_review()`, `mark_stale()`, `reopen_document()`, and `supersede_document()`.

- [ ] **Step 1: Write failing `new` tests**

Assert stable slug/IDs, overwrite refusal, invalid slug rejection, Scope refusal without committed passed Research, Design refusal without committed passed Scope, and reduced-entry refusal without a validated authority JSON file.

Use these CLI/domain inputs:

```json
{
  "inputs": [
    {
      "kind": "canon",
      "authority_id": "SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001",
      "path": "docs/canon/specifications/surfaces/today.md",
      "commit": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
  ],
  "rationale": "Current canon resolves the skipped Research questions."
}
```

- [ ] **Step 2: Write failing seal tests**

Complete draft seals to `sealed`, writes package/template/hash/freshness, clears reviews, and appends a seal event. Any validation failure leaves bytes unchanged. Seal refuses an untracked document, a worktree-modified package/evidence dependency, or a baseline that does not contain the active package manifest.

- [ ] **Step 3: Write failing review and reopen tests**

Use a concrete review hash of `sha256:` followed by 64 lowercase `a` characters in fixtures. Content PASS moves sealed to content-reviewed; consumer PASS moves content-reviewed to passed; failures move to needs-revision. Wrong revision/hash, duplicate review ID, missing blockers on failure, blockers on pass, and uncommitted reviewed file fail. Reopen increments revision exactly once, clears seal/reviews, and preserves append-only history.

- [ ] **Step 4: Implement deterministic identity and creation**

Normalize initiative names to lowercase ASCII kebab case, generate `PD-YYYY-MM-UPPERCASE-SLUG`, copy exact template bytes, populate current committed package identity and HEAD baseline, and bind standard upstream lifecycle input to the exact passed commit/revision/hash. Reduced entry reads `--authority-file` and validates typed records.

- [ ] **Step 5: Implement seal and committed-handoff guards**

Seal requires `draft`, tracked path, clean operational package/evidence/declared-owner paths, valid baseline, complete tables, derived freshness, and exact active package. It may write the sealed file, but the file is not handoff-ready until committed. `is_committed_exact(path)` compares worktree bytes with `HEAD:path`; downstream creation and consumer review require true.

- [ ] **Step 6: Implement durable review and reconciliation records**

Review JSON has exact fields: review ID, lane, verdict, reviewer surface, timestamp, revision, contract hash, six formal output arrays/next phase, and drift assessments. Append fixed-order Markdown history. `reconcile --reopen` is the only path from needs-revision/stale to draft. Supersede records replacement/reason without editing authority-bearing sections.

- [ ] **Step 7: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_transitions.py' -v
git commit -m "feat: add lifecycle state transitions"
```

---

### Task 7: Implement committed repository freshness and Codex consumption

**Files:**
- Modify: `scripts/product_docs/repository.py`
- Modify: `scripts/product_docs/validation.py`
- Modify: `scripts/product_docs/transitions.py`
- Create: `tests/test_consume.py`

**Interfaces:**
- Produces: `ConsumptionReport` and `consume_document()`; consumer PASS reuses this report and requires assessments for relevant drift.

- [ ] **Step 1: Write failing committed-input tests**

Reject untracked target document, target bytes differing from HEAD, uncommitted upstream/evidence/package files, upstream not passed at its bound commit, current upstream hash/revision mismatch, evidence hash mismatch, unsupported historical contract, and unreachable baseline.

- [ ] **Step 2: Write relevant/unrelated drift tests**

A changed path outside derived freshness is reported but does not require semantic review. A changed exact freshness file or descendant of a `/` prefix requires semantic review. One assessment per relevant path is required; `impact = "material"` blocks consumer PASS, while `impact = "none"` requires a nonempty rationale.

- [ ] **Step 3: Implement consumption order**

Check canonical path, committed exactness, document structure/hash, historical package, current compatibility, typed upstream inputs, evidence, source recheck triggers, baseline reachability, freshness diff, authority class, and declared canon/source deltas. Return stable diagnostics plus sorted relevant/unrelated paths.

- [ ] **Step 4: Integrate consumer review**

Consumer PASS reruns `consume_document()` against current HEAD. Refuse deterministic blockers, missing drift assessment, extra assessment, material impact, or stale document bytes. Append accepted assessments to review history, write passed state, then require a commit before downstream use.

- [ ] **Step 5: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_consume.py' -v
git commit -m "feat: add lifecycle consumption checks"
```

---

### Task 8: Expose the full CLI and JSON contract

**Files:**
- Create: `scripts/product_docs/cli.py`
- Create: `scripts/ambitions_product_docs.py`
- Create: `tests/test_cli.py`

**Interfaces:**
- Produces commands: `package`, `new`, `check`, `hash`, `seal`, `review`, `reconcile`, `consume`, and `supersede`.

- [ ] **Step 1: Write failing parser and exit-code tests**

Exact syntax:

```text
package --check|--write [--json]
new --initiative NAME --phase research|scope|design [--initiative-id ID] [--input PATH] [--authority-file JSON] [--json]
check PATH|--initiative DIR|--all [--json]
hash PATH [--json]
seal PATH [--json]
review PATH --review-file JSON [--json]
reconcile PATH --mark-stale --reason-file TEXT [--json]
reconcile PATH --reopen [--baseline SHA] [--input PATH] [--authority-file JSON] [--json]
consume PATH [--as-of YYYY-MM-DD] [--json]
supersede PATH --replacement PATH --reason-file TEXT [--json]
```

Return `0` success, `1` domain/validation failure, `2` usage failure, `3` unsupported Python or inaccessible repository state. JSON object keys are `command`, `status`, `document`, `changes`, `diagnostics`, and `next_action`.

- [ ] **Step 2: Implement the Python entrypoint**

Match `scripts/ambitions-canon.py`: support 3.11–3.14, insert its own scripts directory, import `product_docs.cli.main`, and exit with its integer result.

- [ ] **Step 3: Prove read-only commands**

Snapshot all repository file hashes and `git status --porcelain`, then run `package --check`, `check`, `hash`, and `consume` on success and failure paths. Assert no file/status change.

- [ ] **Step 4: Run tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_cli.py' -v
git commit -m "feat: expose lifecycle CLI"
```

---

### Task 9: Install the concise skill, metadata, package manifest, and AGENTS routing

**Files:**
- Create: `SKILL.md`
- Create: `agents/openai.yaml`
- Create: `package-manifest.json`
- Modify: `AGENTS.md`
- Create: `tests/test_ambitions_product_docs.py`

**Interfaces:**
- Produces: discoverable portable package, ChatGPT metadata, active package identity, repository routing, and one end-to-end acceptance suite.

- [ ] **Step 1: Write failing skill-surface tests**

Assert exact skill name/description, body under 500 words, all referenced paths exist, no duplicated detailed rubric, and `AGENTS.md` retains the no-process-gates statement.

- [ ] **Step 2: Write `SKILL.md`**

Use exact approved frontmatter. Body sections: `Choose the role`, `Producer`, `Content review`, `Consumer`, `Lifecycle boundaries`, `Commands`. Require role contract and phase rubric. State that Research/Scope cannot authorize implementation and document PASS cannot authorize merge.

- [ ] **Step 3: Write and validate `agents/openai.yaml`**

Start with:

```yaml
interface:
  display_name: "Ambitions Product Development"
  short_description: "Create, review, and consume Ambitions lifecycle documents."
  default_prompt: "Use $ambitions-product-development-lifecycle to create, review, or consume the correct Research, Scope, or Design document for this material Ambitions initiative."
policy:
  allow_implicit_invocation: true
```

Run the current installed OpenAI skill metadata validator. If it rejects a field, replace only that field with the validator’s officially accepted equivalent, update the test to the exact accepted schema, and record the validator command/output in validation evidence. Do not add undocumented metadata.

- [ ] **Step 4: Add concise AGENTS routing**

Insert after Product documentation:

```markdown
For a material new product, UX, or architecture initiative whose behavior is not
already resolved by current canon, use the repository skill
`ambitions-product-development-lifecycle`. ChatGPT authors the canonical Research,
Scope, and Design files; Codex performs consumer review before each downstream
phase. This is a quality workflow, not edit or merge authorization.
```

- [ ] **Step 5: Generate and verify the manifest**

Run `package --write` then `package --check`. Manifest lists every operational file and supported schema/template versions.

- [ ] **Step 6: Implement end-to-end acceptance test**

In a temporary Git repository, install the complete package, commit it, create and commit evidence, create Research, complete/commit/seal/commit/content-review/commit/consumer-review/commit, then create Scope bound to the exact Research commit. Repeat through Design. Assert unrelated drift passes and relevant drift requires assessment.

- [ ] **Step 7: Run all tests and commit**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check
git commit -m "feat: install product development lifecycle skill"
```

---

### Task 10: Rerun pressure scenarios and prove ChatGPT-to-Codex handoff

**Files:**
- Create: `post-skill.md`
- Create: `cross-product.md`
- Create: `docs/product-development/lifecycle-fixture/{research,scope,design}.md`
- Create: `docs/product-development/lifecycle-fixture/evidence/comparison.md`

**Interfaces:**
- Consumes: unchanged Task 1 corpus and active package/template hashes.
- Produces: post-skill compliance evidence and one committed cross-product fixture chain.

- [ ] **Step 1: Rerun the unchanged corpus**

Each fresh agent loads the installed skill. Score the same required behaviors. Any failure first becomes a new failing pressure test; make the minimum skill/contract correction, regenerate manifest, and rerun the failed plus one adjacent scenario.

- [ ] **Step 2: Author fixture Research through ChatGPT**

In fresh ChatGPT context, explicitly load manifest, `SKILL.md`, Research template, producer contract, and Research rubric. Provide synthetic idea and repository access only. ChatGPT creates the canonical draft without originating-chat dependency. Commit evidence and draft, seal and commit, perform content review and commit, then perform Codex consumer review and commit. Research reaches committed `passed`.

- [ ] **Step 3: Author fixture Scope and Design through ChatGPT**

For each phase, provide only the passed committed upstream file, current repository, and active package. Require complete IDs, owner paths, boundaries, traceability, declared deltas, and zero invention-causing open decisions. At every transition: write, commit, seal, commit, content-review, commit, consumer-review, commit.

- [ ] **Step 4: Prove drift behavior without polluting main history**

Use a temporary branch/worktree. Commit one unrelated file and record `consume --json` as pass. Commit one declared owner path and record semantic-review requirement. Discard the temporary branch after copying output to `cross-product.md`.

- [ ] **Step 5: Commit evidence**

Record package/template/document hashes, commits, ChatGPT inputs, Codex read order, commands, statuses, and explicit absence of originating chat. Commit fixture and post-skill/cross-product evidence.

```bash
git commit -m "test: validate lifecycle skill across ChatGPT and Codex"
```

---

### Task 11: Final validation and implementation handoff

**Files:**
- Create: `docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md`
- Modify earlier files only to repair a reproduced defect.

**Interfaces:**
- Produces: final coverage map, command evidence, proof ceiling, package hashes, and clean handoff.

- [ ] **Step 1: Run complete checks**

```bash
python3 -m unittest discover -s .agents/skills/ambitions-product-development-lifecycle/tests -p 'test_*.py' -v
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py package --check
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check --initiative docs/product-development/lifecycle-fixture
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py consume docs/product-development/lifecycle-fixture/design.md --json
python3 scripts/ambitions-canon.py check
git diff --check
```

All exit `0`; Design reports `can_pass: true` and no blocking diagnostic.

- [ ] **Step 2: Prove read-only behavior**

Hash all lifecycle files and capture `git status --porcelain`; rerun every read-only command; assert identical hashes/status.

- [ ] **Step 3: Build specification coverage table**

Map package identity, ChatGPT deployment, producer, content review, consumer, canonical persistence, typed inputs, state machine, hash, handoff summary, freshness, Research, Scope, Design, consume, CLI, canon reconciliation, evolution, pressure tests, security/privacy, and acceptance criteria to exact files and test methods.

- [ ] **Step 4: Scan user-facing artifacts for unresolved draft markers**

Run:

```bash
rg -n "PRODUCT-DOC-DRAFT|implement later|fill in details" \
  .agents/skills/ambitions-product-development-lifecycle/SKILL.md \
  .agents/skills/ambitions-product-development-lifecycle/references \
  docs/product-development/lifecycle-fixture \
  docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation
```

Expected: no match in passed fixture/evidence or operational instructions. Versioned blank templates are intentionally excluded because they contain draft sentinels; tests and validator source are excluded because they contain rejection literals.

- [ ] **Step 5: Record proof ceiling**

State that fixture proof covers package identity, creation, committed handoff, sealing, reviews, traceability, drift, historical verification, and ChatGPT-to-Codex consumption. It does not prove every future initiative or replace product, code, runtime, accessibility, privacy, performance, or release verification.

- [ ] **Step 6: Commit final validation**

```bash
git add docs/qa/evidence/2026-08-02-product-development-lifecycle-skill-validation/validation.md
git commit -m "test: close lifecycle skill validation"
```

- [ ] **Step 7: Report completion**

Report exact files, commits, package/template hashes, test results, pressure results, fixture IDs, proof ceiling, follow-up adoption work, and confirmation that no Code Quality workflow or branch-protection gate changed.

---

## Plan Self-Review

- **Spec coverage:** All approved design sections map to Tasks 2–11; package evolution and historical verification map to Task 4, committed handoff and state transitions to Tasks 6–7, and ChatGPT-to-Codex proof to Task 10.
- **Placeholder scan:** No unresolved implementation placeholder remains. Draft sentinel strings are deliberate template data and are tested as seal blockers.
- **Type consistency:** `LifecycleDocument`, `DocumentMetadata`, `ReviewRecord`, `ConsumptionReport`, `GitRepository`, and transition function names are introduced once and consumed consistently.
- **Scope check:** The plan builds the lifecycle system and synthetic proof only. A real Ambitions feature and CI integration remain follow-up adoption work.

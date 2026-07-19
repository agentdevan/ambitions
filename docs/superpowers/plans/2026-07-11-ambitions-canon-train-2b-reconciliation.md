# Ambitions Canon Train 2B — Atomic Claims and Owner Conflict Dockets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Decompose all authority into disposition-complete atomic claims and produce owner-facing conceptual conflict dockets with reasoned recommendations.

**Architecture:** Continue `codex/canon-02-reconciliation` after Train 2A. Parallel agents may inspect domains read-only; one synthesis writer creates dockets, and no material conflict is integrated without owner decision.

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

### Task 11: Validate atomic claims and complete source dispositions

**Files:**
- Modify: `tools/ambitions_canon/model.py`
- Modify: `tools/ambitions_canon/migration.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/fixtures/claims-valid.json`
- Create: `tests/canon/test_claims.py`
- Create: `docs/canon/schemas/claim.schema.json`
- Create: `docs/canon/migration/claim-dispositions.json`
- Produce ignored claim batches: `.codex/canon-migration/claims/*.json`

**Interfaces:**
- immutable `AtomicClaim`
- fields: `claim_id`, `source_id`, `source_location`, `concept`, `subject`, `predicate`, `value`, `modality`, `scope`, `conditions`, `exceptions`, `authority_claim`, `owner_approval`, `disposition`, `target_id`.
- dispositions: `keep`, `rewrite`, `compose`, `reject`, `provenance_only`, `conflict`.
- `migration claims import`
- `migration claims coverage` with `--concept-prefix`, `--target-class`, and `--output` filters.
- Coverage exits `1` when any registered source section lacks a claim/disposition.

- [ ] **Step 1: Write failing claim tests**

Cover:

- complete claim parses;
- unknown source ID fails;
- duplicate claim ID fails;
- empty concept/scope fails;
- material claim cannot use `provenance_only` without rationale;
- `keep`, `rewrite`, and `compose` require target ID before cutover;
- every registered source section has a claim or explicit `no_normative_claims` disposition.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_claims.py -v
```

- [ ] **Step 3: Implement claim validation**

Claim JSON is an interchange format, not final canon. It must retain exact source location and original wording separately from normalized semantics.

- [ ] **Step 4: Run parallel read-only extraction**

Dispatch independent Sol High reviewers for:

1. mission/origin/moat;
2. IA/shell/surfaces;
3. object model/lifecycle;
4. runtime/persistence/privacy/sync;
5. native iOS/accessibility/visual;
6. proof/release/Codex process;
7. source/tests-only behavior;
8. Linear/Figma topology.

Each reviewer writes one JSON batch under ignored `.codex/canon-migration/claims/`. No reviewer edits `docs/canon/**`.

One canonical integrator imports batches, resolves duplicate claim IDs, and writes `claim-dispositions.json`.

- [ ] **Step 5: Run coverage**

```bash
python3 scripts/ambitions-canon.py migration claims import \
  --input-dir .codex/canon-migration/claims
python3 scripts/ambitions-canon.py migration claims coverage
```

Expected: every v3 section and every registered authority source has a disposition; unresolved semantic conflicts remain `conflict`, not silently composed.

- [ ] **Step 6: Commit**

```bash
git add tools/ambitions_canon/model.py tools/ambitions_canon/migration.py \
  tools/ambitions_canon/cli.py tests/canon/test_claims.py \
  tests/canon/fixtures/claims-valid.json docs/canon/schemas/claim.schema.json \
  docs/canon/migration/claim-dispositions.json
git commit -m "feat: normalize canon claims and dispositions"
```

---
---

### Task 12: Detect conceptual conflicts and produce owner decision dockets

**Files:**
- Create: `tools/ambitions_canon/conflicts.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tests/canon/test_conflicts.py`
- Create temporary dockets under `docs/canon/decisions/open/`
- Generate: `docs/canon/generated/unresolved-conflicts.md`

**Interfaces:**
- `conflict_candidates(claims: Iterable[AtomicClaim]) -> tuple[ConflictCandidate, ...]`
- `render_conflict_docket(candidate: ConflictCandidate) -> str`
- `conflicts report` and `conflicts report --require-resolved`
- `--require-resolved` exits `1` when any active docket lacks owner decision and target requirement.
- exact resolution values: `keep_a`, `keep_b`, `compose`, `reject_both`.
- unresolved docket blocks affected task packs and cutover.

- [ ] **Step 1: Write failing tests**

Cover:

- different wording with same normalized value is not conflict;
- same concept with incompatible normalized values is conflict;
- `MUST` versus `MUST NOT` overlapping scope is P0;
- disjoint scopes may coexist;
- later owner correction is still presented with provenance, not auto-selected;
- docket includes recommendation, stronger-composition option, all impact dimensions, and owner field;
- resolved docket produces ledger entry and is removable only after target requirement exists.

- [ ] **Step 2: Run RED**

```bash
python3 -m unittest tests/canon/test_conflicts.py -v
```

- [ ] **Step 3: Implement deterministic candidate detection and docket rendering**

The compiler detects candidates using normalized concept, modality, scope, and claim value. It does not call a model.

- [ ] **Step 4: Produce the minimum required dockets**

Create dockets for:

```text
CONFLICT-TODAY-PRIMARY-IDENTITY
CONFLICT-ORCHESTRATION-LOOP
CONFLICT-MUTATION-SEQUENCE
CONFLICT-CLOUDKIT-CONTINUITY
CONFLICT-CALENDAR-REPLACEMENT-BAR
```

Use Sol Max to synthesize each from source claims and recommend `keep`, `compose`, or a stronger third law. Include exact affected repo files, Linear entities, Figma nodes, source/test implications, and superseded artifacts.

- [ ] **Step 5: Run deterministic report**

```bash
python3 -m unittest tests/canon/test_conflicts.py -v
python3 scripts/ambitions-canon.py conflicts report
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

Expected: command exits `1` while dockets remain unresolved and generated report lists them.

- [ ] **Step 6: Commit unresolved dockets and stop for owner decision**

```bash
git add tools/ambitions_canon/conflicts.py tools/ambitions_canon/cli.py \
  tests/canon/test_conflicts.py docs/canon/decisions/open \
  docs/canon/generated/unresolved-conflicts.md
git commit -m "docs: present canon conflict dockets"
```

**Owner gate:** Do not begin Task 13 until Devan records a resolution and canonical wording in every P0 docket. After decisions, update each docket, run review, integrate the decision in Task 13, append the supersession ledger, and delete the resolved docket in the same commit that creates its target requirement.

This completes Train 2. Run whole-train review and open the stacked reconciliation PR.

---

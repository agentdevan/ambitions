# Ambitions Canon Train 5A — Purge Safety, Dual-Run Proof, and Authority Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prove purge eligibility and reference safety, pass the dual-run gate, then atomically switch repo routing and CI to the new canon.

**Architecture:** Create `codex/canon-05-cutover` from the merged reviewed Train 4 head. Cutover is serialized, owner-approved, independently reviewed, and reversible through named tags and a single routing/CI boundary commit.

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
- ChatGPT expresses intent but cannot authorize implementation. Machine-readable intake is untrusted intent only; Project Instructions, skills, PR prose, local approval/proof claims, and contributor-authored JSON are not authority.
- Every tracked change requires current `task start` and exact-diff `task finalize` authorization computed from the trusted base branch, trusted event/approval provenance, and base-trusted, revisioned repository snapshots. Intake may request but cannot authorize scope, files, validation/proof, break-glass, or merge.
- Task packs, authorization envelopes, and finalization receipts remain ignored local artifacts. Required CI uses a base-owned or externally pinned immutable digest for validator/policy logic, treats the PR checkout as data only, produces CI-owned validation attestations, and rejects local artifacts as proof.
- Local hooks are convenience-only. The protected-branch required check is the enforcement boundary; no routine bypass is permitted.
- Break-glass requires explicit owner approval, an incident record, rollback, and post-action independent review.
- Gate B and Gate C remain hard Red gates. Delegated owner approval for Tasks 22–29 is exercisable only after all mandated proof is Green and cannot waive any Red, Critical, Important, authorization, security, required-CI, protected-branch, or destructive-cleanup requirement.

---

### Task 24: Implement purge eligibility, authority-sprawl enforcement, and reference verification

**Files:**
- Create: `tools/ambitions_canon/purge.py`
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/cli.py`
- Create: `tools/ambitions_canon/authorization.py`
- Create: `tools/ambitions_canon/skill_conformance.py`
- Create: `docs/canon/schemas/task-intake.schema.json`
- Create: `docs/canon/schemas/task-authorization.schema.json`
- Create: `docs/canon/schemas/trusted-event.schema.json`
- Create: `docs/canon/schemas/approval-attestation.schema.json`
- Create: `docs/canon/schemas/validation-attestation.schema.json`
- Create: `docs/canon/references/skill-dependencies.json`
- Create: `docs/canon/references/validation-command-manifest.json`
- Create: `tests/canon/test_purge.py`
- Create: `tests/canon/test_authorization.py`
- Create: `tests/canon/test_skill_conformance.py`
- Create: `tests/canon/test_integration.py`
- Create fixtures:
  - `tests/canon/fixtures/purge-eligible.toml`
  - `tests/canon/fixtures/purge-unresolved-claim.toml`
  - `tests/canon/fixtures/purge-active-reference.toml`
  - `tests/canon/fixtures/authority-outside-canon.txt`
  - `tests/canon/fixtures/task-intake-valid.json`
  - stale/missing intake, stale-envelope, stale-skill, and undeclared-change fixtures

**Interfaces:**
- `PurgeArtifact`
- `build_purge_plan(source_catalog, dispositions, references, rollback_ref) -> PurgePlan`
- `purge_findings(plan: PurgePlan, repo_root: Path, registry: CanonRegistry) -> tuple[Finding, ...]`
- `authority_sprawl_findings(repo_root, manifest, baseline=None) -> tuple[Finding, ...]`
- `purge plan` is read-only except for its named output file.
- `purge verify --dry-run` never deletes.
- Actual deletion remains explicit Git/connector work in later tasks.
- `task start --mode local --intake-json <path> --output <ignored-path>` treats intake as request-only, computes local advisory scope from trusted base policy plus the local HEAD/starting delta, emits the bounded pack, and writes an ignored deterministic envelope.
- `task finalize --mode local --authorization <path> --output <ignored-path>` recomputes local bindings and writes an ignored advisory receipt for the local final delta; it cannot authorize merge.
- CI PR-range mode consumes `trusted_event_provenance` from a platform-owned event projection and computes `computed_authorized_files`; intake contains `requested_changed_files` only.
- Trusted event provenance binds immutable repository ID/name, PR number, `trusted_base_sha`, `trusted_head_sha`, and `merge_base_sha = git merge-base(trusted_base_sha, trusted_head_sha)`. Base drift, force-push/head replacement, repository mismatch, missing objects, or inconsistent merge base fails closed and requires regeneration.
- Exact CI authorization compares the tree at `merge_base_sha` with the tree at `trusted_head_sha`, never the synthetic GitHub merge commit, synthetic merge checkout, or empty worktree. `trusted_base_sha` remains independently bound for drift detection.
- Normalize path-by-path from Git tree entries. Each record binds base64url-encoded raw path bytes, optional non-authoritative UTF-8 display, presence/equality-derived status, old/new mode, old/new object types, old/new object IDs, and blob size. Sort by unsigned raw path bytes and hash newline-terminated canonical JSON with SHA-256.
- Do not use Git rename/copy or textual/binary heuristics: moves use delete/add rename normalization, copies are copy as add, and every binary payload is an opaque binary blob identified only by Git object metadata. Symlink and submodule gitlink identity comes from mode.
- Finalize authorizes only the exact final diff represented by that trusted canonical tree delta and computed scope.
- Required owner-gated actions consume a separate platform-authenticated approval attestation bound to repository, PR/task/intake, base/head, intake digest, policy revision, authenticated principal, scope, expiry/revocation, and one-time-use state.
- Start and finalize bind canon/source/policy/schema revisions, source ownership, known issues/proof/conflict and skill state from base-trusted snapshots; external mutable state requires a separate trusted sync snapshot.
- Required validation derives from the base-owned or pinned `validation-command-manifest.json`; every attestation binds its command-manifest digest and trusted validation workflow path/ref/digest.
- `skill-conformance --check` validates retained procedural adapters against canonical dependency metadata offline and deterministically.
- Neither a task pack, envelope, receipt, Project Instructions, skill, nor ChatGPT output is authority. CI independently regenerates authorization and never trusts contributor-generated artifacts.

- [ ] **Step 1: Write failing purge tests**

Cover:

1. eligible artifact has every claim disposition, replacement ID, inbound-link rewrite, owner approval, independent review, and rollback ref;
2. unresolved claim blocks with `PURGE_CLAIM_UNRESOLVED`;
3. missing replacement requirement blocks;
4. active inbound Git reference blocks;
5. unknown Linear/Figma reference blocks;
6. missing owner approval blocks;
7. no archive destination is accepted as a substitute for delete;
8. plan serialization is deterministic;
9. dry-run does not mutate files.

- [ ] **Step 2: Write failing authority-sprawl tests**

Assert:

- normative file under `docs/canon/` and listed by manifest passes;
- authority-like file outside `docs/canon/` fails after cutover;
- current legacy files are allowed only while `authority_state = "shadow"` or while explicitly present in the approved purge plan;
- source comments containing the word `authority` do not fail solely by wording;
- a new `PRODUCT_TRUTH.md`, `CANON.md`, or `CONSTITUTION.md` outside the manifest fails.

- [ ] **Step 3: Write failing authorization, skill-conformance, and integration tests**

Before the integration tests, add focused authorization and skill-conformance tests covering:

1. valid intake produces a deterministic, sorted, UTF-8, newline-terminated, atomic envelope with no volatile timestamp;
2. intake is request-only: fields are `requested_*`, including `requested_changed_files`, and authoritative approval, authorized files, validation/proof results, break-glass, or merge permission in intake fail schema/policy validation;
3. `task-authorization.schema.json` distinguishes requested values from `computed_authorized_files`, computed required checks/proof/claim ceiling, `trusted_event_provenance`, trusted snapshot digests, and approval-attestation references;
4. missing or stale intake, stale canon/policy, changed issue request, shifted source ownership, stale trusted known-issue/proof/conflict snapshots, stale skill dependencies, unavailable trusted external snapshot, and missing/revoked/reused platform-authenticated approval attestation fail closed;
5. trusted-event tests cover immutable repository identity, PR number, base ref/SHA, head SHA, merge base, repository mismatch, missing Git objects, base movement, force-push/head replacement, and inconsistent merge base;
6. canonical base-to-head tree-delta tests cover base advancement, clean head and synthetic merge checkout compatibility, delete/add rename normalization, copy as add, opaque binary blob, base64url raw path bytes, symlinks, old/new modes including mode-only changes, old/new object types/IDs, deletions, submodule gitlinks, merge commits, and force-push/head replacement;
7. local start/finalize and CI PR-range modes normalize compatible records but local receipts and synthetic merge state cannot authorize merge;
8. `task finalize` rejects a stale authorization envelope, any tree change outside computed authorization, and any final delta not derived from the trusted starting/event state;
9. finalize rejects missing, stale, contributor-authored, mismatched-head, skipped-required, or non-Green CI-owned validation attestations and authorizes only the exact computed tree delta;
10. changed PR validation workflow or command manifest, wrong workflow/command-manifest digest or integration identity, and re-attested untrusted Green results fail closed; PR code runs only as the test subject inside a least-privilege no-secrets trusted validation job;
11. a retained skill with missing, undeclared, circular, stale, or authority-bearing dependencies fails `skill-conformance --check`;
12. ignored task packs, envelopes, receipts, PR prose, and contributor JSON cannot be loaded as canonical authority, approval, evidence, or CI proof.

The task-intake, task-authorization, trusted-event, approval-attestation, and validation-attestation schemas must require every binding named above and reject unknown fields.

Add full pipelines:

```text
parse → manifest → registry → graph → audit → build
amendment → impact → supersession
issue intake → task pack → stale check
source catalog → claims → conflict docket
purge plan → reference scan → verify
```

Use temporary repositories and fixtures; no network.

- [ ] **Step 4: Run RED**

```bash
python3 -m unittest tests/canon/test_purge.py tests/canon/test_authorization.py \
  tests/canon/test_skill_conformance.py tests/canon/test_integration.py -v
```

Expected: missing module/functions.

- [ ] **Step 5: Implement purge and sprawl checks**

Purge plan TOML artifact shape:

```toml
[[artifact]]
artifact_id = "REPO-PRODUCT-EXPERIENCE-CANON"
kind = "repo"
locator = "docs/truth/PRODUCT_EXPERIENCE_CANON.md"
action = "delete"
replacement_ids = ["EXPERIENCE-001", "USER-CONTROL-001", "LEARNING-004"]
claims_resolved = true
incoming_links_rewritten = true
external_references_reconciled = true
owner_approved = true
independent_review = true
rollback_ref = "canon-system-baseline-2026-07-11"
```

Do not execute deletion in Python. The compiler proves eligibility and validates the post-delete tree.

Implement authorization as pure standard-library functions over explicit inputs. Canonical JSON serialization uses sorted keys and a terminal newline; tree-delta, command-manifest, snapshot, approval, validation, and dependency digests use SHA-256; outputs are written through a temporary file and atomic replacement. Tree normalization reads Git objects/entries without rename/copy or binary heuristics. `task start` and `task finalize` perform no network/model/cloud calls. Current offline state means exact base-trusted, revisioned repository snapshots or platform-authenticated attestations; intake digest never proves external freshness. `skill-dependencies.json` and `validation-command-manifest.json` own dependency/validation policy metadata, not product doctrine, and retained skills remain non-authoritative procedural adapters.

- [ ] **Step 6: Run GREEN**

```bash
python3 -m unittest tests/canon/test_purge.py tests/canon/test_authorization.py \
  tests/canon/test_skill_conformance.py tests/canon/test_integration.py -v
python3 scripts/ambitions-canon.py skill-conformance --check
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py purge plan \
  --output .codex/canon-migration/sample-purge-plan.toml
python3 scripts/ambitions-canon.py purge verify \
  --plan .codex/canon-migration/sample-purge-plan.toml --dry-run
git diff --check
```

Expected: shadow authority-sprawl check permits only baseline legacy authority plus `docs/canon/`; sample plan verifies without mutation.

- [ ] **Step 7: Commit**

```bash
git add tools/ambitions_canon/purge.py tools/ambitions_canon/audit.py \
  tools/ambitions_canon/cli.py tools/ambitions_canon/authorization.py \
  tools/ambitions_canon/skill_conformance.py docs/canon/schemas/task-intake.schema.json \
  docs/canon/schemas/task-authorization.schema.json \
  docs/canon/schemas/trusted-event.schema.json \
  docs/canon/schemas/approval-attestation.schema.json \
  docs/canon/schemas/validation-attestation.schema.json \
  docs/canon/references/skill-dependencies.json \
  docs/canon/references/validation-command-manifest.json tests/canon/test_purge.py \
  tests/canon/test_authorization.py tests/canon/test_skill_conformance.py \
  tests/canon/test_integration.py tests/canon/fixtures
git commit -m "feat: prove authority purge eligibility"
```

---
---

### Task 25: Prove the dual-run cutover gate

**Files:**
- Create generated report: `docs/canon/generated/cutover-readiness.md`
- Create: `docs/canon/migration/purge-plan.toml`
- Modify generated outputs only.

**Interfaces:**
- old and new audits coexist;
- every old active authority has disposition;
- no accepted unique claim lost;
- no unresolved P0 conflict/gap;
- rollback tag exists;
- external reconciliation state explicit.
- Gate B remains hard Red until current ChatGPT handoff, authorization, skill-conformance, CI-regeneration, rollback, owner approval, and independent-review evidence is Green.
- The controller's delegated owner approval cannot waive any failed authorization, security, required-CI, protected-branch, or destructive-cleanup check.
- Gate B approval is bootstrap approval for Task 26 installation only. Live enforcement cannot be claimed from the branch; after the Train 5A merge, the first post-merge protected-boundary receipt must prove activation before Gate C. Task 29 later repeats inspection and proves no drift.

- [ ] **Step 1: Generate purge plan without deleting**

```bash
python3 scripts/ambitions-canon.py purge plan \
  --output docs/canon/migration/purge-plan.toml
```

Every artifact entry must contain action, replacement IDs, claim coverage, incoming-link status, external impact, owner approval, independent-review state, and rollback ref.

Generate the governed ChatGPT handoff/intake fixture set without authorizing implementation. The Gate B report must prove missing or stale intake, stale authorization envelope, and local-artifact substitution all fail closed.

- [ ] **Step 2: Run the full dual-run matrix**

```bash
python3 -m unittest discover -s tests/canon -p 'test_*.py' -v
python3 -m unittest scripts/tests/test_ambitions_authority_freeze_check.py -v
python3 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py
python3 scripts/ambitions-authority-freeze-check.py
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py external-authority --check
python3 scripts/ambitions-canon.py conflicts report --require-resolved
python3 scripts/ambitions-canon.py migration claims coverage
python3 scripts/ambitions-canon.py build --check
python3 scripts/ambitions-canon.py skill-conformance --check
python3 scripts/ambitions-canon.py benchmark --require-authorization
python3 scripts/ambitions-canon.py purge verify --plan docs/canon/migration/purge-plan.toml --dry-run
python3 scripts/ambitions-constitution-audit.py
python3 scripts/ambitions-remediation-governance-check.py
python3 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
git diff --check
```

The authorization benchmark must exercise all eight representative task scenarios under both `task start` and `task finalize`: Today SwiftUI, Time recurrence, Capture proposal flow, LocalRuntimeOS mutation, CloudKit continuity, Source Atlas boundary, accessibility repair, and release-proof claim. For each scenario prove:

- ChatGPT handoff produces schema-valid intent/intake but cannot authorize itself;
- intake is untrusted intent only and carries requested scope, never authoritative owner approval, authorized files, validation/proof results, break-glass, or merge permission;
- trusted repository/PR/base/head/merge-base event bindings and any required platform-authenticated approval attestation are current and provenance-complete;
- missing/stale intake and stale-envelope cases fail;
- interruption/resume regenerates from base-trusted snapshots and invalidates stale bindings after base movement or force-push/head replacement;
- the canonical tree delta and computed authorized files cover raw Git entries from merge-base tree to trusted head, including base advancement, delete/add moves, copy-as-add, opaque blobs, raw paths, modes, symlinks, gitlinks, merge commits, and synthetic-checkout compatibility;
- skill dependency freshness is current;
- required validation is derived by a trusted workflow and command manifest and represented only by CI-owned validation attestations bound to the same event/workflow/command-manifest digest;
- changed PR workflow/command manifest, wrong digest/integration, and re-attested untrusted Green benchmark cases fail closed;
- a local task pack, authorization envelope, or finalization receipt cannot substitute for CI regeneration.

- [ ] **Step 3: Independent cutover review**

A fresh Sol Max reviewer verifies:

- all design acceptance criteria;
- old audit invariant parity;
- semantic coverage;
- external reconciliation;
- task-pack benchmark;
- ChatGPT handoff, start/finalize, resume, final-diff, and changed-file proof;
- request-only intake, trusted event/approval provenance, canonical tree-delta, and CI-owned evidence proof;
- skill dependency freshness and independent-CI-regeneration proof;
- purge eligibility;
- rollback.

Repair all Critical/Important findings.

- [ ] **Step 4: Record owner cutover decision**

The report must state `owner_cutover_approval = true` with date and approved purge scope. It must also state `gate_b = green` and name the independently reviewed authorization evidence. Without both, stop.

- [ ] **Step 5: Commit readiness evidence**

```bash
git add docs/canon/generated/cutover-readiness.md \
  docs/canon/migration/purge-plan.toml
git commit -m "docs: prove canon cutover readiness"
```

---
---

### Task 26: Cut over repo routing and CI to the new canon

**Files:**
- Modify: `docs/canon/MANIFEST.toml`
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `.agents/skills/README.md`
- Modify retained `.agents/skills/*/SKILL.md` references as required.
- Rename and modify: `.github/workflows/ambitions-canon-shadow-audit.yml` → `.github/workflows/ambitions-canon-audit.yml`
- Delete: `.github/workflows/ambitions-constitution-audit.yml`
- Delete: `scripts/ambitions-constitution-audit.py`
- Generate: `docs/canon/generated/CODEX_START_HERE.md`
- Generate: `docs/canon/generated/CHATGPT_CODEX_HANDOFF.md`
- Generate: `docs/canon/generated/AUTHORIZATION_GATE_TRANSITION.md`
- Create governed reference: `docs/canon/references/chatgpt-project-instructions.md`
- Verify: `docs/canon/references/skill-dependencies.json`
- Verify: `docs/canon/references/validation-command-manifest.json`
- Create Git tag after the reviewed Train 5A merge: `ambitions-canon-v1-cutover`

**Interfaces:**
- `authority_state = "active"`;
- `canon_revision = 1`;
- `docs/canon/` is sole normative root;
- old docs remain temporarily present but non-normative and listed in purge plan;
- AGENTS is a thin router.
- `AGENTS.md` requires current `task start` before any tracked edit and `task finalize` before commit/review.
- retained skills are non-authoritative procedural adapters carrying canonical dependency metadata.
- the exact ChatGPT Project Instructions are stored as governed reference material; their byte-for-byte Project Instructions SHA-256 is recorded and verified in `CHATGPT_CODEX_HANDOFF.md`.
- replacement CI independently regenerates authorization from checkout plus machine-readable PR intake, runs `skill-conformance --check`, and rejects contributor-generated packs/envelopes/receipts as proof.
- merge-authorizing validator/schema/policy/workflow logic comes from the trusted base branch or an externally pinned immutable digest; PR-controlled jobs cannot emit the required authorization context.
- required-check identity binds workflow path/ref/digest and GitHub integration/app identity.
- required validation policy binds the base-owned/pinned validation workflow and command-manifest digest; PR-controlled validation cannot satisfy or be re-attested into the required check.
- verifier/policy changes follow the two-stage gate-change protocol with the old trusted gate protecting transition and no unprotected interval.

- [ ] **Step 1: Change manifest state**

```toml
authority_state = "active"
canon_revision = 1
```

Active audit now requires exactly one Constitution and all listed normative files.

- [ ] **Step 2: Rewrite AGENTS as thin routing contract**

AGENTS must:

1. point to generated `docs/canon/generated/CODEX_START_HERE.md`;
2. require `ambitions-canon pack` for nontrivial work;
3. preserve current local-first, proof, branch, XcodeGen, and resume safety;
4. avoid copying Constitution or surface law;
5. state old truth/constitution files are non-authoritative pending purge;
6. require `task start` for every tracked change and exact-diff `task finalize` before commit or review;
7. state ChatGPT, Project Instructions, skills, PR intake/prose, task packs, envelopes, receipts, local approval claims, and local validation/proof are not authority;
8. state local hooks are convenience-only and protected-branch required CI is the enforcement boundary.

Rewrite retained skills as thin procedural adapters. Each must declare its canonical requirement IDs, dependency paths/digests, and allowed adapter purpose through `skill-dependencies.json`; remove copied law or authority claims. Generate `CHATGPT_CODEX_HANDOFF.md` from canon plus the governed exact Project Instructions reference, and verify its recorded SHA-256 deterministically.

- [ ] **Step 3: Replace CI**

Rename the workflow file and workflow name:

```bash
git mv .github/workflows/ambitions-canon-shadow-audit.yml \
  .github/workflows/ambitions-canon-audit.yml
```

Set the workflow name to `Ambitions Canon Audit`. The merge-authorizing entry point uses base-owned `pull_request_target` or an equivalent trust-boundary workflow with least privilege, read-only contents, no secrets, and no execution or import of PR-controlled code. PR checkout is data only. PR-controlled workflows cannot satisfy required validation even when Green. Untrusted `pull_request` jobs remain advisory and cannot be re-attested into authority. PR code may run only as the test subject inside a least-privilege, no-secrets trusted validation job whose workflow and commands come from the trusted base or immutable pin.

The trusted workflow order is:

```text
1. trusted event projection and request-only intake validation
2. task start --mode ci-pr-range using trusted base/head/merge-base objects
3. trusted required-validation/check derivation from the base-owned/pinned validation-command manifest
4. trusted validation job execution against PR code as data/test subject
5. CI-owned validation attestations with validation workflow path/ref/digest, command-manifest digest, exact command/check identity, repository/base/head/merge-base, integration identity, exit status, artifact digest, skipped/not-run reason, and proof/claim ceiling
6. exact canonical tree-delta task finalize
7. skill-conformance --check, authority-sprawl, audit, coverage, traceability, external-authority, build --check, unit tests, and git diff --check as applicable
```

Delete old audit only after Task 25 proves invariant parity.

The workflow must run offline from trusted base bytes, trusted GitHub event projection, trusted revisioned repository snapshots, PR checkout as inert data, and checked machine-readable intake as untrusted intent. Mutable external Linear/Figma/approval state must be materialized by a separate trusted sync/approval step before authorization or fail closed. It creates CI-owned temporary envelopes/receipts, consumes only matching Green CI-owned validation attestations, finalizes the exact trusted base-to-head tree delta, and discards them. It must fail when local or checked-in artifacts are offered instead; local validation remains advisory and cannot authorize merge.

Required-check identity includes the context, workflow path/ref/digest, validation command-manifest digest, and expected GitHub integration/app identity. Configure the check as protected-branch required CI only through the two-stage gate-change protocol: a prior owner-approved governance amendment authorizes the new verifier/policy digest; the old trusted gate validates the transition PR; after merge and independent proof, the protected ruleset switches with no unprotected interval. Record the bootstrap boundary: existing required CI, this merged amendment, independent re-review, and Gate B approve installation; live enforcement remains unproven on the branch and requires the first post-merge protected-boundary receipt before Gate C.

- [ ] **Step 4: Run cutover validation**

Run the full new matrix plus targeted scans showing no active router points to old truth. Verify Project Instructions SHA-256, retained-skill metadata, request-only intake, trusted event/approval provenance, command-independent tree-delta cases, base-owned/pinned validation workflow/command manifest, CI-owned attestations, required-check workflow/integration identity, two-stage transition evidence, and exact-diff rejection. Do not claim live protected-branch/ruleset posture from offline config. Do not run the deleted old audit after deletion.

- [ ] **Step 5: Commit the cutover boundary**

```bash
git add docs/canon/MANIFEST.toml AGENTS.md README.md docs/README.md \
  .agents/skills .github/workflows docs/canon/generated/CODEX_START_HERE.md \
  docs/canon/generated/CHATGPT_CODEX_HANDOFF.md \
  docs/canon/generated/AUTHORIZATION_GATE_TRANSITION.md \
  docs/canon/references/chatgpt-project-instructions.md \
  docs/canon/references/skill-dependencies.json \
  docs/canon/references/validation-command-manifest.json
git rm .github/workflows/ambitions-constitution-audit.yml \
  scripts/ambitions-constitution-audit.py
git commit -m "docs: cut over to canonical specification system"
```

- [ ] **Step 6: Review and merge Train 5A**

Open the reviewed Train 5A cutover PR containing Tasks 24–26. The old trusted gate validates the transition. Repair all Critical/Important findings, obtain owner approval, and merge the reviewed Train 5A cutover PR so the verifier/workflow actually exists on protected `main`. An unmerged branch workflow is not live enforcement.

- [ ] **Step 7: Prove the live boundary before Gate C**

Immediately after merge, refresh `main`, run controlled external GitHub ruleset/environment/required-check inspection, and record the first durable post-merge protected-boundary receipt with the exact evidence fields required by the design. This activation inspection occurs before Gate C and outside Tasks 27–29. Independent review must confirm the receipt Green.

- [ ] **Step 8: Tag the merged cutover**

```bash
CUTOVER_SHA="$(git rev-parse origin/main)"
git tag -a ambitions-canon-v1-cutover "$CUTOVER_SHA" \
  -m "Ambitions canon and specification system authority cutover"
```

- [ ] **Step 9: Stop for Gate C and Train 5B**

Do not purge in Train 5A. Re-run start/finalize authorization for all benchmark scenarios from merged/tagged cutover. Gate C remains Red until the first receipt, rollback, independent review, and approved purge manifests are current and Green. Only then create or update the Train 5B continuation from merged Task 26 `main` in a separate reviewed PR/commit range.

---

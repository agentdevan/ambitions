# Ambitions Canon Train 5A — Shadow Verifier Foundation, Gate B Proof, and Authority Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Merge a reviewed shadow-only verifier foundation, run proof-only Gate B from those merged bytes, then atomically switch repo routing and CI to the new canon.

**Architecture:** Create the Task 24 foundation from the amended merged Train 4 head, integrate one reviewed Task 24 commit, and merge it without changing authority, routing, retained skills, replacement CI, or cutover. Create Tasks 25–26 from that merged foundation: Task 25 is proof/generated-output-only and Task 26 owns the single routing/CI cutover boundary. Every numbered task remains one reviewable commit.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors where explicitly scoped.

**Train 5 trust-topology amendment:** `TRAIN5-TRUST-TOPOLOGY-AMENDMENT-2026-07-17`, recorded at `docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json`, governs this plan where it is more specific than the original allocation.

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
- Release-proof task packs are complex with an exact estimated-token ceiling of 30,000. Every other budget class and mapping remains unchanged; the speculative `governance: normal` mapping MUST NOT survive.
- Reuse bounded reviewed patches from the frozen speculative Task 24/25 candidates. Do not repair, test, or merge those branches in place.
- Do not run expensive full regressions on speculative, intermediate, known-blocked, or structurally unmergeable candidates. Run one covering set after the complete Task 24 repair bundle is frozen; Task 25 performs its one proof run with merged verifier bytes. The qualifying integrated enforcement regression belongs to Task 29.
- No tracked change, including Task 24, may merge without current task authorization and protected-branch required CI. This amendment establishes neither and does not authorize break-glass. If protected enforcement cannot be established, stop for explicit one-time break-glass approval with incident record, rollback, and independent post-action review.

---

### Task 24: Merge the shadow-only verifier foundation

**Files:**
- Create: `tools/ambitions_canon/purge.py`
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/cli.py`
- Modify: `tools/ambitions_canon/task_pack.py`
- Create: `tools/ambitions_canon/authorization.py`
- Create: `tools/ambitions_canon/skill_conformance.py`
- Create: `tools/ambitions_canon/cutover_readiness.py`
- Create: `tools/ambitions_canon/authorization_benchmark.py`
- Create: `docs/canon/schemas/task-intake.schema.json`
- Create: `docs/canon/schemas/task-authorization.schema.json`
- Create: `docs/canon/schemas/trusted-event.schema.json`
- Create: `docs/canon/schemas/approval-attestation.schema.json`
- Create: `docs/canon/schemas/validation-attestation.schema.json`
- Create: `docs/canon/schemas/gate-b-evidence.schema.json`
- Modify: `docs/canon/schemas/task-pack.schema.json`
- Create: `docs/canon/references/skill-dependencies.json`
- Create: `docs/canon/references/validation-command-manifest.json`
- Create: `docs/canon/references/gate-b-evidence-registry.json`
- Create: `docs/canon/references/task-25-authorization-benchmark-policy.json`
- Create: `docs/canon/references/legacy-audit-invariant-parity.json`
- Modify: `docs/canon/references/task-authorization-policy.json` only if the Gate B binding requires it; otherwise leave it byte-identical.
- Create: `tests/canon/test_purge.py`
- Create: `tests/canon/test_authorization.py`
- Create: `tests/canon/test_skill_conformance.py`
- Create: `tests/canon/test_integration.py`
- Create: `tests/canon/test_cutover_readiness.py`
- Create: `tests/canon/test_authorization_benchmark.py`
- Modify: `tests/canon/test_task_pack.py`
- Create/update durable Task 24 implementation report: `docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md`.
- Update the ignored execution ledger at `.superpowers/sdd/progress.md`; it is not part of the Task 24 tracked commit.
- Create fixtures:
  - `tests/canon/fixtures/purge-eligible.toml`
  - `tests/canon/fixtures/purge-unresolved-claim.toml`
  - `tests/canon/fixtures/purge-active-reference.toml`
  - `tests/canon/fixtures/authority-outside-canon.txt`
  - `tests/canon/fixtures/task-intake-valid.json`
  - `tests/canon/fixtures/authorization-benchmarks/01-today-swiftui.json`
  - `tests/canon/fixtures/authorization-benchmarks/02-time-recurrence.json`
  - `tests/canon/fixtures/authorization-benchmarks/03-capture-proposal.json`
  - `tests/canon/fixtures/authorization-benchmarks/04-local-runtime-mutation.json`
  - `tests/canon/fixtures/authorization-benchmarks/05-cloudkit-continuity.json`
  - `tests/canon/fixtures/authorization-benchmarks/06-source-atlas-boundary.json`
  - `tests/canon/fixtures/authorization-benchmarks/07-accessibility-repair.json`
  - `tests/canon/fixtures/authorization-benchmarks/08-release-proof-claim.json`
  - `tests/canon/fixtures/task25-gate-b-visual-authority-manifest.json`, retained only as an omission/evidence-kind negative fixture and never as completeness authority
  - `tests/canon/fixtures/task25-gate-b-visual-complete-contract.json`, retained only as an omission/evidence-kind negative fixture and never as completeness authority

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
- The Task 24 verifier foundation is shadow and non-authoritative. It MUST NOT change `docs/canon/MANIFEST.toml` authority state, `AGENTS.md`, retained skills, replacement CI/workflows, protected ruleset configuration, or cutover state.
- `cutover_readiness.py`, the Gate B evidence schema/closed registry, fixed benchmark policy, and legacy-audit parity registry are reusable verifier inputs owned by Task 24 and merged before Task 25.
- Visual completeness is derived from merged canon, UX, and visual ledgers across exact screens, states, journeys, objects, accessibility variants, and visual requirements. Review dimensions come only from fixed merged policy. Caller-provided completeness or review dimensions cannot satisfy Gate B.
- `figma-design-export` is a closed evidence kind bound to Figma file key, node ID, frame version, artifact bytes/digest, and the merged visual ledger. Simulator-render evidence is separate and optional and cannot upgrade design-authority, accessibility, device, runtime, or release claims.
- `legacy-audit-invariant-parity.json` maps every base-owned old-audit invariant exactly once to equivalent-or-stronger replacement coverage and rejects missing, duplicate, unknown, or weaker mappings. Gate B requires parsed results for audit, build check, P0 coverage, traceability, and authority sprawl.
- Evidence reads are bounded, verifier-controlled subprocesses have explicit timeouts, rollback proof binds a real receipt or executable restore evidence, and any `gap_blocked_state_ids` entry keeps Gate B Red.
- `PACK_BUDGETS` remains exactly `mechanical=8_000`, `normal=16_000`, `complex=30_000`, and `constitutional-audit=None`. `TASK_TYPE_BUDGET_CLASS` remains exactly `mechanical→mechanical`, `docs→normal`, `release→complex`, `swiftui→complex`, `runtime→complex`, `privacy→complex`, and `constitutional-audit→constitutional-audit`. The release-proof benchmark uses task type `release`, class `complex`, and ceiling `30_000`; no other mapping changes. `governance` remains absent and must fail with `PACK_TASK_TYPE_UNKNOWN`, so the speculative `governance: normal` mapping cannot survive.

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

Add focused verifier-foundation negatives that reject:

1. caller-defined visual completeness, omitted required screen/state/journey/object/accessibility variant/visual requirement, caller-defined review dimensions, or any gap-blocked state;
2. simulator-render evidence offered as Figma design authority, incomplete Figma identity/artifact binding, or a visual design claim upgraded to runtime/device/accessibility proof;
3. missing, duplicate, unknown, or weaker old-audit parity mappings and any missing/non-Green one of the five replacement commands;
4. unbounded evidence input, verifier-controlled subprocess without an explicit timeout, or prose-only rollback evidence;
5. a release-proof task pack not classified complex at exact ceiling 30,000, any changed non-release budget mapping, or the speculative `governance: normal` mapping;
6. any Task 25 fixture or evidence attempting to load candidate-owned verifier/schema/policy/registry/CLI/test bytes.

Fold the durable cases from speculative `test_task24_review_repairs.py`, `test_task24_second_review_repairs.py`, and `test_task24_third_review_repairs.py` into the permanent owners `tests/canon/test_task_pack.py`, `tests/canon/test_authorization.py`, `tests/canon/test_purge.py`, `tests/canon/test_skill_conformance.py`, `tests/canon/test_integration.py`, `tests/canon/test_cutover_readiness.py`, and `tests/canon/test_authorization_benchmark.py`. Do not retain or stage the three repair-named test files in the integrated Task 24 commit.

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
python3.12 --version
python3.12 -m unittest tests/canon/test_purge.py tests/canon/test_authorization.py \
  tests/canon/test_skill_conformance.py tests/canon/test_integration.py \
  tests/canon/test_task_pack.py \
  tests/canon/test_cutover_readiness.py \
  tests/canon/test_authorization_benchmark.py -v
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

Implement authorization and the reusable Gate B verifier as pure standard-library functions over explicit inputs. Canonical JSON serialization uses sorted keys and a terminal newline; tree-delta, command-manifest, snapshot, approval, validation, evidence-artifact, benchmark-policy, and dependency digests use SHA-256; outputs are written through a temporary file and atomic replacement. Tree normalization reads Git objects/entries without rename/copy or binary heuristics. `task start`, `task finalize`, and the Gate B verifier perform no network/model/cloud calls. Current offline state means exact base-trusted, revisioned repository snapshots or platform-authenticated attestations; intake digest never proves external freshness. `skill-dependencies.json`, `validation-command-manifest.json`, the closed Gate B registry/policy, and legacy-audit parity registry own dependency and verification metadata, not product doctrine. Retained skills remain non-authoritative procedural adapters. Bound reads and subprocess timeouts fail closed; rollback and Figma evidence are digest-bound artifacts, never prose assertions.

- [ ] **Step 6: Run GREEN**

```bash
python3.12 --version
python3.12 -m unittest tests/canon/test_purge.py tests/canon/test_authorization.py \
  tests/canon/test_skill_conformance.py tests/canon/test_integration.py \
  tests/canon/test_task_pack.py \
  tests/canon/test_cutover_readiness.py \
  tests/canon/test_authorization_benchmark.py -v
python3.12 scripts/ambitions-canon.py skill-conformance --check
python3.12 scripts/ambitions-canon.py authority-sprawl --check
python3.12 scripts/ambitions-canon.py purge plan \
  --output .codex/canon-migration/sample-purge-plan.toml
python3.12 scripts/ambitions-canon.py purge verify \
  --plan .codex/canon-migration/sample-purge-plan.toml --dry-run
git diff --check
```

Expected: shadow authority-sprawl check permits only baseline legacy authority plus `docs/canon/`; sample plan verifies without mutation. Record the exact `python3.12 --version` output, interpreter executable identity, commands, exit codes, and results in `docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md`.

- [ ] **Step 7: Commit**

```bash
git add tools/ambitions_canon/purge.py tools/ambitions_canon/audit.py \
  tools/ambitions_canon/cli.py tools/ambitions_canon/authorization.py \
  tools/ambitions_canon/skill_conformance.py tools/ambitions_canon/task_pack.py \
  tools/ambitions_canon/cutover_readiness.py \
  tools/ambitions_canon/authorization_benchmark.py \
  docs/canon/schemas/task-intake.schema.json \
  docs/canon/schemas/task-authorization.schema.json \
  docs/canon/schemas/trusted-event.schema.json \
  docs/canon/schemas/approval-attestation.schema.json \
  docs/canon/schemas/validation-attestation.schema.json \
  docs/canon/schemas/gate-b-evidence.schema.json \
  docs/canon/schemas/task-pack.schema.json \
  docs/canon/references/skill-dependencies.json \
  docs/canon/references/validation-command-manifest.json \
  docs/canon/references/gate-b-evidence-registry.json \
  docs/canon/references/task-25-authorization-benchmark-policy.json \
  docs/canon/references/legacy-audit-invariant-parity.json \
  tests/canon/test_purge.py tests/canon/test_authorization.py \
  tests/canon/test_skill_conformance.py tests/canon/test_task_pack.py \
  tests/canon/test_integration.py tests/canon/test_cutover_readiness.py \
  tests/canon/test_authorization_benchmark.py \
  tests/canon/fixtures/purge-eligible.toml \
  tests/canon/fixtures/purge-unresolved-claim.toml \
  tests/canon/fixtures/purge-active-reference.toml \
  tests/canon/fixtures/authority-outside-canon.txt \
  tests/canon/fixtures/task-intake-valid.json \
  tests/canon/fixtures/authorization-benchmarks/01-today-swiftui.json \
  tests/canon/fixtures/authorization-benchmarks/02-time-recurrence.json \
  tests/canon/fixtures/authorization-benchmarks/03-capture-proposal.json \
  tests/canon/fixtures/authorization-benchmarks/04-local-runtime-mutation.json \
  tests/canon/fixtures/authorization-benchmarks/05-cloudkit-continuity.json \
  tests/canon/fixtures/authorization-benchmarks/06-source-atlas-boundary.json \
  tests/canon/fixtures/authorization-benchmarks/07-accessibility-repair.json \
  tests/canon/fixtures/authorization-benchmarks/08-release-proof-claim.json \
  tests/canon/fixtures/task25-gate-b-visual-authority-manifest.json \
  tests/canon/fixtures/task25-gate-b-visual-complete-contract.json \
  docs/canon/migration/TASK_24_IMPLEMENTATION_REPORT.md
git commit -m "feat: add shadow Gate B verifier foundation"
```

Stage `docs/canon/references/task-authorization-policy.json` separately only if the final reviewed Task 24 diff proves the Gate B binding requires a byte change. Never use a broad fixture-directory add.

- [ ] **Step 8: Independently review and merge the foundation**

Freeze one exact Task 24 review package and require consolidated specification-compliance, security/fail-closed, code-quality, determinism, proof-honesty, and claim-ceiling verdicts. Repair all Critical/Important findings in one bounded bundle, run one covering set, and perform one exact re-review. Merge the single Task 24 commit only under current task authorization and protected-branch required CI. The merge MUST leave authority state, `AGENTS.md` routing, retained skills, replacement CI, protected ruleset configuration, and cutover unchanged. If that enforcement cannot be established, stop; this plan does not authorize break-glass.

---
---

### Task 25: Run proof-only Gate B from merged verifier bytes

**Files:**
- Create generated report: `docs/canon/generated/cutover-readiness.md`
- Create: `docs/canon/migration/purge-plan.toml`
- Modify only deterministic generated outputs changed by frozen merged inputs.
- Create/update durable Task 25 implementation report: `docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md`.
- Update the ignored execution ledger at `.superpowers/sdd/progress.md`; it is not part of the Task 25 tracked commit.
- Do not create or modify verifier, schema, policy, registry, CLI, fixture, or test behavior.

**Interfaces:**
- old and new audits coexist;
- every old active authority has disposition;
- no accepted unique claim lost;
- no unresolved P0 conflict/gap;
- rollback tag exists;
- external reconciliation state explicit.
- Task 25 runs only the verifier, schemas, policies, registries, CLI, fixtures, and tests already merged by Task 24. The Task 25 tree is rejected if it supplies or substitutes any of those bytes.
- complete visual coverage is derived from merged canon/UX/visual ledgers and fixed review dimensions from merged policy;
- every required visual uses digest-bound `figma-design-export` evidence and every gap-blocked state keeps Gate B Red;
- the base-owned old audit runs, closed invariant parity passes, and audit/build/P0 coverage/traceability/authority-sprawl results all parse Green;
- rollback proof binds a real receipt or executable restore artifact; evidence reads are bounded and verifier-controlled subprocesses use explicit timeouts.
- Gate B remains hard Red until current ChatGPT handoff, authorization, skill-conformance, CI-regeneration, rollback, owner approval, and independent-review evidence is Green.
- The controller's delegated owner approval cannot waive any failed authorization, security, required-CI, protected-branch, or destructive-cleanup check.
- Gate B approval is bootstrap approval for Task 26 installation only. Live enforcement cannot be claimed from the branch; after the Train 5A merge, the first post-merge protected-boundary receipt must prove activation before Gate C. Task 29 later repeats inspection and proves no drift.

- [ ] **Step 1: Generate purge plan without deleting**

```bash
python3.12 scripts/ambitions-canon.py purge plan \
  --output docs/canon/migration/purge-plan.toml
```

Every artifact entry must contain action, replacement IDs, claim coverage, incoming-link status, external impact, owner approval, independent-review state, and rollback ref.

Generate the governed ChatGPT handoff/intake fixture set without authorizing implementation. The Gate B report must prove missing or stale intake, stale authorization envelope, and local-artifact substitution all fail closed.

- [ ] **Step 2: Run the proof-only Gate B matrix from merged Task 24 bytes**

```bash
python3.12 --version
python3.12 -m unittest -v \
  tests.canon.test_authorization_benchmark \
  tests.canon.test_cutover_readiness
python3.12 scripts/ambitions-constitution-audit.py
python3.12 scripts/ambitions-canon.py audit
python3.12 scripts/ambitions-canon.py build --check
python3.12 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3.12 scripts/ambitions-canon.py traceability --check
python3.12 scripts/ambitions-canon.py authority-sprawl --check
python3.12 scripts/ambitions-canon.py external-authority --check
python3.12 scripts/ambitions-canon.py conflicts report --require-resolved
python3.12 scripts/ambitions-canon.py migration claims coverage
python3.12 scripts/ambitions-canon.py skill-conformance --check
python3.12 scripts/ambitions-canon.py benchmark --require-authorization
python3.12 scripts/ambitions-canon.py purge verify \
  --plan docs/canon/migration/purge-plan.toml --dry-run
bash scripts/canon-language-drift-scan.sh
git diff --check
```

The verifier imports and executes its trusted behavior from the merged Task 24 base, treats the Task 25 checkout as evidence/generated output only, and rejects candidate-owned verifier/schema/policy/registry/CLI/test substitutions. Record the exact `python3.12 --version` output, interpreter executable identity, commands, exit codes, and results in `docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md`. This is the single Task 25 proof run for the frozen inputs; do not rerun it without a relevant verifier, policy, schema, fixture, evidence, or source-input change. This is not the qualifying whole-program regression.

The deterministic authorization benchmark must exercise all eight representative task scenarios under both `task start` and `task finalize`: Today SwiftUI, Time recurrence, Capture proposal flow, LocalRuntimeOS mutation, CloudKit continuity, Source Atlas boundary, accessibility repair, and release-proof claim. It MUST use the fixed merged Task 24 policy and fixtures rather than eight heavyweight repository integrations. For each scenario prove:

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

The Gate B visual and proof evaluation must also prove:

- the required visual set is the deterministic set derived from merged screen/state/journey/object/accessibility-variant/visual-requirement ledgers, not caller lists or circular manifests;
- review dimensions are the closed merged policy set;
- each required frame has `figma-design-export` evidence bound to file key, node ID, frame version, artifact bytes/digest, and merged visual ledger, while simulator-render evidence cannot widen the claim;
- `gap_blocked_state_ids` is empty;
- every old-audit invariant has one equivalent-or-stronger closed parity mapping and each of the five replacement commands emitted a parsed Green result;
- rollback restore evidence, bounded-read limits, and subprocess timeouts are present and verified.

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
- merged-base verifier isolation and candidate-byte rejection;
- deterministic visual coverage derivation, fixed review dimensions, Figma design-export evidence, and zero gap-blocked states;
- closed old-audit invariant parity and all five parsed replacement-command results;
- bounded reads, explicit timeouts, and real rollback restore evidence;
- purge eligibility;
- rollback.

Repair all Critical/Important findings.

- [ ] **Step 4: Record the Gate B / Task 26 bootstrap decision**

Only after every Gate B requirement is Green and the exact proof is independently reviewed may the report state `owner_gate_b_task_26_bootstrap_approval = true`, with decision date and the exact Task 26 installation scope. It must also state `gate_b = green`, `owner_destructive_approval = false`, `owner_purge_approval = false`, `purge_scope_approval_status = "deferred_to_gate_c"`, and `gate_c = red`, and name the independently reviewed authorization evidence. This approval authorizes Task 26 installation only; it is not cutover completion, live-enforcement proof, purge approval, or destructive approval. Without the bootstrap approval and Green Gate B evidence, stop.

- [ ] **Step 5: Commit readiness evidence**

```bash
git add docs/canon/generated/cutover-readiness.md \
  docs/canon/migration/purge-plan.toml \
  docs/canon/migration/TASK_25_IMPLEMENTATION_REPORT.md \
  docs/canon/generated/canon-index.json \
  docs/canon/generated/concept-ownership.json \
  docs/canon/generated/external-reference-impact.md \
  docs/canon/generated/law-proof-map.json \
  docs/canon/generated/law-source-map.json \
  docs/canon/generated/law-test-map.json \
  docs/canon/generated/requirement-graph.json \
  docs/canon/generated/supersession-manifest.json \
  docs/canon/generated/visual-authority-manifest.json
git commit -m "docs: prove canon cutover readiness"
```

Stage only the listed generated paths that actually changed under the frozen inputs; never use a broad directory add. The Task 25 commit MUST contain only the proof/generated material declared in this task.

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

Open the reviewed Train 5A cutover PR containing Tasks 25–26 from the already-merged Task 24 foundation. The old trusted gate validates the transition. Repair all Critical/Important findings, obtain owner approval, and merge the reviewed Train 5A cutover PR so the required workflow actually exists on protected `main`. An unmerged branch workflow is not live enforcement; the merged Task 24 verifier alone does not establish required CI.

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

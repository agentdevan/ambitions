# Ambitions Canon Train 5B — Destructive Supersession and Final Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete superseded repo authority in bounded commits, execute approved Linear/Figma destruction, and install final anti-regression proof.

**Architecture:** Begin the Train 5B continuation from merged Task 26 main only after the reviewed Train 5A cutover PR is merged, the first post-merge protected-boundary receipt is independently Green, and Gate C approves destructive continuation. Use a separate reviewed PR/commit range from Train 5A; `codex/canon-05-cutover` may be updated/recreated only from merged `main`. Every deletion batch has a reviewed manifest and rollback ref; external destruction uses exact stable IDs and owner approval.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors where explicitly scoped.

**Train 5 trust-topology amendment:** `TRAIN5-TRUST-TOPOLOGY-AMENDMENT-2026-07-17`, recorded at `docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json`, governs this plan where it is more specific than the original allocation. Task 28 is unchanged.

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
- ChatGPT expresses intent but cannot authorize implementation; PR intake is untrusted intent only. Project Instructions, skills, PR prose, contributor JSON, approval claims, validation/proof claims, and merge claims are not authority.
- Every tracked change requires current `task start` and exact-diff `task finalize` authorization computed from trusted base canon/policy/ownership, trusted event/approval provenance, and base-trusted revisioned snapshots. Any stale trusted input or canonical tree-delta mismatch fails closed.
- Required CI independently regenerates authorization through a base-owned/pinned verifier, treats PR checkout as data, and consumes only matching CI-owned validation attestations. Local hooks, local validation, task packs, envelopes, and receipts remain advisory/non-authoritative.
- Offline compiler checks never claim live external freshness. Mutable external state requires a separately authenticated revisioned snapshot or platform attestation.
- No routine bypass is allowed. Break-glass requires explicit owner approval, an incident record, rollback, and post-action independent review.
- Gate B and Gate C remain hard Red gates. Delegated owner approval for Tasks 22–29 cannot waive any Red, Critical, Important, authorization, security, required-CI, protected-branch, or destructive-cleanup requirement.
- Release-proof task packs are complex with an exact estimated-token ceiling of 30,000. Every other budget class and mapping remains unchanged; the speculative `governance: normal` mapping is prohibited.
- Task 29 uses fast deterministic unit/fixture tests for permanent negative cases and the eight representative scenarios, exactly one heavyweight end-to-end canary, one qualifying full regression after the integrated cross-cutting enforcement candidate is frozen, and a whole-train closeout rerun only if that candidate changed afterward.

---

## Gate C — Pre-destruction authorization

The activation inspection and first post-merge protected-boundary receipt occur before Gate C and are not part of blocked Tasks 27–29. Gate C blocks destructive Tasks 27–28 and destructive/migration-state-removal portions of Task 29 while that receipt, protected-branch posture, independent review, rollback, or exact purge manifests are missing, stale, or Red. Any non-destructive test preparation may occur earlier only when it changes no tracked state or external state. Before deletion, the controller may exercise delegated owner approval only after all mandated proof is Green. Every deletion remains bounded by its manifest and rollback; Gate C cannot waive trusted base, CI-owned evidence, live ruleset, or one-time break-glass requirements.

---

### Task 27: Purge superseded repo authority in bounded commits

**Files:**
- Delete only artifacts approved in `docs/canon/migration/purge-plan.toml`.
- Rewrite all tracked inbound references.
- Modify: `docs/canon/decisions/SUPERSESSION_LEDGER.toml`
- Remove temporary freeze baseline when no longer needed.

**Interfaces:**
- `purge verify` must pass before and after every batch;
- no active archive directory;
- rollback commit per batch.
- every deleted or rewritten skill, handoff, router, or bypass has verified replacement IDs, rewritten inbound references, explicit owner approval, independent review, and rollback before deletion.

- [ ] **Step 1: Batch A — product truth family**

Expected candidates after verified migration:

```text
docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_ORIGIN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/PRODUCT_EXPERIENCE_CANON.md
```

Delete only those marked eligible. Rewrite references and run purge verification. Commit:

```bash
git commit -m "docs: remove superseded product truth files"
```

- [ ] **Step 2: Batch B — implementation/process/release truth**

Expected candidates:

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
docs/truth/CODEX_START_HERE.md
docs/truth/README.md
```

Delete only after their durable laws and generated implementation/proof projections are verified. Commit separately.

- [ ] **Step 3: Batch C — engineering constitution and registries**

Delete approved:

```text
docs/constitution/ENGINEERING_CONSTITUTION.md
docs/constitution/articles/**
docs/constitution/laws/**
docs/constitution/opportunities/**
docs/constitution/law-source-map/**
docs/constitution/law-test-map/**
docs/constitution/*.json
docs/constitution/README.md
```

Retain no compatibility copy. Commit separately.

- [ ] **Step 4: Batch D — subordinate duplicated authority**

Delete or rewrite approved Figma-gate mirrors, old product handoff docs, stale retained skills, compatibility routers, and authority-like support docs. The manifest must enumerate all authorization bypass paths, including obsolete start/finalize wrappers, alternate task-pack routers, workflow exceptions, PR-controlled merge-authorizing validators, local-artifact or contributor-intake trust paths, copied Project Instructions presented as authority, stale trusted-state projections, reusable break-glass paths, and skills that carry law instead of canonical dependency metadata. Preserve source-adjacent build/validation docs only when current and non-normative.

For every candidate, verify replacement IDs, inbound-reference rewrites, current independent review, owner approval, and rollback before deletion. An unlisted or unresolved path blocks the batch; do not infer coverage from a broad directory entry.

- [ ] **Step 5: Verify after every batch**

```bash
python3 scripts/ambitions-canon.py purge verify \
  --plan docs/canon/migration/purge-plan.toml
python3 scripts/ambitions-canon.py authority-sprawl --check
python3 scripts/ambitions-canon.py audit
python3 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3 scripts/ambitions-canon.py traceability --check
python3 scripts/ambitions-canon.py skill-conformance --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
if git grep -nE 'docs/truth/|docs/constitution/' -- ':!docs/superpowers/**' \
  >.codex/canon-program/stale-authority-references.txt; then
  cat .codex/canon-program/stale-authority-references.txt
  exit 1
fi
git diff --check
```

Any active inbound reference blocks the batch.

Also scan for superseded handoff names, copied Project Instructions, alternate authorization commands, workflow bypasses, and retained skills missing canonical dependency metadata. Any active route around `task start`, `task finalize`, or independent CI regeneration blocks the batch.

- [ ] **Step 6: Remove migration-only freeze files after final repo batch**

Delete `scripts/ambitions-authority-freeze-check.py`, its test, and `authority-freeze-baseline.json` only when `authority-sprawl --check` is active and stronger.

---
---

### Task 28: Execute approved Linear and Figma destruction

**Files:**
- Modify tracked reconciliation/reference manifests.
- Delete temporary migration reconciliation files after completion.
- Generate final external-authority outputs.

**Interfaces:**
- external destruction uses owner-approved entity/node/file list;
- connector limitations remain explicit blockers;
- no false Green.

- [ ] **Step 1: Refresh every target before deletion**

For each Linear entity and Figma node/file, verify current title, modified state, authority status, replacement IDs, and owner approval still match the manifest.

- [ ] **Step 2: Destroy superseded Linear authority**

Delete superseded canon documents and remove copied canon prose from active execution objects. Preserve execution history, decisions referenced by the supersession ledger, and proof links. Archiving is only an interim Yellow blocker when deletion is technically unavailable; it does not satisfy this task.

If deletion is unsupported, produce a precise manual action packet and do not mark external purge Green until the owner confirms completion.

- [ ] **Step 3: Destroy superseded Figma authority**

Delete duplicate authority nodes after unique approved visual content is merged. Delete duplicate files where supported. Preserve canonical authority, failure evidence that remains materially useful, accessibility variants, and proof.

If file deletion is unsupported, produce exact file keys and owner action packet.

- [ ] **Step 4: Reconcile and validate**

```bash
python3 scripts/ambitions-canon.py external-authority --check
python3 scripts/ambitions-canon.py build
python3 scripts/ambitions-canon.py build --check
git diff --check
```

- [ ] **Step 5: Remove temporary reconciliation files and commit**

```bash
git rm docs/canon/migration/linear-reconciliation.json \
  docs/canon/migration/figma-reconciliation.json
git add docs/canon/references docs/canon/generated \
  docs/canon/decisions/SUPERSESSION_LEDGER.toml
git commit -m "docs: complete external authority supersession"
```

---
---

### Task 29: Install final anti-regression gates and close the program honestly

**Files:**
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/purge.py`
- Modify: `tools/ambitions_canon/authorization.py`
- Modify: `tools/ambitions_canon/skill_conformance.py`
- Modify: `.github/workflows/ambitions-canon-audit.yml`
- Modify: `tests/canon/test_authorization.py`
- Modify: `tests/canon/test_skill_conformance.py`
- Create: `docs/canon/schemas/ruleset-evidence.schema.json`
- Generate from reviewed external evidence: `docs/canon/generated/github-authorization-boundary.json`
- Delete temporary migration catalogs that no longer serve active governance.
- Generate final:
  - `docs/canon/generated/INDEX.md`
  - `docs/canon/generated/specification-coverage.md`
  - `docs/canon/generated/codex-consumption-benchmark.md`
  - `docs/canon/generated/supersession-manifest.json`
  - `docs/canon/generated/external-reference-impact.md`

**Interfaces:**
- CI fails on authority outside canon, duplicate owner/ID, stale output, superseded reference, incomplete P0 profile, missing traceability, unknown external ID, unbuildable declared task pack, bypassed amendment, or deleted authority reference.
- CI independently regenerates authorization from checkout plus machine-readable PR intake, authorizes only the exact final diff/changed-file set, and rejects checked-in or local packs, envelopes, and receipts as proof.
- The protected-branch/ruleset requires the named authorization check and has no routine bypass.
- The merge-authorizing validator/policy/workflow is trusted-base-owned or immutably pinned; required-check identity binds context, workflow path/ref/digest, and expected GitHub integration/app identity.
- The trusted validation workflow and its command manifest are base-owned or immutably pinned. A validation attestation binds the workflow path/ref/digest, command-manifest digest, exact command/check identity, repository/base/head/merge-base, integration identity, exit status, artifacts, and claim; any re-attested untrusted Green result is invalid.
- The first post-merge receipt proves the initial live protected boundary before Gate C. Task 29 is the final no-drift proof boundary: final authorization-enforcement and closeout claims require a repeated controlled external GitHub configuration inspection plus independent review.
- The final claim rule is exact: permanent authorization enforcement cannot be claimed until that repeated inspection and independent review prove no drift at Task 29 closeout.
- Permanent verifier tests bind the merged Task 24 foundation identity and reject any Task 25 candidate-owned verifier, schema, policy, registry, CLI, fixture, or test behavior.
- Break-glass status is `not_used` by default. A live break-glass attestation is required only if an actual incident has separate explicit owner approval and the one-time path is used.

- [ ] **Step 1: Write final negative tests**

Add tests for:

- new `PRODUCT_TRUTH.md` outside canon;
- reused retired ID;
- stale generated output;
- active reference to deleted old truth;
- unknown Linear/Figma requirement;
- amendment without impact record;
- cutover manifest reverting to shadow;
- task pack for declared scope failing to build;
- missing or stale intake;
- stale task pack and stale authorization envelope;
- undeclared changed file or mismatched exact final diff;
- missing finalization;
- stale, undeclared, circular, or authority-bearing skill dependencies;
- contributor-generated pack, envelope, or receipt offered as CI proof;
- intake carrying authoritative approval, authorized scope, proof, validation result, break-glass, or merge claims;
- repository/PR/base/head/merge-base mismatch, missing objects, base movement, force-push/head replacement, or inconsistent merge base;
- incomplete raw Git tree-entry delta for delete/add move representation, copy-as-add representation, opaque blob, raw-path byte encoding, symlink, mode-only, submodule gitlink, deletion, merge commit, clean-head, or synthetic-merge-checkout compatibility cases;
- PR-controlled validator/schema/policy/workflow or wrong required-check workflow/integration identity;
- changed PR validation workflow or command manifest, wrong command-manifest digest, wrong command/check identity, wrong integration identity, or an untrusted advisory result re-attested as Green;
- missing, stale, contributor-authored, mismatched-head, skipped-required, or non-Green CI-owned validation attestation;
- stale or contributor-asserted external state presented as a current trusted snapshot;
- forged/stale live-ruleset receipt or reused, revoked, expired, scope-drifted break-glass attestation;
- caller-defined visual completeness, omission of any required screen/state/journey/object/accessibility variant/visual requirement, caller-defined review dimensions, or any gap-blocked state;
- visual authority evidence other than a digest-bound `figma-design-export`, incomplete Figma/artifact identity, or design evidence used to upgrade runtime/device/accessibility claims;
- missing, duplicate, unknown, or weaker legacy-audit invariant mapping, or a missing/non-Green result for audit, build check, P0 coverage, traceability, or authority sprawl;
- unbounded evidence input, verifier-controlled subprocess without an explicit timeout, or prose-only rollback without a bound restore receipt/artifact;
- release-proof task-pack classification other than complex at exact ceiling 30,000, any changed non-release budget mapping, or `governance: normal`;
- Task 25 candidate-owned verifier/schema/policy/registry/CLI/test behavior or execution that does not bind the merged Task 24 verifier bytes;
- a Task 25 report using `owner_cutover_approval`, approving a purge/destructive scope, omitting the Task 26-only bootstrap scope, or failing to keep Gate C Red and purge approval deferred;
- break-glass status other than `not_used` when no separately approved actual incident occurred, or a live attestation without the bound approval/incident/use/post-action review;
- Task 24, Task 25, or Task 29 durable proof evidence missing the exact Python 3.12 version/executable identity or recording a different Python major/minor;
- bypassed amendment;
- deleted authority reference.

Every negative test must assert a stable error code and fail closed without partial output. Include protected-branch workflow fixtures that prove the required check regenerates authorization instead of accepting local artifacts.

Keep these cases as fast deterministic unit/fixture tests. Do not turn the eight representative scenarios into eight heavyweight repository integrations.

Add transition fixtures proving the old trusted gate validates a prior-approved verifier/policy digest, the ruleset switch occurs only after merge and independent proof, and no configuration path creates an unprotected interval.

- [ ] **Step 2: Run RED, implement, and run GREEN**

Follow TDD for every new gate. Rename workflow only after tests pass.

- [ ] **Step 3: Remove migration-only state**

Delete tracked raw migration catalogs, claim dispositions, and purge plan only when their durable results exist in the supersession ledger and generated manifests. Keep no active archive.

- [ ] **Step 4: Freeze the integrated candidate and run the qualifying verification**

```bash
python3.12 --version
python3.12 -m unittest discover -s tests/canon -p 'test_*.py' -v
python3.12 -m compileall -q tools/ambitions_canon scripts/ambitions-canon.py
python3.12 scripts/ambitions-canon.py authority-sprawl --check
python3.12 scripts/ambitions-canon.py audit
python3.12 scripts/ambitions-canon.py coverage --fail-on-p0-gap
python3.12 scripts/ambitions-canon.py traceability --check
python3.12 scripts/ambitions-canon.py external-authority --check
python3.12 scripts/ambitions-canon.py conflicts report --require-resolved
python3.12 scripts/ambitions-canon.py build --check
python3.12 scripts/ambitions-canon.py skill-conformance --check
python3.12 scripts/ambitions-canon.py benchmark --require-authorization
python3.12 scripts/ambitions-canon.py authorization canary \
  --handoff docs/canon/generated/CHATGPT_CODEX_HANDOFF.md
python3.12 scripts/ambitions-canon.py ruleset-evidence --check \
  docs/canon/generated/github-authorization-boundary.json
python3.12 scripts/ambitions-remediation-governance-check.py
python3.12 scripts/ambitions-truth-path-vocabulary-audit.py
bash scripts/canon-language-drift-scan.sh
if git grep -nE 'docs/truth/|docs/constitution/' -- ':!docs/superpowers/**' \
  >.codex/canon-program/stale-authority-references.txt; then
  cat .codex/canon-program/stale-authority-references.txt
  exit 1
fi
git diff --check
```

Expected: all required commands exit `0`; grep returns no active references outside retained historical implementation plans/specs. Historical plans may mention old paths as truthful history but cannot be routing authority. Record the exact `python3.12 --version` output, interpreter executable identity, commands, exit codes, and results in the durable Task 29 closeout evidence.

This is the one qualifying full regression after the integrated cross-cutting authorization/enforcement candidate is frozen. Do not run another whole-train regression at closeout unless tracked verifier, policy, schema, fixture, evidence, generated source input, enforcement, or cleanup bytes change after this run. If they do change, freeze the final candidate and rerun this exact whole-train matrix once.

The ChatGPT-to-Codex canary is the program's exactly one heavyweight end-to-end canary. It must run from governed Project Instructions and a ChatGPT handoff through request-only schema-valid task intake, trusted event/approval provenance, base-owned/pinned CI `task start`, CI-owned validation attestations, exact base-to-head tree-delta `task finalize`, and merge-check result. It must prove ChatGPT intent is not authorization and must not use a model, network, cloud service, or contributor-generated authorization artifact during offline verification. Do not run a second heavyweight canary unless its bound inputs changed and the prior result is therefore stale.

Run all eight representative handoff benchmarks through the merged deterministic harness and fixed fixtures: Today SwiftUI, Time recurrence, Capture proposal flow, LocalRuntimeOS mutation, CloudKit continuity, Source Atlas boundary, accessibility repair, and release-proof claim. Each benchmark must cover start, resume/regeneration, finalization, exact changed files, skill freshness, required validation/proof, and claim ceiling without becoming a separate heavyweight repository integration.

Task 29 repeats the controlled external GitHub configuration inspection separately from the offline compiler and proves no drift from the first post-merge receipt acquired before Gate C. Record a durable independently reviewed receipt with repository/ruleset/environment IDs, protected ref, required check context plus integration/app identity, workflow path/ref/digest, command-manifest digest, required reviewers, bypass actors/posture, and observed status. The compiler can validate the receipt and its trusted bindings but the compiler cannot manufacture live proof.

Do not exercise break-glass merely to produce proof. Record `break_glass_status = "not_used"` by default with no synthetic live attestation. If and only if an actual incident has separate explicit owner approval and the path is used, record a platform-authenticated one-time attestation bound to incident ID, repository, PR, base/head, exact scope, authenticated owner principal, rollback, expiry/revocation, actual use, and post-action independent review. Deterministic fixtures still reject reuse, ordinary routing, scope drift, missing incident record, expiry, or revocation. Gate B/C and delegated approval cannot waive these properties.

Record the exact ChatGPT Project Instructions SHA-256, Python 3.12 version/executable identity, trusted snapshot revisions/digests, protected-branch/ruleset posture, repository/ruleset/environment IDs, required check context/status and integration/app identity, workflow path/ref/digest, reviewers, bypass posture, canary result, all eight benchmark results, `break_glass_status`, any conditionally used attestation/incident evidence, rollback reference, and exact governance claim ceiling in the final generated closeout.

- [ ] **Step 5: Final whole-branch review**

Use a fresh most-capable reviewer against the full Train 5 diff. Require explicit verdicts on:

- design/spec compliance;
- compiler quality;
- authority completeness;
- semantic loss;
- external reconciliation;
- deletion safety;
- rollback;
- proof/claim ceiling;
- ChatGPT-to-Codex authorization and local-artifact rejection;
- skill dependency conformance;
- protected-branch required-check evidence and Gate C integrity.
- trusted event/tree-delta, base-owned verifier, CI-owned attestation, live-ruleset receipt, and either `break_glass_status = "not_used"` or the conditionally required one-time incident evidence.

Repair and re-review all Critical/Important findings.

- [ ] **Step 6: Commit final gates**

```bash
git add tools/ambitions_canon tests/canon .github/workflows \
  docs/canon scripts/ambitions-canon.py
git commit -m "test: enforce the canonical specification system"
```

- [ ] **Step 7: Finish the development branch**

Use `superpowers:finishing-a-development-branch`. Prefer a reviewed draft PR, then merge Train 5 only after CI and owner acceptance.

## Program Closeout Contract

The final report must state:

```text
Baseline tag and SHA:
Cutover tag and SHA:
Final SHA:
Trains and PRs:
Task 24 shadow verifier-foundation PR and merge SHA:
Train 5A cutover PR, merge SHA, and first post-merge receipt:
Train 5B destructive/finalization PR, merge SHA, and repeated no-drift receipt:
Files created:
Files deleted:
Linear entities destroyed/rewritten:
Figma nodes/files destroyed/retained:
Constitution law count:
Specification counts by kind:
Concept owner count:
Requirement count:
P0/P1 gap counts:
Traceability coverage:
Codex benchmark results:
ChatGPT Project Instructions SHA-256:
Protected-branch/ruleset posture:
Required authorization check name and status:
Required check workflow path/ref/digest and integration/app identity:
Trusted snapshot revisions/digests:
Live repository/ruleset/environment evidence receipt:
Required reviewers and bypass actors/posture:
Break-glass status (`not_used` by default; incident/attestation/revocation only if used):
Python 3.12 interpreter version/executable identity:
Single heavyweight ChatGPT-to-Codex canary result:
Eight deterministic handoff benchmark results:
Qualifying full-regression SHA/result and whether a closeout rerun was required:
Validation run with exit codes:
Validation not run and why:
Independent reviews:
Known residual risks:
External manual actions still required:
Rollback:
Claim ceiling:
```

Allowed governance conclusion:

```text
Canon system Source Green / Governance Green for the exact verified scope
```

Forbidden conclusions without separate current evidence:

```text
Product complete
Runtime Green
Visual Green
Accessibility Green
Privacy/legal approved
Device ready
TestFlight ready
App Store ready
Release Green
```

## Execution Recommendation

Use **Subagent-Driven Development** within each train and stacked draft PRs between trains.

- Fresh implementer per task.
- Independent task review after every commit.
- Sol High for compiler/integration.
- Sol Max for conflict synthesis, normative writing, semantic-loss audit, and whole-train review.
- Ultra only for parallel read-only inventories and domain audits.
- One canonical writer for Constitution/Atlas changes.
- Mandatory owner gates after conflict dockets, before cutover, and before destructive external cleanup.
- Gate B and Gate C remain hard Red until every mandated authorization, required-CI, rollback, independent-review, and destructive-cleanup proof is Green; delegated approval cannot waive them.
- Do not execute all 30 tasks as one uninterrupted branch. The five-train boundary is part of the safety architecture.

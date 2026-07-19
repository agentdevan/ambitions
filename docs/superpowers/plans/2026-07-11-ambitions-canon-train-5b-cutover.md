# Ambitions Canon Train 5B — Destructive Supersession and Final Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete superseded repo authority in bounded commits, execute approved Linear/Figma destruction, and close with compact permanent negatives, one canary, and one regression.

**Architecture:** Begin the Train 5B continuation from integrated Task 26 main only after Gate C approves destructive continuation from exact SHA-bound authorization, one exact high-risk review, rollback, privacy/security/proof-honesty review, owner-approved Search frames, and exact destructive manifests/dry-runs. Use a separate reviewed commit range from Train 5A. Every deletion batch has a reviewed manifest and rollback ref; external destruction uses exact stable IDs and owner approval. No protected-boundary receipt or GitHub protection inspection is required.

**Tech Stack:** Python 3.12 standard library (`dataclasses`, `enum`, `tomllib`, `json`, `hashlib`, `sqlite3`, `argparse`, `pathlib`, `tempfile`, `unittest`), Markdown with TOML front matter, TOML/JSON registries, Git, GitHub Actions, Linear and Figma connectors where explicitly scoped.

**Train 5 trust-topology amendment:** `TRAIN5-TRUST-TOPOLOGY-AMENDMENT-2026-07-17`, recorded at `docs/superpowers/amendments/2026-07-17-train-5-trust-topology-amendment.json`, governs this plan where it is more specific than the original allocation. Task 28 is unchanged.

**Owner direct-integration override:** `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` supersedes every protected-branch, required-CI/check, CI-installation, ruleset-inspection, live-boundary activation/no-drift receipt, and post-merge protected-receipt prerequisite for Tasks 24–29. Those controls remain unimplemented and MUST NOT be claimed. Direct integration is authorized only after exact SHA-bound local authorization and verification, one exact high-risk review, the bound owner-approved break-glass record, and current rollback evidence. Gate C retains exact destructive manifests/dry-runs, rollback, independent review, privacy/security/proof-honesty review, and owner-approved Search frames. Task 29 is limited to compact permanent negatives, one canary, and one regression closeout with no GitHub protection inspection. Final claims explicitly exclude protected enforcement, and one reviewable commit per numbered task remains mandatory. Any contradictory Task 24–29 wording below is superseded by this paragraph and the bound amendment record.

Task 24 additionally owns exactly two non-directional canon evidence inputs: `docs/canon/specifications/global/search.md` and `docs/canon/specifications/journeys/search-find-ask-act-inspect.md`. Their content-identity change owns all fourteen `docs/canon/generated/` manifest projections, `docs/canon/generated/codex-consumption-benchmark.md`, plus freshness-only rebinding of `docs/canon/migration/UX_BLUEPRINT.md`, `VISUAL_AUTHORITY_REBASELINE.md`, `ux-blueprint-requirement-dispositions.json`, `ux-blueprint.json`, `visual-authority-r1-node-snapshot.json`, `visual-authority-rebaseline.json`, `docs/canon/registries/command-gate-approval-receipts.json`, and `command-gate-dependencies.json`; Task 24 also owns this five-document topology amendment bundle. After inputs freeze, perform those deterministic rebindings and regenerate the fifteen generated projections exactly once, then require `build --check` Green. Task 25 may not change those inputs or freshness outputs while they remain frozen. Tasks 24–29 use existing task type `release`, budget class `complex`, and exact ceiling `30,000`; `governance` remains unknown and fails `PACK_TASK_TYPE_UNKNOWN`.

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
- Tasks 24–29 use exact SHA-bound local authorization/finalization and verification under owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`; protected CI is not installed, required, inspected, or claimed.
- Offline compiler checks never claim live external freshness. Mutable external state requires a separately authenticated revisioned snapshot or platform attestation.
- The owner decision is the bounded break-glass record for direct integration. It requires one exact high-risk review and rollback and creates no reusable or routine bypass.
- Gate B and Gate C remain hard Red for retained authorization, Critical/Important repair, security/privacy/proof honesty, rollback, owner-approved Search frames, and destructive manifests/dry-runs. Protected CI and branch/ruleset proof are excluded for Tasks 24–29.
- Release-proof task packs are complex with an exact estimated-token ceiling of 30,000. Every other budget class and mapping remains unchanged; the speculative `governance: normal` mapping is prohibited.
- Task 29 is limited to compact deterministic permanent negatives, exactly one end-to-end canary, and exactly one qualifying regression after the candidate is frozen. It performs no GitHub protection inspection or whole-train rerun.

---

## Gate C — Pre-destruction authorization

Gate C blocks destructive Tasks 27–28 and destructive/migration-state-removal portions of Task 29 while exact SHA-bound authorization/finalization, one exact high-risk review, rollback, privacy/security/proof-honesty review, owner-approved Search frames, or exact destructive manifests and dry-runs are missing, stale, or Red. Any non-destructive test preparation may occur earlier only when it changes no tracked or external state. Every deletion remains bounded by its exact manifest, dry-run, and rollback. Protected-branch posture, required CI/checks, ruleset inspection, and post-merge/live-boundary receipts are not Gate C requirements for Tasks 24–29 and must not be claimed.

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

### Task 29: Run compact anti-regression proof and close the program honestly

**Files:**
- Modify: `tools/ambitions_canon/audit.py`
- Modify: `tools/ambitions_canon/purge.py`
- Modify: `tools/ambitions_canon/authorization.py`
- Modify: `tools/ambitions_canon/skill_conformance.py`
- Modify: `tests/canon/test_authorization.py`
- Modify: `tests/canon/test_skill_conformance.py`
- Delete temporary migration catalogs that no longer serve active governance.
- Generate final:
  - `docs/canon/generated/INDEX.md`
  - `docs/canon/generated/specification-coverage.md`
  - `docs/canon/generated/codex-consumption-benchmark.md`
  - `docs/canon/generated/supersession-manifest.json`
  - `docs/canon/generated/external-reference-impact.md`

**Interfaces:**
- compact permanent tests fail closed on exact-diff authorization, stale or authority-bearing inputs, proof overclaim, destructive-manifest/dry-run mismatch, rollback mismatch, privacy/security violations, unapproved Search frames, bypassed amendment, or deleted authority references;
- permanent verifier tests bind the integrated Task 24 foundation identity and reject Task 25-owned verifier/schema/policy/registry/CLI/fixture/test behavior;
- exactly one canary and one qualifying regression run from the frozen final candidate;
- Task 29 changes no `.github/workflows/**` path, creates no ruleset-evidence schema or GitHub-boundary artifact, and performs no branch-protection, required-check, ruleset, activation, or no-drift inspection;
- final evidence records owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z`, exact reviewed SHA, rollback, `live_enforcement_proven = false`, and an explicit protected-enforcement exclusion.

- [ ] **Step 1: Write final negative tests**

Keep one compact deterministic table of permanent negatives covering:

- undeclared changed files, stale exact-diff authorization/finalization, or an exact reviewed-SHA mismatch;
- missing/mismatched owner decision `OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z` or an attempt to reuse it outside Tasks 24–29;
- intake, task pack, skill, or contributor artifact asserting authority, proof, validation, break-glass, or merge permission;
- missing Critical/Important repair, security/privacy/proof-honesty review, or owner-approved Search-frame evidence;
- missing, stale, overbroad, or dry-run-mismatched destructive manifest;
- missing or prose-only rollback evidence;
- Task 25-owned verifier/schema/policy/registry/CLI/fixture/test behavior;
- `live_enforcement_proven = true`, `post_merge_receipt_required = true`, or any protected-enforcement/no-drift claim;
- bypassed amendment or active reference to deleted authority.

Every negative asserts a stable error code and fails closed without partial output. Do not add protected-branch workflow fixtures, ruleset transition fixtures, or GitHub-protection evidence. The eight representative scenarios may run inside the single deterministic regression; they are not separate heavyweight integrations.

- [ ] **Step 2: Run RED, implement, and run GREEN**

Follow TDD for each compact permanent negative. Do not create, rename, or modify a workflow.

- [ ] **Step 3: Remove migration-only state**

Delete tracked raw migration catalogs, claim dispositions, and purge plan only when their durable results exist in the supersession ledger and generated manifests. Keep no active archive.

- [ ] **Step 4: Freeze the integrated candidate and run the qualifying verification**

```bash
python3.12 --version
# compact permanent negatives and the one qualifying regression
python3.12 -m unittest discover -s tests/canon -p 'test_*.py' -v
# exactly one canary
python3.12 scripts/ambitions-canon.py authorization canary \
  --handoff docs/canon/generated/CHATGPT_CODEX_HANDOFF.md
git diff --check
```

Expected: the compact negatives/regression, the one canary, and `git diff --check` exit `0`. Record the exact `python3.12 --version` output, interpreter executable identity, frozen SHA, commands, exit codes, and results in durable Task 29 closeout evidence. Do not add a GitHub-protection or ruleset inspection command.

This is the one qualifying regression after the integrated candidate is frozen. Do not run a second whole-train or closeout regression.

The ChatGPT-to-Codex canary is the program's exactly one end-to-end canary. It runs from governed Project Instructions and a ChatGPT handoff through request-only schema-valid intake, exact SHA-bound local `task start`, local validation evidence, exact tree-delta `task finalize`, owner-decision binding, and review result. It proves ChatGPT intent is not authorization and uses no model, network, cloud service, protected CI, or contributor-generated authorization artifact during verification. Do not run a second canary.

Run all eight representative handoff benchmarks through the merged deterministic harness and fixed fixtures: Today SwiftUI, Time recurrence, Capture proposal flow, LocalRuntimeOS mutation, CloudKit continuity, Source Atlas boundary, accessibility repair, and release-proof claim. Each benchmark must cover start, resume/regeneration, finalization, exact changed files, skill freshness, required validation/proof, and claim ceiling without becoming a separate heavyweight repository integration.

Task 29 performs no controlled external GitHub configuration, branch-protection, ruleset, environment, required-check, activation, or no-drift inspection. No protected-boundary receipt is generated or required.

Record `owner_break_glass_decision_id = "OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z"`, the exact authorized/reviewed SHA, one exact high-risk review, current rollback, and the Task 24–29 scope. Reject reuse, ordinary routing outside the bound scope, scope drift, or missing rollback/review.

Record the exact ChatGPT Project Instructions SHA-256, Python 3.12 version/executable identity, trusted snapshot revisions/digests, canary result, the one regression result including the eight deterministic scenarios, owner decision, exact reviewed SHA, rollback reference, `live_enforcement_proven = false`, and the exact governance claim ceiling. The final claim must say protected enforcement was neither installed nor proven and is excluded.

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
- Gate C integrity, exact destructive manifests/dry-runs, privacy/security/proof honesty, and owner-approved Search frames;
- exact local event/tree-delta authorization/finalization, owner decision, one exact high-risk review, rollback, and the explicit protected-enforcement exclusion.

Repair and re-review all Critical/Important findings.

- [ ] **Step 6: Commit final gates**

```bash
git add tools/ambitions_canon tests/canon docs/canon scripts/ambitions-canon.py
git commit -m "test: enforce the canonical specification system"
```

- [ ] **Step 7: Finish the development branch**

Use `superpowers:finishing-a-development-branch`. Integrate the exact reviewed Task 29 commit directly only after owner acceptance, exact SHA-bound local authorization/finalization, the one high-risk review, and rollback. Protected CI is not required or claimed.

## Program Closeout Contract

The final report must state:

```text
Baseline tag and SHA:
Cutover tag and SHA:
Final SHA:
Trains and PRs:
Task 24 shadow verifier-foundation exact integration SHA:
Train 5A direct-integration exact SHAs:
Train 5B destructive/finalization exact SHAs:
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
Protected enforcement: not installed or proven; explicitly excluded
Trusted snapshot revisions/digests:
Protected-boundary receipt: not required or produced
Owner break-glass decision: OWNER-TRAIN5-DIRECT-INTEGRATION-2026-07-17T234045Z
Exact locally authorized and reviewed SHA:
Python 3.12 interpreter version/executable identity:
Single heavyweight ChatGPT-to-Codex canary result:
Eight deterministic handoff benchmark results:
Single qualifying regression SHA/result:
Validation run with exit codes:
Validation not run and why:
Independent reviews:
Known residual risks:
External manual actions still required:
Rollback:
Claim ceiling (must explicitly exclude protected enforcement):
```

Allowed governance conclusion:

```text
Canon system Source Green / Governance Green for the exact verified scope; protected enforcement excluded
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
- Gate B and Gate C remain hard Red until retained exact SHA authorization/finalization, rollback, high-risk review, privacy/security/proof honesty, owner-approved Search frames, and exact destructive manifests/dry-runs are Green. Protected CI and GitHub protection inspection are excluded for Tasks 24–29 and must not be claimed.
- Do not execute all 30 tasks as one uninterrupted branch. The five-train boundary is part of the safety architecture.

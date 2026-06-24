# SCG-008 Parent Closeout + SCG-009 Handoff

Issue scope: `AMB-1291` / SCG-008 parent closeout, plus `AMB-1292` / SCG-009 child materialization.

Generated: `2026-06-24T03:56:43Z`
Branch: `main`
Baseline SHA: `9bf3fe320bdfb283e9edda678c29442ec939041e`
Final SHA: commit containing this handoff artifact; record exact SHA in Linear/final closeout after commit creation
Status: `Yellow - bounded control/handoff complete`
Status ceiling: `SCG-008 parent honest Yellow; no Visual Green, Release Green, senior-readiness, app release-ready, owner acceptance, or SCG-009 implementation claim`

## Authority Reviewed

- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `docs/quality/senior-review/REPAIR_TRAINS.json`
- `docs/quality/senior-review/REPAIR_TRAINS.md`
- `docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json`
- `docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.json`
- `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.md`
- `docs/quality/senior-review/SCG-008C_STAGE_ACTION_PIPELINE_INVENTORY.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`

## SCG-008 Parent Reconciliation

Decision: close `AMB-1291` / SCG-008 as honest Yellow if this handoff validation passes.

Rationale:

- SCG-008A, SCG-008B, and SCG-008C have all landed on `main` and `origin/main`.
- Each child is bounded to a narrow source/control repair area.
- Child comments and issue descriptions keep broad senior audit residue, visual proof, release proof, owner acceptance, and later SCG work outside the child claims.
- Known-issues mappings touched by SCG-008 children remain synchronized without closing rows that still require runtime/device/visual/accessibility proof.
- SCG-007A known-issues sync verdict allowed bounded child issue generation and found no missing real Red/B0/B1/B2 known-issues row.
- Broad SCG residues remain Yellow/Red outside SCG-008 scope, so the parent cannot be Green.

Parent cannot claim:

- Visual Green
- Release Green
- senior-readiness
- app release-ready
- owner acceptance
- device proof
- manual accessibility proof
- SCG-009 implementation progress
- SCG-010 or later progress

## SCG-008 Child Evidence Summary

| Child | Linear | SHA | Bounded result | Findings | Root causes | Known-issues mapping |
|---|---|---:|---|---|---|---|
| SCG-008A Copy Gate Expansion | `AMB-1299` | `bb81448ff93eeede8d2021361dc52b6770018be2` | Yellow; focused copy-gate evidence Green only | `SCG-004-006`; fixture support `SCG-004-905` | `RC-SCG006-010`, `RC-SCG006-001` | `AMB-ISSUE-0010` mapped/touched; related QA rows referenced, not duplicated |
| SCG-008B Typed Mutation / Proof | `AMB-1300` | `28b660bbc937ef32d517aa88726e64df395b4bd8` | Yellow; source/runtime proof Green only for touched typed mutation/proof paths | `SCG-004-004`; fixture support `SCG-004-903` | `RC-SCG006-001`, `RC-SCG006-004`, `RC-SCG006-007` | `AMB-ISSUE-0004`, `AMB-ISSUE-1401` updated; both remain runtime/device proof pending |
| SCG-008C Stage Action Pipeline | `AMB-1301` | `9bf3fe320bdfb283e9edda678c29442ec939041e` | Yellow; bounded Source Green for touched Stage action pipeline contracts | `SCG-004-004`, `SCG-004-011` | `RC-SCG006-001`, `RC-SCG006-002`, `RC-SCG006-004`, `RC-SCG006-006`, `RC-SCG006-007` | Rows referenced in traces/inventory only; no row closed |

SCG-008C retained inventory:

- `docs/quality/senior-review/SCG-008C_STAGE_ACTION_PIPELINE_INVENTORY.md`

## Known-Issues Dedupe / Mapping

No duplicate known-issues rows or duplicate QA remediation issues were created in this handoff.

Primary synchronized evidence:

- `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.json`
- `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.md`
- `docs/qa/KNOWN_ISSUES.md`

SCG-007A sync verdict:

- `Ready for bounded child issue generation`
- `rows_added`: `0`
- `rows_updated`: `0`
- Open B0/B1/B2 counts: `0 / 0 / 0`
- Open B3/B4 SCG record counts remain accepted Yellow input, not senior-readiness proof.

Rows referenced or touched by SCG-008 children:

- `AMB-ISSUE-0010`
- `AMB-ISSUE-0004`
- `AMB-ISSUE-1401`
- Capture trace rows: `AMB-ISSUE-0003`, `AMB-ISSUE-0008`, `AMB-ISSUE-0012`, `AMB-ISSUE-1101`-`AMB-ISSUE-1107`
- Today action rows: `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`AMB-ISSUE-1007`
- Time handoff rows: `AMB-ISSUE-0009`, `AMB-ISSUE-0501`-`AMB-ISSUE-0507`, `AMB-ISSUE-0913`, `AMB-ISSUE-1401`-`AMB-ISSUE-1404`
- Search / inspection handoff rows: `AMB-ISSUE-0701`, `AMB-ISSUE-1601`-`AMB-ISSUE-1605`
- Proof/accessibility rows: `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`

No row is closed by this handoff.

## Remaining Yellow Limitations

- Broad senior-code audit remains Red/Yellow outside the bounded SCG-008 child scopes.
- SCG-006 traces all 16 flows as Yellow in the upstream flow audit.
- Runtime/device/manual accessibility/offline/account proof remains absent or incomplete.
- Visual Green and Release Green remain forbidden by release truth and current proof.
- SCG-005 ledger still carries Yellow and Unknown review rows.
- SCG-009 children are materialized but not implemented.

## SCG-009 Child Materialization Plan

SCG-009 remains a parent train. It must not be executed broadly as one implementation issue.

Created child issues:

| Child | Linear | Status | Purpose | Production code permission |
|---|---|---|---|---|
| SCG-009A Domain model audit and canon gap map | `AMB-1302` | Todo | Audit the 10 required domain objects, source/test/persistence/projection seams, and known-issues mappings before repair | No production Swift edits |
| SCG-009B Domain model repair train | `AMB-1303` | Todo | Repair only gaps proven by SCG-009A, with encoding/migration/projection proof where needed | Yes, but only for exact SCG-009A-backed domain/runtime/persistence/projection gaps |
| SCG-009C Behavioral test upgrade train | `AMB-1304` | Todo | Upgrade tests so required flows prove behavior rather than source names, strings, files, or mocks | Default no; minimal source seams only if failing-first behavior tests prove a missing hook |

SCG-009 parent `AMB-1292` remains open. No SCG-009 child implementation was started.

## SCG-009 Finding Map

### SCG-009A

Finding IDs:

- `SCG-004-001`
- `SCG-004-003`
- `SCG-004-004`
- `SCG-004-010`
- `SCG-004-011`

Root causes:

- `RC-SCG006-001`
- `RC-SCG006-004`
- `RC-SCG006-005`
- `RC-SCG006-007`
- `RC-SCG006-008`
- `RC-SCG006-009`

Required domain objects:

- `Step`
- `GoalThread`
- `LifeArea`
- `RealityWindow`
- `CapacityShape`
- `CaptureIntake`
- `ClosureOutcome`
- `ProofEvent`
- `RecoveryState`
- `UserSystemProfile`

### SCG-009B

Finding IDs:

- `SCG-004-001`
- `SCG-004-003`
- `SCG-004-004`
- `SCG-004-007`
- `SCG-004-010`
- `SCG-004-011`

Root causes:

- `RC-SCG006-001`
- `RC-SCG006-002`
- `RC-SCG006-003`
- `RC-SCG006-004`
- `RC-SCG006-005`
- `RC-SCG006-007`
- `RC-SCG006-009`

### SCG-009C

Finding IDs:

- `SCG-004-004`
- `SCG-004-007`
- `SCG-004-010`
- `SCG-004-011`
- `SCG-004-013` as status ceiling only

Root causes:

- `RC-SCG006-001`
- `RC-SCG006-002`
- `RC-SCG006-003`
- `RC-SCG006-004`
- `RC-SCG006-005`
- `RC-SCG006-007`
- `RC-SCG006-009`
- `RC-SCG006-010` as proof ceiling only

Required behavior proof scope:

- Capture save persists local capture/proof.
- Closure mutates Today.
- Move/protect/correct Time recomputes Today where required.
- Goal thread feeds Today.
- Undo only appears when real.
- Offline/no-account core works.
- Permission denied fallback works.

## Architecture Closeout

Final Architecture Tree section inspected: yes.

Canonical owners touched by this handoff:

- `Quality/` via retained senior-review artifact only.

Files moved or created:

- Created `docs/quality/senior-review/SCG-008_PARENT_CLOSEOUT_AND_SCG-009_HANDOFF.md`.

Old/non-canonical paths removed:

- None.

Compatibility shims left behind:

- None.

Yellow architecture debt:

- Existing source may still contain compatibility debt described by `IMPLEMENTATION_TRUTH.md`; this handoff does not repair source architecture.

Next repair train for debt:

- SCG-009 children for domain/test proof.
- Existing visual/runtime remediation trains for device, accessibility, shell, Capture, Goals, Time, Today, and final proof rows.

No equivalent folder/path interpretation was used.

## Validation

Validation to run for this handoff:

- `python3 scripts/ambitions-architecture-inventory.py`
- `python3 scripts/ambitions-quality-gate.py`
- `python3 scripts/ambitions-test-strength-audit.py`
- `python3 scripts/ambitions-senior-code-audit.py --json`
- `python3 -m json.tool docs/quality/senior-review/REPAIR_TRAINS.json`
- `python3 -m json.tool docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `python3 -m json.tool docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `python3 -m json.tool docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `python3 -m json.tool docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.json`
- `git diff --check`
- `git status --short --branch`

Validation result:

| Command | Result |
|---|---|
| `python3 scripts/ambitions-architecture-inventory.py` | Pass: `GREEN final-tree parity achieved`; `canonical_required_files=224`, `implemented=224`, `blocking_entries=0` |
| `python3 scripts/ambitions-quality-gate.py` | Pass: `GREEN all strict quality gates passed`; `changed_paths=1` |
| `python3 scripts/ambitions-test-strength-audit.py` | Pass: `ambitions-test-strength-audit GREEN` |
| `python3 scripts/ambitions-senior-code-audit.py --json > /tmp/scg008-009-senior-audit.json` | Failed/capped as expected for broad backlog: exit `1`, audit `status=Red`, `finding_count=29`, `fixture_failures_proven=16`, `scope_guard_failures=2` |
| `python3 -m json.tool` on SCG register JSON files | Pass for `REPAIR_TRAINS.json`, `ROOT_CAUSE_MAP.json`, `AUTOMATED_FINDINGS.json`, `FLOW_TRACE_AUDIT.json`, `KNOWN_ISSUES_SYNC_REPORT.json` |
| `git diff --check` | Pass |
| `git status --short --branch` | Pass with only this new handoff artifact untracked before commit |

Validation cap:

- The senior-code audit remains Red for accepted SCG static findings and its broad scope guard against already-landed SCG-008 production paths. This handoff does not claim broad senior-readiness or broad audit Green.

## Linear Updates

Completed:

- Verified `AMB-1291`, `AMB-1299`, `AMB-1300`, `AMB-1301`, and `AMB-1292`.
- Verified no existing SCG-009A/B/C children under `AMB-1292`.
- Created `AMB-1302` / SCG-009A.
- Created `AMB-1303` / SCG-009B.
- Created `AMB-1304` / SCG-009C.

Pending after validation:

- Comment on `AMB-1291` with parent closeout decision.
- Move `AMB-1291` to Done only if this handoff validation passes.
- Comment on `AMB-1292` with created child issue list and stop boundary.

## Rollback Plan

Repo rollback:

- Revert the bounded handoff commit containing this artifact.

Linear rollback:

- Reopen `AMB-1291` to In Review if moved Done and a validation blocker is later found.
- Comment on `AMB-1292` and the SCG-009 children that materialization should be superseded if the handoff artifact is reverted.
- Do not delete Linear issues; mark superseded only with explicit owner approval.

# Codex OS Usage Efficiency Upgrade Audit

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Yellow / Implemented as docs-tooling upgrade; local repo validation still required.  
Date: 2026-05-07  
Scope: Audit of existing Codex OS and additive usage-efficiency upgrade.

## Existing System Found

The repo already had a mature Codex OS layer:

- `AGENTS.md` with main-only behavior, source-truth read order, architecture boundaries, execution rules, product truth, repo-local Codex entry points, and global batch train alias.
- `.codex/README.md` with skills, operations, templates, validation packs, playbooks, context packs, checklists, and reports.
- `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md` with source hierarchy, batch lifecycle, Green/Yellow/Red semantics, continuation rules, no-background-work, no-overwrite, no-double-work, human-proof boundaries, implementation-claim boundaries, stop, and repair conditions.
- `docs/codex/CONTEXT_INDEX.md` with current operating truth and global train progress.
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md` with CQS gates.
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md` with advisory scan scripts.
- `.codex/reports/current-batch-train-state.md` with global batch state and accepted Yellow history.

## Gap Found

The existing system was strong on governance, quality, and batch discipline, but it lacked a unified repo-local efficiency surface for:

- route-first context loading
- compact state mirrors
- standardized evidence packets
- saved-log summarization
- bounded read helpers
- advisory claim/language scans
- direct Codex OS index for post-3.0 / 4.0 / External Brain work

## Upgrade Added

- ACX non-executing extractor:
  - `scripts/ai/acx.py`
  - `scripts/ai/acx`
- Codex OS index and protocols:
  - `docs/codex/CODEX_OS_INDEX.md`
  - `docs/codex/CODEX_USAGE_EFFICIENCY.md`
  - `docs/codex/CODEX_AGENT_PROTOCOL.md`
  - `docs/codex/CODEX_EVIDENCE_STANDARD.md`
  - `docs/codex/CODEX_BATCH_TRAIN_PROTOCOL.md`
  - `docs/codex/CODEX_ROUTE_CONTEXT_PROTOCOL.md`
  - `docs/codex/CODEX_GATE_ENGINE.md`
  - `docs/codex/CODEX_SKILLS_KIT.md`
- Route catalog:
  - `.codex/routes/README.md`
- Compact state files:
  - `.codex/state/ambitions-known-facts.md`
  - `.codex/state/active-batch.yml`
  - `.codex/state/yellow-ledger.md`
  - `.codex/state/hard-red-ledger.md`
- Efficiency manifest:
  - `.codex/manifests/codex-os-efficiency-map.yml`
- Existing entry points updated:
  - `AGENTS.md`
  - `.codex/README.md`
  - `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md`
  - `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
  - `.gitignore`

## ACX Safety Decision

The first ACX design was intentionally reduced before commit. The committed ACX does not execute shell commands. It only:

- reads bounded repo files
- summarizes saved logs
- groups changed-file text from saved status output
- runs advisory scans
- scans saved logs for gate markers

This preserves usage efficiency while avoiding a repo-local shell proxy.

## Validation Status

This patch was applied through GitHub contents APIs rather than a local checkout. Therefore, no actual repo-local build, test, XcodeGen, or local script execution proof is claimed here.

Required local follow-up:

```bash
python3 scripts/ai/acx.py --help
python3 scripts/ai/acx.py read AGENTS.md --lines 40
python3 scripts/ai/acx.py gate all docs/codex .codex AGENTS.md
python3 scripts/ai/acx.py gate-report
```

## Claims Not Made

This upgrade does not claim:

- app source implementation
- build pass
- test pass on the real repo
- Xcode project validation
- device proof
- accessibility conformance
- privacy/legal compliance
- TestFlight/App Store readiness
- release readiness
- production readiness

## Next Recommended Phase

Run the local validation commands above on the Mac checkout. If Green, future Codex train prompts should require:

1. `AGENTS.md`
2. `docs/codex/CODEX_OS_INDEX.md`
3. one route from `.codex/routes/README.md`
4. relevant state mirror
5. owner source-truth docs
6. evidence closeout using `docs/codex/CODEX_EVIDENCE_STANDARD.md`

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

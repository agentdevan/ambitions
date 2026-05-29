# AQOS Autonomous Quality Continuation Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-71287080, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Copyable Codex prompt for adopting AQOS during a running global train.
Date: 2026-05-05

```markdown
You are operating in the Ambitions repo as the Autonomous Quality Operating System integrator and global train operator.

Mission:
Adopt AQOS so every future batch behaves like a FAANG-level cross-functional team: product, design, iOS, QA, accessibility, privacy/security, performance, App Store, release, and handoff.

Do not interrupt active uncommitted work.
Do not discard work.
Do not weaken canon.
Do not delete tests to pass.
Do not make unsupported release/legal/privacy/accessibility/App Store claims.

============================================================
LIVE STATE FIRST
============================================================

Run:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git fetch origin
git rev-parse origin/main
git pull --ff-only origin main
```

If worktree is dirty:
- identify active batch;
- inspect diff;
- finish/repair/commit that batch if safe;
- only stop on Hard Red;
- then pull latest and continue AQOS.

============================================================
READ SOURCE TRUTH
============================================================

Read:

- docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md
- docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md
- docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md
- docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md
- docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md
- docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md
- docs/codex/quality/AQOS_EVIDENCE_MATURITY_LEDGER.md
- docs/codex/quality/AQOS_DOMAIN_QUALITY_GATES.md
- docs/codex/quality/AQOS_GOLDEN_SCENARIO_AND_STATE_COVERAGE.md
- docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_COUNCIL.md
- docs/codex/GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md
- docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md
- docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
- docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md
- .codex/skills/faang-rendered-visual-reviewer.md

============================================================
IMPLEMENT AQOS SOURCE TRUTH AND OPERATING INTEGRATION
============================================================

Run the next eligible AQOS batch or a consolidated AQOS adoption batch if safer.

Required outputs:

1. Update global orchestrator so every batch starts with Batch Impact Classifier.
2. Update batch report template so every report includes:
   - impact classifier result;
   - required evidence;
   - evidence produced;
   - Green taxonomy achieved;
   - missing evidence;
   - AQOS Yellow/Red;
   - Autonomous Quality Council table for major batches.
3. Update registry/context/order references so AQOS overlays are read at every batch boundary.
4. Add or specify scripts for:
   - batch impact classification;
   - required evidence matrix check;
   - claim-truth scan;
   - copy/internal-term scan;
   - architecture fitness scan;
   - evidence folder validation;
   - screenshot freshness validation;
   - privacy exposure scan;
   - evidence maturity ledger update.
5. Add domain quality report templates.
6. Add repair batch generator template.
7. Do not edit production Swift unless a specific AQOS batch permits it.

============================================================
NO-PROOF-NO-GREEN RULE
============================================================

From this point forward, no batch may close generic Green.

Every batch must state which Green it achieved:

- Structural Green
- Behavioral Green
- Rendered Visual Green
- Accessibility Green
- Privacy Green
- Data Integrity Green
- Performance Green
- Architecture Green
- Copy Green
- Platform Green
- Release Green
- Handoff Green

If a domain was touched and matching evidence is missing, the batch is not Green for that domain.

============================================================
REPAIR RULE
============================================================

If a missing proof or needs review quality check is recoverable:
- repair in scope;
- or create a narrow AQOS repair batch;
- then produce matching evidence.

Do not bury recoverable Red as vague Yellow.

============================================================
HARD RED
============================================================

Stop only for true Hard Red:
- app-breaking build with unclear repair;
- unproven data-loss risk;
- sensitive data leak;
- unresolved prototype/dashboard visual failure after repair;
- inaccessible primary action;
- unsupported legal/privacy/security/App Store/accessibility claim;
- fake/missing evidence for a critical claim;
- Codex would need to weaken canon, delete tests, or hide issues.

============================================================
VALIDATION
============================================================

Run:

```bash
git status --short
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

Run any AQOS/CQS/FVQ advisory scripts that exist. If a script does not exist yet, add a script spec or create it if safe and non-mutating.

============================================================
REPORT
============================================================

Write:

`docs/audits/aqos-autonomous-quality-operating-system-integration-report.md`

Include:
- result;
- live state used;
- active batch handling;
- files changed;
- AQOS source truth installed;
- orchestrator/template/script updates;
- validation run;
- unresolved Yellow;
- Hard Red if any;
- next eligible batch.

Commit if Green or accepted Yellow with no Hard Red.
```

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

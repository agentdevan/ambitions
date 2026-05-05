# AQOS Autonomous Quality Continuation Prompt
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

If a missing proof or failed quality check is recoverable:
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

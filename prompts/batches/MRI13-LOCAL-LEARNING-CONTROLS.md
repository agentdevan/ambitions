<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

MRI13-LOCAL-LEARNING-CONTROLS

# Runner Command

```bash
make batch BATCH=MRI13-LOCAL-LEARNING-CONTROLS PROMPT=prompts/batches/MRI13-LOCAL-LEARNING-CONTROLS.md
```

# Objective

Add controls to reset, disable, delete, or export local learning signals.

Operating system: **Inspectable Intelligence Engine**  
Product loop: **Personal Runtime trust/control**

This batch must help close an end-to-end Ambitions loop, not merely add another disconnected component.

# Active Source Truth To Inspect

- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
- docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
- docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md
- docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md
- docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json


# Allowed Scope

Add controls to reset, disable, delete, or export local learning signals.

The implementation pass may add or modify docs, prompts, fixtures, tests, or runtime source only if the batch-specific objective explicitly requires it and current truth files support it.

# Forbidden Scope

No silent learning or server sync.

Global hard exclusions unless this prompt explicitly narrows them with proof:

- no release automation
- no signing or entitlement changes
- no hosted personal-data backend
- no external/cloud LLM core runtime
- no Plan top-level restoration
- no sixth tab
- no generic task/calendar/dashboard/chatbot UI
- no unsupported readiness claims

# Validation Expectations

Use the minimum honest validation lane for the touched files:

```bash
git diff --check
python3 scripts/ambitions-state-advance-validate.py || true
python3 scripts/ambitions-unsupported-claim-scan.py <changed-files> 2>/dev/null || true
```

If Swift runtime source is touched, run focused owner tests. If visual runtime is touched, produce preview/screenshot or visual acceptance evidence when claiming visual behavior. Do not run broad full-suite Xcode validation unless this batch is a terminal proof gate.

Proof expectation: Data-control tests and receipt proof.

# Hard Red Stop Conditions

- Required truth/source files cannot be inspected.
- Scope drifts outside the batch objective.
- A component is claimed complete without loop behavior or proof boundary.
- User-facing copy violates active product/moat vocabulary.
- The patch adds hosted personal-data, external/cloud LLM core behavior, or hidden recommendation logic.
- The patch restores Plan as top-level or adds a sixth tab.
- Release, device, accessibility, performance, privacy/legal, visual runtime, or global-completion claims are made without current proof.

# Rollback Expectations

Rollback only this batch's changed files. Preserve active SA/PK/global-train work. Do not delete historical evidence unless a dedicated RHC/historical-policy batch owns it.

# Final Report Requirements

Create or update:

```text
docs/audits/mri13-local-learning-controls-report.md
```

Report must include:

- status
- operating system
- product loop
- source truth inspected
- files changed
- validation commands and exit codes
- EFC applicability
- loop behavior added or still deferred
- claims not made
- rollback notes
- next handoff

# Claims Not Made

- release readiness
- TestFlight readiness
- App Store readiness
- device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- visual runtime completion unless proof exists
- global train completion

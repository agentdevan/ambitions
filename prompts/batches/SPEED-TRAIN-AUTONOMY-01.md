<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# SPEED-TRAIN-AUTONOMY-01

## Batch ID

SPEED-TRAIN-AUTONOMY-01

## Runner command

```bash
make batch BATCH=SPEED-TRAIN-AUTONOMY-01 PROMPT=prompts/batches/SPEED-TRAIN-AUTONOMY-01.md
```

## Objective

Validate and preserve the Ambitions Speed Train overlay that lets the operator finish remaining batches faster through `make speed-train` while keeping the canonical Ambitions runner, stale-state checks, queue guards, claim scans, and final heavy validation gates.

## Active source truth to inspect

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
Makefile
scripts/ambitions-codex-train.sh
scripts/ambitions-autonomous-train.sh
scripts/ambitions-speed-train.sh
scripts/ambitions-speed-queue-guard.py
scripts/ambitions-speed-lane-policy.py
scripts/ambitions-stale-state-check.py
scripts/ambitions-unsupported-claim-scan.py
docs/codex/SPEED_TRAIN_OPERATING_MODEL.md
docs/codex/SPEED_TRAIN_QUICKSTART.md
docs/codex/SPEED_TRAIN_LANE_POLICY.json
docs/codex/ambitions-hybrid-runner.md
```

## Allowed scope

- Speed Train docs.
- Speed Train scripts.
- Makefile speed targets.
- Prompt/report updates related to speed-mode preservation.
- Minor non-mutating validation helpers.

## Forbidden scope

- No app feature implementation.
- No Swift source changes.
- No persistence/schema changes.
- No Package.swift or project.yml changes.
- No signing, entitlement, workflow, release automation, CI, hosted backend, external/cloud LLM, or user-data server changes.
- No visual/runtime UI implementation claim.
- No release/TestFlight/App Store/device/accessibility/performance/privacy/legal/global-completion claim.

## Validation expectations

Run and report true exit codes:

```bash
git diff --check
bash -n scripts/ambitions-speed-train.sh
python3 -m py_compile scripts/ambitions-speed-queue-guard.py scripts/ambitions-speed-lane-policy.py scripts/ambitions-stale-state-check.py scripts/ambitions-unsupported-claim-scan.py
python3 -m json.tool docs/codex/SPEED_TRAIN_LANE_POLICY.json >/tmp/ambitions-speed-train-lane-policy-check.json
python3 scripts/ambitions-stale-state-check.py
python3 scripts/ambitions-speed-queue-guard.py PK22
python3 scripts/ambitions-speed-lane-policy.py PK22
python3 scripts/ambitions-unsupported-claim-scan.py docs prompts .codex
make speed-next
```

Do not run implementation batches from this preservation prompt unless the user explicitly requests live speed-train execution.

## Visual proof expectations

Not applicable. This is runner/control-plane tooling only.

## Hard Red stop conditions

- Speed Train points at a completed batch.
- More than one queue item is `executable_now`.
- Active state next batch does not match queue `executable_now`.
- Unsupported completion/readiness claim scanner flags unresolved claims.
- Speed Train bypasses the Ambitions runner instead of wrapping autonomous runner / batch runner.
- The prompt or docs claim release, device, public accessibility, performance, privacy/legal, or global completion proof.
- Any app source, package, project, signing, entitlement, hosted backend, workflow, or release automation file changes appear.

## Rollback expectations

Rollback only Speed Train files and docs from this batch. Do not rollback completed implementation batches.

## Final report requirements

Create/update `docs/audits/speed-train-autonomy-01-report.md` with:

- status,
- files inspected,
- files changed,
- validation command outcomes,
- speed-mode command summary,
- no-claim boundaries,
- next recommended command.

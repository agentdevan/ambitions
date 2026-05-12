<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS00-OPENAI-BUILD-SUITE-INSTALL

# Runner Command

```bash
make batch BATCH=OBS00-OPENAI-BUILD-SUITE-INSTALL PROMPT=prompts/batches/OBS00-OPENAI-BUILD-SUITE-INSTALL.md
```

# Objective

Install the Ambitions OpenAI Build Suite as a dev-only build/control-plane system that helps build, review, evaluate, repair, document, and launch Ambitions faster.

This batch must make the suite ready for future Codex/OpenAI-powered build batches without adding OpenAI to the Ambitions app runtime.

The suite must cover:

1. Codex multi-agent build system
2. Repo intelligence layer
3. Eval / QA layer
4. Prompt repair layer
5. Batch report layer
6. Visual critique layer
7. Launch documentation layer

This is a docs/tooling/control-plane installation batch. It must not run PK28 or any implementation batch.

# Current Repo State Assumption

PK27 Diagnostic Ledger is complete / Green and pushed.

PK28 Data Control Commands is next eligible, but this OBS batch must not run or modify PK28 implementation work.

# Active Source Truth To Inspect

Read these before patching:

```text
docs/truth/README.md
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/PRODUCT_MOAT_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/truth/HISTORICAL_POLICY.md
AGENTS.md
.codex/state/active-batch.yml
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
docs/codex/CODEX_OS_INDEX.md
docs/codex/SPEED_TRAIN_OPERATING_MODEL.md
docs/codex/SPEED_TRAIN_QUICKSTART.md
docs/codex/SPEED_TRAIN_LANE_POLICY.json
docs/codex/ambitions-hybrid-runner.md
```

# OpenAI Source Awareness

Use current OpenAI platform concepts only as dev tooling references:

* Codex can read, modify, and run code in cloud/dev environments and can work on multiple code tasks in parallel.
* Responses API supports model calls and tool use.
* File Search supports retrieval over uploaded/vector-store files.
* Evals support reproducible evaluation and grading.
* Batch API supports async large-scale processing.
* Agents SDK supports agents, tools, handoffs, streaming, and tracing.

Do not add app runtime dependencies on OpenAI. Do not add an API key to the app. Do not send Ambitions user data anywhere.

# Product Architecture Boundary

OpenAI is allowed for:

```text
developer tooling
Codex orchestration
repo intelligence
eval / QA
prompt repair
batch report generation
visual critique
launch documentation drafting
```

OpenAI is forbidden for:

```text
Native/Ambitions app core runtime
Start Here recommendation engine
Private Life Runtime / Intelligence Kernel
local memory
schedule decisions
capture routing
goal decomposition core
action closure logic
proof/trust engine
hidden user-data processing
required product behavior
```

Core Ambitions intelligence remains local-first and deterministic.

# Allowed Scope

Create or update only these paths:

```text
docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md
docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md
docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md
docs/codex/REPO_INTELLIGENCE_LAYER.md
docs/codex/OPENAI_EVAL_QA_LAYER.md
docs/codex/PROMPT_REPAIR_LAYER.md
docs/codex/BATCH_REPORT_LAYER.md
docs/codex/VISUAL_CRITIQUE_LAYER.md
docs/codex/LAUNCH_DOCUMENTATION_LAYER.md
docs/codex/CODEX_OS_INDEX.md

docs/audits/openai-build-suite-install-report.md

tools/openai/README.md
tools/openai/config/ambitions_openai_build_policy.json
tools/openai/config/redaction_rules.json
tools/openai/config/codex_agent_roles.json

tools/openai/repo_brain/build_repo_manifest.py
tools/openai/repo_brain/query_repo_brain.py
tools/openai/repo_brain/README.md

tools/openai/evals/datasets/batch_quality.jsonl
tools/openai/evals/datasets/claim_safety.jsonl
tools/openai/evals/datasets/visual_canon.jsonl
tools/openai/evals/run_evals.py
tools/openai/evals/score_reports.py
tools/openai/evals/README.md

tools/openai/prompt_repair/repair_batch_prompt.py
tools/openai/prompt_repair/README.md

tools/openai/batch_report/summarize_batch_report.py
tools/openai/batch_report/classify_batch_result.py
tools/openai/batch_report/README.md

tools/openai/visual_critique/critique_visual_packet.py
tools/openai/visual_critique/rubrics/ambitions_visual_canon.json
tools/openai/visual_critique/README.md

tools/openai/launch_docs/generate_launch_packet.py
tools/openai/launch_docs/README.md

scripts/openai-build-suite-validate.py
scripts/openai-build-suite-dry-run.py
scripts/ambitions-prompt-queue-consistency.py

prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md
prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md
prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md
prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md
prompts/batches/OBS05-VISUAL-CRITIQUE-LAUNCH-DOCS-LAYER.md
prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md

Makefile
```

Only update `Makefile` for dev-only targets. Do not alter existing batch/speed train targets except to add new OpenAI Build Suite targets.

# Forbidden Scope

Do not touch:

```text
Native/Ambitions/**
Native/AmbitionsTests/**
Package.swift
project.yml
.github/**
*.xcodeproj/**
*.xcworkspace/**
signing
entitlements
provisioning
release automation
hosted backend code
analytics/telemetry SDKs
```

Do not add:

```text
OpenAI SDK dependency to app target
API key
secret file
environment variable default containing a key
network call from app runtime
OpenAI import in Native/Ambitions/**
new UI/chat surface
ChatKit in app
external/cloud LLM dependency for core app behavior
```

# Required Implementation

## 1. Policy docs

Create `docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md` with:

* purpose
* allowed dev-only uses
* forbidden runtime uses
* privacy boundaries
* redaction requirements
* API key handling
* local-only Ambitions architecture boundary
* optional future extension rules
* no-claim boundaries

Create `docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md` with a table:

```text
Capability | OpenAI surface | Ambitions use | repo path | runtime allowed? | risk | status
```

Rows must include:

```text
Codex multi-agent build system
Repo intelligence / File Search
Eval / QA
Prompt repair
Batch report generation
Visual critique
Launch documentation drafting
Optional future user-controlled cloud assist
Forbidden core runtime intelligence
```

## 2. Codex multi-agent build system

Create `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md`.

Create `tools/openai/config/codex_agent_roles.json`.

Required roles:

```text
Implementation Agent
Focused Test Agent
State Advancement Agent
Claim Safety Agent
Prompt Repair Agent
Batch Report Agent
Visual Critic Agent
Repo Intelligence Agent
Launch Docs Agent
```

Each role must include:

```json
{
  "role": "...",
  "purpose": "...",
  "allowed_scope": [],
  "forbidden_scope": [],
  "required_checks": [],
  "hard_red": []
}
```

Make clear this is a Codex/operator orchestration model, not app runtime logic.

## 3. Repo intelligence layer

Create `docs/codex/REPO_INTELLIGENCE_LAYER.md`.

Create:

```text
tools/openai/repo_brain/README.md
tools/openai/repo_brain/build_repo_manifest.py
tools/openai/repo_brain/query_repo_brain.py
```

The first implementation should be safe and local:

* `build_repo_manifest.py` scans allowed repo files and writes a local JSON manifest.
* It must exclude secrets, `.env`, signing/provisioning files, `.codex/runs/**`, build outputs, and private local artifacts.
* `query_repo_brain.py` can be a dry-run/local query stub that explains how OpenAI File Search/vector stores would be used later.
* Do not make live API calls in this batch.

Allowed default index paths:

```text
docs/truth/**
docs/codex/**
docs/audits/**
prompts/batches/**
scripts/**
```

## 4. Eval / QA layer

Create `docs/codex/OPENAI_EVAL_QA_LAYER.md`.

Create:

```text
tools/openai/evals/README.md
tools/openai/evals/datasets/batch_quality.jsonl
tools/openai/evals/datasets/claim_safety.jsonl
tools/openai/evals/datasets/visual_canon.jsonl
tools/openai/evals/run_evals.py
tools/openai/evals/score_reports.py
```

This batch should implement local dry-run eval scaffolding, not live OpenAI API calls.

Required eval datasets:

* `batch_quality.jsonl`
* `claim_safety.jsonl`
* `visual_canon.jsonl`

Each JSONL row must be valid JSON and include:

```json
{
  "id": "...",
  "input": "...",
  "expected": {
    "verdict": "pass|fail",
    "reason": "..."
  }
}
```

`run_evals.py` should validate dataset shape and optionally print what a future OpenAI Evals run would do.

## 5. Prompt repair layer

Create `docs/codex/PROMPT_REPAIR_LAYER.md`.

Create:

```text
tools/openai/prompt_repair/README.md
tools/openai/prompt_repair/repair_batch_prompt.py
scripts/ambitions-prompt-queue-consistency.py
```

`ambitions-prompt-queue-consistency.py` must check a target prompt against live queue/state and flag stale prompt labels such as:

```text
Classification: executable_later
```

when the live queue says `executable_now`.

It should accept a batch ID:

```bash
python3 scripts/ambitions-prompt-queue-consistency.py PK28
```

It must read:

```text
docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
.codex/state/active-batch.yml
prompts/batches/<BATCH>.md
```

It should fail if:

* prompt is missing
* prompt classification contradicts queue for the target batch
* active next batch contradicts the queue executable_now item
* more than one queue item is executable_now

It should pass when prompt labels are absent but live state is valid; prompt labels are advisory, queue/state is authority.

## 6. Batch report layer

Create `docs/codex/BATCH_REPORT_LAYER.md`.

Create:

```text
tools/openai/batch_report/README.md
tools/openai/batch_report/summarize_batch_report.py
tools/openai/batch_report/classify_batch_result.py
```

Implement local parsing/dry-run behavior:

* parse a closeout report path
* extract status line if present
* extract changed files if present
* extract validation commands if present
* flag missing rollback / no-claims / next handoff
* print JSON to stdout

No live API call in this batch.

## 7. Visual critique layer

Create `docs/codex/VISUAL_CRITIQUE_LAYER.md`.

Create:

```text
tools/openai/visual_critique/README.md
tools/openai/visual_critique/critique_visual_packet.py
tools/openai/visual_critique/rubrics/ambitions_visual_canon.json
```

This layer should be local/dry-run in this batch:

* validate a rubric JSON
* accept screenshot paths as input
* report missing files
* print the critique dimensions
* do not upload screenshots
* do not claim visual approval

Rubric dimensions must include:

```text
native iPhone believability
premium material quality
non-generic surface identity
top-level IA correctness
Start Here / Reality Meridian fidelity
Capture composer fidelity
Time / LifeShape fidelity
Goals / Constellation Atlas fidelity
You / Settings-style fidelity
Dynamic Type / Reduce Motion caveats
```

## 8. Launch documentation layer

Create `docs/codex/LAUNCH_DOCUMENTATION_LAYER.md`.

Create:

```text
tools/openai/launch_docs/README.md
tools/openai/launch_docs/generate_launch_packet.py
```

Local/dry-run only:

* read docs/audits reports
* identify proof-backed claims
* list missing proof
* generate a draft launch packet locally
* no readiness claim unless proof exists

## 9. Build suite config

Create:

```text
tools/openai/README.md
tools/openai/config/ambitions_openai_build_policy.json
tools/openai/config/redaction_rules.json
scripts/openai-build-suite-validate.py
scripts/openai-build-suite-dry-run.py
```

`ambitions_openai_build_policy.json` must include:

```json
{
  "runtime_policy": {
    "native_app_openai_dependency_allowed": false,
    "core_runtime_openai_allowed": false,
    "dev_tooling_openai_allowed": true,
    "user_private_data_upload_allowed_by_default": false
  }
}
```

`redaction_rules.json` must include patterns/categories for:

```text
API keys
.env files
signing/provisioning
personal screenshots
private user data
.codex/runs raw logs
```

`openai-build-suite-validate.py` must fail if:

* `Native/Ambitions/**` contains `import OpenAI`, `from openai`, `OPENAI_API_KEY`, or obvious OpenAI SDK usage
* any likely API key appears in tracked files
* `OPENAI_API_KEY` appears outside allowed tooling/docs paths
* OpenAI runtime usage is claimed in docs without optional/dev-only caveat

Allowed mentions:

```text
docs/**
tools/openai/**
scripts/openai-*.py
prompts/batches/OBS*.md
```

## 10. Makefile targets

Add dev-only targets:

```makefile
openai-build-suite-validate:
	python3 scripts/openai-build-suite-validate.py

openai-build-suite-dry-run:
	python3 scripts/openai-build-suite-dry-run.py

openai-repo-brain-index:
	python3 tools/openai/repo_brain/build_repo_manifest.py

openai-evals-dry-run:
	python3 tools/openai/evals/run_evals.py --dry-run

openai-batch-report-dry-run:
	python3 tools/openai/batch_report/classify_batch_result.py --help >/dev/null

openai-visual-critique-dry-run:
	python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run

openai-launch-docs-dry-run:
	python3 tools/openai/launch_docs/generate_launch_packet.py --dry-run
```

Do not alter existing Speed Train targets except to optionally add `openai-build-suite-validate` to `speed-final-gate` only if it is safe and non-blocking. Prefer not to alter speed execution in this batch.

## 11. Future OBS prompts

Create runner-compatible prompts for the next six batches:

```text
prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md
prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md
prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md
prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md
prompts/batches/OBS05-VISUAL-CRITIQUE-LAUNCH-DOCS-LAYER.md
prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md
```

Each must include the required Ambitions runner header:

```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

Each future prompt must preserve:

* dev-only OpenAI usage
* no app runtime OpenAI dependency
* no private user data upload
* no release/readiness claims
* exact allowed scope
* validation expectations
* rollback expectations

## Validation Commands

Run and record exact exit codes:

```bash
git status --short
git diff --check
make batch-self-check
make prompt-audit
python3 -m json.tool tools/openai/config/ambitions_openai_build_policy.json >/tmp/ambitions-openai-build-policy-check.json
python3 -m json.tool tools/openai/config/redaction_rules.json >/tmp/ambitions-openai-redaction-rules-check.json
python3 -m json.tool tools/openai/config/codex_agent_roles.json >/tmp/ambitions-openai-agent-roles-check.json
python3 -m json.tool tools/openai/visual_critique/rubrics/ambitions_visual_canon.json >/tmp/ambitions-visual-canon-rubric-check.json
python3 -m py_compile \
  scripts/openai-build-suite-validate.py \
  scripts/openai-build-suite-dry-run.py \
  scripts/ambitions-prompt-queue-consistency.py \
  tools/openai/repo_brain/build_repo_manifest.py \
  tools/openai/repo_brain/query_repo_brain.py \
  tools/openai/evals/run_evals.py \
  tools/openai/evals/score_reports.py \
  tools/openai/prompt_repair/repair_batch_prompt.py \
  tools/openai/batch_report/summarize_batch_report.py \
  tools/openai/batch_report/classify_batch_result.py \
  tools/openai/visual_critique/critique_visual_packet.py \
  tools/openai/launch_docs/generate_launch_packet.py
python3 scripts/openai-build-suite-validate.py
python3 scripts/openai-build-suite-dry-run.py
python3 scripts/ambitions-prompt-queue-consistency.py PK28
python3 tools/openai/repo_brain/build_repo_manifest.py --dry-run
python3 tools/openai/evals/run_evals.py --dry-run
python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run
python3 tools/openai/launch_docs/generate_launch_packet.py --dry-run
python3 scripts/ambitions-unsupported-claim-scan.py docs prompts .codex
```

No `xcodegen` or `xcodebuild` required. This is docs/tooling only.

## Hard Red Stop Conditions

Stop immediately and do not commit if:

* any `Native/Ambitions/**` file changes
* Package.swift changes
* project.yml changes
* .github workflows change
* signing or entitlement files change
* OpenAI API key or secret appears
* app runtime OpenAI dependency appears
* OpenAI is described as required for Ambitions core features
* user private data upload is allowed by default
* any release/TestFlight/App Store/device/public accessibility/performance/privacy/legal readiness claim appears
* PK28 or any implementation batch is run from this prompt
* Speed Train current batch state is changed without explicit scope
* validation root cause is unknown

## Final Report

Create:

```text
docs/audits/openai-build-suite-install-report.md
```

Report must include:

* status
* files created/updated
* policy summary
* exact validation commands and exit codes
* no-claim boundaries
* rollback notes
* next recommended command

## Rollback

Rollback only OBS/OpenAI Build Suite files and Makefile target additions. Do not rollback PK27 or Speed Train state.

## Claims Not Made

Do not claim:

```text
OpenAI app integration
OpenAI SDK installed in Ambitions app
PK28 completion
implementation batch completion
release readiness
TestFlight readiness
App Store readiness
signed archive readiness
physical-device validation
public accessibility conformance
performance validation
privacy/legal approval
production readiness
global train completion
```

# Final Operator Handoff

After this batch is Green, print:

```bash
git pull --ff-only
make openai-build-suite-validate
make openai-build-suite-dry-run
make speed-status
MAX_BATCHES=10 make speed-train
```

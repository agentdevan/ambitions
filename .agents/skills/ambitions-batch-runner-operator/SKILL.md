---
name: ambitions-batch-runner-operator
description: Use for Ambitions batch/train execution, runner headers, batch continuation, Yellow/Red handling, and runner-governed prompts.
---

# Ambitions Batch Runner Operator

## Authority Boundary
Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active top-level IA is `Today / Goals / Time / Motion / You`. Global action: `Capture` (not a tab). `Motion` replaces `Pulse` (historical context only). `Plan` may appear only as an internal compatibility seam unless an active truth-file-scoped migration changes it.

Hard stops: required cloud AI/LLM core behavior, hosted personal-data backend, analytics/tracking SDKs without approval, privacy manifest dishonesty, release/App Store/TestFlight/device/accessibility/performance claims without evidence, `Plan` as top-level IA, broad staging, destructive cleanup without indexed approval, or converting Ambitions into a dashboard/chatbot/calendar clone/task manager/habit tracker.
## Runner Policy
Use the Ambitions runner for implementation, Codex OS, repo cleanup, architecture, UI, product, and batch-train prompts unless the user explicitly says `bypass the Ambitions runner`.

Canonical commands:
```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
make batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

Every runnable batch prompt must include:
```html
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
```

## Workflow
1. Inspect active batch state, registries, post-batch gates, and current git status.
2. Save or repair prompts before execution; do not execute pasted Ambitions prompts directly without the runner header.
3. Continue only through Green or accepted Yellow with explicit owner, reason, no-claim boundary, and post-batch gate.
4. Stop on Red and report the smallest safe repair.
5. Commit only path-limited validated work; never broad-stage.

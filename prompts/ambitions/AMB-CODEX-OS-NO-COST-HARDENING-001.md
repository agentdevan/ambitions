<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-OS-NO-COST-HARDENING-001

## Batch ID

AMB-CODEX-OS-NO-COST-HARDENING-001

## Runner command

Run through one of these only:

```bash
scripts/ambitions-codex-train.sh AMB-CODEX-OS-NO-COST-HARDENING-001 prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-001.md
make batch BATCH=AMB-CODEX-OS-NO-COST-HARDENING-001 PROMPT=prompts/ambitions/AMB-CODEX-OS-NO-COST-HARDENING-001.md
```

Direct pasted Codex execution is forbidden unless the user explicitly says:
`bypass the Ambitions runner`.

## Assumed Execution Chain

GPT-5.5 plan -> GPT-5.3-Codex-Spark bounded patch -> GPT-5.5 review/repair/final commit.

## Objective

Implement a no-new-cost Ambitions Codex OS hardening pack that makes Codex safer,
faster, more autonomous, more honest, and more aligned with Ambitions' world-class
native iPhone app creation system.

This batch must create or upgrade local-only Codex control-plane assets:

- `AGENTS.md` authority hierarchy.
- Repo-scoped Ambitions Skills under `.agents/skills`.
- Local Codex Rules under `.codex/rules`.
- Local Codex Hooks under `.codex/hooks` plus project config under `.codex/config.toml`.
- Structured Codex batch output schema.
- Local validation / doctor scripts using only Python standard library and shell.
- Documentation explaining how each control-plane asset helps and how to activate it safely.
- Optional runner integration for structured output, only if the existing runner can be upgraded without breaking current batch execution.

This batch must not add OpenAI API usage, GitHub Actions, hosted CI, paid
services, external packages, app-runtime OpenAI dependencies, cloud model
dependencies, package installs, or any dependency with associated monetary cost.

## Prime Directive

Ambitions is being built from scratch to App Store submission through Codex. Treat
this repo as a world-class native Apple product and a Codex OS control plane. The
goal is not generic automation. The goal is a senior product/design/iOS/QA/
accessibility/privacy/release/repo-hygiene department encoded into local repo
authority, reusable Skills, local policy gates, deterministic validation, and
proof-honest batch reports.

## Non-Negotiable No-Cost Boundary

Hard rule: this batch may add only local repo files and local scripts.

Forbidden cost or cost-exposure additions:

- No OpenAI API calls.
- No API keys.
- No `OPENAI_API_KEY`, `CODEX_API_KEY`, or equivalent key wiring.
- No OpenAI SDK dependency.
- No Agents SDK dependency.
- No MCP servers.
- No Codex GitHub Action.
- No `.github/workflows/**` additions or modifications.
- No GitHub Actions, hosted CI, scheduled automation, cloud runner, or remote execution.
- No package installs.
- No new npm, pnpm, yarn, pip, brew, mint, gem, cargo, or Swift package dependency.
- No `curl` or `wget` scripts.
- No gpt-oss model download or local model runtime.
- No Whisper, tiktoken, cookbook, ChatKit, Apps SDK, realtime API, Responses API, Assistants API, or cloud LLM app runtime dependency.
- No subscription, license, SaaS, Figma, Canva, Linear, Slack, GitHub Copilot, or paid connector dependency.
- No app source runtime dependency on OpenAI or any remote LLM.
- No App Store submission automation that requires paid accounts, credentials, signing changes, Transporter upload, notarization, or external services.
- No hidden optional paid path.

Allowed:

- Local Markdown.
- Local JSON schema.
- Local Python standard library scripts.
- Local shell scripts that do not install packages and do not call network services.
- Local Codex config, hooks, rules, and repo-scoped Skills.
- Existing repo runner scripts, modified only conservatively.
- Existing local Codex CLI usage through the Ambitions runner.
- Existing local Xcode build/test commands only for validation, not archive/submission/signing.

If there is any doubt whether a change creates cost exposure, do not implement it.
Document it as excluded.

## Active Source Truth To Inspect First

Before editing, inspect and classify existing repo authority:

```bash
git status --short
git rev-parse --show-toplevel
```

Inspect existing root `AGENTS.md`, `AGENTS.override.md`, `.codex/**`,
`.agents/**`, `Makefile`, `scripts/**`, `docs/**`, `README*`, project files,
app source directories, and existing Ambitions runner files, especially:

- `scripts/ambitions-codex-train.sh`
- any `make batch` target
- any batch queue/status scripts
- any prompt/schema/report directories

Also inspect active source truth for Ambitions architecture, release status, App
Store readiness, local-first posture, UI quality, privacy, source hierarchy, and
batch train.

Do not assume paths exist. Discover them. If a path is missing, create only within
allowed scope.

## Authority Classification Requirement

Create or update:

```text
docs/codex-os/AUTHORITY_HIERARCHY.md
```

It must classify relevant material into:

- Active source truth
- Supporting implementation material
- Historical reference
- Obsolete / archive-candidate
- Delete-candidate, only if obviously stale and safe to flag

Do not delete historical or obsolete material in this batch. Only classify and warn.

## Allowed Scope

Create or modify only:

```text
AGENTS.md
scripts/AGENTS.md
docs/AGENTS.md
.codex/AGENTS.md
.agents/AGENTS.md
.agents/skills/**
.codex/config.toml
.codex/hooks/**
.codex/rules/**
.codex/schemas/**
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
scripts/ambitions-codex-os-print-install-notes.py
scripts/ambitions-codex-train.sh
Makefile
docs/codex-os/**
prompts/ambitions/README.md
```

`scripts/ambitions-codex-train.sh` may be changed only if a safe, minimal,
backward-compatible structured-output upgrade is possible. `Makefile` may be
changed only to add non-conflicting local validation targets.

## Forbidden Scope

Do not modify:

```text
Swift app source files
Xcode project files
entitlements
signing configuration
provisioning files
Info.plist
package dependency manifests
lockfiles
.github/workflows/**
CI configuration
remote deployment scripts
App Store upload scripts
secrets files
user home directory files
files outside the git repo
generated build artifacts
unrelated dirty files
```

If app source or project files appear to need changes, stop and report Yellow with
a proposed next batch. Do not touch them.

## Phase 0 - Preflight And Dirty-Worktree Protection

Run:

```bash
git status --short
git diff --stat
find . -maxdepth 3 -type f \( -name 'AGENTS.md' -o -name 'AGENTS.override.md' -o -name 'Makefile' -o -name '*.xcodeproj' -o -name 'Package.swift' -o -name 'README*' \) | sort
find . -maxdepth 3 -type d \( -name '.codex' -o -name '.agents' -o -name 'scripts' -o -name 'docs' -o -name '.github' \) | sort
```

If there are unrelated existing user changes, preserve them. Do not overwrite
them. When editing a file that already has content, merge surgically and add a
clear Ambitions Codex OS section instead of replacing the file.

## Phase 1 - AGENTS.md Authority Hierarchy

Create or update root `AGENTS.md`. Preserve existing content and add a clearly
marked section:

```text
## Ambitions Codex OS Local Control Plane
```

Required root guidance:

- Ambitions is a world-class native iPhone-first Apple app.
- Local-first / on-device-first posture is default unless active source truth explicitly says otherwise.
- No false release, App Store, validation, build, test, accessibility, privacy, or completion claims.
- All implementation prompts must run through the Ambitions runner unless the user explicitly bypasses it.
- Batches must inspect active source truth before editing.
- Batches must stay within allowed scope.
- Batches must report Green / Yellow / Red honestly.
- Any UI change requires build proof and visual/accessibility proof expectations.
- Any release claim requires exact evidence.
- Cloud/API/runtime dependencies are forbidden unless an active source-truth file explicitly authorizes them.
- No new cost exposure is allowed without explicit user approval in a future batch.

Create or update:

- `scripts/AGENTS.md`: local shell or Python standard library only unless active source truth explicitly allows more; no package installs; no network; no secrets; deterministic output and clear exit codes; validation scripts fail closed for cost-exposure patterns.
- `docs/AGENTS.md`: distinguish active, supporting, historical, obsolete, archive-candidate, and delete-candidate material; no release readiness without proof; no external dependency prose that conflicts with no-cost policy.
- `.codex/AGENTS.md`: local control-plane policy only; hooks are best-effort guardrails; rules are local command policy and must be validated; config must not contain secrets or call external services.
- `.agents/AGENTS.md`: repo-scoped Skills live under `.agents/skills`; skills must be concise, reusable, Ambitions-specific, and must not require package installs, paid tools, network services, API keys, plugins, or external downloads.

## Phase 2 - Repo-Scoped Ambitions Skills

Create these exact Skill files under `.agents/skills/`. Each `SKILL.md` must
start with YAML front matter containing `name` and `description`.

- `.agents/skills/ambitions-batch-runner-operator/SKILL.md`: runner-only execution, allowed scope, validation gates, Red stop conditions, rollback, final proof honesty.
- `.agents/skills/ambitions-source-truth-auditor/SKILL.md`: classify authority files and prevent stale/historical material from being treated as active truth.
- `.agents/skills/ambitions-no-cost-gate/SKILL.md`: prevent monetary cost, API usage, CI billing exposure, external package installs, and cloud dependencies.
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`: maintain world-class native iPhone quality when future app/UI code changes are in scope; note app source is forbidden in this batch.
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`: prevent false completion, release readiness, App Store submission, QA, accessibility, and privacy claims.
- `.agents/skills/ambitions-repo-hygiene-rollback/SKILL.md`: keep repo changes bounded, reversible, and inspectable.
- `.agents/skills/ambitions-subagent-review-template/SKILL.md`: optional manual future multi-review pattern; do not spawn subagents by default; main agent remains sole patch integrator.

## Phase 3 - Local Codex Rules

Create:

```text
.codex/rules/ambitions-no-cost.rules
docs/codex-os/RULES_POLICY.md
```

Use Codex execpolicy Starlark-style `prefix_rule(...)` entries.

Allowed examples:

- `git status`
- `git diff`
- `git diff --stat`
- `git rev-parse`
- `rg`
- `find`
- `ls`
- `pwd`
- `cat`
- `sed`
- `awk`
- `python3 scripts/ambitions-codex-os-validate.py`
- `python3 scripts/ambitions-codex-os-doctor.py`
- `make ambitions-codex-os-validate`

Prompt examples:

- `git add`
- `git commit`
- `xcodebuild`
- `make`
- `python3 scripts/ambitions-codex-train.sh` if applicable
- `chmod`

Forbidden examples:

- `git push`
- `git reset --hard`
- `git clean -fdx`
- `rm -rf`
- `gh workflow`
- `gh run`
- `gh pr merge`
- `npm install`
- `npm i`
- `pnpm install`
- `yarn install`
- `pip install`
- `brew install`
- `curl`
- `wget`
- `security`
- `xcrun altool`
- `xcrun notarytool`
- `xcodebuild archive`

Include inline `match` / `not_match` examples for representative rules.

`RULES_POLICY.md` must document what rules allow, prompt, and forbid; that rules
are guardrails and not a substitute for the validator; that they should be tested
with `codex execpolicy check` when available; and that no rule permits external
services or paid dependencies.

## Phase 4 - Local Codex Hooks

Create:

```text
.codex/config.toml
.codex/hooks/session_start_context.py
.codex/hooks/user_prompt_submit_guard.py
.codex/hooks/pre_tool_use_policy.py
.codex/hooks/permission_request_guard.py
.codex/hooks/post_tool_use_review.py
.codex/hooks/stop_gate.py
docs/codex-os/HOOKS_POLICY.md
```

Use repo-local hooks only. Enable hooks with:

```toml
[features]
codex_hooks = true
```

Configure hooks for:

- `SessionStart`
- `UserPromptSubmit`
- `PreToolUse` for Bash
- `PermissionRequest` for Bash
- `PostToolUse` for Bash and `apply_patch`
- `Stop`

Use commands that resolve from git root, for example:

```text
/usr/bin/python3 "$(git rev-parse --show-toplevel)/.codex/hooks/session_start_context.py"
```

Do not use external commands beyond Python standard library and git-root
resolution. All hook scripts must use Python standard library only, tolerate
missing fields, avoid network, avoid secrets, include small pure helpers, and
compile with `python3 -m py_compile`.

Hook behavior:

- `session_start_context.py`: read JSON stdin, determine git root if possible, print JSON with `hookSpecificOutput.hookEventName = "SessionStart"`, add concise developer context covering runner-required, no-cost policy, active source truth, and final report expectations.
- `user_prompt_submit_guard.py`: block Ambitions implementation/batch/repo patch/release/Codex OS mutation prompts that lack the required runner header unless the prompt explicitly says `bypass the Ambitions runner`; add or block context for API keys, paid services, GitHub Actions, external CI, cloud models, package installs, or SDK additions; avoid blocking harmless questions.
- `pre_tool_use_policy.py`: extract `tool_input.command` robustly; deny API key env vars, package installs, network downloads, GitHub Actions mutation, git push/reset/clean, destructive deletes, archive/signing/submission commands, direct App Store upload tooling, or writes outside repo; return modern `permissionDecision = "deny"` with reason and a legacy block shape; do not fail closed on malformed input.
- `permission_request_guard.py`: deny approval requests for forbidden cost/destructive/network/signing commands; never approve network, API, package install, CI, signing, archive, or push commands.
- `post_tool_use_review.py`: inject context if Swift/UI/app/project files were touched, if a command failed, or if generated docs/scripts changed and validator should run; cannot undo side effects.
- `stop_gate.py`: if `stop_hook_active` true, allow completion; otherwise require final message to include Status, Files changed, Validations run, No-cost proof, Risks / limitations, and Rollback; block with a continuation prompt if missing. Do not demand Green.

`HOOKS_POLICY.md` must document what each hook does, how to trust/activate
repo-local `.codex` config, that hooks are best-effort guardrails, that hooks
cannot replace validation, and that hooks must not contain secrets or call
external services.

## Phase 5 - Structured Batch Output Schema

Create:

```text
.codex/schemas/ambitions-batch-result.schema.json
docs/codex-os/STRUCTURED_OUTPUT.md
```

Schema must require:

- `batch_id` string
- `status` enum: `GREEN`, `YELLOW`, `RED`
- `summary` string
- `changed_files` array of strings
- `validations_run` array of objects containing `command`, `status`, `evidence`
- `no_cost_proof` object containing `new_dependencies_added`, `api_keys_added`, `network_or_ci_added`, `paid_services_added`, `notes`
- `source_truth` object containing `active_truth_files`, `supporting_files`, `uncertainties`
- `risks` array of strings
- `rollback` array of strings
- `next_recommended_batch` string

Set `additionalProperties: false` where practical.

`STRUCTURED_OUTPUT.md` must document intended use with `codex exec --json
--output-schema`, runner preference for schema validation when available, and
that the schema is local-only and does not imply API-key or CI usage.

## Phase 6 - Local Validator And Doctor

Create:

```text
scripts/ambitions-codex-os-validate.py
scripts/ambitions-codex-os-doctor.py
```

Validator required checks:

1. Required files exist: `AGENTS.md`, `.codex/AGENTS.md`, `.agents/AGENTS.md`,
   `.codex/config.toml`, `.codex/rules/ambitions-no-cost.rules`,
   `.codex/schemas/ambitions-batch-result.schema.json`, all hook scripts, all
   Skill `SKILL.md` files, and key docs under `docs/codex-os`.
2. Python hook scripts compile using `py_compile`.
3. JSON schema parses and has basic required-key sanity.
4. Each Skill front matter exists and contains non-empty `name` and `description`.
5. No-cost scan checks changed files and new control-plane files for prohibited patterns, while allowing policy docs and validator code to mention forbidden patterns when clearly presented as forbidden.
6. Forbidden scope scan uses `git diff --name-only` and fails if this batch modified Swift app source, Xcode project files, signing, entitlements, dependency manifests, lockfiles, or `.github/workflows/**`.
7. Runner header scan verifies this prompt pattern is documented in relevant docs or root `AGENTS.md`; direct Codex execution is marked forbidden unless explicitly bypassed.
8. Print a human-readable summary.
9. Write JSON report to `build/reports/ambitions-codex-os-validate.json`.
10. Exit `0` only if all hard checks pass; exit nonzero on hard failures.

Doctor required behavior:

- Print current local Codex OS status.
- List whether `.codex`, `.agents/skills`, rules, hooks, schema, docs, and Make targets exist.
- Print activation notes.
- Print no-cost boundary.
- No network, no install, no modification. Do not implement `--fix` in this batch.

Make both scripts executable if safe.

## Phase 7 - Makefile Integration

If `Makefile` exists, add non-conflicting targets:

```make
ambitions-codex-os-validate:
	python3 scripts/ambitions-codex-os-validate.py

ambitions-codex-os-doctor:
	python3 scripts/ambitions-codex-os-doctor.py
```

If no Makefile exists, create a minimal Makefile only if it does not conflict
with repo conventions. Otherwise, document direct script commands.

## Phase 8 - Optional Runner Integration

Inspect `scripts/ambitions-codex-train.sh`. Modify it only if all are true:

- The script exists.
- Its Codex invocation is clear.
- A minimal backward-compatible patch is possible.
- Current runner behavior remains intact.
- No API-key path, CI path, package install path, or cost exposure is introduced.

Preferred upgrades if safe:

- Use `codex exec --sandbox workspace-write`.
- Support optional JSONL log path.
- Support optional final JSON schema path `.codex/schemas/ambitions-batch-result.schema.json`.
- Support output report directory `build/reports/codex-runs/`.
- Do not force API-key auth.
- Do not add `danger-full-access`.
- Do not add GitHub Actions or remote automation.
- Do not make structured output mandatory if current runner cannot support it.

If the runner is complex or ambiguous, do not modify it. Document exact proposed
patch in:

```text
docs/codex-os/RUNNER_UPGRADE_NOTES.md
```

## Phase 9 - Documentation

Create:

```text
docs/codex-os/NO_COST_CODEX_OS.md
docs/codex-os/CODEX_OS_COMPONENTS.md
docs/codex-os/EXCLUDED_FOR_COST_OR_SCOPE.md
docs/codex-os/ROLLBACK.md
```

`NO_COST_CODEX_OS.md` must include what was implemented, why it is no-new-cost,
what is deliberately excluded, activation notes, validator and doctor commands,
Green/Yellow/Red interpretation, how to add future Skills safely, how to avoid
false release claims, and how to avoid GitHub Actions/API-key cost exposure.

`CODEX_OS_COMPONENTS.md` must include a table with: Component, File paths,
Purpose, How it helps, Cost posture, Validation command, Failure mode, Rollback.

`EXCLUDED_FOR_COST_OR_SCOPE.md` must list excluded items and reasons:

- Codex GitHub Action
- GitHub Actions workflows
- OpenAI API SDKs
- Agents SDK
- MCP servers
- gpt-oss model runtime
- Whisper
- tiktoken
- openai-cookbook examples
- ChatKit / Apps SDK
- Figma / Canva / paid design integrations
- App Store upload/signing automation
- package managers / dependency installation
- external CI/CD
- external SaaS tools

`ROLLBACK.md` must include path-specific rollback commands, including showing
changed files, reverting this batch path-by-path, removing `.codex` and
`.agents/skills` additions if needed, restoring previous `AGENTS.md`,
`Makefile`, and runner script from git, and never using `git reset --hard` as
default rollback.

## Phase 10 - Validation Expectations

Run at minimum:

```bash
python3 -m py_compile .codex/hooks/*.py scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py
python3 scripts/ambitions-codex-os-validate.py
python3 scripts/ambitions-codex-os-doctor.py
git diff --stat
git diff --name-only
```

If Make targets exist after integration, also run:

```bash
make ambitions-codex-os-validate
make ambitions-codex-os-doctor
```

If `codex execpolicy check` exists locally, run representative checks against
`.codex/rules/ambitions-no-cost.rules`:

- allowed: `git status`
- forbidden: `git push`
- forbidden: `npm install`
- forbidden: `curl https://example.com`
- prompt or forbidden: `xcodebuild archive`

If unavailable, do not fail solely for missing `codex execpolicy`. Mark as a
Yellow note if rules cannot be locally tested.

## Visual Proof Expectations

This batch must not change UI or app source. Visual proof is not required. If
app/UI files are changed accidentally, this is a Hard Red. Revert those changes
or stop and report Red with exact files.

## Hard Red Stop Conditions

Stop immediately and report Red if any occur:

- API-key wiring is added.
- GitHub Actions or CI workflow is added or modified.
- External package dependency is added.
- Package install command is introduced into scripts.
- Network download command is introduced.
- OpenAI API / SDK / Agents SDK / MCP / cloud runtime dependency is added.
- App source, Xcode project, signing, entitlement, dependency manifest, or lockfile is modified.
- Secret file is read or modified.
- A command attempts to write outside the repo.
- Destructive git command is required.
- Validation cannot run and the batch cannot provide honest Yellow status.
- The batch would require payment, subscription upgrade, paid quota, hosted runner, API billing, or external service.

## Yellow Conditions

Report Yellow, not Green, if:

- Hooks/config were created but project-local `.codex` trust/activation cannot be confirmed.
- Codex Rules were created but `codex execpolicy check` is unavailable.
- Runner integration is documented but not safely patched.
- Existing repo structure prevents nested AGENTS creation in some areas.
- Validation passes locally but with warnings.
- Any ambiguity remains about active source truth.

## Green Conditions

Report Green only if:

- All required local files were created or safely updated.
- No forbidden-cost pattern was introduced.
- No forbidden scope file was modified.
- Python hooks/scripts compile.
- Validator passes.
- Doctor runs.
- Docs exist and explain usage/rollback.
- Final report lists exact files changed and validation evidence.
- Any limitations are explicitly stated.

## Rollback Expectations

Provide exact rollback commands in the final report. Rollback must be
path-specific, for example:

```bash
git checkout -- AGENTS.md
git checkout -- scripts/AGENTS.md docs/AGENTS.md
rm -rf .agents/skills/ambitions-*
rm -rf .codex/hooks .codex/rules .codex/schemas
git checkout -- .codex/config.toml .codex/AGENTS.md .agents/AGENTS.md
git checkout -- scripts/ambitions-codex-os-validate.py scripts/ambitions-codex-os-doctor.py
git checkout -- docs/codex-os
git checkout -- Makefile scripts/ambitions-codex-train.sh
```

Do not recommend `git reset --hard` as default rollback.

## Required Final Response Structure

End with this exact structure:

```text
## Status

GREEN / YELLOW / RED

## Summary

Concise summary of implemented work.

## Files changed

List every changed file.

## Validation run

For each command:
- command
- result
- relevant evidence

## No-cost proof

State:
- New dependencies added: yes/no
- API keys added: yes/no
- Network/CI added: yes/no
- Paid services added: yes/no
- App runtime OpenAI dependency added: yes/no
- Notes

## Source-truth notes

List active truth files inspected and any ambiguity.

## Risks / limitations

Be explicit.

## Rollback

Path-specific rollback commands.

## Next recommended batch

One precise next batch recommendation, preferably runner structured-output
adoption or first no-cost Codex OS dry run, depending on what was completed.
```

# Ambitions Skill Index

Repo-local skills live under `.codex/skills/`. Keep durable repo rules in `AGENTS.md`; put repeatable, narrowly scoped execution workflows in a skill.

Personal defaults live in `~/.codex/config.toml`; repo overrides live in `.codex/config.toml`. Project-scoped config and skills are applied only when Codex trusts the project.

Use [.codex/README.md](/C:/Users/Devan/Documents/GitHub/ambitions/.codex/README.md) for project config intent, profile selection, and trusted-project notes.
Use `.codex/operations/` for production work intake and execution conventions, and `.codex/improvement/` when a weak run should change the system itself.

## Skills

- `phase-executor`
  Purpose: turn an Ambitions roadmap phase or implementation ask into an exact repo-grounded execution plan.
  Explicit invoke: `Use the phase-executor skill to turn phase 7 into an execution plan.`
  Implicit trigger examples:
  - `implement phase 9`
  - `break this backlog item into exact repo tasks`
  - `turn this roadmap step into code work`

- `xcodegen-target-writer`
  Purpose: edit `project.yml`, plist, entitlements, and target wiring safely using current Ambitions target conventions.
  Explicit invoke: `Use xcodegen-target-writer to add a new extension target.`
  Implicit trigger examples:
  - `add a new target`
  - `wire a widget extension`
  - `update XcodeGen for intents`

- `ios-extension-builder`
  Purpose: build or modify WidgetKit, Live Activity, Share Extension, and App Intents work using existing Ambitions extension patterns.
  Explicit invoke: `Use ios-extension-builder to add a share extension.`
  Implicit trigger examples:
  - `add widget`
  - `build share extension`
  - `add App Intent`
  - `create Live Activity`

- `capture-flow-implementer`
  Purpose: implement capture-domain work across models, persistence, services, routing, screens, and tests.
  Explicit invoke: `Use capture-flow-implementer to expand CaptureSourceType and wire the inbox.`
  Implicit trigger examples:
  - `build captures inbox`
  - `wire capture service`
  - `expand CaptureSourceType`

- `repo-truth-enforcer`
  Purpose: audit and fix stale repo claims across docs, previews, copy, and comments.
  Explicit invoke: `Use repo-truth-enforcer to clean up stale native docs.`
  Implicit trigger examples:
  - `clean up stale docs`
  - `make repo copy truthful`
  - `remove outdated claims`

- `ios-qa-regression-checker`
  Purpose: run or document the repo's actual validation workflow and report regressions honestly.
  Explicit invoke: `Use ios-qa-regression-checker to validate this branch.`
  Implicit trigger examples:
  - `validate this change`
  - `run regression checks`
  - `make sure this compiles and routes correctly`

- `design-system-guard`
  Purpose: keep Ambitions UI changes aligned with the repo's premium, dark-first, SwiftUI design language.
  Explicit invoke: `Use design-system-guard while polishing the captures screen.`
  Implicit trigger examples:
  - `polish this screen`
  - `make this match Ambitions design system`
  - `keep the UI premium`

- `planner-domain-safe-editor`
  Purpose: protect planning, rescheduling, Today, and evidence/feedback logic from casual regressions.
  Explicit invoke: `Use planner-domain-safe-editor to update Today rescheduling.`
  Implicit trigger examples:
  - `change rescheduling`
  - `update Today logic`
  - `modify planning engine`

- `release-hardening`
  Purpose: run a final preflight across build reproducibility, docs truth, privacy/config, and extension/manual test notes.
  Explicit invoke: `Use release-hardening for final preflight before merge.`
  Implicit trigger examples:
  - `prepare for merge`
  - `release harden this branch`
  - `final preflight`

- `ambitions-canon-v2-reconciler`
  Purpose: reconcile broad Ambitions 2.0 product/design/spec canon, roadmap, batch plans, decision logs, stale copy, terminology, and source-of-truth hierarchy before large integration work.
  Explicit invoke: `Use ambitions-canon-v2-reconciler before integrating the master product and visual system spec.`
  Implicit trigger examples:
  - `reconcile the v2 canon`
  - `update the master product spec`
  - `clean stale roadmap or decision-log truth`
  - `scan deprecated v2 terminology`

- `ambitions-time-context-builder`
  Purpose: implement or align Time Context Hierarchy, Schedule & Availability, free-time calculation, vacation/away behavior, durations, rigidity, readiness, cognitive fit, automation levels, and optional receipt-backed reflow.
  Explicit invoke: `Use ambitions-time-context-builder for Schedule & Availability models.`
  Implicit trigger examples:
  - `build time context hierarchy`
  - `add vacation availability behavior`
  - `ground duration labels`
  - `make reflow permissioned and reversible`

- `ambitions-action-closure-receipts`
  Purpose: implement or align Step Occurrence, Action Closure, closure outcomes, closure receipts, Still Counts, Needs a quick check, Today closure prompts, Trust Center receipt history, and Goal Detail receipt trails.
  Explicit invoke: `Use ambitions-action-closure-receipts to align closure receipts.`
  Implicit trigger examples:
  - `add Still Counts`
  - `show closure receipts in Today and Goal Detail`
  - `replace missed or overdue step states`
  - `build retroactive closure`

- `ambitions-ios-surface-polisher`
  Purpose: implement or polish Ambitions iOS surfaces under the current master product and visual system, including Today, Plan, You, Capture, Goals, Goal Detail, Trust Center, What Ambitions Knows, Reviews, Appearance Studio, Recovery Flow, shared components, previews, and fixtures.
  Explicit invoke: `Use ambitions-ios-surface-polisher while updating Today and Plan surfaces.`
  Implicit trigger examples:
  - `polish Ambitions v2 surfaces`
  - `make the Today surface match the master visual system`
  - `align Trust Center UI`
  - `update shared AmbitionsUI components`

- `ambitions-v2-validation-closeout`
  Purpose: validate broad Ambitions v2 product/design/model/docs/surface implementation before claiming completion, with explicit checks for canon consistency, forbidden language, five-tab IA, Today copy, schedule/vacation/cognitive-fit/receipt truth, duration grounding, previews, tests, and honest verified/not-verified reporting.
  Explicit invoke: `Use ambitions-v2-validation-closeout before declaring this v2 integration complete.`
  Implicit trigger examples:
  - `close out the master product and visual system implementation`
  - `validate v2 consistency`
  - `scan for forbidden language`
  - `produce the final verified/not verified summary`

## AGENTS.md vs Skills

- Put repo-wide, durable truth in `AGENTS.md`.
- Put narrowly scoped, repeatable jobs in a skill.
- Do not duplicate long procedures in `AGENTS.md` when a skill can carry them.
- Keep skill `name` and `description` specific so Codex can trigger them implicitly from user wording.

## Planning Gate

- Risky work must start with a plan before edits.
- Use `phase-executor` when the task spans multiple layers, has uncertain seams, or needs a more formal execution map.
- Use the templates in `.codex/templates/` when a lightweight plan is enough.

## Autonomous Execution Loop

- Classify the task first: maintenance, feature wiring, domain-safe edit, target/config work, docs truth, validation, or release hardening.
- Choose the narrowest skill set that fits. Prefer one primary skill plus a follow-on validation skill rather than blending several vague workflows.
- If the task is risky, plan first with `phase-executor` or the relevant plan template.
- Use `.codex/templates/autonomous-execution-loop.md` when a task needs an explicit classify -> plan -> execute -> check -> retry or stop structure.
- Execute the smallest safe slice, then self-check before continuing.
- If the result misses the goal, retry only with a narrower grounded step.
- If the task is blocked, stop and report the block instead of widening the diff speculatively.
- Finish with a truthful summary that separates verified from unverified.

## Common Skill Chains

- `phase-executor` -> `capture-flow-implementer`
- `phase-executor` -> `xcodegen-target-writer`
- `ios-extension-builder` -> `xcodegen-target-writer`
- `capture-flow-implementer` -> `ios-qa-regression-checker`
- `repo-truth-enforcer` -> `ios-qa-regression-checker`
- `planner-domain-safe-editor` -> `ios-qa-regression-checker`
- `release-hardening` -> `repo-truth-enforcer` and `ios-qa-regression-checker`
- `ambitions-canon-v2-reconciler` -> `ambitions-time-context-builder` -> `ambitions-action-closure-receipts` -> `ambitions-ios-surface-polisher` -> `ambitions-v2-validation-closeout`
- `ambitions-canon-v2-reconciler` -> `ambitions-ios-surface-polisher` -> `ambitions-v2-validation-closeout`
- `ambitions-time-context-builder` -> `ambitions-action-closure-receipts` -> `ambitions-v2-validation-closeout`
- `ambitions-ios-surface-polisher` -> `ios-qa-regression-checker` -> `ambitions-v2-validation-closeout`

## Recovery Rules

- If the wrong skill is likely selected, say so and switch to the narrower correct one.
- If skills overlap, name the primary skill and the follow-on skill instead of blending them into one vague workflow.
- If no skill fits cleanly, use the narrowest truthful plan and explain the gap.
- If validation cannot run, use the validation summary template and separate verified from unverified explicitly.
- Use `.codex/templates/retry-decision.md` when deciding whether to retry, continue, or stop.
- Use `.codex/templates/blocked-work-summary.md` when the repo seam, environment, or scope block the remaining work.
- Use `.codex/templates/execution-report.md` when the task spans several bounded steps and needs a clean final report.
- If the run itself was weak, use `.codex/templates/post-run-review.md` and `.codex/templates/system-refinement-decision.md` to decide whether AGENTS, a skill, a template, an eval, or docs should change.

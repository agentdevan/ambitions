# Ambitions Skill Index

Repo-local skills live under `.codex/skills/`. Keep durable repo rules in `AGENTS.md`; put repeatable, narrowly scoped execution workflows in a skill.

Personal defaults live in `~/.codex/config.toml`; repo overrides live in `.codex/config.toml`. Project-scoped config and skills are applied only when Codex trusts the project.

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

## AGENTS.md vs Skills

- Put repo-wide, durable truth in `AGENTS.md`.
- Put narrowly scoped, repeatable jobs in a skill.
- Do not duplicate long procedures in `AGENTS.md` when a skill can carry them.
- Keep skill `name` and `description` specific so Codex can trigger them implicitly from user wording.

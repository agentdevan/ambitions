# OpenAI Build Suite Adoption Matrix

| Capability | OpenAI surface | Ambitions use | repo path | runtime allowed? | risk | status |
|---|---|---|---|---|---|---|
| Codex multi-agent build system | Codex/Agents SDK orchestration, prompt tools | bounded batch execution coordination | docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md, tools/openai/config/codex_agent_roles.json | No | Low | Planned |
| Repo intelligence / File Search | File Search concepts for local manifest + vector-ready package design | local manifest generation and repo query stubs | tools/openai/repo_brain | No | Medium | Planned |
| Eval / QA | Evals API simulation scaffolding | deterministic local validation packet checks before any real provider wiring | tools/openai/evals | No | Low | Planned |
| Prompt repair | Prompt repair layer and queue consistency helpers | clean prompt audit consistency, stale state checks, local repair utility | tools/openai/prompt_repair, scripts/ambitions-prompt-queue-consistency.py | No | Low | Planned |
| Batch report generation | Local JSON summaries and status extraction | report parsing and local classification for closeout packets | tools/openai/batch_report | No | Low | Planned |
| Visual critique | local image check + rubric validator | local snapshot checklist validator for launch-ready visual packets | tools/openai/visual_critique | No | Medium | Planned |
| Launch documentation drafting | report synthesizer + draft packet emitter | local synthesis from audit/proof docs | tools/openai/launch_docs | No | Medium | Planned |
| Optional future user-controlled cloud assist | optional Agents tools integration | manual opt-in review mode outside core runtime | future docs only | Opt-in only | High | Not started |
| Forbidden core runtime intelligence | OpenAI runtime in app domain | forbidden for this batch | Native/Ambitions/** | No | Red | Blocked by policy |

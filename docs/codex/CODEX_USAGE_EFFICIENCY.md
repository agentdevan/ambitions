# Codex Usage Efficiency

Status: Active Codex OS efficiency protocol.  
Date: 2026-05-07  
Scope: Reduces context, command-output, validation, restart, and batch-train waste.

## Operating Principle

Do not optimize by hiding truth. Optimize by routing to the smallest useful context, summarizing saved output, and preserving raw proof for all meaningful claims.

## Efficiency Stack

| Layer | Name | Purpose |
| --- | --- | --- |
| ACX | Ambitions Command eXtractor | Bounded reads, saved-log summaries, changed-file grouping from saved status text, advisory gates, and gate reports. |
| ARC | Ambitions Route Context | Read route files before broad search. |
| AGE | Ambitions Gate Engine | Run advisory gates for drift, claims, boundaries, and batch proof. |
| AEP | Ambitions Evidence Packets | Preserve command, exit code, raw log, touched files, and claim boundary. |
| ABS | Ambitions Batch State | Keep train state resumable from repo files. |
| ASK | Ambitions Skills Kit | Route work to existing `.codex/skills/` instead of generic agent behavior. |

## ACX Rules

Use ACX for non-executing extraction and summarization:

```bash
python3 scripts/ai/acx.py read AGENTS.md --lines 140
python3 scripts/ai/acx.py summarize-log output/logs/latest-build.log
python3 scripts/ai/acx.py changed-files-from output/logs/git-status-short.txt
python3 scripts/ai/acx.py gate deprecated-language
python3 scripts/ai/acx.py gate release-claims
python3 scripts/ai/acx.py gate all
python3 scripts/ai/acx.py gate-report
```

ACX does not run build, test, git, Xcode, or shell commands. It consumes saved text/logs and scans the repo. This avoids turning the repo efficiency layer into a command-execution proxy.

## Raw-Log Policy

Raw logs are required for:

- failed builds
- failed tests
- failed gates
- hard Reds
- release-readiness claims
- TestFlight/App Store claims
- device proof
- public accessibility proof
- legal/privacy compliance claims
- destructive or migration operations

ACX summaries are acceptable for navigation and routine review only.

## Context Budget Classes

| Class | Use | Max default read |
| --- | --- | --- |
| A | Tiny docs/script edit | `AGENTS.md`, one route, target file. |
| B | Bounded tooling/gate update | `AGENTS.md`, index, route, related existing protocol, target files. |
| C | Cross-Codex OS upgrade | `AGENTS.md`, `.codex/README.md`, peak protocol, CQS matrix/script map, route/state docs. |
| D | Global batch execution | Batch state, batch manifest, context index, selected route, gate matrix, target source/canon. |
| E | Hard Red repair | Raw logs, failure route, owner files, repair protocol, no broad implementation unless required. |

## Search Budget

1. Search exact path or symbol.
2. Search canonical product phrase.
3. Search owning protocol or gate.
4. Stop and summarize uncertainty.
5. Only then use broad repo search.

## No-Redundant-Proof Rule

When command proof already exists for the same commit and no relevant file changed, cite that proof instead of rerunning. When files changed, rerun the smallest relevant validation tier.

## Validation Tiers

| Tier | Purpose |
| --- | --- |
| 0 | Static docs/gate scan. |
| 1 | Focused script or targeted test. |
| 2 | Relevant unit test group. |
| 3 | Full local build/test command. |
| 4 | Physical-device or human/operator proof. |

Do not escalate validation tier automatically. Escalate only when the touched paths and claim require it.

## Anti-Waste Rules

- Do not reread full canon when a current digest/route/state file is enough.
- Do not run full build for docs-only tooling changes unless a script or generated project file changed in a way that needs it.
- Do not create a new operating concept if an existing CQS, route, state, skill, or gate can be extended.
- Do not mark a batch complete from summarized output alone.
- Do not leave a session without a restartable state, evidence packet, or explicit no-change report.

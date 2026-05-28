# Linear Templates

Status: Active workflow contract.
Scope: Repo-backed Linear issue/project templates for Ambitions Codex execution.

This directory is the source of truth for generating Linear issues and projects that
delegate implementation to Codex without letting Linear or Codex become product,
architecture, release, or repo authority.

## Authority

These templates sit below:

1. `docs/truth/*`
2. `AGENTS.md`
3. `README.md`
4. `docs/codex/LINEAR_CONTROL_PLANE.md`
5. `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
6. `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
7. Relevant prompt, source, test, proof, and log paths

If a Linear issue conflicts with repo truth, repo truth wins.

## Token-Efficient Operating Model

Default to compact Linear issues that reference the manifest instead of pasting the
full product law every time.

Use:

```text
Template: AMB-BATCH@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Authority inspected: <exact repo paths>
Intent: <one outcome>
Scope: <allowed files/folders>
Requirements: <numbered implementation requirements>
Validation: <commands or validation lane>
Proof: <artifact paths>
Non-goals: <hard exclusions>
```

Use expanded templates only for high-risk work, cross-surface work, architecture
changes, privacy/runtime changes, release claims, or a failing validation repair.

## Template Selection

| Template | Use |
| --- | --- |
| `AMB-BATCH` | Normal scoped implementation issue for Codex. |
| `AMB-FIX` | Validation failure, build/test repair, or proof repair. |
| `AMB-DESIGN` | SwiftUI surface, design-system, visual QA, accessibility, preview, or screenshot work. |
| `AMB-REVIEW` | Audit, merge-readiness review, proof review, or no-mutation inspection. |
| `AMB-DOCS` | Documentation, canon support note, governance, or process-only work. |
| `AMB-SPIKE` | Investigation only; no production mutation. |
| `AMB-PROJECT` | Multi-issue Linear project / train wrapper. |

## Required Final Codex Report

Every Codex-executed issue must end with:

```text
Summary:
Changed files:
Commands run:
Proof artifacts:
Green/Yellow/Red:
Risks:
Follow-up issue, if needed:
```

## Non-Claims

This directory does not prove:

- Linear templates are installed in the Linear UI.
- Linear API sync/upsert exists.
- Any generated issue has been executed.
- App build, test, accessibility, performance, privacy, device, TestFlight, App Store, or release readiness.
- Any status in Linear is stronger than current repo evidence.

# Ambitions Skill Registry

Status: Active Codex skill registry
Scope: Repo-local `.agents/skills` routing, retention, and validation
Owner posture: Operating support only, not truth or proof

## Purpose

Skills are small operating checklists for Codex. They do not define Ambitions canon, implementation truth, release proof, accessibility proof, privacy approval, or App Store readiness.

Truth files answer what is true. Skills answer what Codex must check before touching a specific kind of work.

## Authority Boundary

`docs/truth/*`, live source, tests, current logs, current proof artifacts, and current user or issue instructions win over every skill.

If a skill conflicts with `docs/truth/*`, the skill is stale. Update or demote the skill; do not use it to reinterpret truth.

## Required Starting Point

Read `docs/truth/CODEX_START_HERE.md` before loading a skill. It is the routing aid for choosing the right truth files and the smallest useful skill set. It remains subordinate to the substantive truth files.

## Skill Routing Matrix

| Task type | Skills |
|---|---|
| Any repo edit/review | `ambitions-source-truth-authority` |
| Source creation/move/refactor/architecture review | `ambitions-source-truth-authority`, `ambitions-architecture-tree-enforcement` |
| SwiftUI/frontend/Apple-platform work | `ambitions-source-truth-authority`, `ambitions-architecture-tree-enforcement`, `ambitions-ios-quality-gate` |
| Build/test/release/readiness/proof claims | `ambitions-source-truth-authority`, `ambitions-release-proof-honesty` |
| Visual/product-surface closeout | `ambitions-ios-quality-gate`, `ambitions-release-proof-honesty` |
| Docs/governance only | `ambitions-source-truth-authority`; add `ambitions-release-proof-honesty` only if proof/release wording is touched |
| Account/R2/Source Atlas work | `ambitions-source-truth-authority`, `ambitions-ios-quality-gate` if platform code changes, `ambitions-release-proof-honesty` if readiness/proof is claimed |

## Retained Skills

| Skill | Path | Role |
|---|---|---|
| `ambitions-source-truth-authority` | `.agents/skills/ambitions-source-truth-authority/SKILL.md` | Classifies truth, live evidence, stale material, and allowed claims. |
| `ambitions-architecture-tree-enforcement` | `.agents/skills/ambitions-architecture-tree-enforcement/SKILL.md` | Enforces the exact Final Architecture Tree and non-equivalent owner law. |
| `ambitions-ios-quality-gate` | `.agents/skills/ambitions-ios-quality-gate/SKILL.md` | Routes native iPhone, Apple-platform, UI, accessibility, and visual-proof checks. |
| `ambitions-release-proof-honesty` | `.agents/skills/ambitions-release-proof-honesty/SKILL.md` | Separates verified proof from unsupported release/readiness claims. |

## When To Load

- Load `ambitions-source-truth-authority` for any non-trivial repo edit, review, docs governance change, script change, or claim classification.
- Load `ambitions-architecture-tree-enforcement` before source creation, movement, refactor, architecture review, or any train touching `Features/` compatibility.
- Load `ambitions-ios-quality-gate` before SwiftUI, UIKit, SwiftData, WidgetKit, App Intents, notification, permission, privacy, accessibility, shell, keyboard, or Apple-platform work.
- Load `ambitions-release-proof-honesty` before build/test/release/readiness wording, proof packets, privacy/account/R2 proof, TestFlight/App Store wording, or any Green/Yellow/Red claim that depends on evidence.

## When Not To Load

- Do not load all skills by default for a narrow docs or script edit.
- Do not use skills to skip `docs/truth/CODEX_START_HERE.md` or required substantive truth files.
- Do not use a skill as product canon, implementation proof, release proof, visual proof, or owner acceptance.
- Do not use old non-retained skills as active routing unless a future approved train promotes them back into the retained list.

## Skill Count Policy

Retain four repo skills by default:

1. source/truth authority
2. architecture tree enforcement
3. iOS quality gate
4. release proof honesty

A fifth retained skill requires explicit truth-file approval and must prove the need cannot be covered by the four retained skills or `docs/truth/CODEX_START_HERE.md`.

## How To Add, Change, Or Delete A Skill

Before changing skill inventory:

1. Read `docs/truth/CODEX_START_HERE.md`, `docs/truth/README.md`, `docs/truth/CODEX_PROCESS_TRUTH.md`, and `docs/truth/HISTORICAL_POLICY.md`.
2. Confirm the change preserves Today / Goals / Time / You, Capture as global composer, Motion as behavior, Trust inspection, local-first/offline core, account/R2 boundaries, and proof honesty.
3. Prefer updating an existing retained skill over adding a new one.
4. Keep each skill task-triggered and short.
5. Add or update the `## Skill digest`.
6. Update this registry and run `python3 scripts/ambitions-skill-registry-check.py`.

Deletion requires future approval unless the file is clearly stale, unreferenced, unsafe, and redundant. This registry may mark candidates, but marking a candidate is not deletion approval.

## Merge Candidates

| Skill | Path | Why not retained | Required future approval before removal |
|---|---|---|---|
| `ambitions-anti-pattern-detection` | `.agents/skills/ambitions-anti-pattern-detection/SKILL.md` | Duplicates `IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, `ambitions-ios-quality-gate`, and release-proof limits. | Approve merge into retained iOS/release skills, then delete. |
| `ambitions-canon-closeout` | `.agents/skills/ambitions-canon-closeout/SKILL.md` | Duplicates `CODEX_START_HERE.md`, `IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, and `ambitions-release-proof-honesty`. | Approve merge into retained release skill, then delete. |
| `ambitions-product-object` | `.agents/skills/ambitions-product-object/SKILL.md` | Duplicates rendered-product acceptance and iOS quality gates. | Approve merge into retained iOS skill, then delete. |
| `ambitions-visual-proof` | `.agents/skills/ambitions-visual-proof/SKILL.md` | Duplicates visual proof law in acceptance truth and release-proof honesty. | Approve merge into retained iOS/release skills, then delete. |
| `ambitions-visual-red-team` | `.agents/skills/ambitions-visual-red-team/SKILL.md` | Duplicates independent visual-review boundaries and is not a task-triggered retained checklist. | Approve merge into retained iOS/release skills, then delete. |

## Delete Candidates

No skill is approved for deletion in this train. The merge candidates above are present only to prevent unregistered skill sprawl and require future approval before removal.

## Validation Expectations

Minimum skill-layer validation:

```bash
test -f .agents/skills/README.md
rg -n "## Skill digest" .agents/skills/*/SKILL.md
rg -n "docs/truth/CODEX_START_HERE.md" .agents/skills/*/SKILL.md
python3 scripts/ambitions-skill-registry-check.py
git diff --check
```

Run the relevant safe canon, vocabulary, claim, copy, and scenario checks for the train. Do not run Xcode builds for docs/governance-only skill registry work unless a separate source/runtime change requires it.

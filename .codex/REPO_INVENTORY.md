<!-- markdownlint-disable MD013 -->

# Codex Repo Inventory

Status: Active repo map and routing index
Date updated: 2026-05-10
Branch: main
HEAD: 661206bd
Scan method: `find`, `rg`, `git status`, active truth docs, Codex OS files, current state files, and Phase 0-8 cleanup evidence.
Known scan limits: large historical/train files were not line-reviewed end to end; use large-file overrides and the archive/stale ledger before archive/delete decisions.
Large-file overrides used: `docs/status/large-doc-classification-overrides.md`; later phases may add batch-train-specific overrides.

## How To Use This Inventory

Use this file first when a future ChatGPT/Codex session needs to answer repo
structure, routing, ownership, or status-location questions. This file can
tell a session where to inspect next. It cannot prove implementation, build,
tests, release readiness, real-hardware validation, accessibility conformance,
performance, privacy/legal signoff, or completeness.

## Authority Map

| Question type | Inspect first | Secondary sources | Conflict winner |
| --- | --- | --- | --- |
| Product/design truth | `docs/truth/PRODUCT_DESIGN_TRUTH.md` | `docs/AmbitionsCanon/README.md` | `docs/truth/*` |
| Implementation status | `docs/truth/IMPLEMENTATION_TRUTH.md`, `docs/status/current-implementation-map.md`, live source | tests, project files | live source + truth files |
| Release/proof status | `docs/truth/RELEASE_TRUTH.md`, `docs/status/release-evidence-packet.md` | raw logs/proof packets | current raw evidence |
| Codex process | `docs/truth/CODEX_PROCESS_TRUTH.md`, `AGENTS.md` | `.codex/OPERATING_SYSTEM.md` | truth + `AGENTS.md` |
| Batch train status | `.codex/GLOBAL_BATCH_TRAIN.md` | `.codex/BATCH_TRAIN_REGISTRY.md`, state files | truth + global train |
| Skill status | `.codex/SKILL_GOVERNANCE.md` | `.codex/manifests/skills-routing-map.yml` | skill governance |
| Archive/delete status | `docs/truth/HISTORICAL_POLICY.md` | archive/stale ledger | historical policy |
| Source structure | `Native/`, `Sources/`, `AppUI/`, `project.yml`, `Package.swift` | `AGENTS.md` overlays | live source |
| Build/test validation | `.codex/TOOLING_AND_VALIDATION.md` | `docs/native-build-and-release.md`, logs | raw logs |
| Visual QA | product truth, FET/SI/DAV/SIG gates | screenshots, visual evidence | raw visual evidence |
| Accessibility | product truth, release truth | accessibility docs/logs | current evidence |
| Privacy/security | release truth, privacy/security docs | scans, manifests | truth + source evidence |
| Backend/provider assumptions | truth files, skill governance | cleanup docs | provider exclusion policy |
| Model-tier routing | `.codex/SESSION_BOOTSTRAP.md` | model-tier docs | bootstrap + OS |
| MCP/tooling | `.codex/TOOLING_AND_VALIDATION.md` | `tools/mcp/*` | tooling map |
| Historical docs | `docs/truth/HISTORICAL_POLICY.md` | archive/stale ledger | historical policy |

## Top-Level Repo Map

| Path | Classification | Purpose | State | Owner department | Inspect when |
| --- | --- | --- | --- | --- | --- |
| `docs/truth/` | truth | Active authority | active | Codex Process, Product, Release | any conflict |
| `README.md` | front door | public repo routing | active | Repo Hygiene | repo entry |
| `docs/README.md` | docs front door | docs routing | active | Repo Hygiene | docs entry |
| `AGENTS.md` | contributor guidance | Codex/developer rules | active | Codex Process | any Codex work |
| `.codex/` | operating system | state, skills, tools, registries | active/supporting | Codex Process | Codex operation |
| `docs/status/` | evidence/status | current maps, reports, ledgers | active/supporting | Repo Hygiene, Release | status/proof |
| `docs/codex/` | historical/supporting OS docs | batch/train/gates/prompts | mixed | Codex Process | train history |
| `docs/AmbitionsCanon/` | product/design canon | compatible supporting canon | supporting | Product/Design | product/design work |
| `docs/canon/` | older/future canon | historical/supporting | mixed | Product/Design | historical context |
| `docs/audits/` | audit/proof history | logs, reports, visual evidence | supporting | QA/Release | evidence lookup |
| `docs/archive/` | archive | retained superseded material | historical | Repo Hygiene | history |
| `Native/` | app source | native app, tests, extensions | source | iOS Engineering | implementation |
| `Sources/` | shared packages/source | components/theme/accessibility | source | iOS Engineering/Design | shared UI/source |
| `AppUI/` | Swift package UI | shared UI package | source | iOS Engineering/Design | UI package |
| `project.yml` | XcodeGen source | target/project wiring | source | Build Systems | project config |
| `Package.swift` | SwiftPM source | package config | source | Build Systems | package config |
| `scripts/` | local tooling | validation/scans/setup | active/supporting | Build Systems/Codex | validation |
| `tools/mcp/` | optional MCP tooling | repo/proof/tool servers | active/candidate | Codex Process | MCP work |
| `.github/` | hosted CI | absent | absent | Build Systems | CI questions |
| `output/` | generated/local output | logs/build output | generated | QA/Build Systems | local evidence |

## Source Map

- `Native/Ambitions/App`: app entry, dependency container, shell, routing.
- `Native/Ambitions/Domain`: domain models, contracts, state machines.
- `Native/Ambitions/Services`: service protocols and implementations.
- `Native/Ambitions/Persistence`: SwiftData persistence and portable data work.
- `Native/Ambitions/Features`: Today, Goals, Capture, Time/Plan compatibility, You/Profile compatibility.
- `Native/Ambitions/UI`: shared native UI.
- `Native/Ambitions/AppIntents`, `AmbitionsShareExtension`, `AmbitionsWidgetExtension`: extension/surface paths.
- `Native/Ambitions/Resources`: resources and privacy manifests.
- `Native/AmbitionsTests`, `Native/AmbitionsUITests`: local tests.
- `Sources/Accessibility`, `Sources/Components`, `Sources/Theme`, `Sources/Previews`: shared package surfaces.
- `project.yml`: XcodeGen project source truth.
- `Package.swift`: Swift package source truth.

## Truth And Docs Map

- `docs/truth`: active authority.
- `docs/status`: current implementation, release evidence, cleanup reports, ledgers.
- `docs/AmbitionsCanon`: compatible product/design canon.
- `docs/codex`: batch/train/process history and supporting operating docs.
- `docs/canon`: older/future canon and supporting policy material.
- `docs/audits`: proof reports, logs, visual evidence, doc QA logs.
- `docs/handoff`: historical/supporting handoff material.
- `docs/archive`: retained superseded material.

## Codex OS Map

- `.codex/OPERATING_SYSTEM.md`: active OS router.
- `.codex/DEPARTMENT_REGISTRY.md`: department/review/ownership/risk map.
- `.codex/SKILL_GOVERNANCE.md`: skill policy and inventory.
- `.codex/GLOBAL_BATCH_TRAIN.md`: active sequencing.
- `.codex/BATCH_TRAIN_REGISTRY.md`: originating train classification.
- `.codex/TOOLING_AND_VALIDATION.md`: tools and validation.
- `.codex/SESSION_BOOTSTRAP.md`: start/resume/recovery path.
- `.codex/REPO_INVENTORY.md`: this repo map.
- `.codex/state`: active/recent/yellow/repair state.
- `.codex/reports`: current run/train reports.
- `.codex/templates`: templates; old prompts are supporting unless current.
- `.codex/manifests`: routing and manifest support.
- `.codex/skills`: repo-local skills; use governance before auto-loading.

## Batch Train Map

| Train | Status | Source files | Folded into global train |
| --- | --- | --- | --- |
| Global | active | global order/queue/state files | yes |
| PK | active/planned | `PK00_PK41_PLATFORM_KERNEL_TRAIN.md` | yes |
| EFC | active proof overlay | `EFC00_EFC18_*`, EFC overlay docs | yes, as overlay |
| SA | planned/supporting | `SA01_SA32_*` | yes |
| LDI | mixed completed/planned/blocked | `LDI01_LDI22_*` | yes |
| AOS | mixed completed/blocked | `AOS01_AOS30_*` | yes |
| FCP/PFC | mixed completed/planned | FCP/PFC train files | yes |
| FET | completed/supporting | `FET01_FET12_*` | yes, as gates |
| PX | historical complete/do not rerun | `PX01_PX20_*` | historical only |
| PD/SI/DAV/EB/HPS/FL/ME/REC/CQS/CS | completed/supporting mix | train files | supporting |
| SIG/RHC | deferred/planned | SIG/RHC train files | yes, later |
| F03.5/F04-F30 | historical/supporting | older F train files | historical only |

Use `.codex/BATCH_TRAIN_REGISTRY.md` for details.

## Skill Map

- Active operating skills: use only when `.codex/SKILL_GOVERNANCE.md` allows.
- Candidate skills: require explicit batch selection.
- Historical/deprecated skills: context only.
- Deleted provider skills: `.agents/skills/supabase/` and
  `.agents/skills/supabase-postgres-best-practices/`.
- Line-review status: not every `.codex/skills` file has been line-reviewed.

## Tooling And Validation Map

- `scripts/run-doc-qa.sh`: docs QA, advisory output may remain.
- build/test scripts: local validation only.
- claim/privacy/accessibility/visual scans: advisory gates unless logs are
  captured and cited.
- `tools/mcp/ambitions_repo_mcp`: optional read-only repo aid.
- `tools/mcp/ambitions_proof_mcp`: optional allowlisted proof aid.
- `.github/`: absent.
- Dangerous: broad deletes/restores, dependency installs, hosted CI activation,
  signing/App Store/TestFlight automation, provider/backend activation.

Use `.codex/TOOLING_AND_VALIDATION.md` for details.

## Archive / Stale Material Map

- Stale inventories: `docs/audits/tracked-files.txt` contains deleted provider paths.
- Old prompts: many `docs/codex/*PROMPT*` and resume docs are supporting/historical unless refreshed by `.codex/SESSION_BOOTSTRAP.md`.
- Obsolete train docs: no deletion approved in Phase 8.
- Historical canon docs: governed by `docs/truth/HISTORICAL_POLICY.md`.
- Delete candidates: none approved by this inventory.
- Must not delete: truth files, front doors, current implementation/release evidence, active Codex OS files, active state, source/runtime files.

## Future Question Routing

| If asked... | Inspect first |
| --- | --- |
| What is current product truth? | `docs/truth/README.md` |
| What is implemented? | `docs/status/current-implementation-map.md` + live source |
| What batch is next? | `.codex/GLOBAL_BATCH_TRAIN.md` |
| What trains are obsolete? | `.codex/BATCH_TRAIN_REGISTRY.md` + `docs/status/archive-and-stale-material-ledger.md` |
| What skills are active? | `.codex/SKILL_GOVERNANCE.md` |
| Can Codex use mini? | `.codex/OPERATING_SYSTEM.md` + `.codex/SESSION_BOOTSTRAP.md` |
| Can we delete this file? | `docs/status/archive-and-stale-material-ledger.md` |
| Can we claim release readiness? | `docs/status/release-evidence-packet.md` |
| Where are validation tools? | `.codex/TOOLING_AND_VALIDATION.md` |
| What is stale? | `docs/status/archive-and-stale-material-ledger.md` |
| What is historical? | `docs/truth/HISTORICAL_POLICY.md` + `.codex/REPO_INVENTORY.md` |

## No-Claim Reminder

This inventory does not prove:

- build success
- test success
- release readiness
- validation on real hardware
- accessibility/performance/privacy signoff
- implementation completeness
- hosted CI proof
- App Store or TestFlight readiness

## Regeneration Instructions

Use these commands to refresh the inventory:

```bash
git status --short --branch
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD
find . -maxdepth 1 -mindepth 1 -print | sort
find docs -maxdepth 2 -type d | sort
find Native Sources AppUI -maxdepth 2 -type d 2>/dev/null | sort
find docs/codex/batch-trains -maxdepth 1 -type f -name '*.md' | sort
find .codex -maxdepth 2 -type f | sort
find tools/mcp -maxdepth 2 -type f | sort
find scripts -maxdepth 2 -type f | sort
rg -n -i "supabase|provider|hosted ci|testflight|app store|release|accessibility|production" README.md docs .codex scripts tools 2>/dev/null || true
```

## Inventory Freshness Stamp

Fresh as of Phase 8 on 2026-05-10, branch `main`, HEAD `661206bd` before the
Phase 8 commit.

Phase 8 result: Green with accepted Yellow items. Large-file and stale-material
details continue in the Phase 9 archive/stale ledger.

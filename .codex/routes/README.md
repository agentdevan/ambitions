# Codex Route Catalog

Status: Active route catalog.  
Date: 2026-05-07  
Scope: Compact routing for Ambitions Codex OS usage efficiency.

## Route Selection Rule

Pick one route before broad repo search. Add a second route only when the task crosses a real boundary, such as UI plus build failure or canon drift plus release claims.

## Routes

| Route | Use | Read first | Required gates | Forbidden drift |
| --- | --- | --- | --- | --- |
| Today UI | Start Here Surface, Reality Meridian/Rail, pressure/recovery, closure, Step Session entry. | `AGENTS.md`, `CODEX_OS_INDEX.md`, current batch state, Today owner canon/FCP evidence. | Source Truth, Top-Level Composition, Visual/FVQ, Accessibility, Canon Drift, Validation. | Generic task dashboard, card stack, silent schedule mutation, unsupported release/accessibility claims. |
| Goals UI | Goals atlas, Goal Detail, Mission Control, LifePath, Proof Spine. | Goals owner canon and FCP10-FCP13B evidence. | Source Truth, no-KPI-dashboard, Visual/FVQ, Accessibility, Proof/Receipt, Validation. | Forced single primary goal, KPI dashboard, hidden path mutation. |
| Capture UI | Composer, Placement Shelf, Placement Resolver, Correction Fold, Goal Seed Incubator. | Capture owner canon and FCP18-FCP21 evidence. | Composer-first, Privacy/Hidden Learning, Accessibility, Validation. | Inbox/feed/notes posture, automatic goal creation, hidden learning. |
| Plan UI | LifeShape, pressure/recovery, reflow, schedule/availability, capacity. | Plan/LifeShape/Reflow owner canon and FCP14-FCP16 evidence. | Calendar-clone rejection, silent-reflow rejection, protected/free-time proof, Accessibility. | Generic calendar clone, silent mutation, fake precision. |
| You UI | Personal System Center, Planning Setup, Trust/Memory/Receipts, Appearance Studio. | You/Profile compatibility docs and FCP22-FCP24 evidence. | You terminology, grouped-list, privacy/trust/memory, Accessibility. | New Profile top-level destination, hidden durable memory/sync claims. |
| Build Failure | Compile, test, Xcode, Swift, XcodeGen, dependency, validation failure. | Raw log, evidence standard, build/toolchain docs. | Validation, Senior Architecture, Release Claim, Report. | Broad refactor before root cause, dependency addition without approval. |
| Visual QA | Screenshot/rendered proof, flagship object quality, native believability. | CQS gate matrix, surface route, FVQ evidence. | Visual Quality, FVQ Rendered Proof, Accessibility, Anti-Slop. | Claiming human-approved visuals/public accessibility/release readiness without proof. |
| Canon Drift | Product language, source truth, supersession, naming conflicts, top-level IA. | Context index, peak protocol, CQS matrix, owner doc. | Source Truth, Canon Drift, Report, Release Claim when needed. | Erasing history, creating new top-level tabs, turning status truth into product truth. |
| Global Batch Train | Resume/continue batch train until complete or hard Red. | `RESUME_GLOBAL_BATCH_TRAIN.md`, current batch state, global order, selected batch prompt. | Source Truth, Scope, No-Double-Work, Validation, Report, batch-specific gates. | Continuing through hard Red, claiming app behavior from canon/scaffold alone. |
| Repo Hygiene | Stale docs, duplicated concepts, generated artifacts, ignored logs, script maps. | `.codex/README.md`, CQS script map, RHC reports. | Scope, No-Overwrite, Anti-Slop, Validation, Report. | Deleting historical docs or accepted Yellow history without approval. |
| Source Atlas | Pack manifests, claims, requirements, proof maps, validators, projection recipes. | Source Atlas canon, SA/SAP reports, SA06 schema evidence. | Source Truth, Schema/Sync/Migration if touched, Privacy/Security, Validation. | Fabricating seed files, marking missing imports complete, hosted-AI claims. |

## Evidence Requirements

Every route must report:

- files read
- files touched
- commands run
- exit codes
- raw logs when relevant
- claims not made
- Green / Accepted Yellow / Red

## Staleness Rule

This file is a route map, not source truth. If it conflicts with `AGENTS.md`, active canon, `docs/codex/CODEX_OS_PEAK_OPERATING_PROTOCOL.md`, or `.codex/reports/current-batch-train-state.md`, trust the owner file and update this catalog in a Codex OS maintenance pass.

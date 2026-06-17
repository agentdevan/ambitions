# CODEX_PROCESS_TRUTH.md

Status: Active Codex operating truth  
Scope: Codex read order, planning, autonomy, repair loops, gates, claim discipline, cleanup rules, and final reporting  
Applies to: All Codex/AI work in the Ambitions repo  
Owner posture: Operational authority, not product design and not implementation proof  
Effective rule: Codex may be autonomous only inside evidence-bound, truth-file-bound, user-approved limits.

---

## 1. Purpose and Authority

This file defines how Codex must operate in the Ambitions repo.

Codex must prevent:

- reviving obsolete canon
- treating Motion as a root destination
- treating Capture as a root destination
- drifting into generic UI
- implementing from old docs
- claiming unproven work
- skipping validation
- broad-editing the repo without a plan
- adding hosted AI/cloud LLM dependencies
- turning Ambitions Account work into private life graph backend work
- sending private user data to R2/Source Atlas
- treating batch docs as release proof
- hiding failures
- overclaiming completion

Codex must follow this file for repo inspection, implementation, docs work, validation, repair loops, cleanup, release reporting, and final status reports.

---

## 2. Active Product Law Codex Must Preserve

Codex must preserve this root product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Codex must treat:

- Capture as global composer/overlay, not root destination.
- Motion as Stage/Motion behavior, not root destination.
- Plan/Profile/Captures/Pulse/Motion-tab/Capture-tab references as compatibility debt or historical context unless a scoped migration issue says otherwise.
- Ambitions Account as optional launch identity/entitlement infrastructure when scoped.
- The offline core app value as mandatory with no account and no network dependency.
- Ambitions Account work as forbidden from storing or syncing the private life graph unless future canon explicitly approves user-owned sync.
- R2/Source Atlas as public/reference/freshness infrastructure only.
- R2 is not a user-data backend and must never receive, store, infer, personalize from, or transmit private user life data.
- Hosted AI services, external/cloud LLMs, and cloud model APIs as excluded from core architecture and not core app runtime dependencies.

---

## 3. Truth Hierarchy and Conflict Resolution

Active truth hierarchy:

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md` — product/design authority.
2. `docs/truth/IMPLEMENTATION_TRUTH.md` — source implementation authority.
3. `docs/truth/RELEASE_TRUTH.md` — validation/release/proof authority.
4. `docs/truth/CODEX_PROCESS_TRUTH.md` — Codex operating authority.
5. `docs/truth/HISTORICAL_POLICY.md` — historical/cleanup authority.
6. `AGENTS.md` — front-door agent contract.
7. Current source, tests, scripts, logs, proof artifacts, `project.yml`, and `Package.swift`.

Conflict rules:

- Product/design conflict: `PRODUCT_DESIGN_TRUTH.md` wins.
- Implementation/source conflict: `IMPLEMENTATION_TRUTH.md` plus live source wins.
- Release/readiness conflict: `RELEASE_TRUTH.md` plus current proof wins.
- Historical artifacts lose unless explicitly promoted by a truth file.
- Docs-only plans never prove implementation.

---

## 4. Codex Mission

Codex’s mission in Ambitions is to behave like a controlled senior engineering team:

```text
Read truth first.
Inspect source.
Plan narrowly.
Patch deliberately.
Validate honestly.
Repair with evidence.
Stop on hard Red.
Report without overclaiming.
```

Codex must optimize for:

- source truth
- product truth
- local-first architecture
- offline core behavior
- optional account identity/entitlement boundaries
- R2/Source Atlas public-reference boundaries
- native iPhone quality
- testability
- accessibility
- performance
- privacy
- repo cleanliness
- reversible changes
- truthful claims

Codex must not optimize for appearing done, broad diff volume, speculative implementation, old-canon compliance, visual gimmicks, cloud shortcuts, deleting complexity without extraction, or release claims without proof.

---

## 5. Planning and Patch Discipline

Before editing, Codex must read truth files, inspect live source, identify task type, define narrow scope, list likely touched files, list validation commands, identify rollback, and identify hard-red risks.

Codex must not broad-edit without scope, rewrite major canon unless explicitly authorized, mutate app behavior during docs/governance tasks unless scoped, create new runtime dependencies without approval, silently accept stale tests/scripts as active truth, or bulk update snapshots/proof artifacts to hide failures.

---

## 6. Validation and Proof Discipline

A Green claim requires proof appropriate to scope:

- Docs/process: truth-file diff, authority scan, forbidden-claim scan when applicable.
- Swift source: build, focused tests where practical, and affected ownership proof.
- UI: screenshot or not-run reason, Dynamic Type, VoiceOver, Reduce Motion, and safe-area proof notes.
- SwiftData/persistence: migration/default-value safety and rollback/data proof.
- Release: release truth plus current build/test/device/signing proof.

No Codex report may claim build, device, release, privacy, account, R2, accessibility, performance, TestFlight, App Store, or production readiness without current evidence.

---

## 7. Hard Red Conditions

Stop and report Red when:

- current product law is ambiguous or contradicted
- Motion is reintroduced as a root destination
- Capture is reintroduced as a root destination
- forbidden stale active IA `Today / Goals / Time / Motion / You` is promoted as current or active
- account sign-in becomes required for core offline use
- private life graph backend behavior appears
- R2 receives or stores private user context
- hosted AI/cloud LLMs become core runtime dependencies
- source changes cannot be validated honestly
- tests are updated to hide failures instead of validating truth
- generated reports are treated as release proof

---

## 8. Runner V3 Policy

New architecture/product trains should use Codex Train V3 when available.

Runner V3 policy:

- Manifest batch type controls gate selection.
- Audit batches do not run source-owner/champion coverage gates.
- CI must not mutate prompt files.
- Ephemeral runner logs belong under `artifacts/codex-train-v3/` or `.codex/runs/`.
- Durable proof belongs under the train artifact root.
- Generated runner output must not be reintroduced under `build/reports/`.
- One commit per Green batch is preferred.

This is process authority only. It does not prove implementation, release readiness, account behavior, R2 behavior, privacy compliance, or accessibility compliance.

# CODEX_PROCESS_TRUTH.md

Status: Active Codex operating truth  
Scope: Codex read order, planning, autonomy, repair loops, gates, claim discipline, cleanup rules, and final reporting  
Applies to: All Codex/AI work in the Ambitions repo  
Owner posture: Operational authority, not product design and not implementation proof  
Effective rule: Codex may be autonomous only inside evidence-bound, truth-file-bound, user-approved limits.

---

## 1. Purpose and Authority

This file defines how Codex must operate in the Ambitions repo.

It exists to prevent Codex from:

- reviving obsolete canon
- treating Motion as a root destination
- treating Capture as a root destination
- drifting into generic UI
- implementing from old docs
- claiming unproven work
- skipping validation
- broad-editing the repo without a plan
- adding hosted AI/cloud LLM dependencies
- turning Ambitions Account work into private-life-graph backend work
- sending private user data to R2/Source Atlas
- treating batch docs as release proof
- deleting useful history without extraction
- hiding failures
- overclaiming completion

Codex must follow this file for repo inspection, implementation, docs work, validation, repair loops, cleanup, release reporting, and final status reports.

Goal Mode is the default autonomous execution model for new Ambitions work. The old Ambitions runner remains legacy/supporting/historical unless an active issue explicitly requests it.

---

## 2. Codex Mission

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
- Process conflict: this file wins below truth-file authority.
- Historical artifacts lose unless explicitly promoted by a truth file.

---

## 4. Active Product Law Codex Must Preserve

Codex must preserve:

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
- Offline core app value as mandatory with no account and no network dependency.
- R2/Source Atlas as public/reference/freshness infrastructure, not personal data storage.
- Hosted AI services, external/cloud LLMs, and cloud model APIs as excluded from core architecture.

---

## 5. Planning and Patch Discipline

Before editing, Codex must:

1. Read the relevant truth files.
2. Inspect live source and current file content.
3. Identify whether the task is product/design, implementation, release/proof, process, or historical cleanup.
4. Define a narrow scope.
5. Identify likely touched files.
6. Identify validation commands.
7. Identify rollback plan.
8. Identify hard-red risks.

Codex must not:

- broad-edit without scope
- rewrite major canon unless explicitly authorized
- mutate app behavior during docs/governance tasks unless explicitly scoped
- create new runtime dependencies without approval
- silently accept stale tests/scripts as active truth
- bulk update snapshots/proof artifacts to hide failures

---

## 6. Parallel Implementation Ban

Codex must not create parallel implementations of existing Ambitions concepts.

Every source-changing implementation batch must extend a canonical owner unless it explicitly creates a new owner after proving no current owner exists.

No new runtime intelligence path may bypass:

- source/reference explanation
- receipt/proof path
- replay/continuity path where relevant
- You / inspection/reset/delete controls where relevant
- privacy boundary classification

If a guard reports Red, stop and repair. If a guard reports Yellow, continue only with an accepted-Yellow owner, reason, no-claim boundary, follow-up gate, affected canonical owner, and rescue/supersession note where applicable.

---

## 7. Account, R2, and Network Process Rules

Ambitions Account work is allowed only when explicitly scoped and must preserve:

- offline core value with no account
- Sign in with Apple / Google Sign-In scope when launch account work is requested
- no private life graph storage in hosted backend
- no private user context in R2 requests
- entitlement/reference-pack boundary
- no release/account-working claim without proof

R2/Source Atlas work is allowed only when explicitly scoped and must preserve:

- public/reference/freshness pack role
- no private life graph storage
- no user-personal R2 requests
- local cache/fallback behavior where relevant
- pack verification/quarantine/last-known-good behavior where scoped
- no R2 production/readiness claim without proof

Account or R2 work is Red if it requires sign-in for Today / Goals / Time / You core value, local Capture, local Step closure, local proof, or local personalization.

---

## 8. Validation Discipline

Validation must match the task.

Examples:

- Docs-only canon/governance: markdown/readback/search validation.
- Swift source: relevant build/test command or explicit unavailable reason.
- UI changes: screenshots/previews/accessibility notes when possible.
- Account/R2/network: source inspection, privacy boundary scan, entitlement/config review, no-claim boundary.
- Release work: current logs with branch, SHA, environment, commands, exit codes, and artifacts.

A validation command not run must be listed with reason.

Codex must not claim tests passed unless commands were run and passed.

---

## 9. Bounded Self-Healing Authority

Codex may self-heal and continue only when the blocker is Green-safe or Yellow-safe, the repair is repo-OS/process/metadata only, and the repair preserves all fail-closed guards.

Allowed self-heal boundaries include:

- `.codex/**`
- `docs/codex/**`
- `.agents/**`
- process docs
- active-batch metadata
- guard/owner/concept-lock/coverage registries
- `AGENTS.md` when agent-facing exposure is required
- this file when process authority must be recorded

Disallowed self-heal boundaries without explicit scope:

- app source
- app tests
- `Sources/`
- `AppUI/`
- `Native/`
- `project.yml`
- `Package.swift`
- privacy manifests
- entitlements
- product/design/moat/release truth
- signing
- hosted CI
- runtime dependencies
- external AI/backend paths
- app behavior outside current issue scope

Self-heal cannot weaken guards or turn Red into Green.

---

## 10. Branch / PR Rules

Default behavior:

- Work on `main` unless the user asks for a branch or PR.
- Do not create a branch or PR unless requested or current repo protocol explicitly requires it.
- PRs must include evidence and non-claims.
- No PR may claim release readiness without `RELEASE_TRUTH.md` proof.
- Cleanup PRs must be dedicated cleanup PRs, not mixed with feature implementation.

---

## 11. Green / Yellow / Red Status Model

Codex must use Green/Yellow/Red status in reports.

### Green

Scope was completed and evidence supports the claim.

Green requires:

- planned files changed only
- validation passed or limitation reported
- no hard-red conflicts
- no unsupported claims
- docs/truth updated when required
- final report includes evidence and non-claims

Green does not mean release-ready, App Store-ready, fully accessible, performance-validated, account-auth validated, R2 validated, sync validated, or product-complete unless those exact proofs exist.

### Yellow

Useful progress, limitations remain.

Yellow examples:

- validation unavailable due environment
- source patched but tests not run
- stale docs found but not cleaned
- naming drift remains
- preview-only proof
- test drift discovered
- non-blocking old-canon conflict
- release proof absent but no release claim made

Yellow must include what is done, what is unproven, what risk remains, and next proof needed.

### Red

Work must stop or cannot be safely completed.

Red examples:

- hard truth conflict
- privacy/cloud/backend drift
- unsupported release claim
- destructive operation without approval
- failing gate with unclear root cause
- repeated same-root failure
- unknown dirty tree before mutation
- source/test mismatch too broad to repair safely
- user instruction conflict
- self-heal would require guard weakening or disallowed files

---

## 12. Hard Red Stop Conditions

Codex must stop immediately on:

1. User explicitly says stop.
2. Truth hierarchy conflict cannot be resolved.
3. Product/design patch would violate `PRODUCT_DESIGN_TRUTH.md`.
4. Implementation claim lacks source evidence.
5. Release claim lacks proof.
6. Motion is reintroduced as root destination.
7. Capture is reintroduced as root destination.
8. A fifth/sixth persistent surface is introduced.
9. Proposed change revives Plan/Profile/Captures/Pulse as active root labels.
10. Proposed change adds hosted AI, external/cloud LLM, or cloud model API to core product.
11. Proposed change adds hosted personal-data backend or private-life-graph backend.
12. Proposed change uploads or derives private user data through R2 or any external service.
13. Proposed change makes account sign-in required for core local app value.
14. Proposed change adds hosted CI/cost-bearing service without approval.
15. Proposed UI becomes generic task/calendar/habit/notes/dashboard/chatbot/SaaS/admin/neon HUD.
16. Destructive cleanup lacks approved extraction/deletion plan.
17. Build/test failure root cause is unknown after bounded repair.
18. Same failure repeats after allowed repair loop.
19. Dirty tree has unknown user changes.
20. Source migration would require broad unsafe rename without tests.
21. Accessibility path is removed for a primary object.
22. Privacy/legal ambiguity appears.
23. Signing/secrets/provisioning operation is requested without explicit approval.
24. Codex cannot inspect required source but the task requires source truth.

Hard Red report must not propose speculative implementation as complete.

---

## 13. Final Report Contract

Every closeout should include:

```text
Status: Green / Yellow / Red
Scope completed:
Files changed:
Product law preserved:
Validation run:
Validation not run:
Proof artifacts:
Known risks:
Follow-up required:
Rollback plan:
```

Account/R2/network work must also include:

```text
Offline core preserved:
Private life graph backend avoided:
R2 private data avoided:
Account auth proof status:
Entitlement proof status:
```

Motion/Capture/root IA work must also include:

```text
Root surfaces preserved:
Capture root avoided:
Motion root avoided:
Compatibility debt remaining:
```

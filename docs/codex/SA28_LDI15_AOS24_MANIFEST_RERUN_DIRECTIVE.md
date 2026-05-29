# SA28 / LDI15 / AOS24 Manifest Rerun Directive

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active rerun override  
Date: 2026-05-15  
Authority: Active queue override until closed by explicit reconciliation evidence  
Execution mode: Antigravity/local-branch implementation; no Codex runner prompt as deliverable

This directive supersedes any current queue/state claim that SA28-SA32, LDI15-LDI22, or AOS24-AOS30 are complete enough to continue to FCP27.

The existing commits are retained as historical/supporting evidence. They must not be reverted by default. They also must not be treated as sufficient completion unless the relevant manifest acceptance criteria are satisfied by source, tests, reports, and queue evidence.

## Hard stop

Do not continue to FCP27, FCP28, FCP29, FCP30, or later platform/release/compliance work until this directive is closed.

FCP27 is blocked because the current repo contains evidence that SA28-SA32, LDI15-LDI22, and AOS24-AOS30 were advanced through Green or complete-state claims that need manifest-faithful rerun verification.

## Required source truth

Read in this order before any work:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `frontend/README.md`
9. `frontend/installed-canon.md`
10. `frontend/intended-canon.md`
11. `frontend/visual-encyclopedia/README.md`
12. `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
13. `frontend/visual-encyclopedia/ACTIVE_IA_AND_SURFACE_MAP.md`
14. this directive
15. the relevant batch train manifest
16. the relevant prior closeout reports

## Encyclopedia authority rule

Any rerun batch that touches user-facing UI, SwiftUI surfaces, preview fixtures, visual QA, rendered proof, navigation, copy, accessibility labels, screenshots, widgets, Live Activities, App Intents presentation, or frontend-facing reports must treat the frontend encyclopedia as active authority.

Minimum frontend authority inheritance:

- top-level IA is exactly `Today / Goals / Capture / Time / You`
- `Plan` is not a top-level destination; it is allowed only as contextual/action language or internal compatibility
- active surface objects are Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, and User System Profile
- Start Here / Recommended step / Start now / Open step language must be preserved where applicable
- no chatbot UI, generic surface, generic calendar clone, task-manager identity, top-level sixth tab, or false release/readiness claims
- visual encyclopedia source files outrank stale historical canon when conflicts exist

If a batch touches frontend behavior and does not read and inherit the encyclopedia, it cannot close Green.

## Existing commits policy

Do not revert by default.

Classify existing SA28-SA32, LDI15-LDI22, and AOS24-AOS30 commits as one of:

- valid evidence toward the manifest batch
- partial/supporting evidence only
- wrong-scope substitution
- build-risk evidence
- stale state-advancement evidence

Existing generic tail-gate files may be retained only as supporting proof-boundary helpers. They cannot by themselves satisfy a manifest batch whose scope requires UI integration, fixture libraries, privacy/performance QA, claim truth, handoff, repair classification, or roadmap continuation.

## Batches requiring full manifest-faithful rerun

### Source Atlas

- SA28 — Pack Diff / Changed Claim Tooling
- SA29 — Hash / Signature / Revocation Tooling
- SA30 — Freshness Broker Manifest Contract
- SA31 — Official Source Adapter Contracts
- SA32 — Source Atlas UI Primitives / QA / Handoff

Source Atlas rerun requirements:

- preserve offline-first/source-state boundaries
- no official/current overclaim
- no user-data server
- no hosted AI dependency
- no live API dependency in app runtime for core behavior
- every changed claim, freshness, revocation, disputed, source-needed, unknown, contradicted, and locally proven path must be explicit where in scope
- SA32 must inherit frontend encyclopedia authority for UI primitives, rendered proof, state language, and visual QA

### Living Dream / LDI

- LDI15 — Living Plan Recompiler
- LDI16 — Mutation Permissions And Impact Levels
- LDI17 — Continuity Sync
- LDI18 — Archive And Schema Migration
- LDI19 — Multi-Device Merge Ledger
- LDI20 — Freshness Broker
- LDI21 — Red-Team Evaluation Suite
- LDI22 — Governance And Maintenance Console

LDI rerun requirements:

- preserve local-first/private-runtime posture
- no cloud sync, account, hosted user-data backend, hosted AI, or live service dependency unless explicitly scoped by active truth
- mutation permissions must require visible user control and receipts
- schema/migration claims require actual source/test evidence and no-lost-data boundaries
- sync/continuity language must not imply production cloud sync unless proven
- any frontend-facing surface, console, receipt, QA, or handoff must inherit the frontend encyclopedia authority rule

### AmbitionsOS

- AOS24 — AmbitionsOS UI Integration
- AOS25 — AmbitionsOS Test Fixture Library
- AOS26 — AmbitionsOS Privacy Performance QA
- AOS27 — AmbitionsOS App Store Claim Truth
- AOS28 — AmbitionsOS Handoff
- AOS29 — AmbitionsOS Repair Train
- AOS30 — AmbitionsOS Beyond Roadmap

AOS rerun requirements:

- AOS24 must implement or explicitly classify UI integration across Today, Goals, Capture, Time, and You; generic runtime/tail-gate receipts are not enough
- AOS25 must provide actual fixture library / coverage matrix; generic tail-gate tests are not enough
- AOS26 must provide privacy/performance QA artifacts, checks, or tests; generic booleans are not enough
- AOS27 must provide App Store / public claim truth boundaries; no release readiness by implication
- AOS28 must produce a useful handoff grounded in actual AOS state, blockers, and evidence
- AOS29 must classify Yellow/needs review gates and produce repair outcomes or a repair backlog
- AOS30 must produce the beyond-roadmap continuation decision/backlog according to the manifest
- any UI, rendered proof, state/copy, visual QA, or frontend-facing evidence must inherit frontend encyclopedia authority

## Required rerun branch

Use a local branch:

```bash
git checkout main
git pull
git checkout -b ai/manifest-rerun-sa28-ldi15-aos24
```

Do not perform the rerun directly on `main`.

## Required closeout artifact

Create and maintain:

```text
docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md
```

For every batch, include:

- manifest title
- manifest acceptance criteria
- prior commit/report evidence retained
- whether prior work was valid, partial, wrong-scope, build-risk, or stale-state evidence
- files changed in rerun
- validation commands and exit codes
- frontend encyclopedia inheritance status if frontend touched
- claims not made
- final classification: Green, Accepted Yellow with owner, Blocked, or Needs Repair

## Required validation floor

Every rerun pass must run or explicitly record why it could not run:

```bash
git status --short
git diff --check
make batch-self-check
python3 scripts/ambitions-source-atlas-title-check.py --strict
scripts/codex-forbidden-claim-scan.sh <changed-files> || true
```

For Swift changes:

```bash
xcodegen generate
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

Focused tests may be used for intermediate repair, but final Green for implementation-sensitive batches requires the strongest feasible local proof and an explicit statement of what was not proven.

## Queue repair requirement

Until the rerun closes:

- `.codex/state/active-batch.yml` must point to this rerun directive
- `.codex/reports/current-batch-train-state.md` must say this rerun is active
- `.codex/reports/current-run-state.md` must say this rerun is active
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` may still contain stale complete classifications, but this directive overrides them until repaired

When the rerun closes, update the queue so every affected batch is truthfully classified and FCP27 is only executable if all prior requirements are Green or Accepted Yellow with explicit non-blocking owners.

## Hard Red stop conditions

Stop and repair before continuing if any of these occur:

- FCP27 is started before this directive closes
- an affected batch is marked Green without satisfying its manifest scope
- frontend-touching work ignores the encyclopedia
- TailGate files are used as a substitute for manifest work
- Swift compile risk is discovered and not repaired
- source/freshness/official/current claims are made without proof
- sync/cloud/account/server/hosted AI behavior is implied without implementation and active-truth approval
- release, TestFlight, App Store, device, public accessibility, privacy/legal, or performance readiness is claimed without proof

## Closeout condition

This directive may close only when:

1. SA28-SA32 are rerun or truthfully reclassified against the Source Atlas manifest.
2. LDI15-LDI22 are rerun or truthfully reclassified against their active manifest/source truth.
3. AOS24-AOS30 are rerun or truthfully reclassified against the AOS manifest.
4. Existing wrong-scope commits are retained as supporting evidence, not erased.
5. Frontend-touching batches document encyclopedia inheritance.
6. Queue state no longer advances past unresolved prerequisites.
7. No forbidden release/platform/public proof claims are introduced.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

+++
initiative = "intelligence-change-management"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions can securely acquire, verify, evaluate, stage, promote, inspect,
rollback, revoke and purge intelligence artifacts as sources/models/policies
change. Each active task has one exact compatible tuple; affected drafts become
reviewable/unavailable while accepted canonical truth remains unchanged.

## In scope

- Immutable content-addressed artifact/release/attestation/change metadata for
  corpora, sources, relationships, current facts, tasks/prompts/schemas/tools,
  models/adapters/policies/evaluations/migrations/UI semantics.
- App-pinned versioned trust root, signing/threshold/rotation/revocation and
  anti-rollback/freeze/mix-and-match/wrong-artifact verification.
- Compatibility graph/tuple by task/app/OS/device/locale/model/source/policy.
- Change classification, dependency impact and claim-bound evaluation gate.
- Acquire/verify/compatible/evaluate/stage/atomic-promote/LKG/rollback/quarantine/
  revoke/withdraw/purge/offline lifecycle.
- OS-owned model-change detection, task disable/fallback and prompt tuple choice.
- Draft invalidation/canonical owner notification, change inspection and controls.
- Privacy/security/accessibility/change-service evaluation.

## Out of scope

- Product-semantic approval by a generic release service, process-only Git/merge
  gates, private user rollout profiling or remote A/B behavior collection.
- Unsigned arbitrary remote config, TLS-only trust, automatic acceptance of
  older/mixed/expired/revoked releases or blanket provenance claims.
- Automatic canonical Goal/Path/Step/Time/Proof mutation or private schema write
  triggered by a public package.
- Rollback of an OS system model Ambitions cannot control, resurrection of
  rights-withdrawn content or remote kill/delete of private canonical data.

## Requirements

### REQ-001 — Every artifact is immutable and attributable
Manifest binds family/ID/version/hash/size/schema/materials/builder/provenance/
signer/time/rights/jurisdiction/compatibility/dependencies/supersession/
withdrawal/risk/evaluation/release notes. Published attestation is immutable.

### REQ-002 — Trust metadata resists update attacks
Pinned versioned root and signed role metadata enforce threshold/rotation,
versions/expiry, consistent snapshots, target hashes/sizes and bounded roles/
depth. Older/mixed/frozen/wrong/unknown metadata fails closed visibly.

### REQ-003 — Semantic owners retain responsibility
Each family owner supplies source locks, rights, schemas, semantic validators,
compatibility and affected claim types. The coordinator cannot declare content
correct merely because signature/provenance pass.

### REQ-004 — Compatibility is task specific
One active tuple binds task/model/runtime/prompt/schema/validator/tools/policy/
corpus/relationship/current/evaluation plus app/OS/device/locale. Unknown or
unevaluated combination is unavailable; passes do not transfer.

### REQ-005 — Changes are precisely classified
Additive/correction/breaking/source/rights/security/model-environment/evaluation/
rollback changes state exact affected artifacts/tasks/claims and purge needs.

### REQ-006 — Evaluation gates promotion
Claim-bound Evaluation results must match exact artifacts/tuple/slices/thresholds
and be current. Missing/hard-fail evidence blocks promotion; aggregates cannot
hide hard gates.

### REQ-007 — Staging and promotion are atomic
Acquire into quarantine; verify/validate/evaluate off active generation; stage
immutable snapshot; atomically promote one compatible generation. Readers never
observe mixed/partial releases.

### REQ-008 — Rollback is deliberate and safe
Rollback targets a previously trusted compatible/evaluated non-revoked release
under a local plan and produces a new activation receipt. Network downgrade is
rejected. Unrollbackable system model change disables/falls back affected tasks.

### REQ-009 — Revocation/withdrawal is exact and urgent
Signed security/rights change blocks affected purpose, prevents LKG reuse,
notifies dependents and performs resumable purge of prohibited bytes while
preserving content-free allowed lineage.

### REQ-010 — Impact never mutates accepted truth
Exact dependencies classify drafts recompute/stale/source-needed/invalid and
notify canonical owners. Releases never auto-replan/adopt/edit; owner shows any
separate reconciliation preview.

### REQ-011 — User change inspection is honest
Show active versions/mode/source status, plain what-changed/affected/fallback,
download/stage/progress/error/rollback/revocation and controls. No blame or
unsupported security/current claim.

### REQ-012 — Offline/LKG behavior is purpose specific
Bundled/verified active generation remains usable offline only within rights/
freshness/compatibility. Expired update metadata blocks new install, not safe
local core by default. Missing safe tuple yields manual/deterministic fallback.

### REQ-013 — Private/public migration boundary is strict
Public release cannot execute arbitrary private writes. Private owner migrations
are separately versioned/transactional/recoverable; drafts retain exact evidence
or become review-only. Accepted History remains truthful.

### REQ-014 — Change observability is privacy safe
Diagnostics/metrics use artifact/task/version/state/reason/timing/count; no
private context, prompt/response, identity, draft or behavior-based cohort.

### REQ-015 — Lifecycle and purge are recoverable
Acquire/stage/promote/rollback/revoke/purge journals are idempotent/crash safe.
Purge removes raw/artifact/index/model/prompt/tool/render/cache/export/prohibited
derived bytes and cannot resurrect through replay.

### REQ-016 — Security incident handling is bounded
Key/artifact compromise supports signed root/role rotation, revocation,
quarantine, task disablement and diagnostics without arbitrary remote commands
against private data or bypassing app-pinned trust.

### REQ-017 — Evaluation includes the change system
Test verification/compatibility/impact/rollback/revocation/purge/privacy/security/
accessibility/user comprehension per artifact/change/device; no blanket ready.

### REQ-018 — Accessibility covers change and recovery
Version/source/mode/change/impact/progress/error/fallback/rollback/revoke/purge
meaning and controls have ordered text and assistive-technology parity.

## Acceptance criteria

- AC-001: manifest/attestation round-trip and immutable hash/provenance linkage.
- AC-002: rollback/freeze/mix-match/wrong/signature/expiry/role-bomb attacks fail.
- AC-003: signed but semantically invalid/rights-unknown artifact is quarantined.
- AC-004: incompatible/unevaluated tuple cannot execute its task.
- AC-005: each change reports exact impact/purge class.
- AC-006: stale/missing/hard-fail evaluation blocks promotion.
- AC-007: fault injection proves one reader generation and no mixed bytes.
- AC-008: safe rollback receipt works; system-model change disables/falls back.
- AC-009: revoked/withdrawn content is unusable and completely purged.
- AC-010: canonical/private owner bytes remain unchanged by release lifecycle.
- AC-011: user inspection accurately explains all change/fallback states.
- AC-012: offline/LKG matrix respects purpose/rights/freshness/compatibility.
- AC-013: private migrations cannot be smuggled in public packages.
- AC-014: private/cohort canaries occur nowhere in diagnostics/requests.
- AC-015: every lifecycle phase resumes/idempotently reaches truthful terminal.
- AC-016: compromise/rotation/revocation works only through pinned trust policy.
- AC-017: per-change service/evaluation hard gates pass.
- AC-018: accessibility/device/direct-user comprehension passes.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

Add Intelligence Change Management canon; update Source Atlas, private runtime,
all artifact registries, evaluation, privacy/security/degraded, trust inspection,
History/Receipts, migrations, deletion and offline/update contracts.

## Risks and open decisions

No product fork remains. Exact cryptographic implementation/key custody is an
engineering/security design detail constrained by pinned threshold trust and
independent validation, not an unresolved user behavior choice.

Review verdict: **PASS** after two reconciliation rounds. Review added anti-
downgrade versus authorized rollback, OS-model disablement, semantic-owner gates,
private migration isolation and no private rollout cohorts. Devan delegated
approval; Scope approved 2026-08-04.

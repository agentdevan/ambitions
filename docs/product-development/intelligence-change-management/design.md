+++
initiative = "intelligence-change-management"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add `IntelligenceReleaseCoordinator` over a content-addressed artifact store,
TUF-inspired pinned trust metadata verifier, domain semantic-validator registry,
task compatibility graph, Evaluation result client and atomic generation store.
It acquires into quarantine, computes a `ChangeImpactSet`, stages one immutable
compatible `IntelligenceReleaseGeneration`, promotes/rolls back/revokes through
a journaled actor and notifies exact consumers without mutation.

## User flows

- Background may check finite public timestamp/snapshot IDs, verify/stage a safe
  low-risk release and show update-ready/active state. Large or policy-required
  downloads ask user control; private context never shapes request.
- Trust inspection lists active source/model mode/task/policy versions in plain
  groupings and last update/evaluation/fallback, with technical detail on demand.
- When a change affects a saved draft, the draft says what changed and offers
  recompute/review/keep historical/manual; accepted state remains.
- A failed/invalid/frozen/revoked update shows the affected capability and safe
  fallback, retry/inspect/clear. Security/rights revoke can immediately disable
  exact tasks and purge with visible progress.
- Rollback shows target, reason, affected tasks and limitations; user-facing
  product flow never suggests rolling back an OS model that cannot be controlled.

## States and recovery

Artifact: `discovered`, `acquiring`, `quarantined`, `verified`, `compatible`,
`evaluated`, `staged`, `active`, `superseded`, `rollbackReady`, `revoked`,
`withdrawn`, `purging`, `purged`, `failed`. Tuple: `active`, `fallback`,
`unevaluated`, `incompatible`, `sourceNeeded`, `disabledByEnvironment`,
`disabledByRevocation`. Coordinator: `idle`, `checking`, `staging`, `promoting`,
`rollingBack`, `revoking`, `purging`, `recoveryRequired`.

One actor serializes lifecycle. Readers lease immutable generation. Journal and
active pointer update transactionally; staging is never visible. Relaunch verifies
every phase and completes/rolls back without mixed bytes. Network metadata has
strict size/depth/time/version limits. Clock uncertainty blocks new timestamp-
sensitive updates but retains permitted current generation/fallback.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 9 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

Add under
`Native/Ambitions/Core/LocalRuntimeOS/IntelligenceChangeManagement/`:

- artifact/release/attestation/material/change/revocation models;
- pinned trust root/role/timestamp/snapshot/target metadata models and verifier;
- content-addressed quarantine/artifact/attestation stores;
- domain semantic-validator registry and validator receipt models;
- compatibility graph/tuple builder and environment capability detector;
- Evaluation evidence client/gate;
- change classifier/dependency graph/impact planner;
- immutable generation store/reader lease/coordinator/journal;
- promotion/rollback/revocation/withdrawal/purge/recovery services;
- consumer notifier and owner reconciliation-input builder;
- user inspection/change-note/degraded projection;
- privacy/security diagnostics and clear-storage service.

Foundry/control-plane tooling under `tools/intelligence-release/` builds canonical
manifests, SLSA-compatible provenance where honestly supported, trust role
metadata, compatibility matrices, change diffs, impact/evaluation bundles,
release notes and deterministic archives. It integrates existing Source Atlas
Foundry/artifact builders instead of replacing domain pipelines.

### Trust and semantic verification

App bundle pins root v1 and accepted algorithms/role limits. Root rotation
requires sequential old/new threshold validation. Timestamp/snapshot/targets
enforce version/expiry/hash/length/consistent set. Transport is untrusted. Artifact
signature/provenance proves identity/origin only at declared level; domain
validator separately proves schemas/source locks/rights/semantics and produces
claim-specific receipt.

### Compatibility and evaluation

`TaskCompatibilityManifest` enumerates allowed task/model capability/runtime/
prompt/schema/validator/tool/policy/public releases/app/OS/device/locale ranges.
Environment detector treats Apple system model/OS tuple as observed capability;
if it changes beyond evaluated manifest, task is disabled or switches to an
already approved fallback. Evaluation gate resolves exact signed result IDs and
hard-gate dimensions; it cannot infer pass from family/version similarity.

### Impact, promotion and owner handoff

Impact graph uses public artifact/task/claim IDs and opaque private draft/canonical
evidence references. Diff classifies changed fields/purposes/withdrawals and
computes exact consumers. Promotion atomically changes active public/config
generation and emits notifications. Draft owners mark/recompute; canonical owners
may build new preview. Change service holds no private command clients.

Rollback is a new local activation of a safe archived generation, checks current
trust/rights/evaluation/compatibility and records reason. Revocation bypasses
normal desirability staging only to disable/purge exact unsafe purposes, still
requires pinned signed authority and cannot target private data.

### Persistence, migration, deletion

Public/config artifacts and attestations are separated from protected private
dependency references/change-read state. Public releases contain no user data.
Private migrations are owner bundles shipped in app code and invoked by those
owners, never artifact scripts. Clear downloaded data restores bundled generation
if safe. Purge is content-addressed but checks shared allowed references before
delete; prohibited bytes are removed everywhere and replay tombstones prevent
resurrection.

## Privacy and accessibility

Update requests use fixed public metadata IDs and no user/task usage/profile/
cohort. Diagnostics contain artifact/task/version/state/reason/count/timing, no
private objects, prompt/response or draft content. Change notes derive from
public semantic diffs plus local owner reason codes, not remote private data.

Inspection groups changes by user outcome with plain status, sources/mode,
affected saved work and fallback; technical hashes/attestations are progressive
detail. Progress/errors are textual and cancellable where safe. VoiceOver, Voice
Control, Switch Control, keyboard, largest Dynamic Type, Reduced Motion, RTL,
non-color and focus restoration cover update, inspect, rollback, purge and retry.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Immutable manifest/attestation/content store |
| REQ-002 | Pinned sequential threshold trust verifier and bounded metadata |
| REQ-003 | Domain semantic-validator registry/receipts |
| REQ-004 | Exact TaskCompatibilityManifest/environment detector |
| REQ-005 | Change classifier and semantic diff |
| REQ-006 | Exact signed Evaluation gate |
| REQ-007 | Quarantine/stage/atomic generation/reader leases |
| REQ-008 | Safe new activation rollback and environment fallback |
| REQ-009 | Signed exact revoke/withdraw/purge |
| REQ-010 | Public dependency notifier and no command clients |
| REQ-011 | User inspection/change note projections |
| REQ-012 | Purpose-specific LKG/fallback matrix |
| REQ-013 | Owner-only app-code private migrations |
| REQ-014 | Fixed public requests/no-private diagnostics/cohorts |
| REQ-015 | Journaled lifecycle and resurrection tombstones |
| REQ-016 | Pinned trust-only incident controls |
| REQ-017 | Per-artifact/change/service evidence metadata |
| REQ-018 | Accessible grouped inspection/recovery |

## Verification design

- Manifest/provenance/trust root rotation and TUF attack/fuzz matrices.
- Domain-semantic signed-but-invalid/rights/lock/schema fixtures.
- Compatibility cross-product and OS model/environment change fallback.
- Exact Evaluation gate stale/wrong-tuple/hard-fail/no-transfer tests.
- Stage/promote/read/rollback/revoke/purge every-phase fault/relaunch/concurrency.
- Impact/canonical mutation spies and private migration isolation.
- Rights/security withdrawal shared-reference complete purge/resurrection denial.
- Fixed public request and private/cohort/log canaries.
- Accessibility/device storage/network/verification/promotion/query/purge/
  background energy/performance and direct-user change comprehension.

## Open decisions

None. Key custody and concrete crypto libraries require threat-reviewed
implementation choices but are bounded by exact trust semantics and test vectors.

Review verdict: **PASS** after two reconciliation rounds. Review separated trust
from semantics/evaluation, made rollback a checked new activation, isolated owner
migrations and constrained emergency controls to signed public purposes. Devan
delegated approval; Design approved 2026-08-04.

# PLOS-025 R2 Source-Only Boundary Matrix

Status: Green for AMB-658 R2 source-only boundary documentation scope; Yellow for later R2 production rollout, pack publication, Source Atlas distribution mesh implementation, runtime fetch behavior, storage/fetch measurement, privacy/legal, device, accessibility, and release proof
Linear issue: AMB-658
Parent issue: AMB-610
Program phase: PLOS-M02 local data, CloudKit, R2 boundary, and data lifecycle foundation
Updated: 2026-06-12
Branch: main

## Closeout Header

- PLOS child closeout: yes
- Linear issue: AMB-658
- Parent issue: AMB-610
- Green/Yellow/Red status: Green for R2 source-only boundary matrix documentation scope; Yellow for unimplemented R2 distribution, pack publication, runtime fetch, Source Atlas mesh, fetch/storage measurement, device, accessibility, privacy/legal, and release proof.
- Pushed to main: pending at report creation
- Push hash: pending at report creation
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: no; AMB-608 / PLOS-M00 and AMB-609 / PLOS-M01 were already complete before this M02 child started.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for AMB-658 documentation scope
- Yellow limits: this report defines the R2 boundary. It does not publish packs, implement R2 fetch/storage, change Source Atlas runtime eligibility, add Cloudflare dependencies, update privacy manifests, or claim production rollout.
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-658 commit, push, and Linear closeout, continue AMB-659 / PLOS-026 only.

## Scope

AMB-658 defines exactly what R2 may store and what it must never store for Ambitions. The boundary is source-only: R2 may distribute public, reusable Source Atlas/source/pathing material and related control metadata. R2 must never store, receive, derive, infer, or personalize from private user life data.

This child does not implement R2 production rollout, Source Atlas distribution mesh, pack publication, runtime fetch, cache mutation, Cloudflare configuration, privacy manifest changes, App Review work, release work, or app runtime behavior.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-610` and child `AMB-658` by actual `AMB-*` identifiers.
- Linear referenced `Source Atlas Pack and Seed Release Contract`.
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`.
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`.
- `docs/codex/SEED_BASED_PLANNING_LAW.md`.
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`.
- `artifacts/personal-life-os/reports/PLOS-020-local-data-cloud-boundary.md`.
- `artifacts/personal-life-os/reports/PLOS-021-cloudkit-schema-constraints.md`.
- `artifacts/personal-life-os/reports/PLOS-022-user-data-lifecycle-archive-strategy.md`.
- `artifacts/personal-life-os/reports/PLOS-023-local-database-index-query-strategy.md`.
- `artifacts/personal-life-os/reports/PLOS-024-receipt-retention-delete-reset-export-policy.md`.
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`.
- `Native/Ambitions/Domain/SourceAtlasPackFactoryModels.swift`.
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`.
- `Native/Ambitions/Domain/SourceAtlasUserMiniPackBuilderModels.swift`.
- `Native/Ambitions/Runtime/SourceAtlasStepCandidateFieldBridge.swift`.
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`.

Validation artifacts:

- `artifacts/personal-life-os/validation/PLOS-025-r2-source-only-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-025-focused-r2-source-boundary-search-log.txt`

## M00 / M01 Consumption Evidence

AMB-658 consumes M00 governance outputs and M01 runtime maps as load-bearing inputs:

- M00 local data/cloud boundary law states R2 is public-reference and source/pathing distribution only.
- Source Atlas Authority Law requires source state, freshness, revocation, review, risk, jurisdiction, and eligibility metadata before runtime source-backed claims.
- Seed-Based Planning Law requires reusable seeds and blocks exact-user hardcoded finished Steps in production/public packs.
- AMB-647 / PLOS-011 maps existing Source Atlas models, tools, bridge/replay seams, tests, and R2/distribution assets without claiming production distribution.
- AMB-649 / PLOS-013 identifies Source Atlas packs, sources, claims, requirements, proof, receipt, replay, sharing, CloudKit sync, local learning, and privacy controls as distinct owners.
- AMB-653 / PLOS-020 defines the local data/cloud boundary and excludes private user data from R2.
- AMB-657 / PLOS-024 prevents receipt/proof/replay data from drifting into undeletable or remote private storage.

No source file is changed by AMB-658, so source-ownership gating is not applicable for implementation. Current source was inspected only to define the boundary matrix.

## Source Anchors

Current source provides R2-adjacent Source Atlas anchors but not R2 production Green:

- `SourceAtlasStore` evaluates bundled, cached, and last-known-good payloads using SHA-256, schema validation, source state, revocation, contradiction, and quarantine.
- `SourceAtlasPackManifest` carries id, title, kind, version, domain ids, schema version, classification, production-use flag, and canon document ids.
- `SourceAtlasSourceRecord` carries source id, title, kind, locator, retrieval time, content hash, and official-claim approval state.
- `SourceAtlasClaim`, `SourceAtlasRequirement`, freshness, risk, and review states decide whether source material can drive current recommendations.
- `SourceAtlasPackValidator` blocks runtime-store behavior unless the pack is value-model-only and flags missing manifest identity, missing canon integration, missing composition contract, official claims without approved sources, high-risk claims without review, and related source/proof issues.
- `SourceAtlasFreshnessManifest` carries version id, published date, pack index, pack hash/signature, rollback pointers, changed claim ids, and claim-state buckets.
- `SourceAtlasUserMiniPackBuilder` creates local user mini-packs with `privacyClass: .privateLife`, `sourceKind: .userProvided`, and `productionUse: false`; these are local value models, not public R2 source truth.
- `SourceAtlasStepCandidateFieldBridge` composes Step candidate traces locally from source pack ids, source records, source claims, freshness warnings, and redacted sensitive context; this is local runtime composition, not public pack storage.

## R2 Boundary Rules

1. R2 may store only public, non-user-specific Source Atlas/source/pathing material and release/control metadata.
2. R2 must not store, receive, infer, derive, personalize from, or log private user life data.
3. R2 objects must be reusable ingredients, not exact-user plans, schedules, proof histories, receipts, replays, or local learning.
4. R2 fetch requests must not include raw user goals, captures, schedule context, proof, receipt ids, replay ids, user profile, behavioral patterns, or user-identifying life graph state.
5. R2 material can become runtime-eligible only after later Source Atlas phases prove source binding, hash/signature, freshness, revocation, review, rollback, high-risk boundaries, and local fallback.
6. R2 cannot be used as Ambitions personal data storage, backup, sync, diagnostics, telemetry, analytics, or cloud learning.
7. Missing classification is Yellow for docs and Red for runtime behavior that could transmit data.

## Boundary Matrix

| Material | R2 allowed? | Why | Required metadata if allowed | Explicitly prohibited variants | Owner / future gate |
|---|---|---|---|---|---|
| Public Source Atlas pack manifest | Yes | Public routing and validation metadata for reusable source packs. | Pack id, version, schema, domain, classification, production-use state, hash/signature, release receipt, rollback pointer. | User-specific pack id, private goal title, raw user text, local profile labels, personal schedule hints. | M04/M05/M06. |
| Public source records | Yes, when redistribution rights and source authority are recorded. | Source Atlas needs public source binding. | Source id, title, locator, retrieved/review date, content hash, approved-for-official-claims flag, license/redistribution posture. | Private imports, OCR output, private files/photos, user notes, proprietary personal documents. | M04/M06/M18. |
| Public claims and requirements | Yes, if non-user-specific and source-bound. | Reusable source/pathing constraints can be downloaded and composed locally. | Source ids, freshness state, risk class, review state, jurisdiction/eligibility envelope, revocation state. | User-provided claims, privateClaim, local-proof-only claims, exact private eligibility facts. | M05/M06/M18. |
| Reusable seed packs | Yes. | Seeds are reusable ingredients for local composition. | Seed type, requirement/proof/source ids, freshness/review/risk envelope, rollback/deprecation. | Finished exact-user Steps, user schedule slots, proof requirements derived from private context. | M05/M09/M13. |
| Starter guidance | Yes, only when generic and source bounded. | Low-risk starter guidance may be public reference. | Starter-guidance-only state, risk class, source ids, blocked high-risk domains, no schedule install authority. | Personalized recommendations, private capacity fit, medical/legal/financial action without high-risk gate. | M05/M18. |
| Freshness manifest | Yes. | Clients need public pack freshness, changed claim, hash/signature, and rollback metadata. | Manifest version, published date, pack index, current SHA/signature, rollback pointers, changed claim ids, state buckets. | Per-user freshness history, private usage logs, user source-needed requests with raw goal context. | M04/M06. |
| Revocation and quarantine metadata | Yes. | Public clients need kill-switch/deprecation and invalid-pack handling. | Revoked pack/source/claim ids, reason class, effective date, rollback pointer, compatibility impact. | Per-user exposure history, private failed plan data, private receipt/replay references. | M04/M06/M24. |
| Release receipts for packs | Yes, if public and pack-scoped. | Distribution needs inspectable release proof. | Validator command, pack hashes, release owner, date, affected packs, rollback note, non-claims. | User action receipts, proof receipts, private execution receipts, local learning receipts. | M04/M05/M06. |
| Compatibility metadata | Yes. | Clients need schema/platform/pack compatibility. | Schema version, minimum app/runtime version, deprecated fields, migration note, fallback behavior. | Device identity, user install history, private settings, diagnostics traces. | M04/M23/M24. |
| Public templates/rules/requirements | Yes, when not personalized. | Public dates, rules, equipment, certification, jurisdiction, and reference requirements can be source material. | Source locator, date, jurisdiction, risk, review, freshness, expiration. | User's deadline, school/account id, location trace, private eligibility profile. | M05/M18. |
| Source Atlas user mini-packs | No. | User mini-packs are local private value models and not source truth. | N/A for R2. | Any `user_mini_pack`, `userProvided`, privateLife, local proof, correction/rejection/deletion eligibility data. | Local-only user mini-pack owners. |
| User goals, captures, schedules, proof, receipts, replay, local learning | No. | Private Personal Life OS data. | N/A for R2. | Raw text, summaries, ids, embeddings, classifications, inferred priorities, source-needed requests containing private context. | Local-only / future user-owned CloudKit only after proof. |
| Export packages and diagnostics | No by default. | Export/support are user-controlled local paths, not R2 storage. | N/A for R2. | Portable snapshots, receipt histories, proof packages, support bundles, crash/analytics telemetry. | M24 and release/privacy gates. |

## Request Boundary

R2 request construction must be source-only:

- Allowed request keys: public pack id, domain id, schema version, app-supported schema range, public compatibility version, current pack hash, locale/jurisdiction only when not user-identifying and not derived from private context.
- Blocked request keys: raw goal/capture text, plan title, schedule, calendar data, proof state, receipt id, replay id, local learning, user profile, age/school/employer, location trace, private source import, free-form user context, device/user identifiers, analytics ids.
- If a future feature needs coverage-demand or source-needed updates, it must send only sanitized, non-user-specific coverage categories after a separate privacy proof. Raw user goals or context are Red.

## Local Composition Boundary

R2 may provide ingredients. Ambitions composes locally:

- Public packs/seeds can define reusable requirements, proof candidates, starter items, source records, and freshness metadata.
- The user's final Recommended step, schedule fit, proof requirement, recovery path, and reflow behavior are composed locally from private context.
- Public packs must not store finished exact-user Steps as the main unit.
- User mini-packs remain local-only and are not promoted to public R2 source truth.

## Performance and Storage Flags

AMB-658 does not measure performance. It flags boundary cost risks for future owners:

- Required R2/source-only search produced 14,776 lines and focused R2/source-boundary search produced 21,056 lines, showing broad Source Atlas/R2/pack/manifest vocabulary across source, tests, docs, and artifacts.
- Pack manifests and freshness manifests should be small, cacheable, hash-addressed, and revocation-friendly.
- Public pack payloads need bounded size, deterministic compression policy, and last-known-good fallback before runtime fetch Green.
- R2 should not become a place for per-user diagnostics or export packages because those would create privacy, storage, and deletion liabilities.
- M04/M05/M06 own distribution/freshness/release receipt implementation; M19 owns measured performance; M24 owns diagnostics/export support proof.

## Validation

Commands run for AMB-658:

- `git status --short --branch` - clean on `main` before AMB-658 execution.
- `git pull --ff-only` - already up to date.
- `git rev-parse HEAD` - BASE_SHA `08de56a8e9fd73d3783f4516e504ca43b61ed55e`.
- Linear issue fetch for `AMB-658` - succeeded.
- Linear status update for `AMB-658` to In Progress - succeeded.
- `rg -n "R2|source-only|pack|manifest" . > artifacts/personal-life-os/validation/PLOS-025-r2-source-only-required-search-log.txt` - exited `0`, 14,776 lines.
- Focused R2/source boundary search over Persistence, Domain, Services, Support, Resources, tests, docs/codex, and PLOS-020 through PLOS-024 reports - exited `0`, 21,056 lines, artifact `artifacts/personal-life-os/validation/PLOS-025-focused-r2-source-boundary-search-log.txt`.
- Focused source inspection of Source Atlas store, pack manifest/source/claim/requirement models, pack factory, freshness manifest, user mini-pack builder, Step candidate bridge, Source Atlas laws, local data/cloud boundary law, and Source Atlas hardening plan.

Closeout validation run after report creation:

- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T175542.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T175542.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 53 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T175618.log`.
- `git diff --cached --check` - pending until staging.

Not run:

- Build/test/screenshot/accessibility/performance validation was not run because AMB-658 is documentation/control-plane R2 boundary work and no app source, project, UI, runtime, test source, Cloudflare/R2 config, pack publication, privacy manifest, entitlement, or release artifact changed.

## Runtime Path Proof

Not applicable for implementation proof. AMB-658 inspects current Source Atlas source owners and prior PLOS reports to define boundary policy, but it does not implement or change runtime behavior.

## Privacy / Safety / Source Checks

Green for AMB-658 documentation scope:

- R2 is explicitly public-reference/source/pathing only.
- Private user goals, captures, schedule, proof, receipts, replay, local learning, user mini-packs, export packages, and diagnostics are excluded from R2.
- R2 requests must not carry private user context or identifiers.
- Source Atlas packs must remain reusable seed/source ingredients, not exact-user finished Step storage.
- Future CloudKit and export paths remain separate from R2.

## Accessibility Checks

Not applicable. No UI or accessibility behavior changed. No accessibility verification or certification is claimed.

## Rollback / Failure Behavior

Rollback is to revert this AMB-658 artifact/control-plane commit. Later R2 distribution, Source Atlas pack release, runtime fetch, privacy, diagnostics, export, and performance work must hold if this boundary is removed or fails validation.

## Remaining Yellow / Red

Yellow:

- App privacy declaration map remains AMB-659 / PLOS-026.
- 20-year data compaction and annual snapshot model remains AMB-660 / PLOS-027.
- M04 owns R2 Source Atlas distribution mesh implementation.
- M05/M06 own Source Atlas pack/seed/freshness/source authority implementation.
- M19 owns measured performance hardening.
- M24 owns diagnostics/export support proof.
- M26 owns certification gauntlets.

Red blockers: none for AMB-658 scope.

## Follow-Up Issues Created

None.

## Next Issue To Run

AMB-659 / PLOS-026 only, after AMB-658 is committed, pushed to `main`, and updated in Linear.

## Non-Claims

AMB-658 does not claim runtime implementation, app source change, R2 production rollout, Cloudflare/R2 configuration, pack publication, Source Atlas distribution mesh implementation, runtime fetch behavior, pack runtime eligibility, privacy manifest correctness, privacy/legal approval, App Review readiness, release readiness, TestFlight readiness, App Store readiness, screenshot proof, accessibility verification, measured performance proof, device proof, owner approval, or PLOS-M03+ execution.

## PLOS Child Closeout

PLOS child closeout

Linear issue: AMB-658

Parent issue: AMB-610

Green/Yellow/Red status: Green for AMB-658 R2 source-only boundary matrix documentation scope; Yellow for later R2 production rollout, Source Atlas distribution mesh, pack publication, runtime fetch, performance, CloudKit separation, privacy declaration, release, accessibility, device, and privacy/legal proof not claimed.

Pushed to main: pending at report creation

Push hash: pending at report creation

App source changed: no

Runtime features implemented: no

PLOS-M00 executed: no; AMB-608 and AMB-609 were already complete before this M02 child started.

Linear identifiers used: AMB issue identifiers only

Validation run:
- `git status --short --branch` - clean on `main` before child execution.
- `git pull --ff-only` - already up to date.
- Linear issue fetch for `AMB-658` - succeeded.
- Linear status update for `AMB-658` to In Progress - succeeded.
- `rg -n "R2|source-only|pack|manifest" . > artifacts/personal-life-os/validation/PLOS-025-r2-source-only-required-search-log.txt` - exited `0`.
- Focused R2/source boundary search - exited `0`.
- Focused source inspection of Source Atlas store, pack models, pack factory, freshness manifest, user mini-pack builder, Step candidate bridge, and governing Source Atlas/R2 laws.

Validation run after report creation:
- `git diff --check` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_EXECUTION_QUEUE.json` - exited `0`.
- `python3 -m json.tool artifacts/plos-runtime/PLOS_LINEAR_ISSUE_MAP.json` - exited `0`.
- `python3 scripts/codex/plos-readiness-validate.py` - exited `0`.
- `scripts/codex/program-preflight.sh plos` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-preflight-20260612T175542.log`.
- `scripts/codex/program-phase-gate.sh plos M02` - exited `0`, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M02-20260612T175542.log`.
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md` - exited `0`.
- `bash scripts/codex/program-proof-index.sh plos` - exited `0`, wrote `artifacts/proof-ledger/proof-index.json` with 53 entries and artifact `artifacts/plos-runtime/script-output/program-proof-index-20260612T175618.log`.
- `git diff --cached --check` - pending until staging.

Validation not run:
- Build/test/screenshot/accessibility/performance validation was not run because no app source, project, UI, runtime, test source, R2/Cloudflare configuration, Source Atlas pack publication, privacy manifest, entitlement, or release artifact changed.

Proof/claim boundaries:
- Documentation/control-plane boundary matrix only.
- No runtime behavior, source implementation, release readiness, accessibility verification, privacy/legal approval, device proof, or performance proof claimed.

Rollback notes:
- Revert the AMB-658 commit to remove this boundary/report/control-plane update.

Next eligible action:
- AMB-659 / PLOS-026 only after AMB-658 is committed, pushed to `main`, and updated in Linear.

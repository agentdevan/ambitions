# AMB-667 / PLOS-036 - R2 API Compatibility Validation Plan

Status: Green for scoped documentation/control-plane R2 API compatibility validation plan after validation
Date: 2026-06-12
Linear issue: AMB-667
PLOS label: PLOS-036
Parent: AMB-611 / PLOS-M03
Scope: Define compatibility assertions, required R2-facing operations, unsupported response handling, version drift handling, fallback behavior, and future validation proof shape.
Out of scope: Implementing compatibility tests, configuring Cloudflare/R2, provisioning credentials, executing network calls, writing production objects, adding runtime fetch, dependency changes, release readiness, and security certification.

## Source Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md`
- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`
- `artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasFreshnessBrokerModels.swift`
- `tools/source-atlas/ambitions-pack-crypto.py`
- `tools/source-atlas/ambitions-freshness-broker.py`

## Validation Evidence

- Required search: `rg -n "R2|API|compatib|manifest" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-036-r2-api-compatibility-required-search-log.txt`
  - Lines: 98,897
- Focused R2 API compatibility search over Source Atlas domain models, Source Atlas tools, Source Atlas Factory artifacts, docs/codex, truth docs, and M02/M03 R2/security reports.
  - Output: `artifacts/personal-life-os/validation/PLOS-036-focused-r2-api-compatibility-search-log.txt`
  - Lines: 4,950
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- `RELEASE_TRUTH.md` states R2 freshness is not implemented or validated and may only be future read-only public/non-personal reference data.
- PLOS-025 requires R2 to remain public-reference/source/pathing distribution only and blocks private user data, diagnostics, exports, proof, receipts, replay, local learning, and user mini-packs from R2.
- PLOS-030 requires unsupported R2 API behavior to quarantine the path and use safe local/bundled fallback.
- PLOS-031 requires signatures/checksums, release receipts, freshness manifests, revocation lists, rollback manifests, validation reports, and release promotion proof before production eligibility.
- PLOS-032 requires last-known-good fallback to be signed or checksum-pinned by a non-revoked key and source-safe.
- PLOS-033 separates runtime read-only access from staging/production write authority and requires safe dev/staging validation before any future production write path.
- `tools/source-atlas/ambitions-pack-crypto.py` already models hash validation, revocation check, quarantine, and last-known-good status for local files, but it is not R2 compatibility proof.
- No production Cloudflare/R2 config, bucket, token, Worker, runtime fetch, or network compatibility test is implemented by AMB-667.

## Allowed Future Operation Classes

| Operation class | Required behavior | Production eligibility gate |
|---|---|---|
| `HEAD` / metadata read | Confirm object existence, length, hash metadata, ETag or equivalent integrity metadata, content type, and version marker. | Required before runtime read eligibility. |
| `GET` full object | Fetch exact object bytes for public non-personal Source Atlas material only. | Required; must match expected hash/signature and schema. |
| `GET` range | Fetch partial object only when future client/tooling needs it. | Required only if a runtime/tooling path depends on range behavior. |
| ETag or equivalent validator | Bind response to expected object version/hash semantics. | Required or replaced by stronger signed manifest/hash proof. |
| `LIST` staging prefix | Enumerate staging artifacts for validation reports only. | Staging/dev only; not required in app/runtime. |
| `PUT` staging object | Write public non-personal staging candidates. | Staging/dev only; never app/runtime. |
| `DELETE` staging object | Remove staging candidates or incident objects. | Staging/dev or emergency path only; audited. |
| Production promote/write | Promote already validated artifacts. | Future M04+ only with AMB-664 token isolation, AMB-662/663 signing/revocation gates, release receipt, and owner-visible operation evidence. |

## Compatibility Assertions

Future R2 validation must assert:

1. Object path is public, non-user-specific, and belongs to an allowed Source Atlas material class.
2. Response status code is explicitly allowed for the operation.
3. Required headers or metadata are present for object length, content type, version, hash/signature pointer, freshness, and rollback/revocation references.
4. Object bytes match expected SHA-256 or signed manifest hash.
5. Schema version is supported.
6. Freshness state is current or acceptable for fallback.
7. Revocation/contradiction/stale-critical state blocks runtime eligibility.
8. Unknown, missing, malformed, partial, compressed, redirected, cached, or transformed responses fail closed unless explicitly tested and documented.
9. Private user context is never sent in request path, query, headers, body, logs, or support output.
10. Runtime read path, if future-approved, is read-only and cannot infer user identity or private life context.

## Unsupported Response Handling

| Condition | Required result |
|---|---|
| Unknown status code | Quarantine path; no runtime eligibility. |
| Missing or mismatched hash/signature | Quarantine object; use verified last-known-good only if allowed. |
| Unsupported schema/version | Quarantine path; source-needed or bundled fallback. |
| Missing freshness or revocation metadata | Not production-eligible; source-needed or local fallback. |
| Redirect, transform, compression, or cache behavior changes bytes unexpectedly | Fail closed until compatibility is proven. |
| Private user data appears in request/response/log | Red; stop, remove/quarantine object, open privacy/security follow-up. |
| Staging write succeeds without validation receipt | Not promotable; block production. |
| Production write attempted without token isolation and release receipt | Red; stop and revoke/rollback as needed. |

## Fallback Behavior

- Prefer bundled/local safe pack when R2 behavior is incompatible or unverifiable.
- Use last-known-good only when exact artifact id/hash/signature, freshness, revocation, and source state remain valid.
- If fallback cannot be proven, route to source-needed/no recommendation rather than consuming unverifiable pack material.
- Record a local failure receipt naming the operation, object id, expected metadata, observed failure class, fallback chosen, and non-claims.

## Performance Boundary

- Compatibility validation should happen at fetch/import/release boundaries, not every UI render.
- Hash/signature checks can be cached locally only when tied to exact object id, hash, freshness, and revocation state.
- Range support should be required only for future flows that prove a size/performance need.
- AMB-667 does not measure network latency, battery, memory, app launch cost, or production fetch performance.

## Follow-Up Owners

- M04: implement R2 Source Atlas distribution mesh and bucket/object contract.
- M05/M06: pack/seed foundry and Source Authority Mesh runtime eligibility.
- M25/M26: release/compliance/certification proof.

## Closeout

PLOS child closeout: AMB-667 / PLOS-036
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped R2 API compatibility validation plan documentation; Yellow for future compatibility test implementation, real R2/Cloudflare account proof, network validation, production write proof, measured performance, and release certification proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-667.
Linear identifiers used: AMB-667 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-667 documentation/control-plane R2 API compatibility validation plan after validation.
Yellow limits: no app source change; no runtime feature; no compatibility test implementation; no Cloudflare/R2 configuration; no credential provisioning; no network call; no production write path; no runtime fetch; no dependency/scanner/SDK changes; no production pack publication; no security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-667 is committed, pushed to `main`, and moved to Done in Linear, run AMB-611 / PLOS-M03 parent acceptance only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-036-r2-api-compatibility-validation-plan.md`
- `artifacts/personal-life-os/validation/PLOS-036-r2-api-compatibility-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-036-focused-r2-api-compatibility-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

# AMB-663 / PLOS-032 - Key Rotation and Emergency Revocation Policy

Status: Green for scoped documentation/control-plane rotation and revocation policy after validation
Date: 2026-06-12
Linear issue: AMB-663
PLOS label: PLOS-032
Parent: AMB-611 / PLOS-M03
Scope: Define key rotation cadence, signer trust states, emergency revocation triggers, response, recovery, quarantine, rollback, and follow-up expectations.
Out of scope: Rotation tooling, key provisioning, cryptographic implementation, signer storage, Cloudflare/R2 action, dependency changes, production publication, release readiness, and security certification.

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
- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`

## Validation Evidence

- Required search: `rg -n "rotate|revok|key|sign" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-032-key-rotation-revocation-required-search-log.txt`
  - Lines: 87,550
  - Note: Broad search includes many non-security `sign` matches; focused search below is the reviewed evidence lane.
- Focused rotation/revocation search over Source Atlas domain models, Source Atlas artifacts, docs/codex, truth docs, M03 reports, M02 R2 boundary, `project.yml`, and `Package.swift`.
  - Output: `artifacts/personal-life-os/validation/PLOS-032-focused-key-rotation-revocation-search-log.txt`
  - Lines: 5,279
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- `SourceAtlasStoreSourceState` already includes `revoked`.
- `SourceAtlasStoreQuarantineReason` already includes `revoked`, `hashMismatch`, unsupported schema, corrupt JSON, invalid pack, and contradicted.
- `SourceAtlasStore` already blocks revoked/contradicted pack states and quarantines hash mismatches.
- `SourceAtlasPackModels.swift` includes revoked, stale, contradicted, source-needed, and review/freshness concepts.
- Existing source does not implement signer identities, key ids, key rotation, emergency key revocation, signed revocation lists, or production rollback tooling.

## Trust States

Future signing trust must use explicit states:

| State | Meaning | Runtime posture |
|---|---|---|
| `active` | Current signing key allowed for new release candidates. | Accept only if artifact also passes hash, source, release receipt, freshness, revocation, and high-risk gates. |
| `rotating` | Old and new keys overlap during planned rotation. | Accept artifacts signed before cutoff by old key and new releases by new key; require manifest/release receipt to name key id. |
| `deprecated` | Key can validate older last-known-good artifacts but cannot sign new releases. | No new production promotion; only verified historical fallback until cutoff. |
| `revoked` | Key is compromised or invalid. | Quarantine all artifacts signed only by that key unless a later emergency receipt explicitly revalidates via a new key. |
| `unknown` | Key id not recognized or trust metadata missing. | Fail closed; no runtime eligibility. |

## Rotation Cadence

- Planned rotation cadence: at least annually for production signing keys, or earlier after personnel/tooling/process changes that affect signing authority.
- Emergency rotation: immediate when a signing key, release token, write path, build machine, or release receipt path is suspected compromised.
- Overlap window: planned rotations may allow a short overlap where both old and new key ids validate exact hash-covered artifacts.
- New releases during overlap: must use the new active key unless a documented incident exception exists.
- Old key deprecation: after overlap, old key becomes `deprecated` and cannot sign new release candidates.
- Decommission: deprecated keys must have a documented final cutoff after which they are no longer accepted except in offline historical inspection, not runtime eligibility.

## Emergency Revocation Triggers

Emergency revocation is required for:

- confirmed or suspected private key exposure
- R2 write token exposure
- release receipt tampering
- manifest signature mismatch
- payload hash mismatch on published artifact
- private user data discovered in public pack/R2 object
- broad write token or production write authority in repo/log/artifact
- unauthorized dependency/SDK in signing/release path
- revoked/contradicted source that was used in a production-eligible pack
- unsupported R2/API behavior that could serve unverifiable content

## Emergency Response Path

1. Stop production promotion and runtime eligibility for affected artifacts.
2. Mark affected key id, pack ids, manifest ids, source ids, and release receipts as `revoked`.
3. Publish or stage a signed revocation list only through the approved future distribution path; until implemented, record a local control-plane revocation artifact and keep runtime production use blocked.
4. Quarantine affected local caches and avoid permissive fallback.
5. Use last-known-good only if it is signed or checksum-pinned by a non-revoked key and its sources are not revoked/contradicted/stale-critical.
6. Generate a rollback manifest that names exact previous artifact ids, hashes, signer ids, reason, and compatibility note.
7. Open urgent follow-up for key replacement, pack repair, privacy/security incident handling, and user-facing degradation if runtime was affected.
8. Record non-claims: revocation policy does not prove release recovery, App Review readiness, or runtime implementation.

## Compromised Trust Failure Rules

| Condition | Required result |
|---|---|
| Compromised active key | Revoke key, block new releases, quarantine affected artifacts, rotate immediately. |
| Compromised deprecated key | Revoke key and re-evaluate any last-known-good fallback signed only by it. |
| Unknown signer | Fail closed and mark source-needed/quarantine. |
| Revocation list missing | Treat affected material as not proven current; do not use for production eligibility. |
| Revocation list invalid signature | Fail closed for affected distribution path. |
| Rollback target signed by revoked key | Reject rollback target unless re-signed/revalidated by non-revoked emergency key and release receipt. |

## Recovery Expectations

- Recovery must preserve local-first privacy: do not request fresh user data, raw goals, schedules, receipts, or proof to recover public pack trust.
- Recovery must be deterministic: exact artifact ids, hashes, key ids, and rollback manifests are required.
- Recovery must be inspectable: local failure receipt should explain revoked key/pack/source and chosen fallback state.
- Recovery must degrade safely: source-needed, bundled safe pack, or no recommendation is better than consuming unverifiable pack material.

## Follow-Up Owners

- AMB-664: R2 write-token isolation and production/staging write authority separation.
- AMB-667: R2 API compatibility and unsupported response quarantine.
- M04/M05/M06: distribution mesh, pack release, Source Authority Mesh, and runtime eligibility implementation.
- M25/M26: App Review/compliance and certification proof.

## Closeout

PLOS child closeout: AMB-663 / PLOS-032
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped key rotation and emergency revocation policy documentation; Yellow for future rotation tooling, signer trust implementation, key provisioning, R2 distribution, and production recovery proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-663.
Linear identifiers used: AMB-663 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-663 documentation/control-plane rotation/revocation policy after validation.
Yellow limits: no app source change; no runtime feature; no key rotation tooling; no key provisioning; no cryptographic implementation; no signer trust source model; no R2/Cloudflare action; no dependency/scanner/SDK changes; no production pack publication; no security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-663 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-664 / PLOS-033 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`
- `artifacts/personal-life-os/validation/PLOS-032-key-rotation-revocation-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-032-focused-key-rotation-revocation-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

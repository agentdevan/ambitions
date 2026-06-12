# AMB-662 / PLOS-031 - Pack and Manifest Signing Policy

Status: Green for scoped documentation/control-plane signing policy after validation
Date: 2026-06-12
Linear issue: AMB-662
PLOS label: PLOS-031
Parent: AMB-611 / PLOS-M03
Scope: Define signing and verification requirements for packs, manifests, validation receipts, release receipts, and release promotion.
Out of scope: Key rotation implementation, key provisioning, cryptography implementation, dependency changes, Cloudflare/R2 action, production pack publication, release readiness, and security certification.

## Source Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `artifacts/personal-life-os/reports/PLOS-025-r2-source-only-boundary-matrix.md`
- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `project.yml`
- `Package.swift`

## Validation Evidence

- Required search: `rg -n "sign|signature|manifest|receipt" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-031-signing-policy-required-search-log.txt`
  - Lines: 180,035
  - Note: Broad search includes many non-security matches for `sign`; focused search below is the reviewed evidence lane.
- Focused signing policy search over Source Atlas domain models, packages, Source Atlas artifacts, docs/codex, truth docs, M02/M03 reports, `project.yml`, and `Package.swift`.
  - Output: `artifacts/personal-life-os/validation/PLOS-031-focused-signing-policy-search-log.txt`
  - Lines: 6,821
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- `SourceAtlasStore` currently verifies payload bytes against declared SHA-256, decodes JSON, checks schema version, blocks revoked/contradicted states, and quarantines invalid packs.
- `SourceAtlasPackValidator` currently blocks unsupported schema, missing manifest identity, missing canon integration, missing composition contract, runtime-store behavior, official claims without approved sources, high-risk claims without review, and related proof/source risks.
- Existing source does not implement production signing, signature verification, key rotation, certificate pinning, release-ring promotion, or R2 publication.
- AMB-661 defined the parent M03 plan: production-eligible public packs require signature or pinned checksum strategy before runtime eligibility.

## Signing Policy

Unsigned production paths are blocked. Hash-only validation may support local drafts, fixture review, and staged development, but production-eligible public distribution requires a signed or explicitly pinned checksum strategy with release receipt evidence.

| Artifact | Minimum identity | Required integrity control | Required release evidence | Runtime behavior if missing/invalid |
|---|---|---|---|---|
| Source pack payload | Pack id, schema, version, domain, content hash | Signed manifest reference plus payload hash, or pinned checksum in signed manifest | Release receipt naming pack id, hash, validator, reviewer, rollback | Quarantine; do not use for recommendation. |
| Seed pack payload | Seed id, schema, version, source domain, content hash | Signed manifest reference plus payload hash | Release receipt and source/seed validation report | Quarantine; compose locally only from last-known-good verified seed. |
| Pack manifest | Manifest id, schema, version, object list, hashes, signer id/key id | Signature required for production eligibility | Manifest validation report and release receipt | Block production promotion. |
| Freshness manifest | Version, published date, changed ids, pack index, hashes | Signature or signed parent manifest reference | Freshness validation report | Treat stale/source-needed; avoid silent freshness claims. |
| Revocation list | Effective date, revoked pack/source/key ids, reason class | Signature required | Emergency revocation receipt | Block affected material; prefer safe fallback. |
| Rollback manifest | Current bad version, target prior version, hashes, reason | Signature required | Rollback receipt and compatibility note | No rollback unless prior target independently verifies. |
| Validation report | Validator version, command, exit code, artifact hashes | Hash in release receipt; signature required for published report | Release receipt reference | Report is advisory only if unsigned/unreferenced. |
| Release receipt | Released artifacts, hashes, signer/reviewer, rollback note | Signature or checksum pinned by release process | The receipt itself | No production eligibility without release receipt. |

## Required Verification Steps

Future runtime/distribution implementation must verify in this order:

1. Resolve requested public pack/manifest without private user context.
2. Validate object identity, schema, version, and compatibility.
3. Verify manifest signature or signed parent reference.
4. Verify payload hash matches the signed manifest hash.
5. Verify release receipt covers the exact artifact ids and hashes.
6. Verify freshness, revocation, rollback, and high-risk review state.
7. Quarantine any mismatch before runtime use.
8. Use last-known-good only when it independently verifies and is not revoked.
9. Record local/redacted failure receipt for inspection.

## Release Blocking Rules

- A pack can be `draft_local` or `validated_local` with hash-only validation.
- A pack can be `staged_public` only if no private user data exists and a validation report names the hash.
- A pack can become `release_candidate` only when manifest integrity and release receipt are present.
- A pack can become `eligible` only when signature/pinned checksum, release receipt, revocation check, rollback path, source binding, and high-risk review gates pass.
- Any production path that lacks signing/checksum proof is Red if claimed Green.

## Failure Handling

| Failure | Behavior |
|---|---|
| Missing signature/checksum in production path | Block promotion and keep pack non-eligible. |
| Signature mismatch | Quarantine artifact, block pack, require follow-up under AMB-663 or M04/M05 owner. |
| Payload hash mismatch | Quarantine, prefer verified last-known-good only if still allowed. |
| Release receipt missing or does not cover exact hash | Treat as unreleased; no runtime eligibility. |
| Revocation list signature invalid | Treat revocation state as unknown and fail closed for affected public distribution path. |
| Rollback manifest invalid | Do not roll back automatically; keep local safe fallback/source-needed state. |

## Performance Notes

- Verify signatures/hashes at download, import, cache promotion, and release-ring transition boundaries.
- Do not re-verify large payload signatures on every UI render.
- Keep manifests compact enough to validate before payload fetch.
- Cache verification results with artifact hash and revocation epoch, not with user identifiers.

## Follow-Up Ownership

- AMB-663 owns key rotation, signer trust, emergency revocation, overlap windows, and compromised-key response.
- AMB-664 owns R2 write-token isolation.
- AMB-667 owns R2 API compatibility proof.
- M04/M05/M06 own distribution, pack/seed release, Source Authority Mesh, and runtime eligibility implementation.

## Closeout

PLOS child closeout: AMB-662 / PLOS-031
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped pack/manifest signing policy documentation; Yellow for future key rotation, cryptographic implementation, R2 distribution, release-ring tooling, and production verification proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-662.
Linear identifiers used: AMB-662 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-662 documentation/control-plane signing policy after validation.
Yellow limits: no app source change; no runtime feature; no cryptography implementation; no key rotation implementation; no key provisioning; no R2/Cloudflare action; no dependency/scanner/SDK changes; no production pack publication; no security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-662 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-663 / PLOS-032 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/validation/PLOS-031-signing-policy-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-031-focused-signing-policy-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

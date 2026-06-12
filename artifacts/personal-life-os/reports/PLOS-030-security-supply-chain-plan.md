# AMB-661 / PLOS-030 - Security and Supply-Chain Plan

Status: Green for scoped documentation/control-plane security plan after validation
Date: 2026-06-12
Linear issue: AMB-661
PLOS label: PLOS-030
Parent: AMB-611 / PLOS-M03
Scope: Define end-to-end security and supply-chain controls for public packs, manifests, distribution, dependencies, SDKs, secrets, and failure handling.
Out of scope: Cryptography implementation, key provisioning, Cloudflare/R2 actions, network calls, dependency changes, source-pack publication, production readiness, release claims, privacy/legal approval, and runtime behavior.

## Source Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `artifacts/source-atlas-factory/SAF_HARDENING_PLAN.md`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- Prior M02 reports: PLOS-020, PLOS-021, PLOS-025, PLOS-026, and AMB-610 parent acceptance.

## Validation Evidence

- Required search: `rg -n "security|secret|token|sign|dependency" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-030-security-supply-chain-required-search-log.txt`
  - Lines: 25,432
- Focused search over Native, Sources, AppUI, Packages, scripts, docs/codex, truth docs, Source Atlas artifacts, M02 reports, `project.yml`, and `Package.swift` for security/secret/token/credential/signature/hash/checksum/dependency/SDK/R2/manifest/receipt/revocation/rollback/supply-chain terms.
  - Output: `artifacts/personal-life-os/validation/PLOS-030-focused-security-supply-chain-search-log.txt`
  - Lines: 16,852
- `scripts/codex/program-phase-gate.sh plos M03`: pass before AMB-661 start.
- `scripts/codex/program-preflight.sh plos`: pass before AMB-661 start.
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

Current repo evidence supports security planning, not production security implementation:

- `SourceAtlasStoreModels.swift` already evaluates bundled, cached, and last-known-good payloads using SHA-256 hash checks, schema checks, source state, revocation/contradiction state, stale state, and quarantine reasons.
- `SourceAtlasPackModels.swift` already carries source state, freshness, revoked/contradicted/stale states, manifest identity, production-use flags, high-risk review concepts, and validator-style blocking reasons.
- `SAF_HARDENING_PLAN.md` requires source binding, freshness, revocation, release receipt, runtime eligibility state, and rollback for packs/seeds.
- `LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` blocks private user data in R2 and names R2 as public-reference/source/pathing distribution only.
- `PROGRAM_EXECUTION_CONTRACT.md` blocks new runtime dependencies, hosted services, cloud AI paths, telemetry, analytics, signing automation, or write-capable tooling without explicit approval.
- `Package.swift` currently defines local package products only: `AmbitionsDesignSystem` and `AmbitionsWidgetUI`.
- `project.yml` depends on local packages, `AmbitionsExperienceKernel`, widget extension, share extension, and Apple frameworks already configured; this report does not change those dependencies.
- `PrivacyInfo.xcprivacy` currently declares no tracking, no collected data types, and no accessed API reasons.

Missing / future-owned:

- No production pack signing implementation is claimed.
- No signing keys, KMS, keychain policy, cert pinning, or verification library is added.
- No R2 bucket, token, Worker, Cloudflare account, or production object is configured.
- No dependency scanner, secret scanner, CI, or release-ring automation is installed by this child.

## Security Control Plan

M03 security control ownership is layered:

| Control area | Required policy | Runtime default | Owner / later gate |
|---|---|---|---|
| Public pack identity | Every public pack, seed pack, manifest, freshness manifest, revocation list, rollback manifest, validation report, and release receipt must carry stable id, schema, version, content hash, and release state. | Treat missing identity/hash as quarantined or source-needed. | AMB-662, M04/M05/M06. |
| Signing and verification | Production-eligible public packs require signature or pinned checksum strategy before runtime eligibility. | Unsigned/unverifiable production paths blocked. | AMB-662. |
| Key rotation | Signing trust must support planned rotation, overlap, and deprecation windows. | Unknown signer or stale trust blocks production eligibility. | AMB-663. |
| Emergency revocation | Compromised pack/source/key must be revocable through public revocation metadata and local quarantine. | Use bundled or last-known-good only when still verified and safe. | AMB-663, M04/M06. |
| R2 write-token isolation | Client apps must never carry write tokens. Developer/Codex write authority must be least-privilege, scoped, logged, and separated from production. | No write-capable app runtime. | AMB-664. |
| Dependency audit | New dependencies require explicit issue authority, privacy/security review, release-note impact, rollback path, and validation. | Prefer native/local code; no convenience SDK additions. | AMB-665, AMB-666. |
| Secrets scanning | Secrets/tokens/account ids/write credentials must not enter repo source, artifacts, logs, screenshots, or support bundles. | Secret exposure is Red unless contained and rotated. | AMB-665. |
| SDK minimization | Analytics, telemetry, crash, tracking, hosted backend, external AI, network, or security SDKs require explicit approval and App Privacy review. | Default deny. | AMB-666. |
| R2 API compatibility | Only required read/write operations may be used; unsupported responses quarantine the path. | Strict validation over permissive interpretation. | AMB-667. |

## Pack Distribution State Machine

Public packs and manifests must move through explicit states:

1. `draft_local`: local artifact only; not published, not runtime eligible.
2. `validated_local`: schema/hash/source checks passed locally; not production.
3. `staged_public`: staged R2/public mirror candidate; no private user data; validation receipt required.
4. `release_candidate`: signed or checksum-pinned; freshness/revocation/rollback metadata present.
5. `eligible`: runtime-eligible only after source binding, review, signing/checksum, release receipt, rollback, and high-risk gates pass.
6. `quarantined`: invalid hash/schema/signature, revoked, contradicted, unsupported, stale-critical, or private-data contamination.
7. `revoked`: public kill-switch state; local caches must stop using the affected material.
8. `rolled_back`: deterministic safe fallback to a prior verified release.

No future runtime may skip from draft/staged to `eligible` because a file exists or a validator partially passes.

## Failure Handling

| Failure | Required behavior | Red / Yellow |
|---|---|---|
| Missing hash/checksum/signature for production path | Quarantine or source-needed; no runtime eligibility. | Red if claimed production-ready. |
| Signature mismatch/hash mismatch | Quarantine, preserve diagnostic receipt locally, prefer last-known-good only if independently valid. | Red for permissive fallback. |
| Revoked pack/key/source | Block use and follow rollback manifest. | Red if still used for recommendations. |
| R2 write credential in repo/log/artifact | Stop, rotate/revoke credential, purge exposed artifact where possible, open urgent security follow-up. | Red until contained. |
| Private user data in R2/public pack | Stop, quarantine, remove distribution, create privacy/security incident follow-up. | Red. |
| Dependency with unknown security posture | Block addition or keep Yellow with no runtime/release claim. | Yellow for docs; Red for unapproved source dependency. |
| Unsupported R2 API behavior | Quarantine path and use safe local/bundled fallback. | Red if consumed permissively. |

## Runtime Cost Notes

Security checks must be bounded:

- Hash/signature verification should happen at download/import/release boundaries, not on every UI render.
- Manifests should be compact and versioned so current app can validate before downloading large payloads.
- Revocation/freshness checks should support last-known-good local fallback.
- Diagnostics for failures must be local/redacted and must not upload private user context.

## Red Conditions

- Private user data, user goals, schedules, proof, receipts, local learning, diagnostics, support bundles, or raw user text in R2/public packs.
- Client app contains R2 write tokens, secrets, broad credentials, or Cloudflare account write authority.
- Signing/hash/revocation checks are treated as optional for production-eligible packs.
- A new runtime dependency, SDK, hosted service, analytics/telemetry/crash SDK, external AI SDK, or signing automation is added without explicit approval and review.
- Cloudflare/R2 production-readiness claim without plugin/account/bucket/action/result evidence.
- Release/privacy/security/App Review readiness claim without current proof.

## Follow-Up Owners

- AMB-662 / PLOS-031: pack and manifest signing policy.
- AMB-663 / PLOS-032: key rotation and emergency revocation policy.
- AMB-664 / PLOS-033: R2 write-token isolation.
- AMB-665 / PLOS-034: dependency audit and secrets scanning policy.
- AMB-666 / PLOS-035: third-party SDK minimization policy.
- AMB-667 / PLOS-036: R2 API compatibility validation.
- M04/M05/M06: R2 distribution, pack/seed foundry, source authority mesh implementation proof.
- M25/M26: App Review/compliance and certification proof.

## Closeout

PLOS child closeout: AMB-661 / PLOS-030
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped security/supply-chain plan documentation; Yellow for future signing/key/R2/dependency/scanner/SDK/API implementation and release/security/privacy proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-661.
Linear identifiers used: AMB-661 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-661 documentation/control-plane security plan after validation.
Yellow limits: no app source change; no runtime feature; no cryptography implementation; no key provisioning; no R2/Cloudflare action; no dependency/scanner/SDK changes; no production pack publication; no security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-661 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-662 / PLOS-031 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `artifacts/personal-life-os/validation/PLOS-030-security-supply-chain-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-030-focused-security-supply-chain-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

# AMB-664 / PLOS-033 - R2 Write-Token Isolation Policy

Status: Green for scoped documentation/control-plane R2 write-token isolation policy after validation
Date: 2026-06-12
Linear issue: AMB-664
PLOS label: PLOS-033
Parent: AMB-611 / PLOS-M03
Scope: Define R2 write-token scope, separation of duties, production write isolation, credential handling, evidence requirements, failure handling, and follow-up expectations.
Out of scope: Credential provisioning, Cloudflare/R2 configuration, R2 write implementation, network calls, token creation, secret storage, dependency changes, production publication, release readiness, and security certification.

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
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`
- `tools/source-atlas/ambitions-pack-crypto.py`
- `tools/source-atlas/ambitions-freshness-broker.py`
- Source Atlas domain model files under `Native/Ambitions/Domain/`

## Validation Evidence

- Required search: `rg -n "token|R2|credential|secret" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-033-r2-write-token-isolation-required-search-log.txt`
  - Lines: 40,065
- Focused R2 write-token isolation search over Source Atlas domain models, services, persistence, support, Source Atlas artifacts, docs/codex, truth docs, M02/M03 reports, `project.yml`, `Package.swift`, `scripts`, and `tools`.
  - Output: `artifacts/personal-life-os/validation/PLOS-033-focused-r2-write-token-isolation-search-log.txt`
  - Lines: 5,893
- Secret-like pattern review over the two new AMB-664 logs found code/test placeholders and variable names in reviewed excerpts, not live credentials. Full dependency and secrets scanning remains owned by AMB-665.
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- No active `wrangler`, Cloudflare, R2 bucket, R2 token, Worker, Cloudflare account, or production R2 object configuration file is present in the reviewed repo file list.
- Existing Source Atlas tooling includes pack crypto, freshness broker, coverage, import, and release-adjacent utilities, but AMB-664 does not change or run any production Cloudflare/R2 write path.
- `RELEASE_TRUTH.md` states R2 freshness is not implemented or validated and may only be future read-only public/non-personal reference data.
- `LOCAL_DATA_CLOUD_BOUNDARY_LAW.md` and PLOS-025 require R2 to remain public-reference/source/pathing distribution only, with no private user goals, captures, schedules, proof, receipts, replay, learning, diagnostics, exports, support bundles, or raw user text.
- PLOS-030 states client apps must never carry R2 write tokens, and broad write credentials in repo/log/artifact are Red.
- PLOS-032 makes R2 write-token exposure an emergency rotation/revocation trigger.

## Token Classes

Future R2 write authority must use explicit token classes:

| Token class | Allowed use | Required boundary |
|---|---|---|
| `local_dev_read` | Read public non-personal pack/source objects for local validation. | No write, no production mutate, no private user data. |
| `staging_write` | Write staging public-reference Source Atlas candidates. | Staging bucket/prefix only; no production paths; short-lived; logged. |
| `production_promote` | Promote already validated public artifacts into production paths. | Separate owner approval, least privilege, release receipt, no raw secret in repo/logs/artifacts. |
| `emergency_revoke` | Publish or stage revocation/rollback control objects during an incident. | Separate emergency path, audit note, exact affected artifact ids, follow-up rotation. |
| `runtime_read_only` | App/client read of public non-personal references if future implementation is approved. | Read-only only; no write authority in app, bundle, config, logs, or support output. |

## Isolation Rules

1. Client app/runtime code must never contain an R2 write token, Cloudflare account write authority, broad credential, or production mutation secret.
2. Production write authority must be separate from staging/dev write authority.
3. Production promotion must require release receipt, exact object ids/hashes, signer trust, validation report, and a human-visible operation note before any future write.
4. Staging writes cannot become runtime-eligible without a production promotion record and the signing/revocation gates from AMB-662 and AMB-663.
5. Tokens must be least-privilege by action, bucket/prefix, environment, and duration.
6. Tokens, secrets, Cloudflare account ids, bucket write endpoints, or credential material must not be committed to repo source, generated artifacts, logs, screenshots, support bundles, Linear comments, or release reports.
7. Any Cloudflare/R2 write operation must record account/bucket/prefix/action/result in a redacted owner-visible receipt without exposing credentials.
8. R2 write access must not be available to generic app build scripts, UI tests, runtime tests, preview fixtures, public CI, or write-capable MCP unless a future explicit security review authorizes it.
9. Read-only runtime access, if future-approved, must use anonymous/non-personal public references and must not include private user context in requests.
10. Emergency revocation must be able to revoke or quarantine affected tokens and objects without granting broad production write access to ordinary development paths.

## Environment Separation

| Environment | Allowed write authority | Production eligibility |
|---|---|---|
| Local developer | None by default; staging-only write only after explicit setup. | None. |
| Codex/governance run | None for current AMB-664 scope. Future write tooling requires separate approval. | None. |
| Staging/source review | Staging prefix only, short-lived, least-privilege. | Not runtime-eligible until promoted. |
| Production promotion | Narrow promote-only authority, separated from staging and runtime read. | Eligible only with release receipt/signature/freshness/revocation gates. |
| Emergency incident | Separate emergency revoke/rollback authority. | Used only to block, revoke, or restore verified last-known-good artifacts. |
| App/runtime | Read-only public references only if future R2 implementation is approved. | No write authority ever. |

## Red Conditions

- R2 write token, Cloudflare write credential, broad API token, or account write authority appears in repo source, artifact, log, screenshot, support bundle, Linear comment, or app bundle.
- Production and staging write authority use the same token, prefix, bucket, or unscoped credential.
- Client app/runtime has write authority.
- Codex, MCP, CI, or generic scripts have production write authority without explicit separate approval and security review.
- Private user data is written to R2 or included in R2 write requests.
- A production object is promoted without release receipt, source binding, hash/signature, freshness, revocation, rollback, and compatibility evidence.
- Unsupported R2/API behavior is accepted permissively instead of quarantined.

## Failure Handling

| Condition | Required result |
|---|---|
| Write token exposed in repo/log/artifact | Stop, mark Red, revoke/rotate token, remove or quarantine exposed artifact where possible, open security follow-up. |
| Production write path accidentally available to runtime | Block release/runtime eligibility, remove write authority, audit bundle/config, open urgent follow-up. |
| Staging object promoted without release receipt | Revoke promotion, quarantine object, require signed receipt before eligibility. |
| Private user data found in R2 object or request | Stop, remove distribution, open privacy/security incident follow-up, preserve no-release claim boundary. |
| Unknown token scope | Fail closed; no write operation and no production eligibility. |
| R2 API behavior unsupported or unverifiable | Quarantine path and use bundled/local last-known-good if valid. |

## Follow-Up Owners

- AMB-665: dependency audit and secrets scanning policy, including formal scanner choice and evidence shape.
- AMB-667: R2 API compatibility validation and unsupported-response quarantine.
- M04: R2 Source Atlas distribution mesh implementation and bucket/object contract.
- M05/M06: pack/seed foundry and Source Authority Mesh release eligibility.
- M25/M26: compliance and certification proof.

## Closeout

PLOS child closeout: AMB-664 / PLOS-033
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped R2 write-token isolation documentation; Yellow for future credential provisioning, R2/Cloudflare configuration, write tooling, scanner selection, API compatibility proof, and production operation proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-664.
Linear identifiers used: AMB-664 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; secret-like pattern review over new AMB-664 logs; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-664 documentation/control-plane R2 write-token isolation policy after validation.
Yellow limits: no app source change; no runtime feature; no credential provisioning; no Cloudflare/R2 configuration; no R2 write implementation; no network call; no token creation; no secret storage; no dependency/scanner/SDK changes; no production pack publication; no security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-664 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-665 / PLOS-034 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`
- `artifacts/personal-life-os/validation/PLOS-033-r2-write-token-isolation-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-033-focused-r2-write-token-isolation-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

# AMB-665 / PLOS-034 - Dependency Audit and Secrets Scanning Policy

Status: Green for scoped documentation/control-plane dependency audit and secrets scanning policy after validation
Date: 2026-06-12
Linear issue: AMB-665
PLOS label: PLOS-034
Parent: AMB-611 / PLOS-M03
Scope: Define dependency review cadence, secrets scanning expectations, failure escalation, containment, and future automation requirements.
Out of scope: Full CI implementation, scanner installation, dependency changes, package manifest changes, hosted services, telemetry/analytics/crash SDKs, secret provisioning, credential rotation, release readiness, and security certification.

## Source Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/PROGRAM_EXECUTION_CONTRACT.md`
- `artifacts/personal-life-os/reports/PLOS-030-security-supply-chain-plan.md`
- `artifacts/personal-life-os/reports/PLOS-031-pack-manifest-signing-policy.md`
- `artifacts/personal-life-os/reports/PLOS-032-key-rotation-emergency-revocation-policy.md`
- `artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`
- `Package.swift`
- `project.yml`
- `Packages/AmbitionsExperienceKernel/Package.swift`

## Validation Evidence

- Required search: `rg -n "Package|secret|token|dependency" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-034-dependency-secrets-required-search-log.txt`
  - Lines: 33,711
- Focused dependency/secrets search over package manifests, project config, native source, scripts, tools, PLOS/M03 reports, docs/codex, truth docs, and Source Atlas Factory artifacts.
  - Output: `artifacts/personal-life-os/validation/PLOS-034-focused-dependency-secrets-search-log.txt`
  - Lines: 2,226
- Secret-like pattern review over the two new AMB-665 logs found code/test placeholders and variable names in reviewed excerpts, not live credentials. This is not a formal scanner certification.
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-034-dependency-audit-secrets-scanning-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- Root `Package.swift` declares local targets only: `AmbitionsDesignSystem` and `AmbitionsWidgetUI`.
- `project.yml` references local packages (`AmbitionsPackages`, `AmbitionsExperienceKernel`) and Apple SDK `AppIntents.framework`; no external package URL is present in reviewed manifest output.
- `Packages/AmbitionsExperienceKernel/Package.swift` declares the local `AmbitionsExperienceKernel` target and its test target dependency only.
- No scanner, CI, dependency change, package install, or manifest rewrite is introduced by AMB-665.
- `PROGRAM_EXECUTION_CONTRACT.md` blocks new runtime dependencies, hosted services, cloud AI paths, telemetry, analytics, signing automation, or write-capable tooling without explicit approval.
- `RELEASE_TRUTH.md` does not claim release-grade crash/logging/observability proof or production telemetry readiness.
- PLOS-030 classifies secret/token/account/write credentials in source, artifacts, logs, screenshots, or support bundles as Red unless contained and rotated.
- PLOS-033 requires R2 write tokens and Cloudflare write credentials to stay out of repo source, artifacts, logs, screenshots, support bundles, Linear comments, and app/runtime.

## Dependency Audit Policy

Dependency review is required at these points:

| Trigger | Required review |
|---|---|
| New package, SDK, binary, XCFramework, hosted service, analytics, telemetry, crash, AI, security, network, storage, or signing dependency proposed | Stop for explicit approval, privacy/security/release review, source justification, and rollback plan before source change. |
| Package manifest, project dependency, or build setting changes | Review manifest diff, dependency tree, license posture, platform impact, build-cost implication, privacy manifest implication, and release non-claims. |
| Source Atlas/R2 tooling dependency proposed | Verify public-reference-only boundary, no user data path, no write-capable runtime, and owner-visible operation evidence. |
| Pre-release/M25/M26 proof | Re-run manifest audit, secret scan, privacy manifest review, build/test proof, and release boundary review before any readiness claim. |
| Security incident or exposed token suspected | Freeze dependency promotion, scan affected history/artifacts, revoke/rotate credentials, and open urgent follow-up. |

## Cadence

- Per-issue: any source-changing issue that touches manifests, package references, build settings, scripts, SDK use, network paths, telemetry, analytics, crash reporting, AI, Cloudflare/R2, signing, or security tooling must run a focused dependency/security audit before Green.
- Per-M03 child: documentation/control-plane children may use bounded search evidence and explicit non-claims; they must not install scanners or dependencies unless explicitly authorized.
- Before M25/M26: run formal dependency inventory, license/privacy/security review, secrets scan, build-cost review, and release-boundary review.
- After incident: scan current tree and relevant history/artifacts, rotate exposed credentials, and keep status Red until containment is evidenced.

## Secrets Scanning Expectations

Future scanner automation must cover:

- repo source and tracked artifacts
- generated logs intended for commit
- support bundles and screenshots before sharing
- Linear closeout text and pasted evidence summaries
- package manifests, build settings, scripts, CI/config files, and local tool configs
- history or diff range when a credential exposure is suspected

Expected pattern classes include:

- cloud/API tokens, R2/Cloudflare credentials, account write credentials, signing keys, private keys, GitHub tokens, OpenAI/API keys, webhooks, passwords, connection strings, certificates, provisioning secrets, and app/runtime write credentials
- raw private user data accidentally embedded in fixtures, logs, screenshots, support bundles, or source packs
- misleading placeholders that look like real credentials and should be replaced with clearly fake sentinel strings

## Failure Escalation

| Failure | Classification | Required action |
|---|---|---|
| Live secret or write credential in source/artifact/log/comment | Red | Stop, do not push further, revoke/rotate credential, remove/quarantine exposure where possible, open urgent security follow-up, document no-readiness boundary. |
| New dependency without explicit approval | Red | Revert or hold change, document approval gap, run privacy/security review before retry. |
| Scanner unavailable for a documentation-only child | Yellow if no secret is found in reviewed evidence | Record bounded search evidence and no-claim boundary; do not claim formal secret certification. |
| Suspicious placeholder or test marker | Yellow unless it can be proven fake and non-sensitive | Rename to obvious fake sentinel or document why it is safe; do not allow it in production-like config. |
| Dependency audit unknowns before release | Red for release claim | Do not claim M25/M26 or release readiness until formal audit passes. |

## Automatable Future Shape

- A future scanner should run locally first and produce redacted output suitable for proof artifacts.
- Scanner output must never print secret values into committed logs; it should report file, line, detector id, severity, redacted fingerprint, and containment status.
- Dependency inventory should emit package name, source, version/pin, license if known, owner, privacy implication, release implication, and rollback note.
- Any scanner or dependency audit dependency itself must be reviewed before installation.

## Follow-Up Owners

- AMB-666: third-party SDK minimization policy.
- AMB-667: R2 API compatibility validation and unsupported response quarantine.
- M25/M26: release/compliance/certification proof.
- Future source-changing dependency issue: install or select formal scanner only with explicit approval and review.

## Closeout

PLOS child closeout: AMB-665 / PLOS-034
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped dependency audit and secrets scanning policy documentation; Yellow for future scanner implementation, dependency inventory automation, formal history scan, CI integration, and release certification proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-665.
Linear identifiers used: AMB-665 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; secret-like pattern review over new AMB-665 logs; manifest inspection; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-034-dependency-audit-secrets-scanning-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-665 documentation/control-plane dependency audit and secrets scanning policy after validation.
Yellow limits: no app source change; no runtime feature; no scanner installation; no CI implementation; no dependency changes; no package manifest changes; no hosted service, telemetry, analytics, crash SDK, security SDK, external AI SDK, signing automation, credential provisioning, Cloudflare/R2 configuration, production pack publication, security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-665 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-666 / PLOS-035 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-034-dependency-audit-secrets-scanning-policy.md`
- `artifacts/personal-life-os/validation/PLOS-034-dependency-secrets-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-034-focused-dependency-secrets-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

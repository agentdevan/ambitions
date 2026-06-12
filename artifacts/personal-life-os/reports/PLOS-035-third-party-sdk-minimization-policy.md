# AMB-666 / PLOS-035 - Third-Party SDK Minimization Policy

Status: Green for scoped documentation/control-plane third-party SDK minimization policy after validation
Date: 2026-06-12
Linear issue: AMB-666
PLOS label: PLOS-035
Parent: AMB-611 / PLOS-M03
Scope: Define default avoidance, approval thresholds, review criteria, rejection rules, and rollback expectations for third-party SDKs.
Out of scope: Removing current SDKs, dependency changes, package manifest changes, app source changes, CI implementation, scanner installation, hosted services, analytics/telemetry/crash SDK installation, external AI SDKs, security SDKs, release readiness, and security certification.

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
- `artifacts/personal-life-os/reports/PLOS-034-dependency-audit-secrets-scanning-policy.md`
- `artifacts/personal-life-os/reports/PLOS-033-r2-write-token-isolation-policy.md`
- `Package.swift`
- `project.yml`
- `Packages/AmbitionsExperienceKernel/Package.swift`

## Validation Evidence

- Required search: `rg -n "Package.swift|XCFramework|SDK" .`
  - Output: `artifacts/personal-life-os/validation/PLOS-035-sdk-minimization-required-search-log.txt`
  - Lines: 4,475
- Focused SDK minimization search over package manifests, project config, packages, native support files, truth docs, docs/codex, and M03 policy reports.
  - Output: `artifacts/personal-life-os/validation/PLOS-035-focused-sdk-minimization-search-log.txt`
  - Lines: 351
- Current manifest inspection found local package references and Apple SDK/framework usage, with no external package URL or binary target observed in the reviewed manifest output.
- `git diff --check`: pass
- JSON parse for PLOS queue/map: pass
- `python3 scripts/codex/plos-readiness-validate.py`: pass
- `scripts/codex/program-preflight.sh plos`: pass
- `scripts/codex/program-phase-gate.sh plos M03`: pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-035-third-party-sdk-minimization-policy.md`: pass
- `bash scripts/codex/program-proof-index.sh plos`: pass
- `git diff --cached --check`: pass

## Current Source Facts

- Root `Package.swift` declares local targets only: `AmbitionsDesignSystem` and `AmbitionsWidgetUI`.
- `project.yml` references local packages and Apple SDK `AppIntents.framework`; no external package URL is present in reviewed manifest output.
- `Packages/AmbitionsExperienceKernel/Package.swift` declares the local `AmbitionsExperienceKernel` target and its test target dependency only.
- `PROGRAM_EXECUTION_CONTRACT.md` blocks new runtime dependencies, hosted services, cloud AI paths, telemetry, analytics, signing automation, or write-capable tooling without explicit approval.
- `RELEASE_TRUTH.md` does not claim production telemetry readiness or release-grade crash/logging/observability proof.
- PLOS-030 sets SDK minimization owner scope: analytics, telemetry, crash, tracking, hosted backend, external AI, network, or security SDKs require explicit approval and App Privacy review.
- PLOS-034 requires dependency audit and secrets review before new dependency or SDK Green.

## Default Rule

Ambitions defaults to no third-party SDK. Native Apple frameworks, local repo-owned packages, deterministic local tools, and small source-owned utilities are preferred over SDK installation. SDK convenience never overrides privacy, local-first runtime, inspectability, offline operation, App Privacy honesty, binary size, build reliability, or source/security review.

## Approval Thresholds

Any third-party SDK requires explicit separate approval before source change when it is:

- analytics, telemetry, tracking, attribution, crash, logging, support, experimentation, A/B testing, engagement, subscription, payment, AI/LLM, network, backend, storage, database, security, signing, scanning, identity, ads, social, or messaging
- binary-only, closed-source, dynamically loaded, obfuscated, or difficult to audit
- capable of collecting device identifiers, account identifiers, usage behavior, contacts, files, location, notifications, clipboard, calendar, health, finance, school/work, or private life context
- capable of network access, background execution, remote config, code generation, or silent behavior mutation
- added to app targets, extensions, widgets, tests that ship artifacts, or release tooling

## Review Criteria

Before any future SDK can pass Green, the implementing issue must document:

| Review area | Required evidence |
|---|---|
| Native alternative | Why Apple-native or repo-owned implementation is insufficient. |
| Data boundary | Exact data collected, stored, transmitted, inferred, retained, deleted, and excluded. |
| Local-first impact | Why the SDK does not make core behavior cloud-first or server-dependent. |
| Privacy manifest/App Privacy | Required manifest changes, labels, permission copy, and legal review owner. |
| Security posture | Source, vendor, version, signing, binary target status, update cadence, vulnerability history, and rollback. |
| Runtime cost | Binary size, startup cost, background behavior, memory, network, and battery impact. |
| Accessibility/product impact | No UI degradation, dark patterns, tracking prompts, or generic SDK experience. |
| Failure behavior | Offline behavior, service outage behavior, data deletion, export, reset, and user trust receipt boundaries. |

## Rejection Rules

Reject or keep Red when an SDK:

- tracks, profiles, fingerprints, or sells private life behavior
- requires cloud-first core planning, hosted inference, hosted personal data, or external AI for core behavior
- adds analytics/telemetry/crash collection without explicit approval and privacy/legal/release review
- ships broad network, identity, write-capable, or remote-config authority without a narrow product need
- cannot be audited, pinned, rolled back, or removed cleanly
- changes App Privacy labels or privacy manifest truth without explicit review
- increases binary/runtime cost without measured budget and owner acceptance
- is requested during docs/control-plane-only scope

## Failure Handling

| Condition | Required result |
|---|---|
| SDK added without approval | Red; revert or hold, document approval gap, run dependency/security/privacy review. |
| SDK found to collect private user data beyond approved boundary | Red; disable/remove, open privacy/security follow-up, block release claims. |
| SDK introduces telemetry/analytics/crash behavior without proof | Red for release/privacy claims; remove or obtain explicit approval and evidence. |
| Binary-only or opaque SDK proposed | Default reject unless owner explicitly accepts risk with security/legal/release review. |
| SDK no longer needed | Remove in a scoped issue, validate build/test/privacy manifest, and record rollback. |

## Follow-Up Owners

- AMB-667: R2 API compatibility validation.
- Future source-changing dependency issue: explicit approval, privacy/security/release review, scanner evidence, and rollback plan before adding any SDK.
- M25/M26: App Review/compliance and certification proof for any approved SDK.

## Closeout

PLOS child closeout: AMB-666 / PLOS-035
Parent issue: AMB-611 / PLOS-M03
Green/Yellow/Red status: Green for scoped third-party SDK minimization policy documentation; Yellow for future SDK inventory automation, scanner proof, measured binary/runtime cost proof, privacy/legal approval, and release certification proof.
Pushed to main: pending at report validation time
Push hash: pending at report validation time
PLOS-M00 executed: no; PLOS-M00 was already complete before this child and was not re-executed in AMB-666.
Linear identifiers used: AMB-666 child issue; AMB-611 parent issue.
Validation run: required `rg`; focused `rg`; manifest inspection; `git diff --check`; JSON parse for PLOS queue/map; `python3 scripts/codex/plos-readiness-validate.py`; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M03`; `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-035-third-party-sdk-minimization-policy.md`; `bash scripts/codex/program-proof-index.sh plos`; `git diff --cached --check`.
Red blockers: none for scoped AMB-666 documentation/control-plane SDK minimization policy after validation.
Yellow limits: no app source change; no runtime feature; no SDK removal; no dependency change; no package manifest change; no CI implementation; no scanner installation; no hosted service, analytics, telemetry, crash SDK, security SDK, external AI SDK, signing automation, credential provisioning, Cloudflare/R2 configuration, production pack publication, security/privacy/legal/release/performance/accessibility/device proof.
Owner approval claimed: no.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: after AMB-666 is committed, pushed to `main`, and moved to Done in Linear, continue AMB-667 / PLOS-036 only.

Files changed:

- `artifacts/personal-life-os/reports/PLOS-035-third-party-sdk-minimization-policy.md`
- `artifacts/personal-life-os/validation/PLOS-035-sdk-minimization-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-035-focused-sdk-minimization-search-log.txt`
- PLOS run-state, queue, issue map, changelog, decisions, risk register, goal, proof ledger, and proof index artifacts.

App source changed: no.
Runtime features implemented: no.
Release status changed: no.

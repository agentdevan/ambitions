+++
spec_id = "STANDARD-SECURITY-PRIVACY"
title = "Security and Privacy"
kind = "standard"
status = "normative"
owner_domain = "standard-security-privacy"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "engineering.security.threat-model",
  "engineering.security.hostile-input",
  "engineering.security.sensitive-surfaces",
  "engineering.security.secrets-keys",
  "engineering.security.dependencies",
  "engineering.security.abuse-proof",
  "engineering.supply.admission",
  "engineering.supply.minimal",
  "engineering.supply.sbom",
  "engineering.supply.egress",
  "engineering.entitlement.offline-data",
  "engineering.entitlement.states",
  "engineering.entitlement.purchase",
  "engineering.entitlement.ethics",
]
inherits = ["LAW-LOCAL-AUTHORITY-001", "LAW-R2-PUBLIC-ONLY-001", "LAW-OFFLINE-NO-ACCOUNT-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-SYNC-CONTINUITY"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Quality/"]
+++

# Security and Privacy

This standard owns cross-cutting threat, hostile-input, dependency, secret, entitlement-safety, and abuse-proof obligations. Data classification and egress decisions remain with the owning system specification.

## SECURITY-001 — Threat-model coverage
- **Concept:** `engineering.security.threat-model`
- **Modality:** `MUST`
- **Scope:** Local stores/files, App Group, extensions, routes, imports, attachments, notification/App Intent/EventKit/CloudKit paths, diagnostics, backup, account, Source Atlas, and dependencies
- **Status:** `normative`
- **Verification:** `REVIEW-THREAT-MODEL-001`
- **Supersedes:** none

The active threat model MUST enumerate assets, trust boundaries, attackers, abuse paths, mitigations, residual risk, source owners, tests, proof, and incident response for every applicable boundary.

## SECURITY-002 — Hostile input limits
- **Concept:** `engineering.security.hostile-input`
- **Modality:** `MUST`
- **Scope:** ICS, URLs, deep links, files, scans, text, metadata, archives, and external records
- **Status:** `normative`
- **Verification:** `TEST-HOSTILE-INPUT-001`
- **Supersedes:** none

External input MUST be treated as hostile and constrained by type, size, recursion, decompression, path, encoding, time, memory, and output limits with quarantine and safe failure.

ICS, URLs, deep links, files, scans, text, metadata, and external MUST record are untrusted.

Parsers MUST enforce size, recursion, decompression, path, encoding, and resource limits.

## SECURITY-003 — Sensitive-surface policy
- **Concept:** `engineering.security.sensitive-surfaces`
- **Modality:** `MUST`
- **Scope:** App switcher, notifications, widgets, Spotlight, clipboard, capture, diagnostics, support, and export
- **Status:** `normative`
- **Verification:** `PROOF-SENSITIVE-SURFACES-001`
- **Supersedes:** none

Every sensitive surface MUST declare visible fields, defaults, consent, redaction, retention, protection, user control, denial behavior, and proof.

Security MUST support Face ID/passcode app lock, lock timing, protected notification previews, sensitive-action confirmation, and a safe fallback when biometrics fail.

Recovery MUST NOT permanently lock the user out of local data.

Destructive operations, account deletion, sync reset, and private exports MUST require explicit confirmation.

## SECURITY-004 — Secrets and keys
- **Concept:** `engineering.security.secrets-keys`
- **Modality:** `MUST NOT`
- **Scope:** Source, logs, fixtures, generated output, and public artifacts
- **Status:** `normative`
- **Verification:** `AUDIT-SECRETS-KEYS-001`
- **Supersedes:** none

Secrets MUST NOT appear in public or tracked content. Keychain/file-protection ownership, rotation, recovery, deletion, and environment separation MUST be explicit.

Secrets MUST NOT live in source, logs, fixtures, or public artifacts.

Keychain/file-protection ownership, rotation, development/production separation, and recovery MUST be documented.

## SECURITY-005 — Dependency security
- **Concept:** `engineering.security.dependencies`
- **Modality:** `MUST`
- **Scope:** Third-party code, binary artifacts, tools, and services
- **Status:** `normative`
- **Verification:** `AUDIT-DEPENDENCY-SECURITY-001`
- **Supersedes:** none

Dependencies MUST pass ownership, license, maintenance, privacy, security, update, test, vulnerability-response, and removal review.

## SECURITY-006 — Abuse-case proof
- **Concept:** `engineering.security.abuse-proof`
- **Modality:** `MUST`
- **Scope:** Security-sensitive acceptance
- **Status:** `normative`
- **Verification:** `TEST-SECURITY-ABUSE-001`
- **Supersedes:** none

Acceptance MUST cover malformed input, replay, spoofed routes/actions, duplicates, tampered backup, corruption, compromised external records, secret/log leakage, and private-graph egress attempts.

App lock, Face ID/passcode, sensitive notification redaction, sensitive-action confirmation, protected exports, secure App Group boundaries, privacy manifest, and recovery behavior MUST require separate implementation proof.

## SUPPLY-001 — Dependency admission
- **Concept:** `engineering.supply.admission`
- **Modality:** `MUST`
- **Scope:** New dependencies
- **Status:** `normative`
- **Verification:** `REVIEW-DEPENDENCY-ADMISSION-001`
- **Supersedes:** none

A dependency MUST have a named owner, product need, native-alternative review, license/privacy/security assessment, maintenance and version policy, tests, and removal plan.

## SUPPLY-002 — Minimal dependency posture
- **Concept:** `engineering.supply.minimal`
- **Modality:** `MUST NOT`
- **Scope:** Dependency selection
- **Status:** `normative`
- **Verification:** `REVIEW-DEPENDENCY-MINIMAL-001`
- **Supersedes:** none

A dependency MUST NOT be added for trivial convenience or architecture theater. Binary dependencies MUST have verifiable provenance and integrity, license and privacy review, vulnerability scanning, version pinning, tests, and a removal plan.

Minimal dependency posture MUST NOT add a dependency for trivial convenience or architecture theater.

Unknown, unverifiable, or unscannable binary dependencies MUST NOT ship.

## SUPPLY-003 — SBOM and vulnerability response
- **Concept:** `engineering.supply.sbom`
- **Modality:** `MUST`
- **Scope:** Release evidence
- **Status:** `normative`
- **Verification:** `AUDIT-SBOM-001`
- **Supersedes:** none

Release evidence MUST include a dependency inventory or SBOM where supported and a tested vulnerability triage, patch, removal, and rollback process.

## SUPPLY-004 — Dependency egress boundary
- **Concept:** `engineering.supply.egress`
- **Modality:** `MUST NOT`
- **Scope:** Dependencies and external services
- **Status:** `normative`
- **Verification:** `TEST-DEPENDENCY-EGRESS-001`
- **Supersedes:** none

No dependency MUST bypass network-egress, privacy, logging, analytics, data-classification, Account, R2, Source Atlas, or hosted-AI boundaries.

Dependencies MUST NOT bypass network-egress, privacy, logging, analytics, or data-classification law.

## ENTITLEMENT-001 — Offline data remains accessible
- **Concept:** `engineering.entitlement.offline-data`
- **Modality:** `MUST NOT`
- **Scope:** Entitlement loss, expiry, uncertainty, or account mismatch
- **Status:** `normative`
- **Verification:** `TEST-ENTITLEMENT-DATA-SAFETY-001`
- **Supersedes:** none

Entitlement state MUST NOT delete, corrupt, upload, or make existing local private data inaccessible.

An entitlement downgrade MUST NOT destroy or block access to offline local data.

## ENTITLEMENT-002 — Explicit entitlement states
- **Concept:** `engineering.entitlement.states`
- **Modality:** `MUST`
- **Scope:** Entitlement behavior
- **Status:** `normative`
- **Verification:** `TEST-ENTITLEMENT-STATES-001`
- **Supersedes:** none

Active, trial, grace, retry, expired, revoked, restored, supported sharing, offline-cached, mismatch, and unknown states MUST have explicit non-destructive behavior.

## ENTITLEMENT-003 — Purchase integrity
- **Concept:** `engineering.entitlement.purchase`
- **Modality:** `MUST`
- **Scope:** Purchase, restore, downgrade, and deletion
- **Status:** `normative`
- **Verification:** `TEST-PURCHASE-INTEGRITY-001`
- **Supersedes:** none

Purchase flows MUST be accessible, non-coercive, platform-compliant, testable, and separable from private-graph ownership and account deletion.

Purchase, restore, and downgrade flows MUST be accessible, non-coercive, App Store compliant, and independently testable.

## ENTITLEMENT-004 — Ethical monetization
- **Concept:** `engineering.entitlement.ethics`
- **Modality:** `MUST NOT`
- **Scope:** Paywalls and entitlement messaging
- **Status:** `normative`
- **Verification:** `REVIEW-PAYWALL-ETHICS-001`
- **Supersedes:** none

Monetization MUST NOT use dark patterns, fake urgency, shame, blocked deletion, misleading comparisons, or erosion of the offline-core guarantee.

Monetization MUST NOT use dark patterns, fake urgency, shame, blocked account deletion, or misleading comparison.

Core offline product law MUST remain explicit.

<!-- canon-section: purpose -->
Define cross-cutting security, dependency, secret, sensitive-surface, entitlement-safety, and abuse-proof law.
<!-- canon-section: scope -->
Applies to every trust boundary while exact data handling, continuity, account, import/export, and incident behavior remains in system owners.
<!-- canon-section: requirements -->
The requirements consolidate useful Articles 33, 38, and 39 without duplicating system-specific privacy law.
<!-- canon-section: exceptions -->
Exceptions require documented threat analysis, minimum scope, removal conditions, tests, privacy impact, and rollback; no exception permits private graph egress to forbidden destinations.
<!-- canon-section: verification -->
Verify with threat analysis, scanners, fuzz/abuse tests, dependency inventory, egress inspection, and entitlement-state tests.
<!-- canon-section: source-ownership -->
Target owners are `PrivacySecurity/`, `Boundary/`, exact adapters, and `Quality/Security/`;
<!-- canon-section: proof -->
Verification includes threat analysis, abuse/fuzz results, secret and dependency scans, SBOM, egress inspection, entitlement-state fixtures, and incident regressions.
<!-- canon-section: amendment-impact -->
When security or privacy behavior changes, update affected assets, threats, destinations, data classes, secrets, dependencies, entitlements, source/tests, migrations, and rollback handling.

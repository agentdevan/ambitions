+++
spec_id = "SYSTEM-PRIVACY-DATA-CLASSIFICATION"
title = "Privacy and Data Classification"
kind = "system"
status = "normative"
owner_domain = "system-privacy-data-classification"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.privacy.classification", "system.privacy.egress-firewall", "system.privacy.external-assistance"]
inherits = ["LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "LAW-ACCOUNT-BOUNDARY-001", "LAW-R2-PUBLIC-ONLY-001", "PRIVACY-CLOUDKIT-CONTINUITY-001", "PRIVACY-VISIBILITY-001"]
depends_on = ["CONSTITUTION", "SURFACE-YOU", "APP-PERMISSIONS", "GLOBAL-TRUST-INSPECTION", "SYSTEM-PRIVATE-LIFE-RUNTIME"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Privacy and Data Classification

This shadow specification defines intended privacy controls and exhaustive egress law.

## SYSTEM-PRIVACY-CLASSIFICATION-001 — Every datum and derived fact has one handling class

- **Concept:** `system.privacy.classification`
- **Modality:** `MUST`
- **Scope:** Private graph, attachments, account/entitlement, public reference, external metadata, diagnostics, projections, exports, and derived or inferred facts
- **Status:** `normative`
- **Verification:** `AUDIT-SYSTEM-PRIVACY-CLASSIFICATION-001`
- **Supersedes:** none

Every stored, rendered, logged, exported, indexed, cached, synchronized, or transmitted datum MUST carry an explicit handling class, owner, allowed destinations, redaction, retention/deletion, consent, protection, and inspection policy. Derived schedules, behavior patterns, inferred priorities, recommendation context, and identifiers joined to private records remain private graph data rather than anonymous by assertion.

If the user provides sensitive context, Ambitions MAY use it locally.

## SYSTEM-PRIVACY-EGRESS-001 — Private graph egress fails closed

- **Concept:** `system.privacy.egress-firewall`
- **Modality:** `MUST NOT`
- **Scope:** Ambitions-controlled backend, Account, R2, Source Atlas, hosted AI/model services, analytics/telemetry, implicit support upload, and server profiling
- **Status:** `normative`
- **Verification:** `PRIVACY-SYSTEM-NO-PRIVATE-GRAPH-EGRESS-001`
- **Supersedes:** none

No Ambitions backend, Account service, R2, Source Atlas, hosted AI/cloud model, analytics, telemetry, implicit support upload, or server profiler MAY receive, store, infer from, personalize from, or transmit Goals, Life Areas, Captures, notes, attachments, calendar facts, schedule assumptions, availability, Protected time, Proof, Receipts, closure/history, corrections, behavior patterns, inferred priorities, recommendation context, private identifiers, or any private-graph payload. An explicitly user-controlled reviewed export or named external integration may carry only user-selected private data through its owning import/export or integration contract, with minimum fields, destination preview, confirmation, Receipt/History, and durable outbox/result where applicable. This reviewed-egress route never permits private-graph receipt by an Ambitions backend, Account service, R2, Source Atlas, hosted AI/cloud model, analytics, telemetry, implicit support upload, or server profiler. A separate explicitly approved user-owned CloudKit continuity path is governed only by `SYSTEM-SYNC-CONTINUITY` and is disabled until its complete gate passes.

Ambitions Account MUST NOT store the private life graph unless a future canon explicitly approves a user-owned sync architecture.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns classification, redaction, local protection, consent/permission explanation, sensitive-surface policy, egress authorization, export policy, retention/deletion boundaries, and privacy inspection. It does not own account identity, continuity merge, public-reference content, product analytics, or legal approval by prose.

<!-- canon-section: inputs-outputs -->
The contract consumes a typed boundary request and emits one enforceable policy decision.
Inputs are typed datum/derivation, source owner, requested operation/destination, user consent/permission, purpose, environment, and policy revision. Outputs are allow/deny, minimum payload, redactions, local protection, user explanation, Receipt/history requirement, retention/deletion rule, and redacted audit fact.

<!-- canon-section: authority-boundary -->
`Core/LocalRuntimeOS/PrivacySecurity/` and `Boundary/` enforce privacy before adapters/network code. Account owns identity/entitlement only; R2/Source Atlas own public reference only; diagnostics are local/redacted; hosted AI and server profiling are excluded. Destination declarations never override classification.

<!-- canon-section: data-classification -->
Classes include private life graph, attachment, account/entitlement, public reference, external integration metadata, and redacted diagnostic. Combining public or account data with private context inherits the private class and remains prohibited from public/backend paths.

<!-- canon-section: state-model -->
The state model binds each boundary action to class, purpose, destination, and decision.
Each boundary decision records class, purpose, destination, consent/permission, redaction, allowed fields, environment, retention, Receipt need, policy revision, and allowed/denied result. Unknown class, purpose, or destination is denied.

<!-- canon-section: failure-recovery -->
Classification or redaction failure blocks egress and preserves local data. Suspected leakage becomes a privacy incident with containment, local redacted diagnosis, key/token response where relevant, affected-path disablement, and proof-required repair; retry reclassifies from current policy.

<!-- canon-section: local-network-boundary -->
No-account/offline core is complete. Network denial never blocks local planning, mutation, inspection, proof, history, learning, export preview, or deletion. Optional public/reference access sends no private context; user-controlled export is explicit reviewed egress, not backend storage.

<!-- canon-section: determinism -->
Stable class, purpose, destination, and consent facts select one firewall result.
Equivalent datum class, operation, destination, consent, environment, and policy revision produce the same allow/deny and redaction result. Heuristics cannot upgrade an unknown/private item to public.

<!-- canon-section: observability -->
Local redacted traces bind the request shape to its allow or deny result.
Local redacted evidence records policy revision, class, destination category, requested/allowed field names, decision reason, consent/permission state, payload-shape hash where safe, and result without recording private values.

<!-- canon-section: source-ownership -->
Exact target owners are `Core/LocalRuntimeOS/Boundary/`, `PrivacySecurity/`, and `Inspection/`; `Surfaces/You/` and `Trust/` present controls; `Quality/` owns privacy-abuse proof. Current privacy source presence and scanner proof remain narrower than app-wide network, export, diagnostics, adapter, and future-code coverage.

<!-- canon-section: tests-proof -->
Executable abuse scenarios exercise every declared class and destination boundary.
Test every class/destination pair, unknown fail-closed, derived/inferred data, identifier joining, public-private mixed payload, R2/Source Atlas request inspection, account payloads, hosted-AI/server-profile denial, diagnostics/support/export redaction and preview, permission denial, sign-out/delete separation, malicious adapter, logs/snapshots/widgets/Spotlight/clipboard, and executable no-private-graph egress audit.

<!-- canon-section: performance-resource-constraints -->
Classification and redaction are bounded, synchronous only for small in-memory metadata, streaming for large export/blob work, cancellable, and fail closed under pressure. Article 31 calibration must define representative field/blob/payload scale, device/OS/build/tool, percentile/maximum, memory/energy/storage, and regression threshold; this target invents no numeric budget or proof.

## SYSTEM-EXTERNAL-ASSISTANCE-BOUNDARY-001 — External assistance boundary

- **Concept:** `system.privacy.external-assistance`
- **Modality:** `MUST NOT`
- **Scope:** External assistance boundary
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-EXTERNAL-ASSISTANCE-BOUNDARY-001`
- **Supersedes:** none

Optional external assistance MAY support an explicitly user-initiated non-core task only with minimum selected data, destination disclosure, consent, private-context prohibition, no private-graph retention or profiling, and a complete local fallback; it MUST NOT become core intelligence or receive implicit private context.

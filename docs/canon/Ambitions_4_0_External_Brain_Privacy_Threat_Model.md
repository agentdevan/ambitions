# Ambitions 4.0 External Brain Privacy Threat Model

<!-- markdownlint-disable MD013 -->

Status: Active Ambitions 4.0 External Brain privacy threat-model evidence; not implementation proof.
Date: 2026-05-04

Parent truth:
- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
- `docs/canon/Ambitions_4_0_Trust_Privacy_And_User_Control_Kernel.md`
- `docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md`
- `docs/codex/EXTERNAL_BRAIN_RISK_REGISTER.md`

This document extends the active Ambitions 3.0 privacy threat model for the
Ambitions 4.0 External Brain Foundation. It is a product and engineering threat
model, not legal review, product behavior, production readiness, release
readiness, public accessibility proof, or physical-device proof.

## Scope

EB37 covers privacy risks created by the External Brain kernels:

- Universal Capture
- Life Memory Graph
- Trust, Privacy, And User Control
- Product Maturity And Onboarding
- Accessibility And Cognitive Load
- External Brain search/context recall
- External Brain command-surface contracts
- External Brain preview/scenario evidence

EB37 does not implement app behavior, durable memory, persistence/schema,
route/raw-value changes, cloud/sync/account behavior, export/delete execution,
calendar write behavior, networking, top-level destinations, or production UI.

## Sensitive Data Classes

External Brain work can touch or imply these sensitive classes:

- raw capture text, attachments, route suggestions, and clarification state
- goals, steps, plans, proof, receipts, recovery, and Still Counts context
- schedule, availability, protected time, away time, and calendar-derived facts
- memory source, confidence, stale/rejected/private/corrected state
- personal operating manual preferences and sensitive-memory approvals
- command-surface intent, safety summary, fallback, and confirmation needs
- privacy controls, source freshness, correction, deletion, export, and audit boundaries
- accessibility, cognitive-load, overloaded-day, and motor/voice alternative needs
- preview/demo fixture content and generated evidence reports

## Threat Matrix

| Threat ID | Threat | Affected EB lanes | Current mitigation | Required Green proof | Release impact |
| --- | --- | --- | --- | --- | --- |
| EB-PRIV-001 | Capture material becomes durable memory without source, confidence, approval, correction, delete, and receipt paths. | Universal Capture, Life Memory, Trust | EB03A/EB03B split, EB06 receipt projection, EB13 Trust gate, EB31/EB32 dependency rules. | Focused Capture-to-memory tests, Trust controls, receipt proof, rollback proof, and no silent sensitive promotion. | Blocks durable memory and capture-to-memory claims. |
| EB-PRIV-002 | Search/context recall exposes stale, rejected, private, or inferred context without explanation. | Life Memory, Search/Recall, You | EB08-EB12 memory evidence, EB33 retrieval scope/search tokens, rejected/private/stale labels. | UI consumption proof, source/freshness labels, correction/delete path, VoiceOver/Dynamic Type evidence. | Blocks broad context recall and memory trust claims. |
| EB-PRIV-003 | Command surfaces imply hidden automation, calendar writes, plan mutation, or durable memory writes. | Command Surface, Trust, Plan/Capture | EB34 command contract marks calendar writes and durable memory false and requires safety summaries. | Confirmation UI, receipt/fallback proof, no-silent-mutation tests, and explicit unsupported-action copy. | Blocks automation, assistant, and calendar-write claims. |
| EB-PRIV-004 | Trust Center or What Ambitions Knows suggests export/delete/privacy controls that do not execute. | You, Trust, Memory | EB10-EB18 evidence labels distinguish future-owned controls and non-claims. | Actual export/delete/correction execution tests, persistence rollback, and privacy receipts when implemented. | Blocks export/delete and full trust-center claims. |
| EB-PRIV-005 | Onboarding requests sensitive setup before value is demonstrated or without skip/recovery. | Product Maturity, Onboarding, Trust | EB20-EB24 evidence requires value-first setup, privacy setup, progressive disclosure, skip/later, and setup receipts. | Onboarding UI proof, skip/recovery tests, privacy-copy review, no calendar permission during onboarding. | Blocks onboarding maturity/privacy setup claims. |
| EB-PRIV-006 | Accessibility or cognitive-load data is treated as behavioral inference or public proof without user control. | Accessibility, Cognitive Load, You | EB25-EB30 evidence names modes and proof boundaries; EB36 keeps human proof Yellow. | Surface traversal evidence, user-visible controls, non-color meaning, motor alternatives, and no public conformance claim without proof. | Blocks public accessibility and cognitive-mode claims. |
| EB-PRIV-007 | Preview/demo fixtures leak realistic private data or imply unimplemented behavior. | Preview, QA, Release Claims | EB35 typed scenarios use expected evidence and privacy boundaries; EB36 risk register names fake-proof risk. | Privacy-safe fixture review, rendered proof only when actually produced, and no fake release copy. | Blocks screenshot/demo and release-readiness claims. |
| EB-PRIV-008 | Local-first posture is overstated when future sync/cloud/account behavior is not implemented. | Trust, Persistence, Release Claims | EB reports repeatedly mark network/sync/account/cloud behavior as not changed. | Source-level proof for storage boundary, sync/account threat model if introduced, and migration/rollback proof. | Blocks local-first, cloud, account, and privacy claims beyond current evidence. |
| EB-PRIV-009 | Receipts and audit trails over-retain sensitive detail. | Receipts, Audit, Trust, Memory | EB17/EB18 evidence names audit/export/source freshness and privacy receipt boundaries without durable storage. | Privacy-level projection, redaction, retention controls, delete/export proof, and receipt minimization tests. | Blocks receipt/audit release claims. |
| EB-PRIV-010 | Train evidence drifts into unsupported product, release, accessibility, or device claims. | Codex OS, QA, Closeout | EB36 risk register, no-fake-proof gate, release-claim scans, current run-state non-claims. | Every batch report lists run/not-run proof, claim boundaries, and Yellow owners. | Blocks release, App Store, TestFlight, physical-device, and full accessibility claims. |

## Permission And Storage Boundaries

- Calendar-derived context must remain labeled by source and cannot become
  sensitive memory from one event without user approval.
- Capture intake must not write durable memory merely because routing,
  classification, or clustering suggests a destination.
- Local-first posture can be claimed only for the currently proven local
  surfaces and models; future sync, account, cloud, export, delete, and import
  behavior require separate owner batches.
- External surfaces, notifications, widgets, Live Activities, Siri/App Intents,
  screenshots, and preview evidence must use privacy-safe projections.
- Private/sensitive states must degrade to generic labels such as `Private item`
  where compact or external display could leak meaning.

## User Control Requirements

Any future External Brain implementation that stores, recalls, recommends,
routes, corrects, deletes, exports, or changes meaningful user context must
provide:

- source and freshness
- confidence or uncertainty boundary when relevant
- user correction/rejection path
- delete or stop-using path for memory claims
- receipt or audit trail when trust can be affected
- undo or rollback where safe
- clear fallback when an action is unsupported
- non-shaming recovery language

## Accessibility And Cognitive-Load Requirements

Privacy controls are not Green until the owning surface records:

- Dynamic Type behavior
- VoiceOver order and labels
- Reduce Motion equivalent where motion exists
- non-color meaning
- tap target and motor alternative notes
- plain-language explanation
- overloaded-day/cognitive-load behavior
- public-claim boundary

No public accessibility compliance claim is allowed from this document.

## EB37 Classification

- Production Swift touched: no.
- UI behavior changed: no.
- Routes/raw values changed: no.
- Persistence/schema changed: no.
- Network/sync/account/cloud behavior changed: no.
- Export/delete execution changed: no.
- Top-level tabs changed: no.
- App Store/TestFlight/release readiness proved: no.
- Physical-device, screenshot, VoiceOver, Dynamic Type, contrast, Instruments, or battery proof produced: no.

## Owner Follow-Ups

| Owner batch | Required follow-up |
| --- | --- |
| EB38 | Close External Brain accessibility evidence honestly, keeping human/device proof Yellow unless actually performed. |
| EB39 | Handoff and RC implications must include this threat model and must not convert it into release readiness. |
| EB40 | Close External Brain only with Green or accepted-Yellow evidence from EB01-EB39. |
| Future Capture / Trust / Persistence owner batches | Implement durable storage, export/delete, cloud/sync, calendar writes, or memory promotion only with exact owner files, tests, preview/evidence lane, migration/rollback, and release-claim impact. |

## Claim Boundaries

This document may support the claim that EB37 produced an External Brain privacy
threat model. It must not be used to claim shipped External Brain behavior,
legal/privacy signoff, production readiness, App Store/TestFlight readiness,
physical-device proof, full accessibility compliance, durable memory, export or
delete execution, sync/account/cloud behavior, or release readiness.

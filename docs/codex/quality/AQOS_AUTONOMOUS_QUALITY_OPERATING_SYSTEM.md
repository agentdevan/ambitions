# AQOS — Autonomous Quality Operating System

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS quality source truth.
Date: 2026-05-05
Train: AQOS01-AQOS30

## Purpose

AQOS makes Ambitions' Codex workflow behave like an autonomous FAANG-level product, design, engineering, QA, privacy, accessibility, performance, release, and handoff organization.

The core rule is:

> No matching evidence, no Green.

A batch may not close Green because it created the right files, named the right components, compiled, or wrote a convincing report. It closes Green only when the proof type matches the thing it changed.

## Why AQOS Exists

Ambitions already has strong canon, batch order, repair loops, CQS, FVQ, PFC, FCP, AOS, LDI, and Found Life layers. The remaining risk is evidence mismatch: a batch can satisfy structural checks while the lived product result remains weak.

Example class of failure:

- UI objects exist, but rendered simulator output looks like a prototype.
- Accessibility labels exist, but VoiceOver order or Dynamic Type layout is poor.
- Privacy policy exists, but sensitive Found Life text leaks into widgets or logs.
- Performance plan exists, but a visual primitive drains battery.
- Schema docs exist, but migration/corruption behavior is not proven.
- App Store claim docs exist, but release evidence is not present.

AQOS closes that gap.

## Operating Principle

Every batch must answer four questions before Green:

1. What did this batch touch?
2. What evidence does that domain require?
3. Was the evidence produced durably?
4. Did an adversarial review find any unresolved Hard Red?

## Green Taxonomy

Green is no longer generic.

A report must name which Green types it achieved:

- Structural Green — code/docs/contracts exist, build, and are owned.
- Behavioral Green — user flow or domain behavior is tested.
- Rendered Visual Green — simulator/preview output is fresh, durable, scored, and above bar.
- Accessibility Green — VoiceOver/Dynamic Type/Reduce Motion/non-color/touch target proof exists.
- Privacy Green — data exposure, redaction, logging, external-surface, and memory behavior are proven.
- Data Integrity Green — schema, migration, deletion, export/import, corruption, backup/restore, and stale data behavior are proven where applicable.
- Performance Green — launch/render/memory/battery/background budgets are proven or safely bounded.
- Architecture Green — ownership, dependency, file-size, module boundary, and anti-sprawl checks pass.
- Copy Green — user-facing copy is human, non-shaming, non-internal, non-generic, and canon-aligned.
- Platform Green — widgets, Live Activities, App Intents, notifications, StoreKit, and external surfaces are proven where touched.
- Release Green — App Store/TestFlight/device/legal/privacy claims are evidence-bound and no self-certification occurs.
- Handoff Green — a senior external team can understand the repo without chat history.

A batch may be Structural Green but Visual Yellow. It must not collapse that into generic Green.

## Batch Impact Classifier

Before execution, Codex must classify every batch by touched domain:

- UI / visual
- motion / haptics
- accessibility
- user-facing copy
- privacy / sensitive data
- persistence / schema / data integrity
- sync / cloud / app groups
- performance / battery
- architecture / repo structure
- security / secrets / logging
- external surfaces
- monetization / StoreKit
- App Store / legal / release claims
- AI / recommendation / AOS / LDI runtime
- tests / preview fixtures
- docs-only canon
- handoff / governance

The classifier selects required gates. The batch does not choose convenient proof.

## Evidence Must Be Durable

Evidence cannot live only in memory, a temporary simulator path, or a chat response.

Use durable paths:

- `docs/audits/evidence/<batch>/`
- `docs/audits/visual-evidence/<batch>/`
- `docs/audits/accessibility-evidence/<batch>/`
- `docs/audits/privacy-evidence/<batch>/`
- `docs/audits/performance-evidence/<batch>/`
- `docs/audits/data-integrity-evidence/<batch>/`
- `docs/audits/release-evidence/<batch>/`

If evidence cannot be committed because of tooling limits, the batch must record Accepted Yellow and provide an operator proof checklist.

## Adversarial Review Required

Before commit, Codex must review the batch as:

- Founder Vision Guardian
- Chief Product Reviewer
- Apple Design Award Visual Reviewer
- Staff iOS Architect
- Senior SwiftUI Reviewer
- Accessibility Lead
- Privacy/Security Reviewer
- Performance/Battery Reviewer
- QA Lead
- App Store / Claim Truth Reviewer
- FAANG Handoff Auditor

Each reviewer must identify the strongest failure risk. If any reviewer finds Hard Red, the batch cannot close Green.

## Repair Behavior

AQOS preserves the user's preferred global-train flow:

- do not stop for Yellow
- do not stop for recoverable Red
- repair, split, or document safely
- stop only for Hard Red

But AQOS tightens what counts as recoverable vs hard.

Recoverable Red:

- missing screenshot but screenshot tooling available
- failing touched-scope visual score that can be repaired locally
- missing accessibility state proof
- copy leak of internal term
- file-size issue with clear extraction path
- missing performance evidence for a bounded visual primitive
- stale build evidence that can be fixed with build stamp/fresh install

Hard Red:

- unresolved sensitive data leak
- unproven data-loss/migration risk
- app-breaking build failure with unclear repair path
- visual output still prototype/dashboard-like after focused repair
- unsupported legal/privacy/App Store/security claim
- screenshot cannot be proven fresh and batch relies on it
- Codex must delete tests, weaken canon, fake evidence, or hide issues to pass

## Founder Vision Standard

Every major batch must preserve:

> Find your life. Keep your promises. Build your future. Enjoy today.

Ambitions must not drift into:

- generic productivity app
- task manager
- habit tracker
- calendar clone
- AI chatbot wrapper
- project management app
- surface
- notes app
- school LMS too early
- enterprise admin software too early
- surveillance-feeling memory system

## Completion Standard

AQOS is complete when:

- AQOS train source truth exists
- Batch Impact Classifier exists
- Required Evidence Matrix exists
- Green Taxonomy exists
- Repair Batch Generator exists
- Domain Gates exist
- Evidence Maturity Ledger exists
- Golden Scenario and State Coverage system exists
- Autonomous Quality Council exists
- scripts/skill maps exist
- global overlay requires AQOS at every safe batch boundary
- future UI-affecting and platform-affecting batches cannot close generic Green without matching evidence

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

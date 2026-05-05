# AQOS Required Evidence Matrix
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS quality matrix.
Date: 2026-05-05

## Core Rule

No matching evidence, no Green.

Codex must map every batch to required evidence before execution. If the batch touches multiple domains, it inherits all relevant proof requirements.

## Matrix

| Domain touched | Required evidence before Green |
|---|---|
| Visual UI / SwiftUI surface | FVQ durable screenshots or rendered previews, freshness proof, visual score, accessibility/readability impact, Reduce Motion impact, privacy-sensitive rendering impact, no dashboard/prototype/card-stack Red, and repair decision. If tooling prevents rendering, the batch cannot be Green and must include an operator proof checklist. |
| Motion / haptics | Motion policy, reduced-motion equivalent, no motion-only meaning, haptic boundary, state sequence or screen recording where feasible. |
| Accessibility | VoiceOver order, Dynamic Type, Reduce Motion, non-color meaning, tap targets, truncation check, privacy-safe labels. |
| User-facing copy | Copy diff, internal-term scan, no shame, no fake AI confidence, no generic productivity cliche, source/privacy language where needed. |
| Privacy / sensitive data | Privacy exposure matrix, logs/previews/widgets/notifications/App Intents/Spotlight/shared-storage leak checks, redaction proof. |
| Persistence / schema | Migration tests, backward compatibility, deletion/export/import proof, corruption/restore posture, no data-loss risk. |
| Sync / cloud / app groups | Conflict, offline, tombstone, stale state, merge ledger, local-only honesty, shared-storage privacy proof. |
| Performance / battery | Launch/render/memory/animation/background budget, widget reload budget, Live Activity update budget, Instruments plan/evidence where relevant. |
| Architecture / repo structure | Dependency boundary scan, file-size thresholds, view/domain separation, duplicate model scan, no junk drawer, ownership proof. |
| Security / secrets / logging | Secret scan, sensitive logging scan, debug overlay safety, privacy/security claim truth, network/storage boundary proof. |
| External surfaces | Rendered widget/Live Activity/notification/App Intent screenshots or previews, privacy-safe default, deep-link proof, accessibility proof. |
| StoreKit / monetization | Entitlement tests, restore/cancel/family/plan-state proof, paywall compliance, no dark pattern, App Review-safe copy. |
| App Store / legal / release | Claim-truth packet, privacy labels, privacy manifest, required-reason APIs, TestFlight/build/signing boundary, human legal/device proof bridge. |
| AI / recommendation / AOS / LDI | Golden scenario results, source-grounded why, confidence/uncertainty, capacity realism, correction loop, no silent mutation, safety boundaries. |
| Tests / fixtures | Fixture freshness, scenario coverage, no stale preview-only truth, no production/preview divergence. |
| Docs-only canon | Source-truth consistency, no implementation claim, owner/deferral path, order integration, no claim overreach. |
| Handoff / governance | Architecture map, ownership, evidence maturity ledger, onboarding path, no chat-history dependency. |

## Batch Report Requirements

Every batch report must include:

- impact classifier result
- required evidence selected
- evidence produced
- evidence not produced and why
- Green taxonomy achieved
- Yellow/Red classification
- repair path
- hard Red check

## Evidence Gaps

If evidence is missing:

- classify as Yellow if safe and bounded;
- classify as Recoverable Red if evidence can be produced now;
- classify as Hard Red if the batch relies on missing evidence for a critical claim.

## Never Accept

Never accept:

- temp-only screenshots as visual Green
- compile-only proof for UI changes
- labels-only proof for accessibility changes
- docs-only proof for privacy-sensitive runtime behavior
- strategy-only proof for release readiness
- simulator-only proof for physical-device claim
- self-certification for legal/App Store/public accessibility claims

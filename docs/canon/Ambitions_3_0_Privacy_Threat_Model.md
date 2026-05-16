# Ambitions 3.0 — Privacy Threat Model

> Historical/supporting note: This file is retained for traceability and may still contain useful privacy/security planning concepts.
> It is not active product, implementation, release, or Codex process authority.
> Current authority starts in `docs/truth/README.md`; active privacy, release, and implementation claims must reconcile through `docs/truth/*`, `docs/status/*`, and current source evidence.
> Use this only after reconciling against `docs/status/old-canon-classification-index.md`.

Status: Supporting historical Ambitions 3.0 privacy/security reference  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related docs: [Trust / Privacy / Memory](./TRUST_PRIVACY_MEMORY.md), [Personalization Consent Model](./Ambitions_3_0_Personalization_Consent_Model.md)  
Last updated: 2026-04-30

---

## Purpose

Ambitions contains deeply personal life data. This threat model defines the main privacy risks Ambitions 3.0 must design against.

This is a product and engineering planning document, not a legal review.

---

## Sensitive Data Classes

Ambitions may contain:

- goals and ambitions
- personal plans
- schedule and availability
- work/school blocks
- protected time
- vacation / away time
- health-related goals or closures
- financial goals or reminders
- relationship/family commitments
- creative/private ambitions
- proof artifacts
- receipt trails
- memory/personalization data
- recommendation history
- correction history
- external-surface projections

---

## Threats

### 1. Sensitive data shown in compact UI

Risk: private goals or steps appear in Today, widgets, notifications, Live Activities, screenshots, or previews.

Mitigation:

- sensitive/private projection layer
- generic labels such as `Private item`
- external surfaces hide details by default
- privacy preview before enabling external surfaces

### 2. Hidden personalization

Risk: Ambitions uses behavior or sensitive patterns without user understanding.

Mitigation:

- What Ambitions Knows
- memory source cards
- explicit approval for sensitive memory
- pause/delete/correction controls
- trust receipts

### 3. Silent meaningful changes

Risk: user loses trust because Ambitions moves or changes plans invisibly.

Mitigation:

- no silent change rule
- reflow preview
- user approval
- receipt ledger
- undo/correction where safe

### 4. Over-retention of proof or receipts

Risk: proof/receipt history contains more private detail than user expects.

Mitigation:

- privacy level per receipt/proof
- redacted projections
- deletion/correction controls where safe
- export claims only when verified

### 5. Notification leakage

Risk: lock screen reveals private step, goal, or closure.

Mitigation:

- sensitive notification projection
- generic labels
- user preview before enabling
- protected/away notification rules

### 6. Calendar-derived overreach

Risk: Ambitions infers too much from calendar, work, school, or away time.

Mitigation:

- source labels
- calendar-derived context clearly marked
- no automatic memory from one calendar event
- user approval for patterns

### 7. Screenshot/demo misrepresentation

Risk: marketing assets show private data, fake data behavior, or unimplemented privacy controls.

Mitigation:

- screenshot readiness spec
- canonical demo fixture
- no fake shipped capability
- privacy-safe fixtures

---

## Privacy States

Objects may project as:

- standard
- private
- sensitive summary
- hidden outside app
- local only
- unavailable
- needs review

---

## External Surface Policy

Widgets, Live Activities, Siri, notifications, and App Intents must use privacy-safe projection.

Private/sensitive object projection examples:

- Private step
- Private item
- Open Ambitions
- Details hidden here

---

## Memory Policy

Memory requires source, freshness, affected behavior, and user controls.

Sensitive memory requires explicit approval.

Deletion is a hard stop for that memory.

---

## Acceptance Criteria

A feature passes privacy review when:

- sensitive data classes are identified
- compact/external projection is safe
- memory use is visible and controllable
- meaningful changes create receipts
- calendar-derived facts are labeled
- privacy controls are not paywalled
- screenshot/demo states avoid private real data
- release claims match implementation evidence

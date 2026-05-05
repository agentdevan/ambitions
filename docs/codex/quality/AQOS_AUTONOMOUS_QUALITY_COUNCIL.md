# AQOS Autonomous Quality Council
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS review board protocol.
Date: 2026-05-05

## Purpose

The Autonomous Quality Council is the final adversarial review layer for major batches, repairs, and handoffs. It prevents one-dimensional success where engineering passes but product, visual, privacy, accessibility, performance, or founder vision fails.

## Required Council Roles

For each major batch closeout or AQOS-triggered repair, Codex must review as:

1. Founder Vision Guardian
2. Chief Product Reviewer
3. Apple Design Award Visual Reviewer
4. Staff iOS Architect
5. Senior SwiftUI Composition Reviewer
6. Accessibility Lead
7. Privacy / Security Reviewer
8. Performance / Battery Reviewer
9. QA / Test Lead
10. App Store / Claim Truth Reviewer
11. Legal Boundary Reviewer
12. FAANG Handoff Auditor

## Required Output Per Role

Each role must answer:

- Pass / Yellow / Red
- strongest concern
- evidence reviewed
- missing evidence
- required repair if any
- whether batch can continue

## Founder Vision Guardian Standard

Must verify:

- `Find your life. Keep your promises. Build your future. Enjoy today.` remains true.
- app does not drift into generic productivity, dashboard, habit tracker, AI chatbot, notes app, project-management, or calendar clone.
- Found Life remains life continuity under calm daily clarity.

## Apple Design Award Visual Reviewer Standard

Must verify:

- rendered output exists where UI changed;
- visual quality is native, premium, restrained, proprietary, and not prototype-like;
- one primary object dominates each top-level surface;
- no dashboard/card-stack drift.

## Staff iOS Architect Standard

Must verify:

- ownership boundaries;
- file-size health;
- no view logic bloat;
- no duplicate models;
- no generic helper/manager sprawl;
- testability and maintainability.

## Accessibility Lead Standard

Must verify:

- VoiceOver order;
- Dynamic Type;
- Reduce Motion;
- non-color meaning;
- touch targets;
- private content in labels.

## Privacy / Security Reviewer Standard

Must verify:

- sensitive Found Life content redaction;
- no leaks to external surfaces/logs/previews;
- source/freshness/privacy boundaries;
- no secrets;
- no unsupported privacy/security claims.

## Performance / Battery Reviewer Standard

Must verify:

- no unbounded animations/rendering/background work;
- performance/battery budget where needed;
- low-power/degraded behavior where needed.

## App Store / Claim Truth Reviewer Standard

Must verify:

- no App Store/TestFlight/release/accessibility/legal/privacy compliance claim without evidence;
- claim-truth boundary is explicit.

## Council Hard Red

If any role finds Hard Red, the batch cannot close Green.

Hard Red examples:

- unresolved sensitive data leak
- unproven data-loss risk
- prototype-level top-level visual output after repair
- inaccessible primary action
- unsupported public claim
- architecture drift requiring broad unplanned refactor
- hidden mutation or fake recommendation certainty
- evidence falsified or omitted

## Council Closeout

Every major report should include a council table:

| Role | Result | Strongest concern | Evidence reviewed | Required repair |
|---|---|---|---|---|

If omitted, the batch is at most Structural Green with AQOS Yellow.

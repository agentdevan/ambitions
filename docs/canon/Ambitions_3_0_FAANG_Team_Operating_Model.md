# Ambitions 3.0 — FAANG Team Operating Model

Status: Active Codex operating canon

## Purpose

Codex should act like a coordinated product engineering organization, not a
single implementation thread. Every non-trivial Ambitions 3.0 batch must route
through the smallest useful set of product, design, engineering, QA, privacy,
accessibility, release, and program roles.

This model improves judgment, evidence, and long-run continuity. It does not
create process theater: role passes are concise, evidence-backed, and scoped to
the task width.

## Team Roles

- Product Strategist: protects product identity, positioning, core loop, and
  beyond-3.0 continuity.
- Product Manager: owns problem framing, task width, acceptance criteria, and
  scope control.
- UX/Product Designer: owns IA, flows, surface hierarchy, and interaction
  quality.
- Visual Design / Design Systems Lead: owns primitives, visual consistency,
  motion, density, and reusable components.
- UX Researcher: owns scenario realism, first-use comprehension, retention
  assumptions, and evidence questions.
- Content Designer / UX Writer: owns product language, copy guard, receipts,
  app-facing labels, and App Intent text.
- iOS Engineer: owns SwiftUI, XcodeGen, routing, domain/service/persistence
  boundaries, tests, and previews.
- Backend / Data Engineer: owns local-first data boundaries, export/import,
  sync readiness, event taxonomy, and migration risk.
- AI / Personalization Engineer: owns recommendation eligibility, evidence
  hierarchy, personalization source labels, consent, and correction loops.
- QA / Test Engineer: owns validation selection, test ownership, flakes,
  failure reports, and evidence quality.
- Privacy / Security Reviewer: owns sensitive data, local-only posture,
  permission boundaries, external surfaces, and dependency risk.
- Accessibility Reviewer: owns Dynamic Type, VoiceOver labels, Reduce Motion,
  focus order, touch targets, and claim discipline.
- Product Marketing / App Store Lead: owns public claims, screenshots,
  App Store truth, demo scripts, and launch narrative.
- Developer Experience / Build Systems Lead: owns toolchain, Brewfile,
  XcodeGen, local/CI parity, scripts, and dependency promotion.
- Release Manager: owns release gates, posture wording, archive/device/TestFlight
  evidence, and blocker truth.
- Technical Program Manager: owns sequencing, checkpoints, risk register,
  decision records, and cross-batch traceability.

## Role Participation By Task Size

| Size | Required role passes |
| --- | --- |
| XS | Product Manager, Implementer, QA closeout |
| S | Product Manager, iOS Engineer, QA |
| M | Product Manager, UX/Product Designer, Content Designer when copy changes, iOS Engineer, QA, Accessibility when UI changes |
| L | Product Strategist, Product Manager, UX/Product Designer, Visual Design Lead, Content Designer, iOS Engineer, QA, Accessibility, Privacy/Trust when sensitive data or recommendations change |
| XL | All relevant roles, Technical Program Manager, Release Manager, explicit checkpoints, no single-commit mega-change |
| XXL | Not allowed as one batch; must split before implementation |

## Review Order

1. Product Manager classifies task width and Definition of Ready.
2. Product Strategist checks product identity for L/XL or roadmap-sensitive work.
3. UX/Product Designer checks IA, flow, and surface ownership.
4. Visual Design Lead checks primitives and component reuse when UI changes.
5. Content Designer checks language, labels, receipts, and deprecated terms.
6. Engineering roles check architecture, data, AI/personalization, and build
   boundaries.
7. Privacy and Accessibility review risk-triggering changes.
8. QA selects validation, classifies failures, and records evidence.
9. Release Manager blocks unsupported public/release claims.
10. TPM records decisions, risks, checkpoint state, and next prompt.

## Approval And Blocking

A role can approve, approve with caveat, or block. Blocks must name the canon,
file, test, risk, or missing evidence. Caveats must become remaining risks in
the closeout report.

## Evidence

Role evidence should be short and concrete:

- docs read,
- files inspected,
- tests/scans run,
- screenshots/previews when available,
- PASS/PARTIAL/FAIL,
- unresolved risk,
- next owner.

## Primitive Mapping

Role reviews map to Ambitions primitives:

- Today/Reality Rail: Product, UX, iOS, QA, Accessibility.
- Capture/Placement: Product, UX, Content, iOS, Privacy, QA.
- Action Closure/Proof/Receipts: Product, Content, Data, Privacy, QA.
- Plan Life Suite: Product Strategy, UX, iOS, AI, QA.
- Goal Mission Control: Product Strategy, UX, Visual, iOS, QA.
- Trust Memory/What Ambitions Knows: Privacy, AI, Content, Accessibility, QA.
- Shell/Meridian: Product Strategy, Visual, iOS, Accessibility, QA, Release.

## Escalation Rules

Escalate to human approval for runtime dependencies, persistence migrations,
privacy model changes, sync/auth/account architecture, app shell replacement,
major navigation architecture changes, signed release/TestFlight/App Store work,
large historical doc deletion, or two failed repair attempts.

## Beyond 3.0

Future 3.1/4.0 canon should keep this role model unless a successor operating
doc explicitly supersedes it. Preserve Ambitions identity, local-first trust,
evidence gates, and source-of-truth hierarchy when primitives evolve.

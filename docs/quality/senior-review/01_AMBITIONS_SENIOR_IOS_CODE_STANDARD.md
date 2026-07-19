# Ambitions Senior iOS Code Standard

Status: Active SCG review authority  
Scope: Senior-code expectations for Ambitions source, review, proof, and closeout  
Issue: AMB-1284 / SCG-001  

This standard defines what senior-quality Ambitions implementation must prove before later SCG repair trains may claim Green. It does not prove that the current app meets the standard.

## 1. Product Law Preservation

Every code change must preserve the active Ambitions product law:

```text
Persistent surfaces: Today / Goals / Time / You
Global composer: Capture
Behavior layer: Motion
Trust layer: Proof / Source / Privacy / History / Receipts
```

Senior code never reintroduces Motion as a root destination, Capture as a tab, generic dashboard anatomy, chatbot-first architecture, cloud-LLM core behavior, or account-required offline core value.

## 2. Canonical Ownership

New implementation must use the Final Architecture Tree in `docs/truth/PRODUCT_DESIGN_TRUTH.md` as binding ownership:

- `App/` owns launch, environment, dependencies, and feature flags.
- `Stage/` owns shell, route, overlays, safe areas, chrome, focus, effects, transitions, and `Stage/Motion/`.
- `Core/` owns domain, clock, runtime, persistence, permissions, and local privacy boundaries.
- `Projection/` owns runtime-to-surface translation, commands, mutations, receipts, and undo.
- `Language/` owns copy policy, vocabulary, forbidden terms, and copy budgets.
- `Trust/` owns Proof, Source, Privacy, History, Receipts, and disclosure behavior.
- `Interaction/` owns gestures, keyboard, direct manipulation, and haptics.
- `Rendering/` owns canvas renderers and semantic mirrors.
- `DesignSystem/` owns tokens, primitives, product objects, and accessibility policies.
- `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, and `Surfaces/You` own root product surfaces.
- `Composer/Capture/` owns Capture.
- `Scenarios/`, `Diagnostics/`, and `Quality/` own their named concerns.

`Features/` is compatibility debt, not a canonical owner for new Ambitions architecture.

## 3. Runtime Integrity

Senior code must turn user action into real state changes where the scope includes mutation. A visible button, route, or control is unacceptable unless it has one of these states:

- real mutation with receipt or proof where required
- real navigation to a working detail or correction surface
- honest unavailable state with reason and next proof requirement
- explicit disabled state with accessible explanation

Dead controls, fake success, non-mutating primary actions, silent failure, and placeholder routing are Red.

## 4. Local-First Boundary

Core personal life data remains local by default. Senior code must not send goals, captures, calendar context, schedule assumptions, closure history, receipts, proof, personalization, behavior patterns, inferred priorities, profile data, or private user context to R2, hosted AI services, analytics, or a personal backend.

Network behavior is allowed only where scoped by active truth for public/reference freshness, optional account identity, entitlement, support, or future approved capabilities.

## 5. Native iPhone Quality

Senior SwiftUI implementation must be native, inspectable, accessible, and resilient:

- clear ownership between Stage chrome, root product objects, overlays, and drilldowns
- safe-area correctness across root, overlay, and drilldown states
- Dynamic Type behavior that does not clip critical text or hide controls
- VoiceOver labels, values, traits, order, actions, and state updates
- Reduce Motion and Reduce Transparency fallbacks
- High Contrast and legibility support
- tap targets that remain usable on iPhone
- no duplicate shell/chrome ownership
- no explanatory paragraph replacing the primary product object

Visual Green and Release Green require independent proof. Codex may prepare evidence but may not self-certify those statuses.

## 6. Test And Proof Standard

Senior code must ship with validation proportional to risk:

- source/architecture changes: owner proof, focused tests, and no forbidden path drift
- runtime mutation changes: before/action/after tests and receipt or proof assertions
- UI changes: rendered hierarchy or screenshot proof plus accessibility notes
- persistence changes: migration/default-value/data-safety proof
- privacy/account/R2 changes: request-shape and no-private-life-graph proof
- release-facing changes: proof per `docs/truth/RELEASE_TRUTH.md`

Source string scans may support Source Green. They cannot establish Runtime Green, Interaction Green, Visual Green, or Release Green by themselves.

## 7. Senior Review Decision

Every reviewed file must receive one of these decisions:

- `accept`: meets the relevant standard with current proof
- `accept-with-followup`: acceptable for the current bounded issue, with named Yellow debt
- `request-changes`: blocks the issue until repaired
- `escalate`: needs owner decision, architecture reset, or product truth update

Every decision must cite evidence, risk, owner, required proof, and whether the issue can close.

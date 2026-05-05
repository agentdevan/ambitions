# Ambitions StoreKit / Monetization Strategy
<!-- markdownlint-disable MD013 -->

Status: Active PFC21 monetization strategy; accepted Yellow for future pricing
Date: 2026-05-05

## Purpose

This strategy defines Ambitions launch monetization posture, StoreKit boundary,
free tier, paid-value direction, entitlement rules, paywall rules, trial/offer
posture, restoration requirements, App Review posture, and future decision gates.

It does not implement StoreKit, products, entitlements, paywalls, purchase
flows, receipt validation, server verification, pricing, App Store Connect
setup, subscription metadata, external purchase links, legal claims, or release
readiness.

## Current Repo Reality

Current source contains no active StoreKit runtime, StoreKit product catalog,
purchase flow, paywall UI, entitlement model, subscription validation, receipt
validation, server-side verification, or App Store Connect setup evidence.

Current launch-canon posture says:

- free at launch;
- no paid upfront app at launch;
- no subscription at launch;
- no launch in-app purchase at launch;
- future monetization is deferred and out of launch scope.

Current monetization canon also says future monetization may be acceptable when
it reinforces trust, improves execution, keeps a useful free tier, avoids ads,
and never locks trust/privacy/data controls.

## PFC21 Decision

PFC21 decision:

- Launch default: no StoreKit implementation.
- Launch default: no subscription, in-app purchase, paid upfront app, ad model,
  or paywall.
- Future monetization: allowed only after an explicit business/legal/platform
  decision batch.
- PFC22 StoreKit implementation: blocked/deferred until exact product,
  entitlement, pricing, App Store Connect, restoration, testing, and legal
  prerequisites exist.
- PFC23 paywall review: blocked/deferred until a paywall or upgrade surface is
  explicitly approved.

PFC21 closes accepted Yellow because exact future free-tier limits, product
ids, price points, subscription tiers, family/student/household plans,
trial/offer rules, and external purchase/link posture remain unresolved business
and legal decisions.

## Free Tier Boundary

The free tier must be useful.

Launch free tier must allow:

- creating and organizing at least one meaningful goal;
- using Today / Goals / Capture / Plan / You as the core loop;
- basic Capture, planning, execution, closure/recovery, and proof saving where
  implemented;
- trust, privacy, delete-memory, data-access, export/import basics where
  implemented;
- viewing what Ambitions knows where implemented;
- using the app without account creation unless later source truth changes
  account posture.

Free tier must not:

- feel fake or unusable;
- hide core trust/privacy/data controls;
- create shame or pressure to upgrade;
- block access to user-owned data;
- degrade recovery when the user is already under pressure.

## Future Paid Value Direction

Future paid value may come from:

- deeper planning;
- richer reviews;
- memory/personalization depth;
- advanced external-surface continuity;
- premium execution support that demonstrably improves follow-through.

Future paid value must not come from:

- ads;
- locked data;
- trust/privacy/data controls;
- delete/export controls;
- shame or pressure;
- artificial friction;
- fake scarcity;
- basic recovery;
- basic product dignity.

## Entitlement Rules

No entitlement model is approved for implementation by PFC21.

Future entitlements must:

- be local-first where possible;
- be clearly named;
- be testable without production purchases;
- fail safely;
- restore reliably;
- preserve access to user-owned data;
- never gate privacy, trust, delete, or export fundamentals.

Future entitlements must not:

- hide data behind a pay state;
- silently change app behavior after purchase expiration;
- make recovery, proof, or trust controls hostile to free users;
- require server/account infrastructure unless separately approved and legally
  reviewed.

## Paywall Rules

No paywall is approved for launch.

Any future paywall must:

- be clear and accessible;
- state price, duration, renewal, cancellation, and restore affordances;
- avoid urgency pressure;
- preserve free-tier dignity;
- explain value without claiming guaranteed outcomes;
- include restore and manage-subscription paths where applicable;
- pass App Review-safe copy review and accessibility review.

Any future paywall must not:

- appear during recovery pressure;
- block privacy, trust, delete, or data access;
- create artificial waiting or friction;
- imply Ambitions will make life decisions for the user;
- use manipulative urgency or guilt.

## Trials / Offers / Win-Back

No trial, offer, or win-back rule is approved for implementation by PFC21.

Future offers require:

- explicit business decision;
- App Review-safe presentation;
- clear cancellation and renewal language;
- no pressure during vulnerable moments;
- no private-data leverage;
- focused tests and accessibility proof.

## External Purchase / Link Posture

No external purchase or external link posture is approved by PFC21.

Future external purchase/link behavior requires jurisdiction-aware legal review,
App Review review, product copy review, and explicit user approval before any
implementation.

## Privacy / Trust Boundary

Required:

- trust, privacy, data controls, delete-memory, and basic data access are not
  paywalled;
- purchase state must not be used to infer sensitive life context;
- analytics/telemetry cannot be added by monetization without separate privacy
  review;
- purchase and entitlement logs must not expose private goal/capture/memory
  details;
- claims stay tied to implemented behavior and evidence.

## Accessibility Boundary

Future monetization surfaces must prove:

- VoiceOver order;
- Dynamic Type layout;
- readable price and renewal terms;
- non-color meaning for selected/current/unavailable states;
- plain cancellation/restore paths;
- no motion-only meaning.

## Required PFC22/PFC23 Proof Before Implementation Claim

PFC22 or any later StoreKit implementation batch must produce:

- exact product ids;
- entitlement model;
- StoreKit 2 purchase, verification, expiration, restore, refund/revocation,
  family sharing decision, and failure-state tests;
- sandbox/local StoreKit configuration proof;
- no data-lock proof;
- no trust/privacy paywall proof;
- App Store Connect and legal/human prerequisites if needed.

PFC23 or any later paywall batch must produce:

- paywall copy review;
- accessibility proof;
- free-tier dignity proof;
- App Review-safe terms/renewal/cancellation/restore copy;
- screenshot/rendered proof if a visible paywall exists;
- human legal/business approval for pricing and claims.

## Launch Decision

Safe launch decision:

- no StoreKit;
- no subscription;
- no in-app purchase;
- no paywall;
- no ads;
- no external purchase link.

Future monetization remains possible, but it is explicitly decision-gated. If
exact business/legal/platform decisions are not available, the safe decision is
to keep Ambitions free and defer monetization implementation.

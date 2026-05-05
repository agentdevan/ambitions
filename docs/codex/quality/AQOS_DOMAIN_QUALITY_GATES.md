# AQOS Domain Quality Gates
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS domain-gate source truth.
Date: 2026-05-05

## Purpose

AQOS domain gates prevent hidden misses outside visual design. They extend the FVQ principle across the entire app.

## AXQ — Accessibility Execution Quality

Required when UI, controls, copy, motion, or external surfaces change.

Must prove:

- VoiceOver order follows visual hierarchy.
- Dynamic Type does not break layout or truncate critical meaning.
- Reduce Motion preserves meaning.
- Non-color cues exist.
- Tap targets are appropriate.
- Accessibility labels do not expose private data.
- Internal component names do not leak into accessibility copy.

Hard Red:

- critical action inaccessible;
- sensitive data in accessibility label;
- Dynamic Type makes primary object unusable;
- motion-only meaning.

## PVQ — Privacy Exposure Quality

Required when sensitive Found Life, memory, receipt, commitment, external surface, logging, analytics, storage, or sharing behavior changes.

Must prove no sensitive data leaks through:

- widgets
- Live Activities
- notifications
- App Intents
- Spotlight
- logs
- screenshots
- previews
- shared storage
- analytics
- debug overlays

Hard Red:

- sensitive life data exposed by default externally;
- hidden inference stored or surfaced as fact;
- privacy claim without evidence;
- user deletion/correction boundary weakened.

## DIQ — Data Integrity Quality

Required for persistence/schema/sync/import/export/delete/storage changes.

Must prove:

- migration/backward compatibility;
- deletion path;
- export/import where applicable;
- corruption recovery posture;
- backup/restore posture;
- stale data handling;
- conflict/tombstone/offline behavior where applicable.

Hard Red:

- unproven data-loss risk;
- destructive migration;
- stale data presented as current;
- cloud/sync claim without implementation proof.

## PERQ — Performance / Battery Quality

Required for visual effects, Canvas/Metal, large lists, background work, widgets, Live Activities, sync, or heavy rendering.

Must prove:

- launch impact bounded;
- render cost bounded;
- memory impact bounded;
- no unbounded animation loop;
- widget reload budget;
- Live Activity update budget;
- low-power/degraded posture;
- Instruments plan or evidence where relevant.

Hard Red:

- unbounded render/animation/background work;
- battery-heavy visual gimmick;
- performance claim without evidence.

## ARQ — Architecture / Repo Quality

Required for Swift changes, file movement, new primitives, services, repositories, fixtures, and shared code.

Must prove:

- owner module clear;
- no business logic in SwiftUI views;
- no feature UI imported into domain/services;
- no duplicate models;
- no generic manager/helper sprawl;
- file sizes within threshold or extraction plan exists;
- no junk drawer;
- preview fixtures owned and current.

Hard Red:

- architecture boundary break;
- hidden broad refactor;
- test deletion to pass;
- unowned shared abstraction;
- generated sprawl that cannot be repaired in scope.

## UXW — User-Facing Copy Quality

Required for visible strings, accessibility labels, onboarding, recommendations, receipts, trust, privacy, and error states.

Must prove copy is:

- human;
- clear;
- non-shaming;
- non-generic;
- not motivational filler;
- not fake AI confidence;
- not internal component language;
- source/privacy-aware where relevant;
- aligned with Found Life.

Hard Red:

- user-facing internal terms dominate;
- shame copy;
- unsupported recommendation certainty;
- legal/medical/financial/career certainty without source and boundary.

## RIQ — Recommendation / Intelligence Quality

Required for AOS/LDI/recommendation/path/proof/option-value/mutation changes.

Must prove:

- source-grounded why;
- freshness;
- privacy boundary;
- uncertainty/confidence language where needed;
- capacity realism;
- no silent mutation;
- user correction/rejection path;
- option value preserved;
- golden scenario results.

Hard Red:

- fake certainty;
- unsafe professional claim;
- hidden mutation;
- recommendation not grounded in source or capacity.

## ESQ — External Surface Quality

Required for widgets, Live Activities, notifications, App Intents, Spotlight, App Store screenshots.

Must prove:

- rendered evidence;
- privacy-safe default;
- glanceability;
- deep link correctness;
- accessibility;
- no sensitive Found Life exposure;
- no noisy notification pattern;
- no promotional/dark-pattern content.

Hard Red:

- sensitive external exposure;
- hidden mutation through intent;
- misleading widget/live activity state;
- unsupported platform claim.

## MQ — Monetization Quality

Required for StoreKit, entitlements, subscriptions, paywalls, upgrade prompts.

Must prove:

- entitlement state;
- restore path;
- cancellation/support clarity;
- no dark patterns;
- no paywall blocking expected free/core trust controls;
- App Review-safe copy.

Hard Red:

- deceptive paywall;
- broken restore;
- misleading subscription claim;
- dark pattern.

## RQ — Release / App Store / Claim Truth Quality

Required for release, App Store, TestFlight, privacy labels, manifests, legal/privacy copy, public claims.

Must prove:

- claim-truth packet;
- no self-certification;
- required-reason API review;
- privacy label source;
- screenshot truth;
- release note truth;
- human/legal/device proof boundaries.

Hard Red:

- unsupported legal/privacy/security/accessibility/App Store claim;
- physical-device claim without device proof;
- public compliance claim without human proof.

## HQ — Handoff Quality

Required for final handoff and major train closeouts.

Must prove:

- architecture map;
- ownership map;
- setup instructions;
- evidence ledger;
- unresolved Yellow list;
- no chat-history dependency;
- no prompt-built residue;
- senior team can reason about repo.

Hard Red:

- handoff relies on conversation memory;
- repo cannot be understood;
- unresolved hard quality issue hidden.

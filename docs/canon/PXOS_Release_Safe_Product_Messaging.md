# Release Safe Product Messaging
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS messaging must pass REC and release-claim boundaries before it appears in docs, prompts, handoff packets, product messaging, App Store-adjacent copy, demo scripts, or future implementation claims.

PXOS may describe future canon, future train readiness, and product direction. It must not describe future canon as shipped product behavior. Any product-facing statement must separate:

- current app evidence;
- future canon;
- queued or blocked work;
- Codex-validated proof;
- human/operator proof still required;
- claims that are blocked until external platform verification exists.

## Messaging Truth Law

Every release-adjacent or product-positioning statement must answer:

- What is proven in the repo?
- What is only future canon?
- What proof source supports the claim?
- What human or external proof is still missing?
- Which claim boundary blocks stronger language?
- What must Codex do if the claim depends on unavailable proof?

If a claim cannot answer those questions, it is not release-safe.

## Allowed Claims

These claims are allowed when linked to the matching repo evidence:

| Claim family | Allowed wording | Required evidence | Notes |
| --- | --- | --- | --- |
| Product identity | Ambitions is a native iOS life execution system. | README, active 3.0/4.0 canon | Do not call it a generic task app, chatbot, habit tracker, calendar clone, or project-management app. |
| Core loop | Ambitions helps raw intent become placed structure, plans, daily action, closure/recovery, and proof. | README and 3.0 canon | Does not imply all future PXOS/PD/AOS behavior is implemented. |
| 3.0 status | Ambitions 3.0 is complete by F30 closeout evidence. | F30 closeout docs and registry | This is status truth, not App Store readiness. |
| 4.0 status | Ambitions 4.0 is the active post-3.0 execution program. | 4.0 execution docs | Must say it is not a shipped product version. |
| PXOS status | PXOS is future user-facing product experience canon. | PX01-PX17 evidence after commit | Must not say PXOS is implemented. |
| AmbitionsOS status | AmbitionsOS is future internal intelligence/runtime canon. | AmbitionsOS index | Must not say AmbitionsOS is active app behavior. |
| Release evidence | REC02-REC06 define evidence, guardrails, and handoff boundaries. | REC reports | Must not convert REC evidence docs into human/platform proof. |

## Blocked Claims

Codex must not make or strengthen these claims without matching evidence:

- App Store ready;
- TestFlight ready;
- production ready;
- release ready;
- physical-device passed;
- signed archive distribution proof complete;
- App Store Connect validation passed;
- public accessibility conformance verified;
- external platform rendering verified;
- legal/privacy signoff complete;
- final release decision approved;
- PXOS implemented;
- AmbitionsOS implemented;
- Product Depth implemented;
- model runtime active;
- hosted AI or backend intelligence exists;
- cloud sync or account sync exists;
- calendar/reminder integration production-verified;
- widgets, Live Activities, App Intents, or shortcuts production-verified unless the named platform proof exists.

## Human-Proof Dependent Claims

These claims require Codex to stop and produce an operator checklist instead of continuing:

- physical-device behavior;
- signed archive distribution;
- TestFlight upload, install, or review;
- App Store Connect validation;
- public accessibility conformance;
- external platform rendering;
- legal/privacy approval;
- product-owner screenshot or visual approval when explicitly required;
- final release decision.

Human approval to continue Ambitions 4.0 batches does not satisfy proof for any of the above.

## Messaging Categories

### Current Product Truth

Use for repo-proven, current behavior. Wording should be concrete and evidence-tied.

Example:

```text
Ambitions is a native iOS SwiftUI app and premium life execution system.
```

### Future Canon

Use for PXOS, AmbitionsOS, Product Depth, and queued train direction that is documented but not implemented.

Example:

```text
PXOS defines future user-facing experience canon. It is not current app implementation truth.
```

### Evidence Boundary

Use when release, platform, accessibility, or manual proof is missing.

Example:

```text
Manual platform and human review remain required before stronger release claims.
```

### Forbidden Upgrade

Do not rewrite a future-canon statement into a current readiness claim.

Forbidden example:

```text
PXOS is ready for production release.
```

## Product Messaging Copy Rules

Allowed product language:

- organized life execution;
- concrete steps;
- Start here;
- What needs a place?;
- Does this hold together?;
- Close the loop;
- Still Counts;
- Proof saved;
- You are in control;
- future canon;
- queued/blocked;
- human proof required;
- evidence boundary.

Avoid or block:

- AI wrapper;
- chatbot-first;
- productivity score;
- generic task app;
- release-ready;
- production-ready;
- App Store ready;
- TestFlight ready;
- fully automated;
- model-powered unless implementation evidence exists;
- platform integrated unless platform proof exists.

## Scan Requirements

Release-safe messaging work must scan for:

- `App Store ready`;
- `TestFlight ready`;
- `production ready`;
- `release ready`;
- `physical device passed`;
- `PXOS implemented`;
- `AmbitionsOS implemented`;
- `Product Depth implemented`;
- `AI implemented`;
- `hosted AI`;
- `backend intelligence`;
- `cloud sync`;
- `platform integrated`;
- `public accessibility conformant`.

Matches are acceptable only when they are:

- explicit blocked-claim examples;
- must-not-claim guardrails;
- historical evidence boundaries;
- scan commands;
- human-proof stop rules.

Any positive, unsupported claim is Red.

## Handoff Rule

Any future handoff, roadmap, demo, release packet, marketing draft, or App Store-adjacent copy must include:

- current evidence source;
- future-canon boundary if applicable;
- unverified proof list;
- human/operator proof checklist when relevant;
- no stronger claim than REC evidence supports.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.

## PX17 Evidence Status

PX17 may claim this future-canon release-safe messaging system is documented after its batch evidence is committed. It may not claim release readiness, platform readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, signed archive proof, final release approval, PXOS implementation, AmbitionsOS implementation, Product Depth implementation, or app behavior changes.

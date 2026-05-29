# PXEQ Product Experience Equivalence Gate

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, terminology-quarantine
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active mandatory Ambitions 4.0 / External Brain UI gate; not implementation evidence.
Date: 2026-05-03

## Purpose

PXEQ prevents Ambitions from becoming merely architecturally complete. A UI batch
must also feel production-quality: simple, minimal, conservative, futuristic,
beautiful, living, changing, evolving, and usable.

## Required Principles

1. Simple is not empty.
2. Minimal is not underpowered.
3. Futuristic is not decorative noise.
4. Living visuals communicate state, not just animation.
5. Every animated or evolving module has a reason.
6. Every major visual state supports Reduce Motion.
7. Every surface preserves Dynamic Type, VoiceOver, tap target, contrast, and
   non-color meaning.
8. Glass, blur, translucency, gradients, starfields, and atmospheric materials
   never reduce readability.
9. The app feels native iPhone-first, not SaaS, web, admin, CRM, or surface.
10. Today / Goals / Capture / Plan / You each have one primary visual object or
    system, not stacks of generic cards.
11. External Brain surfaces context through receipts, sources, confidence, and
    user control.
12. Memory UI feels calm and inspectable, not creepy or omniscient.
13. Capture remains composer-first and low-friction.
14. Plan is believable and time-aware, not a generic calendar clone.
15. Goals visually evolve through proof, lanes, momentum, next steps, and
    blockers.
16. You is a personal system center, not a settings dump.
17. Recovery states feel calm, human, and non-shaming.
18. Every UI batch produces preview evidence or explains why no UI changed.
19. Every major UI batch includes before/after product experience impact.
20. Any technically passing batch that fails product experience is Yellow or Red.

## Mandatory Gate

PXEQ is mandatory before any EB UI implementation batch can pass Green. UI-heavy
EB batches include EB03-EB06, EB14-EB18, EB20-EB24, EB26-EB30, EB33-EB34,
EB35, EB38, and any later repair stage that touches UI, previews, fixtures,
copy, motion, visual systems, settings, trust surfaces, memory surfaces, search,
recall, onboarding, capture review, receipts, or accessibility settings.

## Green Yellow Red

Green: surface owner is named, primary visual object is clear, living behavior
has state inputs, motion has meaning and Reduce Motion fallback, preview or
fixture evidence exists, accessibility evidence exists, and anti-generic scans
are reviewed.

Yellow: UI did not change but PXEQ evidence is referenced; minor polish or
human visual review remains deferred; advisory scan hits are classified.

Red: static documentation-driven UI, generic productivity layout, surface
sprawl, heavy settings dump, lifeless cards, noisy AI module, overbuilt memory
UI, cluttered capture inbox, unreadable glass, motion without meaning, or beauty
that harms usability.

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

# Search Find / Ask / Act / Inspect implementation report

Status: shadow candidate; reviewed and covering-test Green for the exact recorded scope

Base SHA: `e52a14c6b249b540345848afb8a4b399c7b8c198`

Authority state: unchanged; `docs/canon` remains non-authoritative pending the approved cutover sequence

Prepared: 2026-07-17

## Outcome

This candidate records the owner-approved Global Search law as one unified,
local-first Find / Ask / Act / Inspect surface while preserving the active
product and implementation claim ceiling:

- Find is immediate, deterministic, privacy-authorized, and offline-capable.
- Ask is optional, on-device, grounded, source-linked, inspectable, and
  unavailable without degrading deterministic Search.
- Act proposes only. Material changes remain owned by the relevant canonical
  owner and retain validation, preview, confirmation, History, Receipt, and
  Undo obligations.
- Inspect keeps Source, Privacy, History, Proof, and Receipts in context.
- Creation intent hands off to Capture; Search does not become a parallel
  composer.
- Session history remains ephemeral unless the user explicitly persists an
  item through an identified canonical owner.
- The presentation remains object-led and native rather than a chatbot stream
  or branded AI destination.
- Hosted AI, cloud profiling, and private-life-graph transfer remain excluded.

The active truth amendment does not claim that Ask is implemented in the
production app. All eight Ask/Capture-handoff command contracts remain
`future_gated` by `SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001`.

## R2 visual-authority follow-on

At Search canon commit `295889c9f76528d398fce8d54b155d3285705f29`,
the following states were independently derived, gap-blocked, and
non-authorizing:

- `UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED`
- `UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED`
- `UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED`
- `UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED`
- `UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK`
- `UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF`
- `UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER`
- `UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS`

The additive R2 follow-on now binds those eight states to exact Figma frame
IDs and product-only screenshot digests. They remain `future_gated`, shadow,
non-authoritative, and ineligible for source task-pack selection. The owner
approved freeze `SEARCH-AUTHORITY-R2-2026-07-17T110150Z` and the eight exact
frames as the final Search visual authority at `2026-07-17T11:46:05Z`. The
pre-approval frozen design bundle has a terminal independent 0/0/0 review;
the approval-record delta also completed independent 0/0/0 review with exact
package/base authentication and live read-only Figma verification. Overall
Gate B remains Red/pending, so no source authorization follows. See
`SEARCH_VISUAL_AUTHORITY_R2_REPORT.md` for the exact freeze.

Visual Green remains outside this candidate.

## Review record

The initial consolidated review found four Important and one repair-required
Minor finding. Subsequent exact-range reviews found additional fail-closed
defects in source snapshot freshness, command-gate live identity, descriptor
confinement, multi-output transaction recovery, marker ownership, and test
harness compatibility. The same sole writer repaired each complete docket
through focused RED/GREEN cycles. No production Swift was changed.

Terminal production/canon review:

- Package: `.superpowers/sdd/review-search-safe-delete-terminal-e52a14c6-working-tree.diff`
- SHA-256: `cea8baed3e557592544f97d632e4f4797edea0170b23544df29514a541c6375e`
- Verdict: specification PASS; code/security PASS; Critical 0 / Important 0 /
  Minor 0.

Covering-discovered test-only deltas were independently reviewed without
production changes:

- command-gate dependency harness: package SHA-256
  `15ffc4c4bf8ceda0089165b25fb05bebab8eb68690d6c01f048a41397166d34c`,
  Critical 0 / Important 0 / Minor 0;
- trusted-history harness: package SHA-256
  `62a1204cbf202cbe9c900f8be1942fca3afd451b36ccb5ec8bac614de405bf52`,
  Critical 0 / Important 0 / Minor 0;
- duplicate-command unit harness: package SHA-256
  `944b0c69a372979240e135f05d116eaec7b9e13db5719dfbe18f5bb4fbd259ad`,
  Critical 0 / Important 0 / Minor 0.

## Verification record

Final Python 3.12 covering command included the Search amendment,
consolidated/follow-up security dockets, audit, supersession, atomic semantic
coverage, UX blueprint, visual-authority rebaseline, command resolution,
command-gate dependency/history, and state-command semantics modules.

```text
Ran 188 tests in 431.142s
OK
```

Log:
`.superpowers/sdd/search-find-ask-act-inspect-python312-covering-green.log`

Direct deterministic checks:

```text
GREEN ambitions canon audit documents=62 requirements=473 concepts=473 authority_state=shadow
GREEN ambitions canon ux-blueprint screens=47 state_models=47 state_taxonomy=423 state_variants=441 objects=18 journeys=12 requirements=473 visual=346 nonvisual=127 authority_state=shadow mode=check
GREEN ambitions canon generated outputs
```

The final generated projections were rebuilt once after the reviewed truth and
tool inputs froze. Their focused coherence test passed. This generated-output
Green is not Visual Green or authority selection.

## Canon-amendment commit scope and claim ceiling

- Production Swift changed: no.
- Figma changed: shared approval metadata only on section `375:2805` and the
  eight approved frames; before/after exported PNG bytes are identical.
- Linear changed: no.
- GitHub protection or CI changed: no.
- Task 24/25 authority changed: no.
- Ask activation changed: no.
- Gate B: pending/Red.
- Gate C: not requested/Red.

The candidate may claim only focused Search canon/tooling and deterministic
projection Green for the exact reviewed and tested scope. It may not claim
production Ask, rendered-app Visual Green, accessibility Green, runtime Green,
privacy/legal approval, device readiness, TestFlight readiness, App Store
readiness, release Green, or canon Governance Green.

## Architecture closeout

Final Architecture Tree inspected: yes. Canonical production owners touched:
none. Files moved: none. Compatibility shims: none. No equivalent-folder
interpretation was used.

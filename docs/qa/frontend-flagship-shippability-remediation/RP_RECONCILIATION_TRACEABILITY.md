# RP-01–RP-08 Reconciliation Traceability

Status: Current authority map
Date: 2026-07-22
Evidence remains in `docs/audits/rp-01-08-evidence-audit/`; this map does not rewrite it.

## Authority graph

```text
current source and tests (implementation evidence)
        + Constitution and normative specifications (product law)
        + owner reconciliation (D-DEV-01..10 product choices)
        v
accepted reconciliation ADRs (architecture/runtime decisions)
        v
canonical UX Blueprint requirements (design input, not proof)
        v
reconciled flagship reconstruction plan (sequencing)
        v
proof gates (future evidence)
        v
provisional visual directions (no Figma/SwiftUI authorization)
```

When implementation and accepted future canon differ, source remains evidence
of current capability while canon/owner/ADR define the planned target. Neither
side may be silently described as the other.

## Traceability matrix

| RP finding | Owner decision | Architecture decision | UX Blueprint requirement | Runtime contract | Reconstruction milestone | Proof gate | Direction |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RP-01 bottom rail conflicts with edge dock | D-DEV-01 | Shell ADR: one owner and dock posture machine | Shell crown/dock/root/global overlay contract | Shell state and selected-root depth | R3 | State machine plus physical gesture proof | `AVF-SHELL-S07-R01` |
| RP-01 inactive paths drive chrome | D-DEV-01 | Four root-local paths; selected-root depth only | Root switching preserves independent depth | Versioned restoration/path store | R3 | Four-root path matrix | `AVF-SHELL-S07-R01` |
| RP-01 exact return unsupported | D-DEV-01 | Durable/in-session/best-effort tiers | Truthful fallback and focus return | Restoration record and stale validation | R3 | Migration/interruption/stale-target tests | `AVF-SHELL-S07-R01` |
| RP-02 no stored Life Area identity | D-DEV-02 | Identity ADR: `LifeAreaRecord` target | Editable Life Area index to Goal depth | Idempotent identity migration | R2/R5 | Migration/reference/history parity | `AVF-GOALS-S08-R00` |
| RP-02 Today projection linkage incomplete | D-DEV-04 | Typed `TodayAdmission`; no duplicate object | Start Here plus max one Also Fits Now | Projection lineage and expiry | R5 | Owner/ID/recalculation tests | `AVF-TODAY-S10-R00` |
| RP-02 Event/Placement identity absent | D-DEV-05 | Event/series/occurrence and Placement target models | Time labels accepted/proposed/external/stale | Source reconciliation and placement owner | R2/R5 | Import, recurrence, authority-state tests | `AVF-TIME-S07-R01` |
| RP-03 mutation paths bypass registry | D-DEV-07 | Truth/mutation ADR lifecycle | Preview/commit/settlement remain distinct | Registry closure and owner commit | R4 | Mutation inventory/replay/failure tests | `AVF-RECOVERY-S07-R01` |
| RP-03 Receipts not universal | D-DEV-07 | Receipt threshold and retention contract | Show Receipt only for covered operation | Durable linked Receipt registry | R4 | Receipt linkage/outcome/retention tests | `AVF-RECOVERY-S07-R01` |
| RP-03 no typed partial settlement | D-DEV-07 | Atomic outcome unless scope threshold met | No Settlement Ledger without typed scopes | Per-scope identity/owner/outcome required | R4/R8 | Independent-scope replay/retry tests | `AVF-RECOVERY-S07-R01` |
| RP-03 Undo only bounded | D-DEV-07 | Typed inverse/compensation only | Hide Undo unless executable and eligible | Expected revision, expiry, result | R4 | Actual inverse and external-limit tests | `AVF-RECOVERY-S07-R01` |
| RP-04 Goals root mismatch | D-DEV-02 | Life Area/Goal/Path ownership | Life Area → Goal → inline lens → timeline | Goal owner retains mutation/history | R5 | Dense, projection, handoff journeys | `AVF-GOALS-S08-R00` |
| RP-04 three Today priorities unsupported | D-DEV-03/04 | One Start Here plus optional earned second | Start Here hierarchy; Today not a task list | Admission eligibility and owner actions | R5 | Quiet/stale/conflict/handoff journeys | `AVF-TODAY-S10-R00` |
| RP-04 computed timing appears accepted | D-DEV-05 | Placement truth-state model | Explicit temporal language | Accepted/proposed/external/stale states | R2/R5 | Projection and mutation authority tests | `AVF-TIME-S07-R01` |
| RP-05 Capture is bounded | Owner Capture revision | Global authority ADR Capture baseline | Text-first interpretation/correction/handoff | Destination capability registry | R6 | Ambiguity, owner acceptance, return | `AVF-CAPTURE-S07-R01` |
| RP-05 Search cannot Act safely | D-DEV-06 | Owner-transfer envelope | Find, grounded Understand, owner-routed Act | Owner revalidation/commit/settlement | R6 | Failure/provenance/transfer tests | `AVF-SEARCH-D07-R01` |
| RP-05 Search failures collapse to empty | D-DEV-06 | Nine-state Search failure taxonomy | Distinct empty/failure/stale/coverage states | Typed repository/index outcomes | R6 | Injected read/index/permission failures | `AVF-SEARCH-D07-R01` |
| RP-06 You overstates accounts/capabilities | D-DEV-09 | Local/no-account and nine-group boundary | Remove unsupported rows, not disable them | Supported commands/permissions only | R7 | Route/row absence and capability tests | `AVF-YOU-D07-R02` |
| RP-06 accent mismatch | D-DEV-08 | Violet-indigo migration contract | System/Light/Dark plus approved accents | Deterministic preference migration | R7 | Contrast, migration, fallback tests | `AVF-YOU-D07-R02` |
| RP-07 no generic durable queue | D-DEV-07 | Domain pending threshold; no generic queue | No “finish later” without durable data | Owner/id/retry/cancel/publication contract | R8 | Interruption/relaunch/idempotency tests | `AVF-RECOVERY-S07-R01` |
| RP-07 conflict states incomplete | D-DEV-07 | Conflict taxonomy and presentation thresholds | Seam only for modeled conflict | Claim IDs, owner, review route | R4/R8 | Each accepted conflict family | `AVF-RECOVERY-S07-R01` |
| RP-08 policy exists but direct proof absent | D-DEV-10 | Accessibility/platform ADR | Semantic continuity requirements | Focus/announcement/localization owners | R9 | Automated plus physical-device matrix | `AVF-A11Y-S07-R00` |
| RP-08 broad platform implications unsupported | D-DEV-10 | iPhone portrait single-scene; external surfaces separate | No out-of-scope platform presentation | Per-target adapters only | R9 | Direct target/device proof | `AVF-COHERENCE-S07-R00` |

## Architecture-to-visual matrix

| Direction | Required architecture | Present capability claim |
| --- | --- | --- |
| `AVF-DNA-S07-R00` | Semantic token/material behavior subject to accessibility | Provisional direction only |
| `AVF-COHERENCE-S07-R00` | One identity/owner across native projections | Provisional direction only |
| `AVF-A11Y-S07-R00` | Focus, announcements, RTL, localization, device proof | Requirement, not completion |
| `AVF-GOALS-S08-R00` | Life Area record, Goal/Path/Step identity and projection | Branch authorized; not implemented |
| `AVF-TODAY-S10-R00` | Today admission, eligibility, owner handoff | Branch authorized; not implemented |
| `AVF-SHELL-S07-R01` | Shell owner, four paths, dock machine, restoration | Revision authorized; not implemented |
| `AVF-CAPTURE-S07-R01` | Bounded draft/extraction and owner transfer | Revision authorized; audited baseline remains bounded |
| `AVF-TIME-S07-R01` | Event/Placement identity and truth states | Revision authorized; target capability incomplete |
| `AVF-SEARCH-D07-R01` | Typed results/failures and owner transfer | Revision authorized; Act not current mutation capability |
| `AVF-YOU-D07-R02` | Local capability inventory and accent migration | Revision authorized; migration not implemented |
| `AVF-RECOVERY-S07-R01` | Typed runtime state, Receipt/Undo/pending gates | Revision authorized; coverage is operation-specific |

## Unresolved decisions

No owner choice from D-DEV-01 through D-DEV-10 is open. No new product-level
decision was introduced.

The following implementation-detail decisions remain deliberately deferred to
their named authority and do not change product meaning:

| ID | Question and recommendation | Alternative and consequence | Authority | Blocks |
| --- | --- | --- | --- | --- |
| R-ARCH-01 | Select the concrete native root-selection container after a prototype proves Back, focus, safe area, and dock gesture boundaries; recommend one native selection owner with custom dock rendering. | A wholly custom root stack increases restoration/accessibility risk. | Architecture | R3 implementation entry |
| R-ARCH-02 | Select schema encodings for the accepted identity models; recommend opaque UUIDs plus explicit source keys/version lineage. | Natural/composite canonical IDs make migration and source change brittle. | Architecture | R2 implementation entry |
| R-RUNTIME-01 | Approve individual bounded outboxes only when a domain needs accepted offline external work; recommend none by default. | A generic queue widens semantics and privacy risk. | Runtime | Pending UI in that domain |
| R-RUNTIME-02 | Set operation-specific Receipt retention/Undo expiry from privacy and external constraints; recommend registry-owned values. | One global duration overstates uniform reversibility. | Runtime/privacy | R4 registry closure |
| R-UX-01 | Specify exact localized copy and state layout within locked hierarchy; recommend object-first, consequence-explicit language. | Denser status-first copy weakens protected hierarchy. | UX Blueprint | Visual closure studies |
| R-RECON-01 | Choose bounded cutover slices only after schemas/tests exist; recommend identity before projections and shell before visual cutover. | Surface-first cutover creates adapters/duplicate owners. | Reconstruction planning | Implementation packets |
| R-A11Y-01 | Assign actual shortcut combinations after system/localization collision testing; recommend platform conventions. | Custom chords harm discoverability and conflict risk. | Accessibility/platform | Keyboard implementation |

## Authorization state

- Figma authorization: false
- SwiftUI approval: false
- Implementation authorization: false

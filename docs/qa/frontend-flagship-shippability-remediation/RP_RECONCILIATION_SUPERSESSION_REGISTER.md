<!-- markdownlint-disable MD013 -->

# RP Reconciliation Supersession and Unsupported-Capability Register

Status: Current authority classification
Date: 2026-07-22

## Classification vocabulary

- **Current authority**: controls current product, architecture, contract, or plan.
- **Superseded**: replaced for future control; retained as historical evidence.
- **Historical**: records prior work or proof ceiling; not current authority.
- **Generated**: compiler-owned projection; never hand-edited.
- **Planned**: accepted target contract without implementation proof.
- **Provisional**: owner-authorized visual direction without Figma/SwiftUI authority.
- **Implementation evidence**: describes current source/runtime/test behavior only.

## Authority register

| Record | Classification | Treatment |
| --- | --- | --- |
| `docs/canon/CONSTITUTION.md` and normative specifications | Current authority | Product law, reconciled by this change where required. |
| `docs/audits/rp-01-08-evidence-audit/00-audit-manifest.md` through `12-*` | Historical evidence | Preserve findings, baseline, contradictions, and proof ceiling intact. |
| `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md` | Current owner authority | Controls D-DEV-01 through D-DEV-10. |
| Four 2026-07-22 reconciliation ADRs | Current architecture/runtime authority | Target contracts; no implementation claim. |
| `docs/canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md` and JSON peer | Current visual-closure input authority | Sole active VC-01–VC-14 baseline; authorization flags remain false. |
| `docs/canon/design/VC_WAVE_1_FOUNDATION_CLOSURE.md` and JSON peer | Current Wave 1 closure authority | VC-01 through VC-06 are closed beneath the unchanged active AVF set; exact calibration and implementation remain deferred. |
| `docs/canon/migration/UX_BLUEPRINT.md` and JSON peer | Current shadow design input | Reconciled overlay controls current UX direction; legacy inventory remains traceable. |
| `docs/canon/generated/*`, including `visual-authority-manifest.json` | Generated | Regenerate through canon compiler; never hand-edit. |
| This register, reconciliation traceability, and reconstruction plan | Current planning authority | Sequencing and authority cleanup only. |
| Current Swift source/tests | Implementation evidence | Establish current capability, not visual approval or future product authority. |

## Superseded or historical control

| Record or clause | Status | Replaced by | Preservation rule |
| --- | --- | --- | --- |
| Bottom-navigation future canon in prior shell requirement/ledger | Superseded | D-DEV-01, shell ADR, `AVF-SHELL-S07-R01` | Current rail remains implementation evidence until parity/cutover. |
| Goals constellation/atlas and old Goal-led root hierarchy | Superseded | D-DEV-02, `AVF-GOALS-S08-R00` | Keep campaign and prior screenshots historical. |
| Three equal Today priorities and prior first-viewport variants | Superseded | D-DEV-03/04, `AVF-TODAY-S10-R00` | Keep campaigns historical. |
| `AVF-GOALS-S07-R01` as root structure | Historical | `AVF-GOALS-S08-R00` | Lens principles survive inside Life Area/Goal depth. |
| `AVF-TODAY-S09-R00` as first viewport | Historical | `AVF-TODAY-S10-R00` | Contextual execution survives under Start Here. |
| Old approved VSP/Figma package statements for reconciled surfaces | Superseded as current selection | Owner reconciliation and current provisional directions | Stable IDs remain provenance only; no Figma authorization. |
| `OWNER_REJECTION_REBASELINE.md` shell/Goals/Today visual prescriptions that conflict with D-DEV-01..03 | Historical owner evidence | File 13 controlling owner reconciliation | Non-conflicting evidence remains useful. |
| Active P0 implementation queue in `EXECUTION_LEDGER.md` | Superseded/frozen | Reconciled reconstruction plan | Historical packet logs and proof remain intact. |
| Audit unresolved D-DEV-01..10 rows | Superseded only as unresolved status | File 13 resolutions | Original question/evidence remains intact. |
| Account/cloud-continuity You screens as current flagship baseline | Superseded | D-DEV-09 and `AVF-YOU-D07-R02` | Future concept records do not authorize active rows. |
| iPad/Mac/visionOS/landscape/multiwindow flagship implications | Superseded for current scope | D-DEV-10 | Cross-device principles remain future-only. |
| New York or other serif as interface type | Superseded | VC input typography contract | Historical specimens remain provenance only; San Francisco is the sole active family. |
| OLED Dark as an approved appearance | Superseded | System/Light/Dark baseline | Historical tokens and frames remain non-authoritative. |
| Atmosphere families, photo-derived atmosphere, and sensory/text-comfort modes | Superseded as active controls | D-DEV-09 and VC input appearance boundary | May remain historical evidence; not disabled or selectable rows. |
| Exact Revision 1 Figma collections, variables, component APIs, and token values | Implementation detail not authorized | VC input exact-token boundary | May be evaluated during closure but cannot be treated as active authority. |
| Legacy accent families | Deferred candidates requiring owner review | Restrained violet-indigo default plus VC-02 review | No candidate is active merely because historical exact values exist. |
| Bottom-rail geometry and legacy Today rail/root anatomy | Superseded | Crowned Edge Dock plus `AVF-TODAY-S10-R00` | Historical frame geometry remains evidence only. |
| Serif, New York, editorial-hero, custom-tracking, and uppercase-state typography proposals | Superseded as active foundation | VC-01 Semantic Cadence | Preserve specimens as historical evidence; San Francisco alone is active. |
| Purely flat D01 or strongly sculpted D04 calibration | Superseded as active foundation | VC-02 Mineral Relief Continuum | Preserve both studies as synthesis provenance; neither exact calibration becomes a token set. |
| Hero/content-card crowns, metric/status crowns, and duplicate floating crowns | Superseded as active foundation | VC-03 Compact Semantic Stack plus Adaptive Semantic Passage | Preserve old studies as evidence only. |
| Symbol-only expanded rail, permanent drawer/sidebar, detached controls, and bottom-tab fallback | Superseded as active foundation | VC-04 Articulated Edge Tray plus Adaptive Navigation Passage | Current runtime rail remains implementation evidence, not target visual authority. |
| Detached status pills, universal spinner/Undo, toast cascade, celebration, warning-card grids, and simulated pending | Superseded as active foundation | VC-05 Semantic State Covenant plus Explicit Stress Scaffold | Historical treatments cannot imply runtime capability. |
| Universal rounded containers/radius, routine elevation, decorative motion/haptics, and root-assigned colors | Superseded as active foundation | VC-06 Articulated Native Grammar with Native Minimal Substrate and Explicit Accessible Structure | Preserve provenance; exact calibration stays deferred. |

## Unsupported current capability

The following must be absent from current-functionality claims until the named
runtime proof exists:

| Capability | Required before presentation | Current treatment |
| --- | --- | --- |
| Crowned Edge Dock | Shell owner, posture machine, native boundary, device proof | Planned/provisional target only |
| Durable exact restoration | Versioned record, migration, stale resolution, focus proof | Tiered claim only |
| Editable Life Areas | Stable record and idempotent migration | Planned; do not simulate from enum |
| Canonical Event/series/occurrence | Identity, source reconciliation, edit commands | Planned |
| Accepted Schedule Placement | Stable relation and authority state | Planned; computed timing is proposed |
| Multi-scope Settlement Ledger | Typed independent scopes and replay/retry proof | Absent |
| Universal Receipt | Registry-covered durable operation | Capability-gated |
| Universal Undo | Executable inverse/compensation | Capability-gated |
| Generic durable queue/later notification | Domain outbox and publication proof | Absent |
| Dictation/broad Capture attachments/arbitrary semantics | Adapter capability and privacy/failure proof | Absent |
| Search domain mutation | Owner transfer and owner revalidation | Search remains non-owner |
| Account/sign-in/devices/subscription/cloud continuity | New product/architecture approval | Removed from flagship baseline |
| Broad permissions/data export/delete/reset | Shipping owner commands and destructive proof | Removed from baseline |
| Density/typography/material/cross-device appearance | Separate approved capability | Removed from baseline |
| Localization completion | Catalogs, tests, direct proof | Planned infrastructure |
| Accessibility completion | Automated and direct device proof | Requirement only |
| Spotlight | Separate authorization and implementation proof | Planned only |
| Out-of-scope platforms | New owner/platform decision | Excluded |

## Later deletion candidates

No deletion is authorized now. After replacement parity, reconstruction must
evaluate duplicate shell/path owners, enum Life Area authority, observation-as-
placement aliases, duplicate Search projections, fictional You rows/routes,
synthetic Receipt/Undo labels, stale architecture checkers, and superseded
frontend/visual control documents. Audit evidence and owner records are never
deleted merely to make current authority appear conflict-free.

## Wave status

- Wave 1 shared visual foundation: `CLOSED`.
- Wave 2 surfaces and journeys: `OPEN`.
- Wave 3 stress and matched baseline: `OPEN`.
- `VC-14`: `NOT_STARTED` and not complete.

Wave 1 closure is not a final design system or component library. Exact type,
color, material, divider, radius, shadow, geometry, motion, haptic, Figma, and
component-token choices remain deferred rather than silently promoted from the
historical Revision 1 corpus.

## Duplicate-authority rule

When a stale document or live source conflicts with current owner/canon/ADR
target, annotate its status and link the current owner; do not rewrite evidence.
When two live mutation stores or projection writers exist, implementation entry
is blocked until one canonical owner and a migration/cutover plan are named.

## Authorization state

- Figma authorization: false
- SwiftUI approval: false
- Implementation authorization: false

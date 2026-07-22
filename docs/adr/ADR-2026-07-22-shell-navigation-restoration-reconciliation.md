# ADR-2026-07-22: Shell, Navigation, and Restoration Reconciliation

Status: Accepted
Date: 2026-07-22
Audit: `docs/audits/rp-01-08-evidence-audit/01-rp-01-shell-navigation-restoration.md`
Owner decision: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`
Direction: `AVF-SHELL-S07-R01`, with `AVF-CAPTURE-S07-R01` and `AVF-SEARCH-D07-R01`

## Decision

Ambitions will have one shell state owner. It owns selection and presentation,
not canonical product data. Its state is the tuple:

```text
ShellState
├── selectedRoot: Today | Goals | Time | You
├── rootPaths: Root -> ordered RouteToken[]
├── rootSelections: Root -> CanonicalObjectReference?
├── globalPresentation: none | SearchSession | CaptureSession
├── crown: CrownContext
├── dock: DockPosture
├── editingPresentation: EditingPresentation?
├── restoration: RestorationRecord
├── focusReturn: AccessibilityFocusTarget?
└── externalOrigin: ExternalEntryOrigin?
```

Every depth calculation uses `rootPaths[selectedRoot]`. An inactive root path
never drives active-root chrome, crown, dock posture, Back, or focus. Search and
Capture are full-screen, temporary, global presentations and never roots.

The Crowned Edge Dock remains the target shell. This ADR authorizes its
architecture and reconstruction planning only; it does not authorize a UI
implementation.

## Root and path ownership

| Concern | Canonical owner | Durable | Rule |
| --- | --- | --- | --- |
| Root set and order | Constitution | Yes | Today, Goals, Time, You only. |
| Selected root | Shell | Yes | One selected root. |
| Root-local ordered path | Navigation, one path per root | Yes | Paths are independent and selected-root-aware. |
| Root-local selected object | Owning surface, referenced by shell | When canonical identity is durable | Shell stores only an ID and revision hint. |
| Route destination behavior | Destination owner | No | Navigation cannot become a mutation owner. |
| Search presentation | Shell plus Search session | In session | Full-screen non-root presentation. |
| Capture presentation | Shell plus Capture session | In session; draft durability is capability-gated | Full-screen non-root presentation. |
| Crown context | Shell from selected owner context | No | Root supplies root context; focused object supplies object context. |
| Dock posture | Shell | No | Derived from selected-root depth, environment, and explicit interaction. |
| Editing presentation | Owning surface | In session unless the owner defines a durable draft | The shell coordinates containment only. |
| External entry origin | App entry adapter plus shell | Yes when needed for return | Minimum identifiers only. |

## Native and Ambitions ownership

| Behavior | Framework-owned | Ambitions-owned |
| --- | --- | --- |
| Root selection semantics | Accessibility activation, focus mechanics, trait propagation | Four-root selection state, ordering, labels, dock rendering, restoration |
| Navigation stacks | Native stack mechanics, transition coordination, interactive Back gesture | Typed routes, one root-local path per root, eligibility, fallback |
| Back | System Back affordance and edge gesture | Parent route, dismissal policy, stale-parent fallback |
| Titles and toolbars | Native placement, Dynamic Type, localization, safe-area behavior | Semantic crown content and owner-supplied actions |
| Crown | Native text/control semantics | Context selection, reading order, conflict/recovery interruption |
| Dock | Gesture and accessibility primitives | Posture state machine, root/global grouping, visibility, mirroring |
| Safe areas | System insets and keyboard geometry | Content and dock avoidance policy; no control may obscure content |
| Focus | Accessibility focus engine and keyboard focus system | Stable focus IDs, requested return target, truthful fallback |
| Keyboard | System presentation and dismissal | Keyboard-aware dock posture and unobscured active field |
| Sheets and covers | Native presentation lifecycle | Typed presentation owner, origin, cancellation, return target |
| Global overlays | Native containment primitives | At most one shell-owned global presentation |
| Deep links and external entry | System delivery | Parse, authenticate, resolve, route, record origin, reject safely |

“Native-compatible” means the framework retains Back, interactive edge-swipe,
focus, safe-area, text-scaling, and presentation mechanics. It does not mean a
custom dock may infer or replace those mechanics.

## Dock posture state machine

The shell owns a base posture and applies environment adaptations. Accessibility
equivalents are not separate product states.

```text
                  root selected / eligible
Hidden ------------------------------------------> Peek
  ^                                                   |
  | drilldown, global presentation,                   | deliberate expand,
  | unsafe gesture/keyboard conflict                  | focus, accessibility action
  |                                                   v
  +----------------------------------------------- Expanded
                                      root chosen / dismiss / inactivity
```

| Posture | Entry | Exit | Focus and semantics | Restoration |
| --- | --- | --- | --- | --- |
| Hidden | Drilldown, full-screen global presentation, unsafe gesture competition, or owner-required immersive depth | Return to eligible root depth | Roots remain available through native accessibility and keyboard commands only when this does not conflict with the presentation | Recomputed, never durably restored as a visual posture |
| Peek | Eligible root depth at rest | Expand, hide, or environmental adaptation | One labelled “Open navigation” control plus selected-root value | Default derived posture |
| Expanded | Explicit expansion, dock focus, or equivalent command | Root choice, dismiss, depth change, inactivity | One navigation group containing four labelled roots plus separate Search and Capture group | Recomputed from restored route |
| Labelled equivalent | VoiceOver, Voice Control, Switch Control, Full Keyboard Access, or comprehension mode requires labels | Environment changes | All controls have unique names, selection traits, actions, and predictable order | Environment-derived |
| Opaque equivalent | Reduce Transparency or insufficient contrast | Environment changes | Same hierarchy and actions, opaque backing | Environment-derived |
| Mirrored left-hand equivalent | Explicit supported handedness preference | Preference changes | Geometry mirrors; semantic root order and labels remain stable | Preference-owned when implemented |
| RTL equivalent | Right-to-left locale | Locale changes | Directional geometry mirrors; chronological and semantic meaning follows locale rules | Locale-derived |
| Keyboard-aware equivalent | Dock would overlap the keyboard or active field | Keyboard dismisses or focus moves | Collapse, relocate, or hide; Search/Capture remain reachable through commands | In-session only |
| Lower-reach equivalent | Supported reachability mode or environment requires it | Mode changes | Same commands and semantic grouping in a reachable envelope | Environment-derived |

## Gesture arbitration

1. The system Back edge owns the leading-edge interactive region. The dock may
   not begin a gesture there, including after RTL or handedness mirroring.
2. A dock gesture begins only inside its visible hit region and after the
   movement satisfies the dock recognizer’s direction and distance threshold.
3. Vertical scroll owns primarily vertical movement that began in content.
4. A focused text field and keyboard dismissal gesture outrank dock expansion.
5. VoiceOver, Switch Control, Voice Control, and Full Keyboard Access activate
   named actions; they never require a drag, edge discovery, hover, or posture.
6. Back while Expanded collapses the dock before changing route only when no
   modal or drilldown owns Back; otherwise the framework-owned presentation or
   navigation stack handles Back.
7. Failed arbitration leaves route, canonical data, and focus unchanged.

## Crown contract

The shell renders one semantic crown. At root depth the selected root owns the
title and root actions. At object depth the canonical object owner supplies the
object title, state, and actions. Editing, conflict, or recovery may temporarily
replace normal actions only through the presentation owner. The crown precedes
content in reading order, never hides framework Back, never overlaps a focused
field, and uses localized semantic text at all Dynamic Type sizes.

## Versioned restoration record

```json
{
  "schemaVersion": 1,
  "selectedRoot": "today",
  "rootPaths": {
    "today": [],
    "goals": [],
    "time": [],
    "you": []
  },
  "focusedObject": null,
  "globalOrigin": null,
  "pendingOperationID": null,
  "savedAt": "RFC3339 timestamp"
}
```

The persisted form uses typed route tokens containing owner, route kind,
minimum canonical object ID, and optional expected revision. It must not store
private display titles or content.

| Tier | Fields | Guarantee |
| --- | --- | --- |
| Durable required | Selected root; four root-local paths; focused canonical object where valid; active global presentation origin; pending authoritative operation ID where that operation is durable | Versioned, migrated, validated before use |
| In session | Active Search query; active Capture expression; surface-owned local selection | Retained only for the live session unless an owning contract separately makes it durable |
| Best effort | Scroll position; text cursor; field focus; keyboard visibility; animation state; pixel position | Never promised across relaunch |

### Stale-target recovery

Restoration resolves from deepest to shallowest:

1. validate record version and selected root;
2. validate each route owner and authorization;
3. resolve each canonical object and expected revision;
4. truncate at the first invalid path component;
5. restore the deepest truthful surviving owning context;
6. if no depth survives, restore the selected root; if it is unavailable,
   restore Today;
7. announce what could not be restored and expose only a real repair action.

Restoration never guesses a replacement object, resurrects deleted data,
replays a mutation, or claims cursor/keyboard/pixel continuity.

## Global presentation, deep link, and external entry

A global presentation record contains presentation kind, session ID, origin
root/path/object/focus, optional external origin, and cancellation target.
Search and Capture preserve this origin without acquiring ownership of the
origin object. Dismissal returns to the deepest still-valid origin and otherwise
uses the stale-target algorithm.

External entry follows:

```text
system delivery -> adapter parse -> privacy/authentication gate
-> canonical ID resolution -> owner route -> shell presentation
-> action or inspection -> truthful return/fallback
```

Malformed, unauthorized, unsupported, stale, or missing targets fail closed and
do not reveal private fallback content. External entry cannot bypass preview,
confirmation, owner commit, Receipt, or Undo eligibility.

## Accessibility focus ownership

The shell owns cross-presentation focus return; each surface owns focus within
its content; mutation owners own outcome announcements. The origin stores a
stable semantic focus ID, never a view instance. On return, focus resolves to:

1. the same valid semantic object/control;
2. the owning object’s primary control;
3. the selected root’s primary object;
4. the selected root heading.

The shell announces root changes, global presentation entry/exit, restoration
fallback, and system-wide unsafe states. It does not announce domain mutation
results on an owner’s behalf.

## Required runtime and reconstruction work

- Introduce a single shell model and four independent typed root paths.
- Remove the aggregate inactive-root depth calculation.
- Add versioned route and restoration serialization with migration tests.
- Add stable semantic focus IDs and cross-presentation focus return.
- Add one global presentation slot and origin envelope.
- Prove gesture arbitration, safe areas, keyboard behavior, RTL, handedness,
  and assistive equivalents before dock cutover.
- Retain the current rail only as implementation evidence until parity proof;
  delete duplicate shell authority only after cutover proof.

## Alternatives rejected

- Bottom tabs as the future visual authority: rejected by `D-DEV-01`.
- One shared path for all roots: rejected because it corrupts ownership and
  selected-root depth.
- Persisting exact pixels, keyboard state, or cursor as durable meaning:
  rejected because the audit found no guarantee and stale layouts make it
  unsafe.
- Search or Capture as roots: prohibited by the Constitution and owner record.

## Proof gates

Source and compiler validation are necessary but insufficient. Entry to visual
closure requires unit proof for the state machine and restoration migration,
integration proof for root paths and global origins, accessibility proof for
focus and labelled equivalents, simulator proof for keyboard/safe areas/RTL,
and physical-device proof for Back-edge and dock gesture arbitration.

## Non-claims

No shell, dock, navigation, restoration, focus, or product runtime behavior was
implemented by this decision. Figma authorization, SwiftUI approval, and
implementation authorization remain false.

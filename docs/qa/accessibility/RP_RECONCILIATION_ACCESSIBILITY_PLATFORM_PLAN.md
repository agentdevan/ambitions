# RP Reconciliation Accessibility, Localization, and Platform Proof Plan

Status: Current planning authority; implementation not authorized
Date: 2026-07-22
Architecture: `docs/adr/ADR-2026-07-22-local-first-recovery-accessibility-platform.md`
Traceability: RP-08, `AVF-A11Y-S07-R00`, `AVF-SHELL-S07-R01`, `AVF-COHERENCE-S07-R00`

## Scope and proof ceiling

The flagship scope is iPhone, portrait, single scene, on iOS 26 or the
repository-approved successor floor. This plan turns Adaptive Semantic
Continuity into executable gates; it is not evidence that any gate currently
passes.

## Focus and announcement contract

- Shell/navigation owns stable semantic focus IDs across root switches,
  Search/Capture presentation, dismissal, and stale-route fallback.
- Each root owns reading order and focus movement inside its content.
- The canonical mutation owner announces accepted/rejected outcome,
  consequence, Receipt availability, recovery, and proven Undo.
- Recovery announcements name the affected object/scope and available action;
  they do not repeat private content unnecessarily.
- Sensitive titles, notes, proof, and calendar details obey the presenting
  privacy classification when spoken or shown on a locked device.
- Dynamic insertions do not steal focus unless required to complete the invoked
  action. On removal, focus moves to the next truthful sibling, owner heading,
  or origin fallback.
- The dock is one labelled navigation group. Search and Capture are a separate
  global-actions group. Hidden/Peek/Expanded geometry never changes available
  semantic commands.
- Keyboard order follows semantic reading order. Root switches and Search/
  Capture have documented shortcuts only after collision review.

## Automated and direct proof matrix

| Capability | Source proof | Unit/integration proof | Simulator proof | Physical/manual proof | Release gate |
| --- | --- | --- | --- | --- | --- |
| Dynamic Type through largest accessibility size | Semantic fonts; no fixed-height semantic content | Layout/state matrix and truncation assertions | Every root/global flow at default and AX sizes | Oldest/smallest supported iPhone, portrait | No hidden identity, consequence, or action |
| VoiceOver | Labels, values, hints, actions, grouping | Accessibility tree and focus-target tests | Reading order, announcements, modal containment | Rotor, focus return, dock/global journeys | All critical journeys complete eyes-free |
| Voice Control | Unique visible names and aliases | Duplicate-name scan | Command activation | Ambiguous-name and correction pass | Every primary action named uniquely |
| Switch Control | All controls exposed and ordered | Focus graph reachability | Auto-scan traversal | Manual full critical journey | No gesture-only dead end |
| Full Keyboard Access | Focusable controls and commands | Traversal/shortcut conflict tests | Tab/arrow/escape/command paths | Hardware keyboard pass | Every critical journey completes |
| Pointer/hover | Optional enhancements only | No hover-only action audit | Pointer inspection where supported | Manual if device supports it | No product meaning depends on hover |
| Reduce Motion | Semantic transition alternatives | Preference/state tests | Root, dock, Search/Capture, settlement | Motion discomfort review | No state loss when motion removed |
| Reduce Transparency | Opaque semantic alternatives | Token/state tests | Crown/dock/overlay contrast | Device appearance review | All content/actions meet contrast |
| Increased Contrast | Semantic colors/materials | Contrast-token audit | Light/dark and selected states | Device review | Identity and state separation pass |
| Differentiate Without Color | Shape/label/value semantics | Non-color state audit | Monochrome/grayscale inspection | Manual task completion | No state communicated only by color |
| Bold Text/Button Shapes | Native semantics and adaptable layout | Trait/layout tests | Root and drilldown matrices | Manual pass | Controls remain identifiable/readable |
| Reach/handedness | Equivalent dock postures | State-machine tests | Left/right/lower reach layouts | One-handed device journeys | No required unreachable control |
| RTL | Direction-neutral layout and symbols | Locale/snapshot assertions | Pseudolocale root/global journeys | Native RTL language manual pass | Back, chronology, dock, and focus correct |
| Long localization | Catalog keys and formatters | Pseudolocalization/plural tests | 30–50% expansion screenshots | Translator/manual inspection | No semantic truncation or overlap |
| Sensitive locked-device behavior | Privacy classifications | Redaction tests | Notification/widget/live surface states | Locked physical device | No sensitive disclosure |
| Widget | Minimized projection source | Timeline/action routing tests | Widget families supported by target | Physical device, stale/offline/locked | Direct target proof required |
| Live Activity | Activity state/privacy policy | Update/end/stale tests | Supported presentations | Physical device and lock screen | Direct lifecycle proof required |
| Notification | Category/action policy | Payload/redaction/routing tests | Foreground/background states | Locked/unlocked device | Permission, action, privacy proof |
| App Intent/Siri/Shortcuts | Typed intent and owner handoff | Parameter/error/result tests | Shortcuts/Siri runs | Device privacy and cancellation | No bypass of owner confirmation |
| Share extension | Minimized handoff draft | Serialization/failure tests | Extension launch/cancel | Device share sheet | No canonical mutation in extension |
| Spotlight | Planned only | None until separately authorized | None | None | Must remain absent |

Screenshot proof supports geometry and copy only. It cannot prove focus,
speech, gesture, keyboard, mutation, restoration, privacy, or release behavior.

## Localization delivery plan

1. Inventory every user-facing literal by owning module and classify current,
   debug/fixture, historical, or unreachable.
2. Establish String Catalog ownership and key naming without changing product
   wording during extraction.
3. Replace concatenation with typed format strings and plural variants.
4. Route dates, times, durations, units, relative language, and calendars
   through locale-aware formatters.
5. Audit directional glyphs and leading/trailing assumptions.
6. Add pseudolocalization, RTL, plural, long-text, and non-Gregorian inspection
   lanes where the platform capability is supported.
7. Obtain direct translator/manual evidence before release claims.

## Shell-specific acceptance

- The semantic crown is read once, before root content, with Back first at
  drilldown depth when framework conventions require it.
- Peek exposes a labelled “Open navigation” action and selected-root value.
- Expanded dock exposes four roots with selected state, then a separately
  labelled Search/Capture group.
- VoiceOver, Voice Control, Switch Control, and Full Keyboard Access never need
  an edge drag to reach a root or global action.
- Keyboard presentation cannot cover the active field or required dismissal.
- RTL/handedness mirroring cannot invade the framework Back edge.
- Minimum interaction envelopes follow the native platform standard and are
  verified on device, not inferred from source constants.

## Release acceptance gates

Release evidence must link a build/commit, OS/device matrix, test output,
manual operator and date, failures/waivers, and privacy classification. All
critical root, Search, Capture, owner-transfer, mutation, recovery, and
restoration journeys must pass the applicable rows above. Unsupported external
surfaces remain absent rather than waived into scope.

## Non-authorization

This plan authorizes planning and proof design only. It does not authorize
Figma, SwiftUI, accessibility implementation, localization implementation,
platform expansion, or product-code changes.

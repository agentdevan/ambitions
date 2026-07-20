# VSP-05 F Quiet Placement Review Owner Review Package R3

Status: Yellow owner-approved visual/Figma target.

Claim boundary: this packages the owner-approved VSP-05/F Quiet Placement Review visual/Figma target. It is not Visual Green, not source implementation, not live SwiftUI parity, not device proof, not runtime behavior proof, not accessibility conformance, not Release Green, and not Done.

## Figma Frame

- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `217:93`
- Board name: `CANDIDATE - VSP-05 - F Quiet Placement Review owner review package - R3`
- Link: https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=217-93

## Owner Review State

- Direction approval source: owner message in Codex thread, `Owner approved`
- Direction approval date: 2026-06-30
- Selection record: `docs/design/provenance/README.md`
- Package approval source: owner message in Codex thread, `Owner approved`
- Package approval date: 2026-06-30
- Selection record: `docs/design/provenance/README.md`
- Approval scope: visual/Figma target only.

## Child Frames

| Frame | Node |
|---|---|
| `CANDIDATE - VSP-05 - F Quiet Placement Review hero - R3` | `217:207` |
| `CANDIDATE - VSP-05 - F Quiet Placement Review state matrix - R3` | `217:343` |
| `CANDIDATE - VSP-05 - F Quiet Placement Review accessibility matrix - R3` | `217:1049` |
| `CANDIDATE - VSP-05 - F Quiet Placement Review SwiftUI anatomy - R3` | `217:1069` |
| `MARKETING_RENDER - VSP-05 - F Quiet Placement Review presentation crop - R3` | `217:1092` |
| `CANDIDATE - VSP-05 - F Quiet Placement Review non-claims - R3` | `217:1293` |

## Product-Law Review

- VSP-01 shell authority preserved: yes. The package is Capture content/composer authority only and does not add dock, root tab, Context Crown, Search placement, route depth, status bar, or shell chrome.
- Capture preserved as global composer: yes. Capture remains a full-screen/global composer overlay, not a tab, inbox, notes feed, category wall, chatbot, or persistent root destination.
- Motion preserved as behavior: yes. Review, save, invalid fallback, and receipt states are object-state transitions, not a Motion surface.
- Trust preserved as inspection detail: yes. Receipt and proof preview are save/review details, not persistent root surfaces.
- Local-first/R2/private graph boundary preserved: yes. The package introduces no account-gated core, cloud LLM core, R2 private graph storage, Source Atlas private data behavior, or private graph egress.

## Design Finding

VSP-05/F makes Capture a quiet global composer that stays non-mutating until the user reviews placement. The root object is the draft field plus placement review, not a dashboard, chat thread, inbox, category chooser, or floating plus command surface.

The package favors native keyboard-first composition, local draft preservation, explicit route review, invalid-route fallback, receipt preview, and a static proof step before save. This keeps Capture powerful without letting it become a fifth persistent surface.

## State Coverage

- default global composer with unsent draft and local input chips;
- draft retained state;
- ambiguous route state with explicit user choice;
- invalid fallback state rejecting stale root areas such as Habits;
- receipt preview state after review;
- attachment/local intake state;
- share intake state;
- reduced-motion static proof step before save.

## Accessibility And Motion Notes

- Dynamic Type: draft field grows; route rows collapse to one clear choice stack; keyboard remains system-owned.
- VoiceOver: draft, route summary, edit, save, receipt preview, then keyboard. Decorative star field is hidden.
- Reduce Motion: route change appears as static proof step with before/review/after semantics; no glass reflow dependency.
- Reduce Transparency: Liquid Glass resolves to opaque elevated material with visible separators.
- Increase Contrast: route marks use labels plus color; action text weight increases.
- Haptics: visible/static confirmation is primary; haptics reinforce saved, invalid, protected, and unavailable states only after source implementation proves device behavior.

## SwiftUI Plausibility Tags

- `Existing SwiftUI primitive`: `CaptureComposerSurface`.
- `Existing SwiftUI primitive`: `CaptureSurface`.
- `Existing SwiftUI primitive`: `CaptureObjectView`.
- `New SwiftUI primitive required`: keyboard-safe full-screen `CaptureDraftField`.
- `New SwiftUI primitive required`: local placement-review route stack.
- `New SwiftUI primitive required`: receipt preview and static proof step inside Capture.
- Canonical owners: `Native/Ambitions/Composer/Capture`, `Native/Ambitions/Stage/Overlays`, `Sources/Components`.
- Rejected for root: `Native/Ambitions/Surfaces/Capture`, Capture tab, inbox/feed, chatbot core, category wall, persistent floating root affordance, VSP-01 shell mutation.

## Export Note

PNG proof uses readable Inter export text because the current Figma screenshot pipeline resolves SF-family text to zero-width. SwiftUI implementation remains native San Francisco/system-font aligned.

R1 was preserved as failure evidence for collapsed text rendering. R2 was preserved as failure evidence for SF-family text export failure. R3 is the readable owner-review package.

## Durable Proof

- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/manifest.md`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-board.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-hero.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-state-matrix.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-accessibility-matrix.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-swiftui-anatomy.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-marketing-crop.png`
- `docs/qa/evidence/2026-06-30-vsp-05-f-owner-review-package-r3/vsp-05-f-owner-review-package-r3-non-claims.png`

## Required Next Gate

Create a bounded Codex implementation leaf before source work begins. The leaf must include approved frame IDs, source owners, non-goals, required SwiftUI primitives, Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, haptic/static feedback acceptance criteria, validation commands, proof artifacts, and rollback plan.

Even with owner approval, VSP-05 remains Yellow until source, device, runtime, accessibility, and validation proof are separately produced.

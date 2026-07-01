# VSP-06 Preference Weave Final Candidate Package R1

Status: Yellow / Ready For Review

This package turns the owner-approved VSP-06 Part 03 Option C direction into a reviewable final candidate package. It is Figma evidence only. It does not claim SwiftUI implementation, Visual Green, device proof, runtime proof, accessibility conformance, account readiness, R2 readiness, or release readiness.

## Canonical Figma Frames

| Frame | Node | Link |
|---|---:|---|
| Final package board | `240:93` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-93 |
| Hero | `240:103` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-103 |
| State matrix | `240:220` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-220 |
| Accessibility matrix | `240:583` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-583 |
| SwiftUI anatomy | `240:946` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-946 |
| Presentation crop | `240:1110` | https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=240-1110 |

## Durable Screenshots

| Artifact | Path |
|---|---|
| Package board | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-final-package-board-r1.png` |
| Hero | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-hero-r1.png` |
| State matrix | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-state-matrix-r1.png` |
| Accessibility matrix | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-accessibility-matrix-r1.png` |
| SwiftUI anatomy | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-swiftui-anatomy-r1.png` |
| Presentation crop | `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/images/vsp-06-preference-weave-presentation-crop-r1.png` |

## Review Notes

- Source direction: `EXPLORATION - VSP-06 - Option C - Preference Weave - R1`, node `232:248`.
- Owner approval exists for the Option C direction only: `docs/qa/evidence/2026-06-30-vsp-06-part-03-ambitions-owned-you-directions-r1/owner-approval.md`.
- The final package itself still needs explicit owner approval before it can become implementation authority.
- VSP-06 remains content-only inside VSP-01 shell authority.
- No shell chrome, dock, status bar, Capture tab, Motion root, or Trust root surface is introduced.
- The package uses You as a native settings/user system surface with local-first/account/privacy boundaries.
- Offline no-account value is represented as product intent only; runtime proof is still missing.

## Audit Result

- Typography audit: pass for Yellow package review after repair. The first export had meta copy and marketing title/body overlap; those were repaired in Figma before durable screenshots were saved.
- Spatial audit: pass for Yellow package review. No observed critical clipping, dock collision, shell conflict, or marketing overlap in the final exported images.
- Product-law audit: pass for Yellow package review. Today / Goals / Time / You remain the only persistent surfaces; Capture remains global composer; Motion remains behavior; Proof / Source / Privacy / History / Receipts remain inspection details.
- Accessibility / Dynamic Type audit: Figma intent only. The accessibility matrix includes standard, large text stress, and reduced-motion static-equivalent frames. Real VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast proof is still missing.
- SwiftUI plausibility audit: plausible with one new primitive requirement. The package identifies `PreferenceWeaveField` as a new SwiftUI primitive candidate and keeps native settings rows/groups as existing primitive candidates.
- Figma-only / marketing-only effects: restrained atmospheric star grain and glow must be reduced, implemented as static decoration, or tagged marketing-only during SwiftUI implementation.

## Non-Claims

- No source implementation.
- No SwiftUI parity.
- No Visual Green.
- No device proof.
- No accessibility conformance.
- No runtime behavior proof.
- No privacy/account/R2 release proof.
- No Done or complete status.

## Required Follow-Up Before Implementation

1. Owner approves, repairs, or rejects the final package board `240:93`.
2. If approved, create a bounded Codex implementation leaf for `Surfaces/You` only.
3. Implementation leaf must preserve VSP-01 shell authority and keep Capture, Motion, and Trust out of root IA.
4. Implementation leaf must produce focused You tests, live SwiftUI screenshots, accessibility proof, and offline/account boundary proof.

## Closeout

Status: Yellow / Ready For Review
Scope completed: VSP-06 final Figma candidate package built from owner-approved Option C direction and exported to durable proof paths.
Files changed: this manifest, frame index/provenance registries, generated provenance report, durable screenshot images.
Figma frames changed: `240:93`, `240:103`, `240:220`, `240:583`, `240:946`, `240:1110`.
Frame labels: `CANDIDATE`, `MARKETING_RENDER`.
Approved shell authority preserved: yes; VSP-06 remains content-only inside VSP-01 shell.
Design-system primitives used: native settings row/group candidates; new `PreferenceWeaveField` primitive required.
Validation run: see final Codex closeout and generated provenance report after registry update.
Screenshot proof: durable PNGs listed above.
Durable proof location: `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/`.
Typography audit: pass for Yellow package review after repair.
Spatial audit: pass for Yellow package review after repair.
Product-law audit: pass for Yellow package review.
Accessibility / Dynamic Type audit: Figma intent present; source/device/manual proof missing.
SwiftUI plausibility audit: plausible with explicit new primitive and marketing-only effect tags.
Figma-only / marketing-only effects: atmospheric grain/glow only; must not carry meaning.
Failures found: first export had meta hero copy and marketing text overlap; repaired before final screenshots.
Repairs made: product copy rewritten, large-text stress title repaired, marketing title/body spacing repaired.
Remaining risks: final package owner approval missing; SwiftUI parity missing; device/accessibility/runtime/privacy proof missing.
Follow-up required: owner review of `240:93`, then bounded You implementation leaf if approved.
Non-claims: no Visual Green, no source implementation, no device proof, no accessibility conformance, no release/account/R2 readiness.
Rollback plan: remove `docs/qa/evidence/2026-07-01-vsp-06-preference-weave-final-package-r1/` and revert provenance registry entries for node `240:93` if the package is rejected.

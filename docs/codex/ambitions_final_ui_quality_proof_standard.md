> Supporting note: This file supports Ambitions final UI quality proof. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Final UI Quality Proof Standard

Status: Active supporting governance
Scope: Evidence required before Codex may report a final UI-quality Green for reconstructed Ambitions surfaces
Owner posture: Proof standard, not proof by itself

## Purpose

This standard defines the proof packet needed for final UI-quality Green. It is not release proof, device proof, privacy/legal approval, TestFlight readiness, App Store readiness, or product completion.

## Required Evidence Categories

| Category | Required evidence |
|---|---|
| Active IA | Today / Goals / Time / Motion / You confirmed in source, with Capture only as global action/compatibility routing |
| Primary object | Each top-level surface shows one primary object and avoids equal-weight panel piles |
| Runtime path | Source, reason, receipt, proof, recovery, or You inspection path visible where the surface claims intelligence |
| Banned-term scan | Required scan returns no active/runtime UI blockers, or every hit is classified with owner follow-up |
| Screenshot board | Required screenshot paths exist and are current to the audited source/build evidence |
| Accessibility | VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Differentiate Without Color, and tap-target proof is recorded |
| Visual review | Human review or explicit not-provided boundary is recorded without fabricating approval |
| Focused validation | Matching focused tests run when they exist; otherwise not-available reason is exact |
| Claim scan | Unsupported/readiness/release claim scans pass for changed reports/docs |
| Yellow debt | Any remaining non-Red debt has owner issue or `none needed` |

## Green Definition

Final UI-quality Green may be reported only when:

- No Red blockers remain.
- Current active IA source matches truth files.
- Required screenshot artifacts are current to the audited source/build evidence.
- Accessibility proof is sufficient for the scoped UI-quality claim.
- Runtime path proof exists for recommendations, source, receipts, proof, recovery, and local inspection where applicable.
- No top-level generic panel pile remains reachable in the audited surface scope.
- No unsupported release, device, public accessibility, privacy/legal, TestFlight, App Store, CI, performance, or product-completion claims are made.

## Yellow Definition

Final UI-quality Yellow is allowed when the source direction is correct but a non-Red proof item remains incomplete and has an owner-filed follow-up issue.

Examples:

- Manual VoiceOver traversal not yet provided.
- Current screenshot generation blocked by local simulator tooling.
- Human review not provided and not required for the scoped gate.

## Red Definition

Final UI-quality Red is required when:

- Active/runtime banned terms remain unresolved.
- Old IA is active as current product truth.
- Capture is reachable as a top-level tab.
- Top-level root structure remains a generic panel pile in the audited scope.
- Required screenshots are absent and no accepted Yellow path exists.
- Runtime proof is absent.
- Claims exceed evidence.

## Required Final UI Proof Footer

```markdown
Final UI quality verdict: Green / Yellow / Red
Active IA source:
Runtime path proof:
Screenshot board:
Accessibility proof:
Banned-term scan:
Human review:
Focused validation:
Changed files:
Remaining Yellow debt:
Red blockers:
No-claim boundary:
```

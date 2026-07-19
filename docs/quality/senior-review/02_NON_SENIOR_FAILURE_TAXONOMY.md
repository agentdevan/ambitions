# Non-Senior Failure Taxonomy

Status: Active SCG review authority  
Scope: Failure classes for senior-code audit, issue creation, and repair-train routing  
Issue: AMB-1284 / SCG-001  

This taxonomy classifies failures discovered by SCG audits. It does not assert that every class currently exists in the repo.

## Severity

| Severity | Meaning | Closeout impact |
| --- | --- | --- |
| `B0` | Product/release blocker, privacy breach, data-loss risk, crash, or false Green | Stop or mark Red |
| `B1` | High-risk architecture/runtime/accessibility defect | Blocks Green until repaired or owner-accepted Yellow |
| `B2` | Meaningful quality, maintainability, proof, or UX debt | Requires named follow-up and owner |
| `B3` | Localized cleanup or clarity issue | Track if in touched scope |
| `B4` | Advisory observation | Does not block |

## Failure Classes

### `canon-drift`

Implementation, tests, docs, scripts, or closeout wording promote stale product law, including Motion as root, Capture as tab, old Plan/Profile/Captures/Pulse root concepts, generic task app language, dashboard framing, chatbot framing, or AI wrapper framing.

### `wrong-owner`

Code lives under a non-canonical owner when the Final Architecture Tree defines a binding owner. Examples include new product logic under `Features/`, Motion outside `Stage/Motion/`, Capture outside `Composer/Capture/`, or trust behavior outside `Trust/`.

### `fake-runtime`

The UI appears to do work but does not mutate local runtime state, does not navigate, does not produce receipt/proof where required, or creates fake success from fixtures, minimum counts, static placeholders, or non-real Step IDs.

### `dead-control`

A visible control cannot complete its visible promise, has no accessible disabled state, silently fails, or opens a generic placeholder unrelated to its label.

### `proof-gap`

The claim is stronger than the current evidence. Common forms include claiming build/test/device/accessibility/privacy/release readiness without current logs, claiming screenshots prove accessibility, or using old proof as current proof.

### `accessibility-gap`

The implementation lacks or breaks VoiceOver state, Dynamic Type behavior, Reduce Motion fallback, Reduce Transparency fallback, contrast, focus order, semantic mirror, accessible action, or tap target requirements.

### `visual-product-gap`

The rendered surface does not prove the product object. Examples include card stacks, report panels, diagnostic blocks, shell/content overlap, clipped text, duplicate chrome, and generic dashboard anatomy.

### `privacy-boundary-risk`

Private life data can leave the device, account becomes required for offline core value, R2 receives private context, hosted AI becomes core runtime, or personal backend assumptions enter implementation.

### `test-theater`

Tests or scripts check superficial strings, snapshots, or file existence while claiming runtime, accessibility, visual, privacy, or release proof. Tests are changed to hide failures instead of validating behavior.

### `over-broad-slice`

The patch bundles unrelated app behavior, refactors, docs churn, generated artifacts, or future-train work into a bounded issue.

### `maintainability-debt`

The code is difficult to reason about or review because ownership is unclear, functions are overgrown, dependencies are hidden, duplication is meaningful, error handling is absent, or state flow is implicit.

## Finding Minimum Fields

Every SCG finding must record:

- finding ID
- source artifact
- severity
- failure class
- affected file/layer/flow
- evidence
- duplicate or related Linear issue when known
- SCG repair train owner
- required proof
- status

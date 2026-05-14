# Primary Object Anatomy Canon

Status: Active primary-object canon

The five primary objects are:

| Destination | Object | Anatomy Doc | Label-Off Test |
|---|---|---|---|
| Today | Reality Meridian | `REALITY_MERIDIAN_ANATOMY.md` | `LABEL_OFF_SIGNATURE_TESTS.md` |
| Goals | Constellation Atlas | `CONSTELLATION_ATLAS_ANATOMY.md` | `LABEL_OFF_SIGNATURE_TESTS.md` |
| Capture | Atmosphere Composer | `ATMOSPHERE_COMPOSER_ANATOMY.md` | `LABEL_OFF_SIGNATURE_TESTS.md` |
| Time | LifeShape Field | `LIFESHAPE_FIELD_ANATOMY.md` | `LABEL_OFF_SIGNATURE_TESTS.md` |
| You | User System Profile | `USER_SYSTEM_PROFILE_ANATOMY.md` | `LABEL_OFF_SIGNATURE_TESTS.md` |

## Shared Rules

- The object must be recognizable without labels if text is blurred.
- The object must stay recognizably native on iPhone.
- The object must expose source, proof, receipt, and recovery paths where relevant.
- The object must remain accessible under Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, and Differentiate Without Color.
- The object must not collapse into a dashboard, card stack, chatbot, or settings clone.

## Shared Anatomy Diagram

```text
object header
  -> dominant current-state region
  -> object-specific action region
  -> source / proof / receipt seam
  -> correction / recovery path
```

## Shared Contract

- Required zones: header, dominant state, action, trust seam, recovery path.
- Zone order: object first, source second, action third, recovery last.
- Density budget: one dominant object and one dominant decision at rest.
- Collapse behavior: secondary metadata collapses before the dominant object or primary action.
- Allowed information types: state, fit, source, proof, receipt, recovery, correction, and local trust.
- Forbidden information types: score, streak, dashboard tile, calendar grid, assistant persona, or generic feed.
- Object-specific state matrix: every object must define active, empty, stale source, blocked, waiting, and recovery modes.
- Source/proof/receipt behavior: receipts stay attached to the state that produced them.
- Transaction behavior: every meaningful change must be previewable, commit-able, receipted, and recoverable.
- Error/conflict behavior: conflict must be inspectable and not silently swallowed.
- Recovery behavior: the user must always see a safe exit path.
- Accessibility fallback matrix: semantics, labels, grouping, and structure must survive without color or motion.
- ADHD safety matrix: keep one dominant attention target and a visible correction path.
- Native iPhone believability rules: thumb-reachable, restrained, and clearly native rather than web-dashboard shaped.
- Anti-generic failure examples: task list, dashboard, chat surface, settings clone, calendar clone.
- Minimum recipe dependencies: object root, label-off test, source-link status, and recipe family anchors.
- Source-link status summary: linked, weak_link, intended_only, missing, needs_direction, obsolete, historical_only.
- Label-off recognition criteria: shape, spacing, and state grammar must still identify the object.
- Concrete good/bad examples: good means object-first; bad means generic app chrome.
- Unique object vocabulary: each object owns a different visible grammar.
- Prohibited lookalike patterns: any surface that could ship unchanged in a generic productivity app.

## ASCII Anatomy

```text
primary object
  -> header
  -> dominant state
  -> action
  -> source / proof / receipt seam
  -> recovery
```

## Required Zones

- header
- dominant state
- action
- trust seam
- recovery path

## Zone Order

1. header
2. dominant state
3. action
4. trust seam
5. recovery path

## Density Budget

- one dominant object at rest
- one correction path visible

## Anti-Generic Failure Examples

- task list
- dashboard
- chat surface
- settings clone
- calendar clone

## Source-Link Status Summary

- linked, weak_link, intended_only, missing, needs_direction, obsolete, and historical_only are the only permitted source-link classes

## Label-Off Recognition Criteria

- shape still reads after labels blur
- recovery path remains obvious
- trust seam remains visible

## Source Link Status

- The source-link manifest tracks the priority recipes that approximate these objects in live source.
- Source-present does not mean final-state complete.
- Compatibility seams remain explicit where the source has not yet been renumbered or renamed.

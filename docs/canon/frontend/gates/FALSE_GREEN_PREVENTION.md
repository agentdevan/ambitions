# False Green Prevention

Status: Active gate guard

## Fail Conditions

- dashboard says Green while P0 intended_only debt is hidden
- dashboard says Green while relying on file existence
- dashboard says Green while proof, source, receipt, accessibility, release, or implementation boundaries are collapsed into one status
- report says 100/100 without all P0 gates passing
- implementation or accessibility proof is claimed out of scope
- source-linkage status collapses into canon status
- implementation proof status is missing or not `Not In Scope`
- an old smaller prompt remains active
- previous Green is reused without new validation
- P0 recipes are not represented in the gate matrix
- object depth is not scored
- label-off recognizability is not scored
- recipe schema depth is not scored
- primitive operationality is not scored
- accessibility / ADHD surface requirements are not scored
- proof / source / receipt coverage is not scored
- transaction coverage is not scored
- dashboard proof separation is not scored

## Repair Rule

If any fail condition is present, the final report must be Red or the validator must explain the open blocker precisely.

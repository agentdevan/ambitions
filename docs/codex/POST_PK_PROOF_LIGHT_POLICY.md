# Post-PK Proof-Light Policy

Status: active speed policy after PK41  
Authority: subordinate to truth files and terminal proof gates

## Principle

Post-PK execution should favor fast installation plus honest proof boundaries.

`Green` requires focused proof for the touched owner. If focused proof is deferred, use `installed_unverified` or Accepted Yellow with an explicit owner and next proof path.

## Lane Matrix

| Lane | Proof during install | Heavy proof timing |
| --- | --- | --- |
| docs_only | `git diff --check`, prompt/claim scan on changed files | final bundle gate |
| prompt_only | prompt audit, queue consistency | final bundle gate |
| state_only | state-advance validation | immediate |
| model_only | focused model tests if Swift touched | bundle stabilization |
| service_only | focused service tests if available | bundle stabilization |
| source_atlas | focused SA model/query/importer tests | SA bundle gate |
| ui_preview | view-model/previews/screenshots only when claimed | visual QA gate |
| repo_hygiene | path/diff/generation checks | RHC terminal gate |
| release_terminal | batch-defined full proof | immediate |

## Accepted Yellow

Allowed for:

- simulator/environment failures,
- broad build blockers outside touched owner seam,
- missing optional visual proof when no visual completion is claimed,
- unavailable physical device proof outside terminal gates.

Not allowed for:

- compile failure in touched owner,
- invalid JSON/state files,
- completed-batch reactivation,
- missing prompt,
- false release/readiness/accessibility/device/performance/privacy/legal claims,
- unknown root cause.

## Proof-Lite Closeout Language

Use `installed_unverified` only when implementation is intentionally installed without focused owner proof. Do not use `Green` unless proof exists.

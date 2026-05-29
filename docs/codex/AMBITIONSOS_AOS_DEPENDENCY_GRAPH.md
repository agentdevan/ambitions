# AmbitionsOS AOS Dependency Graph

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active train dependency truth through AOS23

- AOS01: blocks all AOS work
- AOS02: depends on AOS01
- AOS03: depends on AOS02
- AOS04: depends on AOS01-AOS03
- AOS05: depends on AOS02-AOS04
- AOS06: depends on AOS05
- AOS07: depends on AOS06
- AOS08: depends on AOS05-AOS07
- AOS09: depends on AOS08
- AOS10: depends on AOS02-AOS04
- AOS11: depends on AOS10 and AOS12
- AOS12: depends on AOS02-AOS04
- AOS13: depends on AOS02-AOS04
- AOS14: depends on AOS04, AOS12, and AOS13
- AOS15: depends on AOS04, AOS13, AOS14, and deterministic fallback
- AOS16: must be active before runtime-heavy implementation
- AOS17: must be active before external/sensitive projection work
- AOS18: depends on AOS01-AOS17 contracts
- AOS19: depends on AOS18
- AOS20: depends on AOS14 and AOS18
- AOS21: depends on AOS16, AOS17, and interoperability privacy gates
- AOS22: depends on AOS02, AOS12, and AOS13
- AOS23: depends on all kernel contracts; complete Green as Governance Kernel
  registry evidence after local validation
- LDI01: optimized global order follows AOS23 before later AOS UI integration
  unless dependency review selects another eligible batch
- AOS24: depends on AOS18-AOS23 and any global-order LDI predecessor gates that
  expose Living Dream behavior into UI
- AOS25: depends on AOS18 and AOS24
- AOS26: depends on AOS16, AOS17, AOS18, and AOS25
- AOS27: depends on AOS26
- AOS28: depends on AOS27
- AOS29: runs only after needs review/Yellow AOS gates are classified
- AOS30: runs only after AOS28 or explicit user decision

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->

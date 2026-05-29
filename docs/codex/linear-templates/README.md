# Linear Templates

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-duplicate_stable_id-71725698, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active workflow contract.
Scope: Repo-backed Linear issue/project templates for Ambitions Codex execution.

This directory is the source of truth for generating Linear issues and projects that
delegate implementation to Codex without letting Linear or Codex become product,
architecture, release, or repo authority.

## Authority

These templates sit below:

1. `docs/truth/*`
2. `AGENTS.md`
3. `README.md`
4. `docs/codex/LINEAR_CONTROL_PLANE.md`
5. `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
6. `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
7. Relevant prompt, source, test, proof, and log paths

If a Linear issue conflicts with repo truth, repo truth wins.

## Token-Efficient Operating Model

Default to compact Linear issues that reference the manifest instead of pasting the
full product law every time.

Use:

```text
Template: AMB-BATCH@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Authority inspected: <exact repo paths>
Intent: <one outcome>
Scope: <allowed files/folders>
Requirements: <numbered implementation requirements>
Validation: <commands or validation lane>
Proof: <artifact paths>
Non-goals: <hard exclusions>
```

Use expanded templates only for high-risk work, cross-surface work, architecture
changes, privacy/runtime changes, release claims, or a failing validation repair.

## Template Selection

| Template | Use |
| --- | --- |
| `AMB-BATCH` | Normal scoped implementation issue for Codex. |
| `AMB-FIX` | Validation failure, build/test repair, or proof repair. |
| `AMB-DESIGN` | SwiftUI surface, design-system, visual QA, accessibility, preview, or screenshot work. |
| `AMB-REVIEW` | Audit, merge-readiness review, proof review, or no-mutation inspection. |
| `AMB-DOCS` | Documentation, canon support note, governance, or process-only work. |
| `AMB-SPIKE` | Investigation only; no production mutation. |
| `AMB-PROJECT` | Multi-issue Linear project / train wrapper. |

## Required Final Codex Report

Every Codex-executed issue must end with:

```text
Summary:
Changed files:
Commands run:
Proof artifacts:
Green/Yellow/Red:
Risks:
Follow-up issue, if needed:
```

## Non-Claims

This directory does not prove:

- Linear templates are installed in the Linear UI.
- Linear API sync/upsert exists.
- Any generated issue has been executed.
- App build, test, accessibility, performance, privacy, device, TestFlight, App Store, or release readiness.
- Any status in Linear is stronger than current repo evidence.

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

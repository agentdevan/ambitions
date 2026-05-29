# FCP06 Receipt Drawer / Trust Layer Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Role: Flagship Completion shared trust implementation executor.

Result target: Green or accepted Yellow.

## Source Truth

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- FCP01-FCP04 reports
- PD15 and PD17 reports
- SI10 trust receipt layer evidence
- CQS reviewer, repair, and script gates

## Scope Reconciliation

The older FCP manifest says FCP06 depends on FCP05 and attaches to Start Here
first. The newer highest-priority global optimized order places FCP06 before
FCP05 because the Receipt Drawer / Source Fold is a hard trust dependency for
Start Here, Reality Rail, Capture, Plan, Goals, and You.

This batch uses the stricter safe boundary:

- Implement shared Receipt Drawer and Source Fold primitives now.
- Do not attach to Start Here because FCP05 is not complete.
- Leave Start Here integration to FCP05.
- Do not create a new route, tab, surface, activity feed, or receipt inbox.

## Allowed Files

- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Previews/TrustReceiptLayerPreviews.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- FCP prompt/report docs
- FCP/global registry, context, and run-state docs

## Forbidden Files

- App navigation/shell routes.
- Persistence/schema/sync/cloud/auth/network files.
- App Intents, widgets, Live Activities, notification behavior.
- CI, workflow, signing, entitlement, package, project, generated project files
  unless validation tooling requires regeneration only.
- Today Start Here implementation files unless a later batch explicitly scopes
  them.

## Acceptance

- Shared `ReceiptDrawer` exists.
- Shared `SourceFold` exists.
- A receipt can explain what happened, why, source, freshness, privacy,
  change/no-change, undo, correction, and review.
- Trust is more than toast/snackbar.
- Dynamic Type and VoiceOver labels preserve meaning.
- Meaning is not color-only or motion-only.
- No activity feed, analytics log UI, surface, fake AI confidence, hidden
  mutation, release/legal/privacy claim, or public accessibility claim is made.

## Validation

Run or document inability to run:

- `xcodegen generate` if needed by local project state.
- Focused `AmbitionsTests/TrustReceiptLayerDesignSystemTests`.
- `scripts/build-local.sh`
- `git diff --check`
- touched-file trailing whitespace scan
- CQS product drift, prompt-built smell, privacy/security claim, and
  accessibility/motion scans on touched files
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

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

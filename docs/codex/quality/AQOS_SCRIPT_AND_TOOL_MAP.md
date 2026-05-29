# AQOS Script And Tool Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-89341282, AMB28-same_source_file_targeted_by_multiple_active_batches-29087703, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-62616276

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active AQOS tool specification. Executable scripts are to be materialized by the AQOS adoption batch from these exact specs.
Date: 2026-05-05

## Purpose

This map defines the concrete scripts and tools AQOS needs so Codex can simulate a FAANG-level review process with repeatable checks instead of relying only on written judgment.

Connector note: some executable script creation may be blocked by remote connector guardrails. If scripts are not already present, the AQOS adoption batch must create them locally in the repo and commit them after validation.

## Required Scripts

All scripts should live in `scripts/`, be Bash-first, use only standard macOS command-line tools unless otherwise noted, and run advisory by default. Set `AQOS_STRICT=1` to make relevant findings fail.

### 1. `scripts/aqos-impact-classifier.sh`

Purpose: inspect changed files and classify touched domains.

Inputs:

- `AQOS_BASE_REF`, default `origin/main`
- `AQOS_STRICT`, default `0`

Outputs:

- changed files
- domains touched
- required matrix lookup reminder

Domains:

- Visual UI / SwiftUI
- Motion / Haptics
- Accessibility
- User-Facing Copy
- Privacy / Sensitive Data
- Persistence / Schema
- Sync / Cloud / App Groups
- Performance / Battery
- Architecture / Repo
- External Surfaces
- Monetization / StoreKit
- Release / App Store / Legal
- AI / Recommendation / AOS / LDI
- Tests / Fixtures
- Docs / Governance

### 2. `scripts/aqos-required-evidence-check.sh`

Purpose: lint a batch report for AQOS-required sections.

Required sections:

- Impact classifier
- Required evidence
- Evidence produced
- Evidence not produced
- Green taxonomy
- Yellow / Red classification
- Repair path
- Hard Red check
- Autonomous Quality Council, for major batches

### 3. `scripts/aqos-claim-truth-scan.sh`

Purpose: flag unsupported public-readiness or compliance language.

Flag claim words unless the report includes evidence boundaries:

- ready
- compliant
- certified
- secure
- legal
- App Store ready
- TestFlight ready
- accessible
- privacy compliant
- release ready
- production ready

The script must ignore historical/audit sections only when the report explicitly marks them as historical or no-claim boundary.

### 4. `scripts/aqos-copy-internal-term-scan.sh`

Purpose: detect internal product-object terms leaking into user-facing SwiftUI strings.

Flag visible copy containing terms such as:

- Reality Rail
- Action Closure
- Source Fold
- Proof Pulse
- Context Edge
- MissionControlTimeSpine
- Hero Step Panel
- AI confidence
- surface
- proof signal

Implementation terms may remain in type names, test names, comments, and docs. They should not dominate `Text(...)`, `Label(...)`, accessibility labels, or notification/widget copy.

### 5. `scripts/aqos-visual-card-stack-scan.sh`

Purpose: static heuristic for card-stack drift.

Flag top-level surfaces when repeated rounded-rectangle/material/panel containers appear near top-level body composition without object-specific names such as Rail, Spine, Surface, Fold, Drawer, Field, Pocket, Thread, Lens, Resolver, Center.

This script is advisory only. Rendered FVQ screenshots remain source truth.

### 6. `scripts/aqos-architecture-fitness-scan.sh`

Purpose: detect repo/architecture issues.

Checks:

- large Swift files over configured line thresholds
- repeated `Manager`, `Helper`, `Coordinator`, `Service` names without ownership docs
- SwiftUI view files containing heavy domain/business logic hints
- domain/service files importing SwiftUI
- duplicate model names
- orphan preview fixtures
- unowned shared primitives

### 7. `scripts/aqos-privacy-exposure-scan.sh`

Purpose: detect privacy exposure risks.

Checks:

- sensitive Found Life terms in widgets, Live Activities, notifications, App Intents, Spotlight, shared storage, logs, previews, screenshot fixtures
- private/relationship/family/work/money/health-adjacent content in external-surface defaults
- debug overlays or logs that include user life context

### 8. `scripts/aqos-screenshot-freshness-check.sh`

Purpose: validate screenshot freshness metadata.

Input:

- folder under `docs/audits/visual-evidence/<batch>/`

Require:

- `screenshot-freshness.json`
- repo HEAD SHA
- origin/main SHA
- simulator device/runtime
- scheme
- build timestamp
- app build SHA or accepted Yellow field
- fresh install/reset field
- screenshot filenames list

### 9. `scripts/aqos-evidence-folder-check.sh`

Purpose: ensure evidence paths exist for claimed Green types.

Checks report for Green taxonomy, then verifies corresponding evidence folders exist:

- Rendered Visual Green -> `docs/audits/visual-evidence/<batch>/`
- Accessibility Green -> `docs/audits/accessibility-evidence/<batch>/`
- Privacy Green -> `docs/audits/privacy-evidence/<batch>/`
- Performance Green -> `docs/audits/performance-evidence/<batch>/`
- Data Integrity Green -> `docs/audits/data-integrity-evidence/<batch>/`
- Release Green -> `docs/audits/release-evidence/<batch>/`

### 10. `scripts/aqos-state-coverage-check.sh`

Purpose: check report/fixtures for required scenario/state coverage.

State keywords:

- normal
- empty
- loading
- degraded
- private
- redacted
- stale source
- overloaded
- blocked
- waiting
- recovery
- closure needed
- proof saved
- missing duration
- reduced motion
- Dynamic Type
- VoiceOver

### 11. `scripts/aqos-evidence-maturity-ledger-check.sh`

Purpose: verify major closeouts update or reference the Evidence Maturity Ledger.

### 12. `scripts/aqos-run-all-advisory.sh`

Purpose: run all AQOS scripts in advisory mode and collect output.

Behavior:

- prints a section per script
- never hides failures
- exits 0 by default unless `AQOS_STRICT=1`
- writes optional output to `docs/audits/evidence/<batch>/aqos-script-results.md` when `AQOS_BATCH_ID` is set

## Tool Dependencies

Default dependencies:

- Bash
- Git
- grep/sed/awk/find/wc
- Python 3 standard library for JSON validation
- Xcode command-line tools for simulator screenshot workflows
- xcodegen where repo already uses it
- xcodebuild
- xcrun simctl

No new third-party dependency is required by AQOS by default.

## Strict Mode

All scripts should support:

`AQOS_STRICT=1`

In strict mode, relevant findings should return non-zero. In advisory mode, scripts return zero but print findings clearly.

## Integration Point

The AQOS adoption batch must:

1. create these executable scripts if missing;
2. add them to Codex script maps;
3. run them once;
4. record advisory findings;
5. make future UI/platform/runtime/release batches call the relevant scripts by impact classification.

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

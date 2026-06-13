# AMB-675 / PLOS-047 - Pathing-Data Download Language

Status: Green for scoped documentation/control-plane approved copy set after validation
Date: 2026-06-12 America/New_York
Linear issue: AMB-675
PLOS label: PLOS-047
Parent: AMB-612 / PLOS-M04
Scope: Define calm, privacy-safe, screen-reader-friendly copy for public Source Atlas pathing-data download and refresh behavior.
Out of scope: Full onboarding copy system, runtime UI implementation, network code, R2 fetching, cache/quarantine behavior, background refresh, live R2 writes, Cloudflare/R2 configuration, credential creation, app source changes, dependency changes, release readiness, privacy/legal approval, and security certification.

## Closeout Header

- PLOS child closeout: AMB-675 / PLOS-047
- Linear issue: AMB-675
- Parent issue: AMB-612
- Green/Yellow/Red status: Green for scoped approved download-language copy set; Yellow for UI implementation, onboarding copy system, runtime download behavior, live Cloudflare/R2 proof, network validation, privacy/legal, device, accessibility, measured performance, security certification, and release proof.
- Pushed to main: pending at report validation time
- Push hash: pending at report validation time
- App source changed: no
- Runtime features implemented: no
- PLOS-M00 executed: yes, already complete before this child; PLOS-M00 was not re-executed in AMB-675.
- Linear identifiers used: AMB issue identifiers only
- Validation run: see Validation
- Red blockers: none for scoped AMB-675 documentation/control-plane copy-set work after validation
- Yellow limits: no runtime UI implementation, onboarding copy system, network download behavior, release tooling, pack publication, live R2 writes, bucket provisioning, credential creation, network validation, privacy/legal/release/performance/accessibility/device proof, or M04 parent completion
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next recommended action: after AMB-675 is committed, pushed to `main`, and moved to Done in Linear, continue the next canonical M04 child only after live Linear resolution.

## Existing-First Inspection

Repo and Linear evidence inspected before adding this artifact:

- Linear parent `AMB-612` and child `AMB-675` by actual `AMB-*` identifiers.
- Active truth files, `AGENTS.md`, PLOS GOAL/run-state/queue/map/phase gates, PLOS validation/reporting/proof contracts.
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- M04 R2 specs from `R2_BUCKET_LAYOUT.md` through `R2_SOURCE_ATLAS_FRESHNESS_CADENCE_POLICY.md`.
- M04 reports for bucket layout, freshness/revocation, fetch/verify/cache/quarantine, and freshness cadence.
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasStoreModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`

## Files Changed

- `artifacts/source-atlas-factory/r2/R2_PATHING_DATA_DOWNLOAD_LANGUAGE.md`
- `artifacts/personal-life-os/reports/PLOS-047-pathing-data-download-language.md`
- `artifacts/personal-life-os/validation/PLOS-047-download-pathing-privacy-source-atlas-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-047-focused-download-language-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-675-source-privacy-closeout-review.md`
- PLOS run-state/queue/map/phase-gate/changelog/decision/risk artifacts
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Approved Copy Set

The approved copy set is:

- `artifacts/source-atlas-factory/r2/R2_PATHING_DATA_DOWNLOAD_LANGUAGE.md`

It defines:

- top-level download, refresh, verified-current, stale, source-needed, offline fallback, blocked, privacy, and failure copy
- detail copy for what downloads, what does not download, stale handling, review route, R2 boundary, iCloud boundary, and failure behavior
- VoiceOver/accessibility label guidance
- forbidden copy that would imply user-private data leaves the device/iCloud, AI/cloud personalization, R2 personal storage, privacy approval, or always-current source state
- copy-state rules for when `current`, `older`, `needs review`, `fresh source needed`, and `blocked` are allowed

## Runtime Path Proof

Not applicable for this documentation/control-plane child. No app source changed and no runtime feature is claimed.

## Privacy / Safety / Source Checks

Pass for scoped documentation:

- The copy set states public Source Atlas downloads are public source/reference material, not private user life data.
- The copy set forbids implying that goals, captures, schedule, proof, receipts, personal context, identifiers, or private source-needed context are sent to R2.
- The copy set separates user-owned iCloud sync from public Source Atlas downloads.
- The copy set blocks "always current", "privacy approved", AI/cloud personalization, and R2 personal-storage language.
- Stale/blocked/source-needed states are explicit and do not claim source currentness without proof.

## Accessibility Checks

Pass for scoped copy documentation:

- The copy set includes short screen-reader-friendly labels for current, stale, source-needed, privacy, refresh, review, and blocked states.
- No UI was changed and no Dynamic Type, VoiceOver runtime, screenshot, or accessibility certification proof is claimed.

## Performance Notes

Not applicable for this documentation/control-plane child. The copy set mentions refresh/download behavior but does not implement downloads or measure network/battery cost. No measured startup, network, battery, memory, or latency proof was run or claimed.

## Rollback / Failure Behavior

If this copy set is later found unsafe, rollback is to revert `artifacts/source-atlas-factory/r2/R2_PATHING_DATA_DOWNLOAD_LANGUAGE.md`, this report, and AMB-675 control-plane updates. Future UI/runtime download-language work must remain blocked until privacy boundary, source-state wording, stale/blocked states, and accessibility language are repaired.

## Validation

Commands run for AMB-675:

- `git status --short --branch` - clean on `main` before AMB-675 execution.
- Linear issue fetch for `AMB-675` - succeeded.
- Linear status update for `AMB-675` to In Progress - succeeded.
- `rg -n "download|pathing|privacy|Source Atlas" . --glob '!artifacts/personal-life-os/validation/**' --glob '!artifacts/plos-runtime/script-output/**' --glob '!artifacts/ui-quality-lockdown/**' --glob '!**/*.xcresult/**' > artifacts/personal-life-os/validation/PLOS-047-download-pathing-privacy-source-atlas-required-search-log.txt` - exited `0`, 4,352 lines, 876,240 bytes after trailing-whitespace normalization. This is the required search adapted only to avoid recursive generated validation logs and `.xcresult` bundles.
- Focused download-language search over Source Atlas artifacts, truth/codex laws, M04 reports, Source Atlas privacy/source models, and trust receipt primitives - exited `0`, 1,136 lines, 188,401 bytes after trailing-whitespace normalization, artifact `artifacts/personal-life-os/validation/PLOS-047-focused-download-language-search-log.txt`.

Closeout validation run after report creation:

- `git diff --check` - pass
- JSON parse for PLOS queue/map/proof index - pass
- `python3 scripts/codex/plos-readiness-validate.py` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py --self-test` - pass
- `python3 scripts/codex/source-atlas-readiness-validate.py` - pass
- `scripts/codex/program-preflight.sh plos` - pass
- `scripts/codex/program-phase-gate.sh plos M04` - pass
- `python3 scripts/codex/linear-closeout-validate.py --program plos --scope child artifacts/personal-life-os/reports/PLOS-047-pathing-data-download-language.md` - pass
- `bash scripts/codex/program-proof-index.sh plos` - pass
- `git diff --cached --check` - pass

## Proof Artifacts

- `artifacts/source-atlas-factory/r2/R2_PATHING_DATA_DOWNLOAD_LANGUAGE.md`
- `artifacts/personal-life-os/reports/PLOS-047-pathing-data-download-language.md`
- `artifacts/personal-life-os/validation/PLOS-047-download-pathing-privacy-source-atlas-required-search-log.txt`
- `artifacts/personal-life-os/validation/PLOS-047-focused-download-language-search-log.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-675-source-privacy-closeout-review.md`
- `artifacts/proof-ledger/PROOF_LEDGER.md`
- `artifacts/proof-ledger/proof-index.json`

## Remaining Yellow / Red

- Yellow: no runtime UI implementation, onboarding copy system, network download behavior, cache/quarantine behavior, background refresh, release tooling, pack publication, live R2 account proof, bucket provisioning, network validation, runtime proof, privacy/legal approval, release readiness, device proof, accessibility proof, security certification, or measured performance proof.
- Yellow: AMB-612 parent closeout remains blocked by active duplicate-looking M04 children `AMB-730` through `AMB-737` unless Linear later marks them Duplicate/Canceled or owner accepts them as non-blocking.
- Red blockers: none for AMB-675 scoped documentation/control-plane closeout.

## Follow-Up Issues Created

None.

## Next Issue To Run

After AMB-675 is committed, pushed, and closed in Linear, re-fetch live `AMB-612` children and continue only with the next canonical active M04 child if one exists.

## Non-Claims

AMB-675 does not claim app source change, runtime feature implementation, runtime UI implementation, onboarding copy system, network download behavior, manifest parsing, cache/quarantine storage, background refresh, release tooling implementation, pack publication, Cloudflare/R2 bucket provisioning, live R2 write, credential creation, network validation, CORS/cache/header configuration, dependency change, SDK/scanner installation, security certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, Dynamic Type proof, VoiceOver runtime proof, device proof, measured performance proof, owner approval, any duplicate child execution, or PLOS-M04 parent completion.

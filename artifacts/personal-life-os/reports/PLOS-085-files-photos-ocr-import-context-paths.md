# PLOS-085 Files/Photos/OCR Explicit Import Context Paths Report

Status: Green for scoped AMB-707 / PLOS-085 documentation/control-plane explicit import context path contract after validation
Linear issue: AMB-707
Parent issue: AMB-616
PLOS label: PLOS-085
Date: 2026-06-13 America/New_York

## Scope

AMB-707 defines explicit import-path contracts for Files, Photos, and OCR context in M08. It specializes AMB-702's Native Context Mesh contract into user-initiated file selection, PDF import, plain-text import, URL share, selected photo/screenshot import, OCR fallback, external creation import, and portable restore/import paths.

Out of scope: app source changes, Swift/domain implementation, runtime adapter implementation, Photos integration, Files integration, Vision/OCR implementation, permission prompting implementation, entitlement changes, privacy manifest changes, UI implementation, screenshots, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 writes, Source Atlas publication, production certification, AMB-616 parent completion, and full PLOS project completion.

## Closeout

PLOS child closeout
Linear issue: AMB-707
Parent issue: AMB-616
Green/Yellow/Red status: Green for scoped documentation/control-plane Files/Photos/OCR explicit import context paths, PermissionValueProof linkage, PermissionLedger/revocation linkage, sensitivity classes, context-to-path influence matrix, local/iCloud/R2 privacy boundaries, fixture matrix, and no-background-scan/no-private-source-publication boundaries; Yellow for Swift/domain implementation, runtime adapter implementation, Photos/Files/Vision/OCR implementation, permission prompt implementation, PermissionLedger runtime, executable validator/test harness, UI implementation, accessibility, device, performance, privacy/legal, release, App Review, and M08 parent completion proof not claimed.
Pushed to main: pending at report creation
Push hash: pending at report creation
App source changed: no
Runtime features implemented: no
PLOS-M00 executed: no
Linear identifiers used: AMB-616 parent issue, AMB-707 child issue, AMB-702 through AMB-706 Done children, active M08 children AMB-707, AMB-708, AMB-771, and AMB-710; duplicate/canceled M08 children AMB-764 through AMB-770 and AMB-772; archived AMB-709.
Validation run: `git status --short --branch`; `git pull --ff-only`; live Linear issue fetch for `AMB-707`; live Linear M08 child list; `scripts/codex/program-preflight.sh plos`; `scripts/codex/program-phase-gate.sh plos M08`; issue-required Files/Photos/OCR/import-context search; focused source ownership search; JSON parse validations; PLOS readiness validators; closeout validator.
Red blockers: none for scoped AMB-707 documentation/control-plane explicit import context path contract after artifact creation.
Yellow limits: no Swift/domain implementation, no runtime adapter implementation, no Photos/Files/Vision/OCR implementation, no permission prompt implementation, no PermissionLedger runtime implementation, no executable validator/test harness, no UI implementation, no accessibility/device/performance/privacy/legal/release/App Review proof, and no AMB-616 parent completion.
Owner approval claimed: no new owner approval; this uses the 2026-06-12 owner authorization to continue M02-M26 subject to strict gates.
Release/TestFlight/App Store readiness claimed: no.
Next recommended action: validate, commit, push, update AMB-707 in Linear, then re-fetch AMB-616 and run AMB-708 / PLOS-086 if M08 remains Green and no new active child blocks order.

## Artifacts Produced

- `artifacts/personal-life-os/native-context/FILES_PHOTOS_OCR_IMPORT_CONTEXT_PATHS.md`
- `artifacts/personal-life-os/native-context/FILES_PHOTOS_OCR_IMPORT_CONTEXT_PATHS.json`
- `artifacts/personal-life-os/validation/AMB-707-required-files-photos-ocr-import-context-search-log.txt`
- `artifacts/personal-life-os/validation/AMB-707-files-photos-ocr-source-search-log.txt`
- `artifacts/personal-life-os/validation/AMB-707-files-photos-ocr-source-search-summary.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-707-files-photos-ocr-closeout-review.md`

The JSON artifact is the downstream-consumable contract and fixture matrix for later M08/M12/M14/M15/M16/M18/M19/M23/M24/M26 validators.

## Existing-First Inspection

AMB-707 inspected active truth files, PLOS control-plane artifacts, AMB-616 and AMB-707 in Linear, AMB-702's Native Context Mesh contract, AMB-706's Location contract, existing Source Atlas import/OCR domain models, local portable import/restore services, and external creation import service before adding the contract.

Focused source ownership inspection confirmed:

- `SourceAtlasPDFImportBoundaryModels` defines local/PDF URL import candidates and defaults imported PDFs to user-provided, sensitive, privacy-review-needed state.
- `SourceAtlasVisionOCRFallbackModels` defines OCR fallback candidates, text blocks, quality labels, source-needed/review-required fallback, and no automatic official-current authority.
- `SourceAtlasImageScreenshotImporterModels` defines image/screenshot import candidates, OCR quality labels, manual correction state, sensitive privacy review, and no automatic mutation.
- `SourceAtlasPlainTextImporterModels` and `SourceAtlasURLSourceImporterModels` own explicit text/URL import candidate paths.
- `SourceAtlasPDFKitTextExtractionModels` is an existing local PDF extraction boundary tied to import candidates, not a broad file scan.
- `ExternalCreationImportService` imports pending local creations into Capture without treating them as public source material.
- `PortableSnapshotContracts`, `PortableSnapshotService`, `PortableRestoreRollback`, and `LegacyImportService` own explicit local import/restore behavior for user data packages.
- Focused search found no active production `PhotosUI`, `PHPicker`, Photo Library, `FileImporter`/`fileImporter`, `UIDocumentPicker`, `DocumentPicker`, or Vision integration in AMB-707 scope.

These are source ownership anchors, not evidence that Files/Photos/OCR native context adapter runtime is implemented.

## Green Basis

AMB-707 is Green for scoped documentation/control-plane contract because:

- It defines explicit user action as the only allowed entry point for Files, Photos, and OCR context.
- It distinguishes file selection, PDF import, text import, URL share, selected photo/screenshot, OCR fallback, external creation import, and portable restore/import routes.
- It links import paths to `PermissionValueProof`, `PermissionLedger`, revocation, sensitivity classes, context-to-path influence, privacy boundary, and fixture obligations.
- It blocks broad Photos/Files permission, photo library scans, folder crawls, background ingestion, browsing history access, clipboard history access, face/object/place inference, raw OCR leakage, and hidden mutation.
- It preserves local-only raw payload handling and forbids raw files/photos/OCR/private import content from R2, public Source Atlas, Linear, support bundles, logs, external prompts, analytics, telemetry, screenshots, and share/progress-story artifacts.
- It keeps OCR-derived text review-bound and blocks official-current/source-backed path claims without future Source Authority and release proof.
- It defines denied/canceled/failed/revoked/deleted/stale/source-changed fallback behavior.
- It blocks imported high-risk-sensitive content from producing high-risk advice or softening unsafe-blocked behavior without future M18 authority.
- It defines fixture obligations for downstream implementation/validator phases.

## Validation

- `git status --short --branch --untracked-files=all` - pass before AMB-707 start on `main`.
- `git pull --ff-only` - pass, already up to date.
- Live Linear issue fetch for `AMB-707` - pass, moved to In Progress after start comment and status update.
- Live Linear M08 child list - pass, `AMB-702` through `AMB-706` Done; active M08 children `AMB-707`, `AMB-708`, `AMB-771`, and `AMB-710`; `AMB-764` through `AMB-770` plus `AMB-772` Duplicate/archived/canceled; `AMB-709` archived/non-active.
- `scripts/codex/program-preflight.sh plos` before edits - pass, artifact `artifacts/plos-runtime/script-output/program-preflight-20260613T203413.log`.
- `scripts/codex/program-phase-gate.sh plos M08` before edits - pass, artifact `artifacts/plos-runtime/script-output/program-phase-gate-M08-20260613T203413.log`.
- Issue-required search `rg -n "Files|Photos|OCR|import context" ...` - pass, `artifacts/personal-life-os/validation/AMB-707-required-files-photos-ocr-import-context-search-log.txt`, 296 lines / 42,800 bytes.
- Focused source ownership search - pass, `artifacts/personal-life-os/validation/AMB-707-files-photos-ocr-source-search-log.txt`, 409 lines / 57,031 bytes.
- Read-only reviewer pass - pass, `artifacts/plos-runtime/reviewer-output/AMB-707-files-photos-ocr-closeout-review.md`.
- Final JSON parse, PLOS readiness, closeout, preflight, phase-gate, and proof-index validation are recorded after final validation.

## Red / Yellow / Green

Green:

- AMB-707 Files/Photos/OCR Markdown and JSON contracts are complete for documentation/control-plane scope.
- Existing-first source ownership and required M08 phase gate were completed.
- The raw source search logs are bounded and summarized.
- Privacy/source/safety/runtime reviewer output has no Red findings for the scoped contract.

Yellow:

- Swift/domain implementation, runtime adapter implementation, Photos/Files/Vision/OCR implementation, permission prompt implementation, PermissionLedger runtime implementation, executable validator/test harness, UI implementation, accessibility, device, performance, privacy/legal, release, App Review, and AMB-616 parent completion remain future-owned.

Red:

- None for AMB-707 scoped documentation/control-plane explicit import context path contract.

## Files Changed

- `artifacts/personal-life-os/native-context/FILES_PHOTOS_OCR_IMPORT_CONTEXT_PATHS.md`
- `artifacts/personal-life-os/native-context/FILES_PHOTOS_OCR_IMPORT_CONTEXT_PATHS.json`
- `artifacts/personal-life-os/reports/PLOS-085-files-photos-ocr-import-context-paths.md`
- `artifacts/personal-life-os/validation/AMB-707-required-files-photos-ocr-import-context-search-log.txt`
- `artifacts/personal-life-os/validation/AMB-707-files-photos-ocr-source-search-log.txt`
- `artifacts/personal-life-os/validation/AMB-707-files-photos-ocr-source-search-summary.txt`
- `artifacts/plos-runtime/reviewer-output/AMB-707-files-photos-ocr-closeout-review.md`
- PLOS control-plane/proof artifacts

## Non-Claims

AMB-707 does not claim app source change, Swift/domain implementation, runtime adapter implementation, Photos integration, Files integration, Vision/OCR implementation, permission prompting implementation, entitlement change, privacy manifest change, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 write, Source Atlas publication, production certification, AMB-616 parent completion, or full PLOS project completion.

# Files, Photos, and OCR Explicit Import Context Paths

Status: AMB-707 / PLOS-085 downstream contract
Date: 2026-06-13 America/New_York
Scope: Documentation/control-plane contract for explicit Files, Photos, and OCR import context paths.

This artifact specializes the AMB-702 Native Context Mesh contract for user-initiated Files, Photos, and OCR context. It defines how imported files, selected photos/screenshots, and OCR-derived text may become local review candidates without becoming background library scans, public Source Atlas content, R2 content, Linear private detail, support-bundle payload, external prompt material, telemetry, or automatic planning authority.

This is not Swift implementation, runtime adapter implementation, Photos integration, Files integration, Vision/OCR implementation, privacy manifest change, entitlement work, permission prompting implementation, UI implementation, accessibility proof, device proof, measured performance proof, privacy/legal approval, App Review readiness, release readiness, R2 write, Source Atlas publication, or AMB-616 parent completion.

## Existing Source Ownership

AMB-707 inspected these owners before adding this contract:

- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.md`
- `artifacts/personal-life-os/native-context/NATIVE_CONTEXT_MESH_ADAPTER_CONTRACT.json`
- `artifacts/personal-life-os/native-context/LOCATION_CONTEXT_ADAPTER_CONTRACT.md`
- `Native/Ambitions/Domain/SourceAtlasPDFImportBoundaryModels.swift`
- `Native/Ambitions/Domain/SourceAtlasVisionOCRFallbackModels.swift`
- `Native/Ambitions/Domain/SourceAtlasImageScreenshotImporterModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPlainTextImporterModels.swift`
- `Native/Ambitions/Domain/SourceAtlasURLSourceImporterModels.swift`
- `Native/Ambitions/Domain/SourceAtlasPDFKitTextExtractionModels.swift`
- `Native/Ambitions/Services/ExternalCreationImportService.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Persistence/LegacyImportService.swift`
- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md`

Focused source inspection found existing Source Atlas import and OCR boundary models that default user-provided import candidates to sensitive, review-required, non-official, non-mutating posture. It also found portable/legacy import services for local user data restore and external creation import support. AMB-707 binds a native context contract to those owners; it does not add new runtime access to Files, Photos, Photo Library, Vision, or OCR.

## Core Rule

Files, Photos, and OCR context is allowed only through explicit user action. Ambitions may hold a local review candidate, source-needed scaffold, or user-confirmed source candidate, but it must not scan libraries, crawl folders, infer private facts from media, or convert imported private material into public source authority.

Every import path must satisfy this sequence:

1. The user explicitly selects, pastes, shares, drops, or restores the material.
2. Ambitions records the exact import route and consent boundary.
3. The import path classifies sensitivity, provenance, freshness, review state, and permission state.
4. Raw private payload stays local and is excluded from R2, public Source Atlas, Linear, support bundles, logs, external prompts, analytics, telemetry, screenshots, and public/share artifacts.
5. Only a bounded `ContextSlot` summary, Held Object, source-needed scaffold, or user-confirmed source candidate may influence local planning.
6. Review, redaction, delete/export policy, and revocation handling are attached before the import influences user-visible behavior.
7. Source Authority remains fail-closed until a later owner proves release/source eligibility. Private imported context is never automatically source-backed.

## Import Path Catalogue

| Path | User action | Allowed local output | Permission posture | Must not happen |
|---|---|---|---|---|
| Files document picker | User selects a file or shares a file into Ambitions. | Local import candidate, metadata summary, source-needed scaffold, user-confirmed source candidate after review. | User-initiated picker only; no broad folder crawl. | Background file scan, raw file upload, automatic Source Atlas/R2 publication, hidden mutation. |
| PDF import | User selects local PDF or explicit PDF URL. | `SourceAtlasPDFImportCandidate` style review candidate; metadata or extracted local text summary after review. | Explicit selection; future extraction remains review-bound. | Locked/corrupt/huge/private PDFs becoming official source, automatic planning authority, raw PDF text in Linear/logs. |
| Plain text import | User pastes or imports text intentionally. | Local text candidate, Held Object, source-needed scaffold, reviewed source candidate. | No platform permission; explicit paste/import action. | Treating raw pasted private text as public source, coverage request, fingerprint, or R2 object. |
| URL import | User enters or shares a URL. | URL source candidate with source/freshness/review state. | Explicit user action; no browsing history access. | Browser history scan, private URL leakage, automatic official-current status. |
| Photos selected image | User selects a specific image/photo/screenshot. | Local image/screenshot import candidate with review-required OCR/text summary. | Selected-item only; no library-wide scan. | Photo library crawl, face/object/place inference, raw image upload, private image in Source Atlas/R2. |
| OCR fallback | User-selected image/PDF provides OCR blocks or local extraction. | Review-required normalized text blocks, quality labels, source-needed/review-required state. | OCR is derived from explicit input only. | OCR text treated as official current source, raw OCR in Linear/logs/support/external prompts, automatic Step generation. |
| External creation import | User-created external pending creation is imported into local Capture. | Local capture/import receipt and landing preference. | Ambitions-owned pending local input only. | Treating external creation queue as background document/media scan or public source. |
| Portable restore/import | User imports an Ambitions portable package with dry-run/conflict report. | Local restore/import report and conflict handling. | Explicit restore/import with dry run. | Silent overwrite, hidden resurrection, private package data in R2/Source Atlas/Linear. |

## FilesPhotosOCRImportAdapter

`FilesPhotosOCRImportAdapter` is the future specialization of `NativeContextAdapter` for explicit import context.

Required fields:

| Field | Requirement | Red stop |
|---|---|---|
| `adapterId` | Stable local ID such as `native.explicit_import.files_photos_ocr`. | ID embeds file names, paths, photo metadata, OCR text, source hashes containing private text, or user identifiers. |
| `sourceKind` | `files_photos_ocr_import`. | Import path is treated as Source Atlas public source or R2 pathing data before review/release authority. |
| `importRoute` | Exact route: `file_selection`, `pdf_import`, `plain_text_paste`, `url_share`, `selected_photo`, `selected_screenshot`, `ocr_fallback`, `external_creation`, or `portable_restore`. | Route is vague, background, inferred, or library-wide. |
| `userActionRef` | Local receipt for explicit user action. | Import occurs from passive scan, browsing history, photo library crawl, folder crawl, or automation. |
| `permissionScope` | `none` for paste/local package; selected-item picker scope for Files/Photos; future OCR permission remains tied to selected input. | Broad Photos/Files permission, background access, or permission ask before value proof. |
| `valueProof` | Required before any permission-like import surface that could expose private media/files. | Permission or picker prompt implies Ambitions needs broad access to work. |
| `permissionLedgerRef` | Local permission/import ledger record for request, selection, denial, revoke/delete, or unavailable path. | Denial/revocation leaves stale imported summaries active. |
| `dataClass` | `explicit_import` plus local-only/raw-private classification. | Private import marked public, R2 eligible, or source authority by default. |
| `sensitivityClass` | `imported_private`, `ocr_derived_private`, or `high_risk_sensitive` depending content. | OCR/image/file content is classified as standard/public without review. |
| `slotTypes` | `explicit_import_candidate`, `local_held_object`, `ocr_text_summary_needs_review`, `source_needed_marker`, `reviewed_user_source_candidate`, `import_denied_fallback`, `import_revoked_or_deleted`. | Raw payload drives runtime directly. |
| `freshnessPolicy` | Imported summaries become stale, review-needed, revoked, or deleted according to local state. | Old imported context remains current after deletion/revocation/source change. |
| `revocationPolicy` | Delete/revoke removes current influence and preserves only allowed receipts/tombstones. | Deleted file/photo/OCR continues to drive planning, learning, sharing, or source authority. |
| `allowedInfluence` | Local Held Object, source-needed scaffold, reviewed local source candidate, clarification, same-goal/different-person path fit after review. | Automatic source-backed path, public pack, R2 object, finished Step, share projection, high-risk approval. |
| `storageBoundary` | Local-only raw payload or user-owned local import container; future user iCloud only after M23 proof. | Raw private import leaves local/user-owned boundary. |
| `receiptPolicy` | Local receipt/explanation required before imported context changes visible behavior. | Hidden import-driven mutation. |
| `fallbackBehavior` | Denied, unavailable, failed, no-text, unsupported, or deleted imports keep Ambitions usable and route to manual/source-needed support. | Import failure blocks core Ambitions value or creates fake certainty. |

## Permission Value Proof Linkage

Import surfaces require value proof when the user is about to expose private files, photos, or OCR-derived text.

Required proof content:

- Benefit: Ambitions can turn a user-selected artifact into a local Held Object, source-needed scaffold, or reviewed source candidate.
- What improves: less retyping, clearer source-needed recovery, reviewable local evidence, and better fit only after user confirmation.
- What does not happen: Ambitions does not scan the photo library, crawl files, upload raw files/photos/OCR, create R2 objects, create public Source Atlas packs, train models, analyze faces/places, sell data, or use imported private context for telemetry.
- Boundary: raw import payload and OCR text remain local; only redacted/local summaries can appear in UI, receipts, support, or export paths.
- Control: user can cancel, deny, delete, revoke, re-review, redact, export locally, or keep the goal without the import.
- Fallback: Start here, Step, Goal Detail, local closure, recovery, and source-needed scaffolds remain usable without import access.

Forbidden proof behavior:

- "Ambitions needs your photos/files to plan"
- "AI needs access to your library"
- broad Photos or Files access as a default setup step
- shame, productivity score, fear-of-missing-out, or fake urgency
- implying import grants source authority, high-risk approval, or release/share eligibility

## PermissionLedger And Revocation Linkage

Required states:

| State | Import behavior |
|---|---|
| `not_determined` | Show value proof only at an explicit import moment; no default prompt. |
| `selected_item_granted` | Use only the selected item and allowed summary fields. |
| `limited_selection` | Treat selected media/files as bounded import candidates only. |
| `denied` / `canceled` | Keep app usable; keep no current import influence. |
| `failed` | Route to source-needed/manual support with clear reason. |
| `needs_review` | Hold imported context from meaningful influence until review completes. |
| `revoked` | Invalidate current imported summaries and stop import-derived influence. |
| `deleted` | Remove raw payload and current summaries; preserve only allowed tombstone/receipt if needed. |
| `unavailable` | Use manual/source-needed fallback without nagging. |

Revocation is fail-closed: imported file/photo/OCR-derived summaries cannot continue to influence path density, Today wording, Step generation, schedule fit, elasticity, learning, sharing, or source authority after delete/revoke/stale/source-changed state.

## Sensitivity Classes

| Sensitivity class | Meaning | Allowed storage |
|---|---|---|
| `import_candidate_metadata` | Redacted metadata for a user-selected import candidate. | Local-only receipt/review container. |
| `imported_private_raw` | Raw file, photo, screenshot, or portable package payload. | Local-only raw container; excluded from R2, Source Atlas, Linear, logs, support, external prompts, analytics, telemetry, and public/share. |
| `ocr_derived_private` | OCR text or normalized text blocks from selected input. | Local-only review container; redacted export only after user action. |
| `reviewed_user_source_candidate` | User-reviewed local source candidate that may support local planning. | Local-only; public Source Atlas requires separate source/release authority and must not contain private user data. |
| `high_risk_sensitive_import` | Import appears to contain medical, legal, financial, crisis, identity, minor/student, location, biometric, or similarly sensitive material. | Local-only guarded review; no automatic Step, share, R2, Source Atlas, or external prompt. |
| `import_denied_fallback` | Import was denied, canceled, unsupported, or unavailable. | Local receipt/explanation only. |
| `import_revoked_or_deleted` | Prior import was revoked/deleted/stale and cannot drive current behavior. | Minimal receipt/tombstone only when needed to prevent false proof or resurrection. |

## Context-To-Path Influence Matrix

| Import slot | May influence | Must not influence |
|---|---|---|
| `explicit_import_candidate` | Local review queue, Held Object, source-needed scaffold, clarification path | Finished Step, source-backed path, schedule install, public pack, R2 object, share projection |
| `local_held_object` | Preserve user intent, reduce retyping, keep manual review path | Source authority, automatic learning, external request payload, productivity scoring |
| `ocr_text_summary_needs_review` | Local review prompt, source-needed recovery, quality warning | Official-current claim, raw OCR leakage, high-risk advice, automatic Step generation |
| `reviewed_user_source_candidate` | Local planning hint, local receipt, same-goal/different-person context after review | Public Source Atlas, R2 distribution, high-risk approval, share eligibility, release proof |
| `import_denied_fallback` | Manual/source-needed fallback and no-nag explanation | Broken app state, fake precision, shame, repeated prompting |
| `import_revoked_or_deleted` | Invalidate current influence and preserve safe tombstone if needed | Continuing current influence, hidden mutation, learning update, share projection, Source Atlas/R2 content |

## Privacy Boundary

Allowed local summaries:

- import route
- user action receipt id
- local review state
- redacted title or user-visible label
- file/media kind
- extraction quality
- OCR quality labels
- source-needed/review-needed/failure reason
- local receipt/explanation id
- delete/export/revocation state

Blocked raw material:

- raw files, images, screenshots, PDFs, portable packages, and OCR text in public or external artifacts
- full file paths, exact filenames containing private details, image metadata, EXIF/GPS, faces, people, places, object labels, private document body text, contact names, account identifiers, health/legal/financial/private notes, minor/student records, and precise location details
- photo library inventory, folder inventory, browsing history, clipboard history, and background scan results

Forbidden destinations:

- R2 objects
- public Source Atlas packs, seeds, claims, requirements, or pathing data
- Linear comments containing private import/OCR details
- unredacted support bundles or diagnostics
- external prompts or hosted inference context
- analytics, telemetry, crash, or engagement payloads
- public/share/progress-story artifacts
- screenshots or visual proof containing private imported material

## Fixture Matrix

Future implementation/validator work must cover at least:

- launch core has no default Photos, Files, or OCR permission ask
- import value proof appears before any picker or permission-like surface for private media/files
- Files import uses explicit user-selected item only, not folder crawl or background file scan
- Photos import uses selected item only, not library-wide scan
- OCR runs only on explicit user-selected input and keeps text review-bound
- denied/canceled import keeps Start here, Step, Goal Detail, local closure, and recovery usable
- failed, no-text, unsupported, locked, corrupt, huge, or private-sensitive imports route to source-needed/manual support
- raw file/photo/OCR content never enters R2, public Source Atlas, Linear, logs, support bundles, external prompts, analytics, telemetry, screenshots, or public artifacts
- reviewed local user source candidate does not become public Source Atlas or source-backed path without future Source Authority/release proof
- imported high-risk-sensitive material routes through guarded review and cannot generate high-risk advice or soften unsafe-blocked behavior
- deletion/revocation invalidates current import-derived influence
- stale/source-changed imported context cannot drive current path density, Today copy, schedule fit, Step elasticity, learning, sharing, or source authority
- portable restore/import requires dry-run and conflict report before durable mutation
- fixture/test/generated import and OCR data is not production runtime proof
- Photos/Files/Vision implementation, privacy/legal, release, accessibility, device, performance, TestFlight, App Store, and App Review claims are blocked without exact proof

## Downstream Consumers

- AMB-708 / PLOS-086 CloudKit sync-state context adapter
- AMB-771 / PLOS-087 Permission value proof pattern
- AMB-710 / PLOS-088 Permission ledger and revocation controls
- AMB-619 / PLOS-M12 Multi-Path Lattice
- AMB-621 / PLOS-M14 Step Elasticity Engine
- AMB-622 / PLOS-M15 Schedule Install Kernel
- AMB-623 / PLOS-M16 Life Consequence / Cross-Goal Reflow Engine
- AMB-625 / PLOS-M18 High-risk safety, legality, and jurisdiction
- AMB-628 / PLOS-M19 Performance Runtime hardening
- AMB-632 / PLOS-M23 CloudKit/iCloud sync hardening
- AMB-633 / PLOS-M24 Observability, support, diagnostics, and data export
- AMB-635 / PLOS-M26 certification gauntlets

## Red Conditions

- import or OCR happens without explicit user action
- broad Photos/Files/library/folder/background access is requested before value proof
- raw file/photo/OCR/private import payload leaves the local/user-owned boundary
- imported private context becomes Source Atlas, R2, public pack, Linear private content, support-bundle private content, external prompt content, analytics, telemetry, crash, engagement, or share/progress-story material
- OCR-derived text is treated as official/current source without review and source authority proof
- denied, canceled, failed, revoked, deleted, stale, or source-changed import breaks Ambitions or leaves stale influence active
- imported context silently mutates goals, Steps, schedules, learning, proof, recovery, sharing, or source authority without receipt/explanation
- imported high-risk-sensitive content produces medical, legal, financial, crisis/safety, professional, evasion, harassment, or other guarded advice without future M18 authority
- import path becomes generic document management, photo gallery, task inbox, chatbot attachment feed, dashboard, or score/shame mechanic
- Photos, Files, Vision/OCR, release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or App Review readiness is claimed without exact proof

## Non-Claims

AMB-707 does not claim app source change, Swift/domain implementation, runtime adapter implementation, Photos integration, Files integration, Vision/OCR implementation, permission prompting implementation, entitlement change, privacy manifest change, UI implementation, screenshot proof, accessibility proof, device proof, measured performance proof, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, App Review readiness, R2 write, Source Atlas publication, production certification, AMB-616 parent completion, or full PLOS project completion.

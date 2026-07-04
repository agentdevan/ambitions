# Phase 2 Project Dossier Retrofit Packet — 2026-07-01

This packet is a repo-grounded instruction packet for ChatGPT/Linear. It is not the actual Linear rewrite and does not create, update, move, or close Linear objects.

## Governing baseline

- Ambitions is a premium native iPhone-first, local-first Personal Life OS.
- Today / Goals / Time / You are the only persistent surfaces.
- Capture is the global composer.
- Motion is cross-surface behavior, not a destination.
- Proof / Source / Privacy / History / Receipts are inspection details.
- Offline core value must remain usable without account sign-in.
- Source Atlas / R2 must not store the private life graph.
- External/cloud LLMs are not core architecture.
- Private Life Runtime is the moat.
- No meaningful Ambitions state changes except through Command → Event → Projection → Receipt → Replay.
- No Green claim without current proof.

## Project dossier outlines

### VSP-01 Stage OS Shell Authority

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1480 observed as VSP registry object; repo docs show Ready For Review / Yellow and a nested Spec Ready mismatch requiring owner review.

#### Mission
Represent `VSP-01 Stage OS Shell Authority` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Stage / Shell / Root routing, Context Crown, Continuity Dock, Design System / Visual Language. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Stage/AmbitionsStage.swift`
- `Native/Ambitions/Stage/AmbitionsSurface.swift`
- `Native/Ambitions/Stage/AmbitionsRootStageSurfaceHost.swift`
- `Native/Ambitions/Stage/StageDockRail.swift`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-01: Shell Authority Reconfirmation (Ready For Review / Yellow; mirror AMB-1480)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0006
- AMB-ISSUE-0007
- AMB-ISSUE-0806
- AMB-ISSUE-0901
- AMB-ISSUE-0902
- AMB-ISSUE-1011
- AMB-ISSUE-1701-1709
- AMB-ISSUE-0802
- AMB-ISSUE-1503
- AMB-ISSUE-1901-1906
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-02 Today Reality Window

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1481 observed; repo evidence supports Spec Ready / Yellow target only.

#### Mission
Represent `VSP-02 Today Reality Window` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Today, Daily / weekly / monthly review, Recovery / re-entry. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
- `Native/Ambitions/Surfaces/Today/TodayObjectView.swift`
- `Native/Ambitions/Surfaces/Today/TodayAccessibility.swift`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-02: Today Reality Window (Spec Ready / Yellow; mirror AMB-1481)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0001
- AMB-ISSUE-0004
- AMB-ISSUE-0005
- AMB-ISSUE-0016
- AMB-ISSUE-0101-0108
- AMB-ISSUE-1001-1011
- AMB-ISSUE-1201

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-03 Goals Life Area Atlas

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1482 observed; repo evidence supports Spec Ready / Yellow target only.

#### Mission
Represent `VSP-03 Goals Life Area Atlas` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Goals, Product Object Grammar, Recovery / re-entry. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift`
- `Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift`
- `Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-03: Goals Life Area Atlas (Spec Ready / Yellow; mirror AMB-1482)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0401-0406
- AMB-ISSUE-1301-1309

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-04 Time Native Life Calendar

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1483 observed; repo evidence supports Spec Ready / Yellow target only.

#### Mission
Represent `VSP-04 Time Native Life Calendar` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Time, TimeEngine, EventKit / Reminders. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Surfaces/Time/TimeSurface.swift`
- `Native/Ambitions/Surfaces/Time/TimeObjectView.swift`
- `Native/Ambitions/Surfaces/Time/TimeAccessibility.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-04: Time Native Life Calendar (Spec Ready / Yellow; mirror AMB-1483)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0009
- AMB-ISSUE-0501-0507
- AMB-ISSUE-0913
- AMB-ISSUE-1401-1405

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-05 Global Capture Composer

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1484 observed; current target is F Quiet Placement Review R3, with earlier R1/R2 retained as failure evidence.

#### Mission
Represent `VSP-05 Global Capture Composer` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Capture, CaptureRouteGraph, Share Extension, Search / Find / Act / Inspect. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`
- `Native/Ambitions/Composer/Capture/CaptureSurface.swift`
- `Native/Ambitions/Composer/Capture/CaptureObjectView.swift`
- `Native/AmbitionsShareExtension/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-05: Capture Open Field Composer (Spec Ready / Yellow; mirror AMB-1484)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0002
- AMB-ISSUE-0003
- AMB-ISSUE-0008
- AMB-ISSUE-0012
- AMB-ISSUE-0201-0205
- AMB-ISSUE-1101-1111
- AMB-ISSUE-2002
- AMB-ISSUE-2003
- AMB-ISSUE-0701
- AMB-ISSUE-1601-1605

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-06 You Native Settings

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1485 observed; repo evidence supports Spec Ready / Yellow target only.

#### Mission
Represent `VSP-06 You Native Settings` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: You, Optional account, Entitlements / subscription, Product education. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Surfaces/You/YouSurface.swift`
- `Native/Ambitions/Surfaces/You/YouRootSurface.swift`
- `Native/Ambitions/Surfaces/You/YouObjectView.swift`
- `Native/Ambitions/Trust/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-06: You Native Settings (Spec Ready / Yellow; mirror AMB-1485)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0601-0607
- AMB-ISSUE-1501-1505
- AMB-ISSUE-2004
- AMB-ISSUE-2005
- AMB-ISSUE-2007

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-07 Trust Inspection Details

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1486 observed; contextual inspection only, not a root surface.

#### Mission
Represent `VSP-07 Trust Inspection Details` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Trust / Proof / Source / Privacy / History / Receipts, TrustSystem, PrivacySecurity. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Trust/InspectionSurface.swift`
- `Native/Ambitions/Trust/ProofInspectionView.swift`
- `Native/Ambitions/Trust/SourceInspectionView.swift`
- `Native/Ambitions/Trust/PrivacyInspectionView.swift`
- `Native/Ambitions/Trust/ReceiptInspectionView.swift`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-07: Trust Inspection Details (Spec Ready / Yellow; mirror AMB-1486)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802
- AMB-ISSUE-2004-2009
- AMB-ISSUE-2012

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-08 External Boundary / Account / R2 / Source Atlas

**Recommended action:** `UPDATE`
**Target initiative:** Persistence Privacy Account Boundary
**Current state if known:** Linear mirror AMB-1487 observed; repo evidence supports Spec Ready / Yellow target only and explicitly blocks account/R2/privacy readiness claims.

#### Mission
Represent `VSP-08 External Boundary / Account / R2 / Source Atlas` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: SourceAtlas, RuntimeBoundary, Optional account, Account deletion / erasure, CloudKit / continuity, Legal / terms / privacy policy. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/DesignSystem/StagePrimitives/SharedUI/SourceAtlasUIPrimitives.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SourceAtlasNoPrivateGraphEgressAudit.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SourceAtlasPublicArtifactBoundary.swift`
- `docs/qa/source-atlas/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`
- `docs/qa/source-atlas/`
- `Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/`

#### VSP authority
- VSP-08: External Boundary / Account / R2 / Source Atlas (Spec Ready / Yellow; mirror AMB-1487)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-2004-2009
- AMB-ISSUE-2012
- AMB-ISSUE-2001
- AMB-ISSUE-2010
- AMB-ISSUE-2011

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-09 Motion Haptics Accessibility

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1488 observed; repo evidence supports Spec Ready / Yellow matrix only.

#### Mission
Represent `VSP-09 Motion Haptics Accessibility` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Motion, Accessibility proof, Performance / memory / launch time. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Stage/Motion/StageMotionReductionPolicy.swift`
- `Native/Ambitions/Stage/Motion/StageMotionAccessibility.swift`
- `Native/Ambitions/Interaction/HapticPolicy.swift`
- `Native/Ambitions/DesignSystem/Accessibility/ReduceMotionPolicy.swift`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-09: Motion / Haptics / Accessibility Matrix (Spec Ready / Yellow; mirror AMB-1488)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802
- AMB-ISSUE-0006
- AMB-ISSUE-0007
- AMB-ISSUE-0806
- AMB-ISSUE-0901
- AMB-ISSUE-0902
- AMB-ISSUE-1011
- AMB-ISSUE-1701-1709

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### VSP-10 Implementation Anatomy / Source Owner Map

**Recommended action:** `UPDATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Linear mirror AMB-1489 observed; repo evidence supports source-owner map target only, not product UI proof.

#### Mission
Represent `VSP-10 Implementation Anatomy / Source Owner Map` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Product Object Grammar, Design System / Visual Language, Build / test / CI. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `docs/design/provenance/component-registry.json`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/swift-component-inventory.generated.json`
- `Native/Ambitions/Quality/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-10: Implementation Anatomy / Source Owner Map (Spec Ready / Yellow; mirror AMB-1489)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0802
- AMB-ISSUE-1503
- AMB-ISSUE-1901-1906
- AMB-ISSUE-2001
- AMB-ISSUE-2010
- AMB-ISSUE-2011

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### LocalRuntimeOS Runtime Spine

**Recommended action:** `CREATE`
**Target initiative:** Private Life Runtime / LocalRuntimeOS
**Current state if known:** Repo contains LocalRuntimeOS source and a scoped LocalRuntimeProof Gate Green artifact, but app-wide runtime/device/release proof remains Yellow.

#### Mission
Represent `LocalRuntimeOS Runtime Spine` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Private Life Runtime, LocalRuntimeOS, CommandSpine, TransactionKernel, EventJournal, ProjectionEngine, ObjectState, Planning, TimeEngine, CaptureRouteGraph, TrustSystem, SearchRecall, SideEffectSystem, SyncContinuity, Diagnostics. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Core/LocalRuntimeOS/`
- `docs/qa/runtime/`
- `scripts/ambitions-local-runtime-proof.py`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`
- `Native/Ambitions/Core/LocalRuntimeOS/`
- `docs/qa/runtime/`
- `scripts/ambitions-local-runtime-proof.py`

#### VSP authority
- VSP-04: Time Native Life Calendar (Spec Ready / Yellow; mirror AMB-1483)
- VSP-05: Capture Open Field Composer (Spec Ready / Yellow; mirror AMB-1484)
- VSP-07: Trust Inspection Details (Spec Ready / Yellow; mirror AMB-1486)
- VSP-08: External Boundary / Account / R2 / Source Atlas (Spec Ready / Yellow; mirror AMB-1487)
- VSP-10: Implementation Anatomy / Source Owner Map (Spec Ready / Yellow; mirror AMB-1489)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-2001
- AMB-ISSUE-2010
- AMB-ISSUE-2011
- AMB-ISSUE-0001
- AMB-ISSUE-0004
- AMB-ISSUE-0005
- AMB-ISSUE-0016
- AMB-ISSUE-0101-0108
- AMB-ISSUE-1001-1011
- AMB-ISSUE-1201
- AMB-ISSUE-0401-0406
- AMB-ISSUE-1301-1309
- AMB-ISSUE-0009
- AMB-ISSUE-0501-0507
- AMB-ISSUE-0913
- AMB-ISSUE-1401-1405
- AMB-ISSUE-0002
- AMB-ISSUE-0003
- AMB-ISSUE-0008
- AMB-ISSUE-0012
- AMB-ISSUE-0201-0205
- AMB-ISSUE-1101-1111
- AMB-ISSUE-2002
- AMB-ISSUE-2003

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### Persistence Privacy Account Boundary

**Recommended action:** `CREATE`
**Target initiative:** Persistence Privacy Account Boundary
**Current state if known:** Repo has source areas and release-proof packets, but external release gates, account behavior, erasure, and legal/privacy proof are incomplete or unknown.

#### Mission
Represent `Persistence Privacy Account Boundary` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: SwiftData / local persistence, Import / export / reset, Store health / repair, Optional account, Entitlements / subscription, Account deletion / erasure, Local auth / file protection, Privacy manifest, App Group data, CloudKit / continuity, Logging / telemetry / crash privacy, Legal / terms / privacy policy. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/`
- `Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/AmbitionsWidgetExtension/*.entitlements`
- `Native/AmbitionsShareExtension/*.entitlements`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-06: You Native Settings (Spec Ready / Yellow; mirror AMB-1485)
- VSP-07: Trust Inspection Details (Spec Ready / Yellow; mirror AMB-1486)
- VSP-08: External Boundary / Account / R2 / Source Atlas (Spec Ready / Yellow; mirror AMB-1487)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-2004-2009
- AMB-ISSUE-2012
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802
- AMB-ISSUE-2001-2012

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### iOS External Surfaces

**Recommended action:** `CREATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Repo has Widget and Share extension targets in project.yml; integration proof and app aspect mapping remain partial.

#### Mission
Represent `iOS External Surfaces` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: WidgetKit, Share Extension, App Intents / Shortcuts / Siri, Notifications, EventKit / Reminders, Deep links / URL routing, Live Activities. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/AmbitionsWidgetExtension/`
- `Native/AmbitionsShareExtension/`
- `Native/Ambitions/AppIntents/`
- `Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-04: Time Native Life Calendar (Spec Ready / Yellow; mirror AMB-1483)
- VSP-05: Capture Open Field Composer (Spec Ready / Yellow; mirror AMB-1484)
- VSP-08: External Boundary / Account / R2 / Source Atlas (Spec Ready / Yellow; mirror AMB-1487)
- VSP-09: Motion / Haptics / Accessibility Matrix (Spec Ready / Yellow; mirror AMB-1488)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-2008
- AMB-ISSUE-2009
- AMB-ISSUE-2004-2009
- AMB-ISSUE-2012

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### QA Release Governance

**Recommended action:** `CREATE`
**Target initiative:** Launch Readiness / Governance
**Current state if known:** Repo has QA/quality docs and scripts; release truth remains pre-release and known issues block Green.

#### Mission
Represent `QA Release Governance` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Build / test / CI, Visual QA / screenshot diffing, Accessibility proof, Performance / memory / launch time, Known issues closure, Release train / TestFlight / App Store, Support / feedback / diagnostics, Pricing / paywall. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `docs/qa/`
- `docs/quality/`
- `scripts/ambitions-green-standard-audit.py`
- `scripts/ambitions-architecture-inventory.py`
- `scripts/ambitions-vsp-provenance-audit.py`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-09: Motion / Haptics / Accessibility Matrix (Spec Ready / Yellow; mirror AMB-1488)
- VSP-10: Implementation Anatomy / Source Owner Map (Spec Ready / Yellow; mirror AMB-1489)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802
- AMB-ISSUE-2001-2012

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

### Onboarding Reviews Guidance

**Recommended action:** `CREATE`
**Target initiative:** Ambitions Native iPhone App Control Plane
**Current state if known:** Repo truth defines product language and non-shaming posture; complete implementation/proof coverage for onboarding and reviews is partial or missing.

#### Mission
Represent `Onboarding Reviews Guidance` as a Linear project dossier grounded in repo truth and bounded by current proof ceilings.

#### Product meaning
Covers: Onboarding, Daily / weekly / monthly review, Empty states, Recovery / re-entry, Product education. The project must preserve the Ambitions product law and must not expand root IA, account/R2 authority, or runtime mutation paths beyond canon.

#### User use cases
- User can understand and operate the relevant Ambitions object or boundary without shame, fake urgency, score pressure, or network dependency for core value.
- User-facing flows preserve local-first behavior, inspection details, receipts/history where applicable, and accessible control states.

#### App surface / object ownership
- `Native/Ambitions/Surfaces/Today/`
- `Native/Ambitions/Surfaces/Goals/`
- `Native/Ambitions/Surfaces/Time/`
- `Native/Ambitions/Surfaces/You/`
- `Native/Ambitions/Language/`

#### Non-goals / hard reds
- Do not make Capture, Motion, Trust, Proof, Source, Privacy, History, or Receipts persistent root destinations.
- Do not route private life graph data to R2, Source Atlas, CloudKit, accounts, hosted AI, or external services.
- Do not bypass Command → Event → Projection → Receipt → Replay for meaningful state changes.
- Do not claim Green, release readiness, known issue closure, or Ready For Codex without current scoped proof.

#### Repo truth evidence
- `README.md`
- `AGENTS.md`
- `docs/truth/README.md`
- `docs/truth/CODEX_START_HERE.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_ORIGIN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_EXPERIENCE_CANON.md`
- `docs/design/provenance/vsp-provenance.json`
- `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md`
- `docs/design/provenance/Figma-Annotation-Pack.md`
- `docs/design/provenance/linear-map.json`
- `docs/design/provenance/proof-registry.json`
- `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`
- `docs/qa/KNOWN_ISSUES.md`
- `docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md`
- `docs/quality/`

#### VSP authority
- VSP-02: Today Reality Window (Spec Ready / Yellow; mirror AMB-1481)
- VSP-03: Goals Life Area Atlas (Spec Ready / Yellow; mirror AMB-1482)
- VSP-04: Time Native Life Calendar (Spec Ready / Yellow; mirror AMB-1483)
- VSP-06: You Native Settings (Spec Ready / Yellow; mirror AMB-1485)
- VSP-09: Motion / Haptics / Accessibility Matrix (Spec Ready / Yellow; mirror AMB-1488)

#### Runtime dependencies
- LocalRuntimeOS runtime law where state changes occur.
- Trust/receipt/proof boundaries where inspection or privacy is involved.
- No implementation leaf may invent missing visual grammar or runtime authority.

#### Source Atlas / R2 / privacy boundary, if relevant
Source Atlas/R2 are public/reference/freshness infrastructure only. They must not store the private life graph. If this project touches account, sync, Source Atlas, privacy, diagnostics, external intake, widgets, or extensions, Phase 3 must add an explicit no-private-graph-egress proof requirement.

#### Accessibility requirements
VoiceOver order, Dynamic Type, Reduce Motion/Transparency, color/contrast, hit target, motor accessibility, and screenshot/preview proof must be present for UI-affecting leaves before any Green claim.

#### Copy/state language
Use locked language: `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo`. Avoid AI branding, shame, fake urgency, streak pressure, score pressure, and productivity-guilt framing.

#### Known issue mappings
- AMB-ISSUE-0001
- AMB-ISSUE-0004
- AMB-ISSUE-0005
- AMB-ISSUE-0016
- AMB-ISSUE-0101-0108
- AMB-ISSUE-1001-1011
- AMB-ISSUE-1201
- AMB-ISSUE-0401-0406
- AMB-ISSUE-1301-1309
- AMB-ISSUE-0601-0607
- AMB-ISSUE-1501-1505
- AMB-ISSUE-2004
- AMB-ISSUE-2005
- AMB-ISSUE-2007
- AMB-ISSUE-0013-0015
- AMB-ISSUE-0801-0807
- AMB-ISSUE-0903-0912
- AMB-ISSUE-1801
- AMB-ISSUE-1802

#### Parent Feature requirements
Parent Feature must include mission, product role, non-goals/hard reds, VSP authority, source-owner paths, known issues, validation commands, proof artifacts, rollback plan, and proof ceiling.

#### Codex leaf requirements
Each leaf must have exact bounded scope, likely files, tests, validation commands, accessibility/screenshot requirements where UI is affected, rollback plan, proof ceiling, and done criteria. Leaves must not ask Codex to invent visual grammar.

#### Validation commands
- `git diff --check`
- `python3 scripts/ambitions-green-standard-audit.py || true`
- `python3 scripts/ambitions-architecture-inventory.py || true`
- `python3 scripts/ambitions-vsp-provenance-audit.py || true`

#### Proof required for Green
Current repo proof is not enough for Green. Green requires current scoped implementation proof, rendered/device proof where UI is affected, manual accessibility proof, runtime receipt/replay proof where state changes occur, privacy boundary proof where data leaves a local process, known issue closure evidence, and owner review where required.

#### Explicit non-claims
- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.


## Non-claims

- No source implementation is authorized by this packet.
- No Linear status movement is authorized by this packet.
- No Linear object creation is performed by this packet.
- No Visual Green, app-wide Runtime Green, Release Green, TestFlight readiness, App Store readiness, issue closure, or Ready For Codex promotion is claimed.

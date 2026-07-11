# Ambitions Domain Module Extraction Design

Status: Owner-approved implementation direction
Date: 2026-07-11
Decision record: ADR-BUILD-002
Depends on: ADR-BUILD-001 and the completed Build Architecture Foundation and Pilot
Scope: Core/Domain readiness, evidence-backed consolidation, static AmbitionsDomain extraction, module proof, and throughput measurement
Claim status: Aspirational until implementation and current proof satisfy every scoped gate

## 1. Purpose

Phase 2 extracts the complete canonical Domain boundary into one compiler-enforced static module without moving its source paths, weakening behavior, or publishing unnecessary implementation details.

The design optimizes for the fastest sustainable development loop:

1. preserve the existing canonical source tree;
2. avoid artificial submodules and dependency cycles;
3. delete or consolidate only when current evidence proves safety;
4. expose the minimum cross-target API required by named consumers;
5. prove domain behavior independently from the application;
6. measure the resulting edit-build-test loop before Runtime decomposition.

This phase does not extract Runtime, Projection, Trust, Composer, a surface, Stage, or app composition.

## 2. Current evidence

Live evidence at the approved design point establishes:

- Native/Ambitions/Core/Domain contains 166 Swift files and 35,565 lines.
- The 124 files directly under Core/Domain contain approximately 25,938 lines.
- Core/Domain/GoalEngine contains 40 files and approximately 8,934 lines.
- Core/Domain/ProofMode contains one 141-line file.
- Core/Domain/Reschedule contains one 552-line file.
- All 166 Domain files import Foundation.
- Six Domain files also import CryptoKit.
- No Domain file imports SwiftUI, UIKit, AmbitionsDesignSystem, AmbitionsWidgetUI, AmbitionsTimeFoundation, or a LocalRuntimeOS module.
- The current source disposition inventory classifies all 166 Domain files as unknown_pending_stronger_evidence.
- Therefore, the existing inventory authorizes zero Domain deletions.
- The broader Core-to-UI/design dependency debt is outside Domain: the current matches are under Core/LocalRuntimeOS and Core/Persistence.
- The completed time-module pilot proves canonical-path XcodeGen static frameworks, aggregate module tests, explicit imports, strict concurrency, and stable-cache benchmarking on this host.
- Current warm pilot medians were 4 seconds for project startup, 4 seconds for module build-for-testing, 6 seconds for module test-without-building, 9 seconds for leaf edit through proof, and 6 seconds for app-unit build-for-testing.

The Domain folder is already dependency-clean enough to extract. Its principal risk is public-API expansion, not dependency inversion.

## 3. Decision

Create one XcodeGen-managed static framework target:

~~~text
AmbitionsDomain
~~~

Its source membership is every Swift file recursively under:

~~~text
Native/Ambitions/Core/Domain
~~~

The files remain at those exact canonical paths.

Do not create separate GoalEngine, ProofMode, Reschedule, DomainModels, DomainContracts, or Shared targets in this phase.

The target depends only on Apple system frameworks already required by its source:

~~~text
Foundation
CryptoKit
~~~

AmbitionsDomain does not depend on:

~~~text
Ambitions
AmbitionsTimeFoundation
AmbitionsDesignSystem
AmbitionsWidgetUI
LocalRuntimeOS
Projection
Trust
Composer
Surfaces
Stage
App
~~~

The application, tests, and later modules may depend on AmbitionsDomain only through explicit target edges and explicit imports.

## 4. Why one complete Domain module

### 4.1 Whole Domain is the natural ownership boundary

Domain root models, GoalEngine contracts, GoalEngine services, proof-mode routing, and rescheduling behavior form one semantic layer. Splitting by current subfolder would create interfaces based on directory shape rather than stable ownership.

GoalEngine depends extensively on root Domain types. Reschedule behavior is consumed by runtime and surface services. ProofMode is one file rather than an independently valuable build boundary.

One Domain module avoids:

- cycles between root models and GoalEngine;
- a shared-contract dumping ground;
- one target per concept;
- duplicate public wrappers;
- repeated module loading and linking;
- premature permanence for current subfolder names.

### 4.2 Runtime cleanup moves to Phase 3

The live Core-to-UI/design imports are in LocalRuntimeOS and Core/Persistence, not Domain. Repairing them before Domain extraction would delay a clean boundary and mix two independently reviewable changes.

Phase 3 begins only after this phase proves the Domain API, graph, behavior, and throughput. Phase 3 owns Runtime dependency inversion and Runtime extraction design.

## 5. Canonical ownership

The Final Architecture Tree remains exact path law.

Canonical owner touched:

~~~text
Native/Ambitions/Core/Domain
~~~

Build configuration touched:

~~~text
project.yml
Ambitions.xcodeproj/project.pbxproj
~~~

Tests may remain under their current canonical test paths or move into the existing aggregate module-test root:

~~~text
Native/AmbitionsModuleTests
~~~

No production source moves to Packages. No source moves out of Core/Domain.

The build target is a compiler boundary, not a new product concept, user-facing term, or replacement source tree.

## 6. Public API discipline

### 6.1 Default access

All declarations remain internal by default.

A declaration becomes public only when:

1. a named file outside AmbitionsDomain requires it;
2. the consuming target has a justified dependency edge;
3. the declaration belongs to the stable Domain contract;
4. the declaration and required members have focused coverage;
5. no narrower public facade or value representation can satisfy the consumer.

Compiler errors are discovery evidence, not automatic permission to mark an entire type family public.

### 6.2 Consumer inventory

Before promotion, implementation records for every public declaration:

- declaration name and canonical source file;
- declaration kind;
- consuming target;
- exact consuming files;
- reason the consumer needs the declaration;
- tests covering the contract;
- whether a narrower interface was considered;
- whether the declaration is stable Domain contract or migration debt.

The inventory is generated from live imports, compiler diagnostics, and current source references. Lexical counts alone are insufficient.

### 6.3 Public API budget

The phase records, but does not preselect, a numeric API budget before compilation evidence exists.

The binding rules are qualitative:

- no public storage solely for test convenience;
- no public helper used only inside Domain;
- no public initializers broader than required construction paths;
- no @_exported import;
- no blanket mechanical public conversion;
- no public suffix fragment solely because another fragment needs access;
- no new shared bucket to hide cross-module design problems.

A materially excessive API surface blocks the extraction. The boundary must be redesigned or consolidated rather than forced through.

### 6.4 Test access

Module-local tests may use @testable import AmbitionsDomain.

Application integration tests import AmbitionsDomain explicitly only when they directly exercise a public Domain contract. Test-only builders remain under test support and do not justify production API.

## 7. Destruction and consolidation

### 7.1 No deletion quota

All 166 Domain files are currently unknown. No file is deleted because of age, suffix, filename, line count, or zero lexical references.

This phase has no deletion-count target.

### 7.2 Required evidence

A Domain file or declaration may be deleted or consolidated only after checking:

- compiler references and target membership;
- runtime construction through LocalRuntimeOS;
- SwiftData schema, migration, replay, and persistence compatibility;
- App Intents, widgets, share extension, and reflection/dynamic discovery;
- fixtures, previews, generated registries, and scripts;
- serialization identities and Codable compatibility;
- focused Domain tests and affected integration tests.

A zero-result text search is supporting evidence only.

### 7.3 Suffix review

Existing suffix files are review inputs. This phase may collapse an arbitrary split only when:

- both files have the same canonical owner;
- the resulting file remains below the hard line cap;
- responsibilities become clearer;
- compile invalidation does not worsen materially;
- current tests prove identical behavior;
- no serialization or source-path registry contract depends on the old path.

No new numbered suffix file or broad Models.swift file is allowed.

### 7.4 Unknown remains retained

If evidence is incomplete, the file remains in Domain and its disposition remains unknown. Uncertainty is not converted into deletion authority to make the module smaller.

## 8. Target graph

The Phase 2 graph adds:

~~~text
Ambitions -> AmbitionsDomain
AmbitionsTests -> AmbitionsDomain
AmbitionsModuleTests -> AmbitionsDomain
~~~

The existing time edges remain:

~~~text
Ambitions -> AmbitionsTimeFoundation
AmbitionsTests -> AmbitionsTimeFoundation
AmbitionsModuleTests -> AmbitionsTimeFoundation
~~~

AmbitionsDomain and AmbitionsTimeFoundation are siblings. Neither depends on the other during this phase.

The app target excludes every Swift file recursively under Core/Domain after the Domain target owns them. A Domain file may have exactly one production target membership.

The graph audit must report:

- nested design-system package path only;
- both module targets;
- required target edges;
- zero cycles;
- zero duplicated Domain production membership.

## 9. Test architecture

### 9.1 Module-only tests

The existing AmbitionsModuleTests target gains focused Domain tests.

The first module-only suite proves:

- representative value semantics and Codable round trips;
- deterministic GoalEngine behavior;
- rescheduling behavior;
- proof-mode routing;
- CryptoKit-backed identity behavior where present;
- no dependency on application, runtime, UI, persistence, simulator state, or wall-clock time.

Tests are selected from existing behavior contracts or rewritten at the module boundary without weakening assertions.

### 9.2 Integration tests

The application test target retains affected integration coverage for:

- Goal creation and editing;
- GoalEngine planning/path compilation;
- LocalRuntimeOS command/event/projection behavior consuming Domain;
- Today and Goals projections using Domain contracts;
- rescheduling and conflict behavior;
- persistence encoding/decoding and replay;
- proof and receipt behavior where Domain identities participate.

The implementation plan must name exact test classes after the consumer inventory is generated.

### 9.3 Release compilation

Debug-only success is insufficient.

The phase verifies:

- module Debug build;
- application Debug build-for-testing;
- application Release build with code signing disabled;
- DEBUG-only fixtures remain guarded;
- public access compiles in Release;
- no test-only import leaks into production.

## 10. Benchmark design

All samples use:

~~~text
.codex/DerivedData/Ambitions
~~~

The single-lane lock is mandatory. No competing Xcode process may overlap a sample.

Each scenario has three warm samples with authoritative package identity:

1. project startup;
2. Domain module build-for-testing;
3. Domain module test-without-building;
4. one Domain implementation edit through focused proof;
5. one GoalEngine implementation edit through focused proof;
6. no-change app-unit build-for-testing;
7. affected Domain integration test-without-building.

Temporary benchmark edits are comments only, applied and reversed with apply_patch, and verified byte-identical afterward.

Provisional targets:

| Scenario | Target |
|---|---:|
| Project startup median | <= 15 seconds |
| Domain module no-change build median | <= 30 seconds |
| Domain module test median | <= 30 seconds |
| Domain leaf edit through proof median | <= 60 seconds |
| GoalEngine edit through proof median | <= 90 seconds |
| No-change app-unit build median | <= 30 seconds |
| Focused integration test median | <= 30 seconds |

A missed performance target blocks the throughput claim, not product correctness. A material regression triggers boundary redesign before Runtime planning.

## 11. Implementation sequence

### Slice 1 — Domain boundary census

- Generate the exact recursive Domain source list.
- Generate outside-Domain consumer files and targets.
- Record declaration-level public API candidates.
- Record suffix, file-size, serialization, dynamic-discovery, migration, and registry risks.
- Identify proven consolidation candidates.
- Produce no source deletion without the required evidence.

### Slice 2 — Module-only RED

- Add Domain module tests that import AmbitionsDomain.
- Add the target edge before the production target exists.
- Regenerate and capture the intended missing-target RED.
- Do not commit an unresolved project.

### Slice 3 — Static Domain extraction

- Add the static AmbitionsDomain target.
- Exclude all Domain files from the app target.
- Add explicit target edges and imports.
- Promote only compiler-proven external contracts.
- Preserve exact canonical paths.
- Prove module graph, Release access, and single membership.

### Slice 4 — Behavior proof

- Build and run module tests.
- Build the application once.
- Run named integration tests without rebuilding.
- Repair behavior or access-control regressions.
- Run governance, constitution, graph, truth-path, and diff gates.
- Keep unrelated pre-existing findings explicit.

### Slice 5 — Throughput and graph truth

- Capture the seven benchmark scenarios.
- Regenerate the disposition inventory.
- Update current module graph and scorecard only from generated evidence.
- Record public API inventory and consolidation outcomes.
- Apply the Phase 3 gate.
- Stop before Runtime source work.

## 12. Phase 3 gate

Runtime dependency cleanup and extraction planning may begin only when:

~~~text
AmbitionsDomain static target = Green
Domain single production membership = Green
Domain dependency cycle audit = Green
module-only Domain tests = Green
affected integration tests = Green
Release compilation = Green
public API review = Green
serialization/migration/replay checks = Green
temporary benchmark edits restored = Green
Domain edit throughput = neutral or faster
current disposition inventory = regenerated
whole-phase independent review = clean
~~~

Phase 3 planning must use the resulting compiler graph and public API inventory. It may not assume the original Runtime target proposal remains optimal.

## 13. Failure handling

- If Domain requires a UI, Stage, surface, runtime, persistence, or time dependency, stop and repair ownership rather than adding the edge.
- If public API expansion becomes mechanically broad, stop and redesign the boundary.
- If a Domain file cannot leave the app target because of dynamic or generated behavior, keep the phase Yellow and identify the exact repair.
- If a consolidation changes serialization, migration, replay, or identity behavior, revert it independently.
- If module extraction causes a material build regression, combine, reorder, or revert the boundary before Phase 3.
- No mass source movement and behavior change share a commit.
- Each slice remains independently reviewable and revertible.

## 14. Proof ceiling and non-claims

Design approval proves only the intended approach.

It does not prove:

- AmbitionsDomain exists;
- any Domain declaration is safely public;
- any Domain file is deletable;
- Domain behavior, serialization, migration, or replay is preserved;
- module, app, test, or Release compilation;
- benchmark targets;
- Runtime readiness;
- device, visual, accessibility, privacy/legal, CI, TestFlight, App Store, or release readiness.

Implementation closeout must remain Yellow whenever required proof is missing or failed.

## 15. Design acceptance

Owner-approved direction:

- extract the complete coherent Domain boundary rather than directory-shaped submodules;
- defer Runtime UI/design dependency cleanup to Phase 3;
- preserve canonical Domain source paths;
- use compiler-backed consumer evidence for minimal public API;
- delete or consolidate only with current safety proof;
- measure Domain and GoalEngine edit loops before Runtime planning;
- stop at a reviewed Phase 3 planning gate.

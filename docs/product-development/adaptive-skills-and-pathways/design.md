+++
initiative = "adaptive-skills-and-pathways"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The design is a final integration contract and acceptance harness over existing
child-owned product flows. It adds one canon journey map and test-only fixtures;
it adds no production object, store, command, coordinator, projection, surface,
route, asset, copy, or motion authority.

Each handoff is an immutable, typed value already owned by its producer. The
receiver freezes the identity and revision set it consumes, checks provenance,
sensitivity, authority, lifecycle and freshness, and either proceeds, degrades
with an exact reason, or stops. The acceptance harness exercises the complete
journey only after child implementations and their own proof gates exist.

## User flows

### Preserve progress and explore a direction

1. The user completes capability-bearing activity and accepts any associated
   Proof through the existing Goal/Closure owners.
2. Capability policy may propose a descriptive practiced claim. The user may
   inspect, refine, reject, or confirm it in the child-owned Goals/You flow.
3. A recommendation owner locally combines selected direction, permitted
   Capability projections, and verified public references. It presents
   continuity and aspiration lanes without ranking a winner.
4. The user inspects evidence, sources, gaps, uncertainty, and limits. No Goal
   exists until the user explicitly chooses adoption.

### Adopt, route, compare, and place

1. Destination adoption performs duplicate review and creates at most one
   provisional Goal through the Goal owner.
2. Goal Path generation produces revision-bound route proposals. Adaptive
   comparison may compare materially distinct same-outcome proposals without
   mutating the Goal or current path.
3. Explicit acceptance returns one proposal to the Goal Path owner for fresh
   validation and version creation.
4. Generated Steps may enter context-quality scheduling. Placement remains a
   preview until the Scheduling owner receives exact confirmation.

### Correct, delete, or change direction

1. A correction is applied by the exact Capability, preference, source,
   requirement, path, context, or schedule owner.
2. Dependent projections invalidate from the changed revision and recompute or
   degrade; no historical event is rewritten.
3. A new destination uses adoption/pivot and preserves the old Goal, Proof, and
   History. A same-outcome route change stays in Goal Path. A multi-object
   conflict reaches Life Branch only when its approved necessity threshold is
   satisfied.

## States and recovery

- **Not ready:** one or more child implementations, migrations, visual gates,
  or required proofs are incomplete. Integration tasks remain blocked.
- **Ready for acceptance:** every required child owner and handoff is present at
  a compatible revision; no end-to-end proof is implied yet.
- **Available:** a typed handoff is valid, current, permitted, and supported.
- **Unknown:** evidence or classification is insufficient; the receiver shows
  or records what is unknown and offers the owning review action.
- **Stale/conflicted/withdrawn:** the exact source or projection state remains
  inspectable and cannot silently authorize a downstream claim.
- **Permission blocked:** private or sensitive data is not used; recovery routes
  to the owning permission control without weakening the boundary.
- **Revision changed:** the receiver discards the stale snapshot and requests a
  fresh one. It does not retry a mutation from an old handoff.
- **Interrupted:** test and product flows resume from the last child-owned
  checkpoint; no integration checkpoint becomes mutation truth.
- **Correction/deletion pending:** future influence remains blocked until every
  dependent projection observes the new owner revision.
- **Accepted:** all required evidence lanes pass at their honest proof ceiling.
  External success, release, and App Store readiness remain separate.

## Frontend experience specification

- Surface impact: none
- IA/navigation: none
- Assets/iconography: none
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: N/A — no integration-owned production interface or copy is introduced; visible language remains owned by the approved child Designs.
- Accessibility: The test harness verifies the child-owned semantic order, reflow, non-color meaning, assistive actions, focus, announcements, reduced effects, and interruption recovery without adding UI semantics of its own.
- Visual proof: N/A for this initiative because it creates no production visual artifact; every child frontend implementation retains its required native calibration, owner approval, screenshot, runtime, accessibility, and device evidence.
- Visual gate: not-required
- Experience authority: Existing Goals, You, Time, Today, and Trust child Designs remain the sole experience authority. Integration tests may navigate and assert them but may not change their hierarchy or presentation.

## Architecture and data

### Canon journey map

`docs/canon/specifications/journeys/adaptive-skills-and-pathways.md` contains a
normative owner-and-handoff table. Each row names producer, typed output,
receiver, receiver revalidation, mutation boundary, degraded result, and
forbidden claim. Links point to child specifications rather than copying their
requirements.

### Test-only acceptance harness

`Native/AmbitionsTests/Support/AdaptiveSkillsPathwaysJourneyFixture.swift`
builds deterministic synthetic identities and revisions for an astronaut-style
scenario. It contains public references and private user state in separate
fixtures and exposes only the child-approved handoff types. It is test code,
not a production data source or seeded user profile.

`Native/AmbitionsTests/Runtime/AdaptiveSkillsPathwaysIntegrationTests.swift`
drives the child services in dependency order and records owner outputs. It
does not introduce an integration coordinator. Static boundary tests reject a
new production type whose name or storage registration claims umbrella journey
ownership.

### Data, persistence, migration, and concurrency

The initiative adds no production persistence and therefore no migration.
Child stores remain separately actor-isolated and revisioned. Integration tests
freeze all participating revisions, inject cancellation and conflicts at each
handoff, and require receiver-side revalidation. Replay starts from child event
logs and stores; the test harness itself has no replay state. Crash/relaunch
proof verifies that no test-only checkpoint or aggregate success marker is
required for recovery.

### Dependency and rollout boundary

This project is sequenced after every operational child group. Its first task
may add the canon map before implementation completion, but runtime and journey
tests remain blocked until the named child APIs exist and their focused tests
pass. No compatibility shim may erase a child contract to unblock integration.

## Privacy and accessibility

Public fixture requests contain fixed public artifact identifiers only. Private
Capability, Goal, Proof, constraint, schedule, recommendation, credential,
branch, and history state is injected only into local test/runtime owners.
Request-capture and no-private-graph audits fail on labels, derived summaries,
or identifiers that could expose protected context. Sensitive or ambiguous
derived output is omitted unless a separate approved owner explicitly permits
it.

The acceptance journey uses the existing app's UI-test seams only after child
visual approval. Automated semantics are necessary but not sufficient. Final
evidence includes physical-device VoiceOver, Voice Control, Switch Control,
keyboard, largest Dynamic Type, orientation/reflow, non-color status, reduced
effects, focus restoration, and interruption recovery across each transition.

## Requirement traceability

- REQ-001 → Canon owner map, no-production-owner rule, static duplicate-owner audit.
- REQ-002 → Typed handoff matrix and receiver revision validation.
- REQ-003 → Capability proposal fixture and completion-only rejection cases.
- REQ-004 → Split public/private fixtures, fixed-ID request capture, local join audit.
- REQ-005 → Recommendation non-claim assertions and zero-Goal pre-adoption state.
- REQ-006 → Duplicate review and destination-adoption confirmation boundary.
- REQ-007 → Side-effect-free generation/comparison and Goal Path revalidation.
- REQ-008 → Context-fit preview and Scheduling-owned confirmation.
- REQ-009 → Route, destination, dormant exploration, and Life Branch routing matrix.
- REQ-010 → Correction/deletion invalidation and truthful-history assertions.
- REQ-011 → Missing/stale/conflicted/withdrawn degradation matrix.
- REQ-012 → Forbidden score/rank/probability source and UI audits.
- REQ-013 → Frozen revisions, cancellation, race, idempotency, crash, and replay tests.
- REQ-014 → Derived-sensitivity fail-closed fixtures and privacy boundary scan.
- REQ-015 → Existing-surface automated and physical-device accessibility matrix.
- REQ-016 → Complete proof ledger with explicit evidence ceilings.

## Verification design

- Automated: lifecycle/canon checks, owner/handoff matrix, golden scenario,
  degradation matrix, forbidden-authority scan, dependency and traceability.
- Build: XcodeGen determinism and build-for-testing after all child modules land.
- Runtime: complete happy path plus every handoff unavailable, stale, conflicted,
  canceled, corrected, deleted, interrupted, and replayed.
- Accessibility: automated semantics plus physical-device assistive-technology
  evidence across the existing child-owned journey.
- Privacy/security: request capture, no-private-graph egress, derived sensitivity,
  local-only persistence, minimization, and no hosted inference.
- Migration/replay: child migration matrices and pre/post replay equivalence;
  no integration migration exists.
- Performance: bounded end-to-end latency, memory, energy, and storage measured
  without hiding the cost of individual child stages.
- External/device/release: named-device rendered proof is required; external
  acceptance, real provider outcomes, release, and App Store claims remain out
  of scope.

## Open decisions

None. A request for new integration UI, umbrella persistence, aggregate scoring,
automatic mutation, sensitive inference, or weakened child authority must
return to Scope or begin a separately approved lifecycle.

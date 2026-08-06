+++
initiative = "personal-context-and-constraint-controls"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add a protected local `PersonalContextRegistry` containing immutable revisioned
`ContextFact` records and separate `ContextPurposeGrant` records. Consumers use
a capability-scoped `PersonalContextReadClient` to request an ephemeral minimal
`ResolvedContextView`; they cannot enumerate/write. A deterministic resolver
handles states, precedence, conflicts, units and task-local overrides. An
`InfluenceReceipt` records category/fact opaque IDs and reason/effect codes only.

## User flows

- **Add in context:** a proposal says “Cost is unknown” and offers Add budget /
  Continue without it. A sheet explains purpose, value, retention and fallback.
  Saving creates the fact and optional purpose grant; skipping continues.
- **Review context:** category list shows active/expired/disabled/conflicting,
  purposes and last confirmation. Detail supports edit, duplicate as task-local,
  disable, archive, delete and inspect influences.
- **What-if:** from a draft, user excludes/changes a fact for this run. Recompute
  shows changed influences; registry remains unchanged unless Save as context.
- **Conflict:** results show both facts, affected decision and alternatives; user
  can change task override or facts. No silent relaxation.
- **Delete/reset:** impact preview lists affected drafts/accepted owners. User
  selects category/purpose/all; purge progress/retry is visible. Owners become
  context-needed without being mutated.

## States and recovery

Fact: `active`, `unknown`, `notIncluded`, `declined`, `notApplicable`,
`unavailable`, `conflicting`, `expired`, `disabled`, `archived`, `deleting`,
`deleted`. Grant: `notGranted`, `active`, `expired`, `revoked`. Resolution:
`ready`, `partial`, `conflicted`, `purposeDenied`, `staleRevision`, `unavailable`.

One registry actor serializes mutations and one purge journal scopes deletion.
Read views capture registry/grant/timezone/locale revisions and expire after the
request. Consumers discard stale results. Calendar/timezone changes re-resolve
future occurrences and notify exact dependents; values are not rewritten
silently. Interrupted save/migration/purge resumes idempotently.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 7 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Models

Add under `Native/Ambitions/Core/LocalRuntimeOS/PersonalContext/`:

- `ContextFactModels.swift` with category-specific typed payload enums;
- time/recurrence/money/place/equipment/responsibility/accessibility/sensitive/
  tradeoff payloads and explicit unknown states;
- sensitivity, provenance, status, applicability and strength models;
- `ContextPurposeGrantModels.swift`, policy and store;
- `TaskLocalContextOverrideModels.swift`;
- repository/event/store/migration;
- resolver, precedence/conflict engine, unit/timezone resolver;
- read capability/client/view assembler;
- influence models/recorder/projector;
- dependency index/notifier, impact preview, archive/reset/purge; and
- disabled `ContextSuggestionClient` whose implementation requires a promoted
  local-learning policy.

Use Foundation `Calendar`, `TimeZone`, `Locale`, `Currency`/format styles and
`Measurement` semantics; persist stable identifiers and original user value,
not preformatted text or fixed offsets.

### Interfaces

```
resolve(ContextRequest(purpose, categories, objectRevision, overrides))
  -> ResolvedContextView
recordInfluence(InfluenceDraft, resultRevision) -> InfluenceReceipt
previewImpact(ContextMutationDraft) -> ContextImpactPreview
commit(ContextMutationCommand) -> ContextMutationReceipt
```

Read capabilities are registered per consumer/purpose/category. The returned
view contains allowed typed facts plus missing/conflict reason codes and a view
expiry; it is non-persistable outside the consuming draft's bounded evidence
snapshot. There is no general `allFacts`, inference, remote export or canonical
command interface.

### Ownership and data flow

Context mutation runs through the registry's preview/confirm/commit/replay
boundary and produces History/Receipt. Consumer resolution is read-only. A
consumer may store opaque fact/revision and value-hash influences sufficient to
explain/revalidate; sensitive clear values remain in the registry and are
resolved only with current grants. Public source claims are joined ephemerally
in the consumer, never copied into context.

Impact preview queries opaque dependency records. Change/delete emits a notifier
event. Destination/path/schedule/simulation/action owners decide whether to
recompute and require their own confirmation for accepted mutations.

### Migration, reset and deletion

Existing explicit planning defaults/life-context facts migrate only when source,
meaning, unit and consent/purpose can map. Ambiguous values remain legacy
read-only/not-included until confirmed. No behavior history is mined during
migration. Purge removes facts, grants, events allowed for deletion, indices,
influence snapshots, derived views, caches, exports and continuity copies;
minimal tombstones contain no value or note. Accepted owner receipts retain only
“context unavailable/deleted” where necessary.

## Privacy and accessibility

Protected storage uses existing device protection/encryption and never Source
Atlas/R2/telemetry. Notes are high sensitivity and excluded from model contexts
unless a task explicitly registers them. The registry exposes category/purpose
counts in diagnostics, no values or precise place/time. Screens never imply that
adding more data is required for core use.

Forms use plain labels, examples and unit-aware native controls with manual text
alternatives. Recurrence/timezone/conflict/influence meaning has ordered text.
Sensitive fields receive private announcements and redacted app-switcher/
notification behavior. VoiceOver, Voice Control, Switch Control, keyboard,
largest Dynamic Type, Reduced Motion, RTL, locale/currency and non-color state
are covered; focus returns to the affected fact/action after save/delete.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Typed immutable ContextFact payloads/revisions |
| REQ-002 | Explicit fact/status/resolution enums |
| REQ-003 | In-context skippable capture; no onboarding gate |
| REQ-004 | Disabled suggestion client requiring confirmation/promotion |
| REQ-005 | Separate expiring purpose grant store |
| REQ-006 | Sensitivity policy and optional generic fallback |
| REQ-007 | Capability-scoped no-enumeration ephemeral read client |
| REQ-008 | Deterministic precedence/conflict engine |
| REQ-009 | Read-only views and notifier-only handoffs |
| REQ-010 | Influence receipts/projector with reason/effect codes |
| REQ-011 | TaskLocalContextOverride independent of registry |
| REQ-012 | Impact preview and dependency notifier |
| REQ-013 | Repository/events/journaled scoped purge |
| REQ-014 | Foundation identifier-based unit/time resolver |
| REQ-015 | No-value diagnostics and canary audit |
| REQ-016 | Native accessible forms/list semantics/non-shaming copy |
| REQ-017 | Suggestion/default policy unavailable gate |

## Verification design

- Round-trip/property tests for every payload/unit/timezone/recurrence/status.
- Purpose/grant/sensitivity/no-enumeration and private-canary tests.
- Precedence/conflict/unknown/task-local override golden matrices.
- DST/timezone/calendar/locale/currency change and replay fixtures.
- Mutation/no-consumer-write/no-canonical-mutation spies.
- Concurrency/stale-view/migration/archive/reset/fault-purge/deletion-terminal tests.
- Accessibility/localization/device tests for every form/state/influence/impact.
- Direct-user studies for capture burden, vocabulary, conflict comprehension,
  influence trust and non-shaming alternatives; suggestion defaults stay off
  until v1 interaction evidence passes.

## Open decisions

None for manual/purpose-controlled context. Automatic suggestion thresholds and
default prompts remain deliberately unavailable configuration, not unresolved
architecture.

Review verdict: **PASS** after two reconciliation rounds. Review isolated clear
values from consumer receipts, made suggestions unavailable by default and made
timezone/unit/migration/deletion behavior exact. Devan delegated approval;
Design approved 2026-08-04.

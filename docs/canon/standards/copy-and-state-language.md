+++
spec_id = "STANDARD-COPY-STATE-LANGUAGE"
title = "Copy and State Language"
kind = "standard"
status = "normative"
owner_domain = "standard-copy-state-language"
canon_revision = 1
profile = "standard-v1"
owns_concepts = [
  "language.locked-vocabulary",
  "language.state-consequence",
  "language.humane-tone",
  "language.localization-construction",
  "language.temporal-locale",
  "language.layout-resilience",
  "language.store-localization",
  "copy.visibility-classification",
]
inherits = ["LAW-IA-PLAIN-LANGUAGE-001", "LAW-LANGUAGE-ROOT-LABELS-001", "CONTROL-FORCE-NOTHING-001"]
depends_on = ["CONSTITUTION", "STANDARD-ACCESSIBILITY"]
source_owners = ["Native/Ambitions/Language/", "Native/Ambitions/DesignSystem/", "Native/Ambitions/Quality/"]
+++

# Copy and State Language

This standard owns reusable vocabulary, tone, localization, and state-copy constraints. Exact object and surface copy stays with its specification owner.

## COPY-LOCKED-VOCABULARY-001 — Locked product terms
- **Concept:** `language.locked-vocabulary`
- **Modality:** `MUST`
- **Scope:** User-facing product language
- **Status:** `normative`
- **Verification:** `AUDIT-LOCKED-VOCABULARY-001`
- **Supersedes:** none

Copy MUST use `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, `Still counts`, `Move it`, `Blocked`, `Waiting`, `Not needed`, `Protected`, `Review`, and `Undo` in their owning contexts and MUST NOT reintroduce stale or architecture-facing synonyms.

Domain state and user-facing copy MUST be separate.

Ambitions MAY use direct “you” language.

Locked product vocabulary MUST prevent runtime internals from leaking into primary UI.

Terms classified as user-facing MAY appear prominently in the app.

Terms classified as contextual MAY appear when attached to a clear object or action.

Terms classified as inspection-only SHOULD appear only when the user asks why, opens details, or reviews history.

Terms classified as internal MAY exist in code, documentation, tests, and implementation plans but SHOULD NOT appear in ordinary primary UI.

“Still counts” MUST be a core emotional and functional product behavior.

## COPY-STATE-CONSEQUENCE-001 — State and consequence are explicit
- **Concept:** `language.state-consequence`
- **Modality:** `MUST`
- **Scope:** Actions, validation, failure, recovery, deletion, privacy, sync, and external effects
- **Status:** `normative`
- **Verification:** `REVIEW-COPY-CONSEQUENCE-001`
- **Supersedes:** none

Material controls MUST name the action, object, durable consequence, recoverability, and next safe step in plain language; internal runtime taxonomy MUST NOT replace user meaning.

## COPY-HUMANE-TONE-001 — Calm non-shaming language
- **Concept:** `language.humane-tone`
- **Modality:** `MUST NOT`
- **Scope:** All user-facing copy and notifications
- **Status:** `normative`
- **Verification:** `AUDIT-HUMANE-COPY-001`
- **Supersedes:** none

Copy MUST NOT use shame, fake urgency, streak or score pressure, productivity guilt, manipulative AI branding, or coercive scarcity.

Closure copy MUST name the affected object, resulting state, consequence, and available recovery action and MUST NOT shame the user.

Ambitions copy SHOULD be concise, concrete, action-led, and free of runtime or architecture jargon.

Milestone acknowledgement MAY name the completed object and preserved progress and MUST NOT use scores, streaks, fake urgency, or pressure.

Terms classified as forbidden in primary UI MUST NOT appear in ordinary root surfaces, primary calls to action, empty states, notifications, or basic flows.

## LOCALIZATION-001 — Localizable construction
- **Concept:** `language.localization-construction`
- **Modality:** `MUST`
- **Scope:** User-facing strings
- **Status:** `normative`
- **Verification:** `TEST-LOCALIZATION-CONSTRUCTION-001`
- **Supersedes:** none

Strings MUST use localizable semantic arguments, pluralization, and formatting; concatenation MUST NOT prevent grammatical localization.

## LOCALIZATION-002 — Temporal locale
- **Concept:** `language.temporal-locale`
- **Modality:** `MUST`
- **Scope:** Date, time, recurrence, duration, and schedule language
- **Status:** `normative`
- **Verification:** `TEST-TEMPORAL-LOCALE-001`
- **Supersedes:** none

Temporal language MUST honor locale, calendar, first weekday, 12/24-hour preference, time zone, DST, and region; unsupported behavior must be explicit and tested.

## LOCALIZATION-003 — Layout and spoken resilience
- **Concept:** `language.layout-resilience`
- **Modality:** `MUST`
- **Scope:** Localized visual and accessibility presentation
- **Status:** `normative`
- **Verification:** `PROOF-LOCALIZATION-RESILIENCE-001`
- **Supersedes:** none

Presentation MUST support expansion, right-to-left layout, pseudolocalization, long names, and localized VoiceOver without hiding critical meaning or actions.

## LOCALIZATION-004 — Store localization truth
- **Concept:** `language.store-localization`
- **Modality:** `MUST`
- **Scope:** Store metadata and screenshots
- **Status:** `normative`
- **Verification:** `REVIEW-STORE-LOCALIZATION-001`
- **Supersedes:** none

Localized store content MUST preserve the same product, privacy, accessibility, evidence, and claim boundaries as the app.

<!-- canon-section: purpose -->
Make product language consistent, humane, localizable, consequence-aware, and semantically accessible.
<!-- canon-section: scope -->
Applies cross-cutting language rules; object-specific labels and state transitions remain in owning specifications.
<!-- canon-section: requirements -->
The requirements consolidate useful Article 37 and accepted language laws without a separate engineering constitution.
<!-- canon-section: exceptions -->
An exception requires a documented product rationale plus localized and accessible alternatives and applicable tests.
<!-- canon-section: verification -->
Verify with lexical scans, state/copy review, localization fixtures, pseudolocalization, RTL, Dynamic Type, and VoiceOver evidence.
<!-- canon-section: source-ownership -->
Target owners are `Language/`, relevant presentation owners, `DesignSystem/`, and `Quality/`;
<!-- canon-section: proof -->
Verification includes lexical results, state strings, locale/RTL/pseudolocalization fixtures, assistive speech, and screenshots where layout behavior matters.
<!-- canon-section: amendment-impact -->
When language behavior changes, update affected terms, states, locales, accessibility behavior, tests, and migration handling.

## COPY-VISIBILITY-CLASSIFICATION-001 — Visibility classification language

- **Concept:** `copy.visibility-classification`
- **Modality:** `MUST`
- **Scope:** User-facing visibility and state
- **Status:** `normative`
- **Verification:** `AUDIT-COPY-VISIBILITY-001`
- **Supersedes:** none

Visibility and classification copy MUST state who or what can access the object and MUST NOT substitute architecture, privacy theater, or ambiguous status labels.

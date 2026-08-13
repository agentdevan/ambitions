+++
initiative = "ambitions-private-semantic-intelligence"
document_type = "scope"
status = "draft"
upstream = "research.md"
+++

> **Phase boundary:** Devan approved the upstream Research on 2026-08-13. This
> Scope defines product behavior and architectural boundaries only. It does not
> authorize Design, evaluation implementation, model conversion, package or
> tool creation, implementation grooming, production code, canon edits,
> deployment, or release. Scope approval would authorize initial Design only;
> evaluation implementation may be groomed only after that Design is approved.
> The Research performance numbers remain experimental comparison points and
> gain no Scope or release authority here.

## Outcome

Ambitions will understand semantically equivalent wording well enough to make
existing Search and Capture behavior more useful without becoming an AI
destination or weakening deterministic authority.

For Search, a user can find an already eligible Ambitions object when their
query uses different wording, see bounded related or possible-duplicate results,
and benefit from Goal-related relevance while exact, prefix, privacy, identity,
action, and stale-result rules remain deterministic. Search remains immediately
usable before semantic refinement and when every optional provider is missing.

For Capture, a user receives better evidence for the existing Step / Goal /
Needs a Place proposal, possible duplicates, and possible Goal associations.
Weak, conflicting, or unsupported evidence causes abstention and clarification,
not an automatic assumption. Capture remains the sole owner of draft routing,
correction, confirmation, promotion, and accepted consequences.

V1 semantic behavior is English-only, local, iOS 26-compatible, progressively
enhanced, and nonauthoritative. The initiative establishes a logical
`AmbitionsIntelligence` computation boundary whose outputs are evidence,
candidates, similarities, proposals, confidence evidence, or abstention. Scope
does not decide whether that logical boundary initially remains inside
`LocalRuntimeOS` or is later extracted into a Swift package.

The user should experience better native Ambitions behavior, not a model. There
is no AI tab, chat surface, model selector, autonomous workflow, or generic
assistant. Deterministic Search and Capture remain complete and authoritative
on every supported device.

## In scope

- English semantic refinement of the existing global Search capability for
  paraphrases, zero-token-overlap wording, bounded related-object discovery,
  possible duplicates, and Goal-related relevance.
- Preservation of deterministic exact/prefix results, object eligibility,
  privacy suppression, identity, revision, deletion, action validation,
  consequence, confirmation, and stable fallback.
- English semantic evidence inside the existing Capture proposal flow for
  Step / Goal / Needs a Place routing, possible duplicates, possible Goal
  association, ambiguity, confidence evidence, abstention, and clarification.
- Semantic evidence for waiting, dependency, optional/someday, and date
  ambiguity only as a supplement to existing deterministic rules and parsers.
- A first-class logical, framework-neutral, nonmutating
  `AmbitionsIntelligence` computation boundary.
- A required Apple `NLEmbedding` zero-additional-asset evaluation baseline and
  eligible fallback, with deterministic behavior beneath it.
- A closed, non-production evaluation matrix and the exact evidence questions a
  post-approved-Design evaluation-only tranche must answer before an amended
  Design may select an external production model.
- Core Spotlight semantic search as a separately reported Apple-native
  evaluation arm, never a presumed production Search architecture.
- Full offline operation whenever any required external-model bytes are
  available, and complete deterministic operation before separately delivered
  bytes arrive, while enhancement is disabled, or whenever a provider fails.
- Local-first privacy, egress prohibition, derived-data protection, deletion,
  reclassification, model provenance, supply-chain, rollout, and rollback
  requirements.
- Resource-safe behavior under cancellation, memory pressure, Low Power Mode,
  thermal pressure, app lifecycle changes, and external-provider or delivery
  failure.
- Bounded refinements to existing Search and Capture presentation, Trust-style
  explanation, and—only if Design finds a genuinely new child necessary—an
  accessible settings/storage surface for applicable external-enhancement
  disclosure, enablement, derived-data purge, and delivery-specific controls.
- Coordination boundaries with the approved private generative runtime,
  intelligence quality/safety evaluation, intelligence change-management, and
  grounded-generative proposal initiatives.

## Out of scope

- A generic chatbot, AI tab, new root destination, new global shell capability,
  prompt box, conversational agent, model picker, or Hugging Face-branded UX.
- Any model becoming canonical truth, minting identity, selecting authority,
  validating an action, writing an Event or Projection, creating a Receipt, or
  mutating a Goal, Step, schedule, profile, privacy class, History, or other
  canonical state.
- A new Search owner, fourth independent Search authority, separate Capture
  authority, intelligence-owned FTS store, intelligence-owned action validator,
  or alternate privacy/receipt/history system.
- Selection of Arctic XS, BGE Small, MiniLM, mxbai, Core Spotlight, or any other
  provider as the production winner in Scope.
- A custom local generative LLM; Goal decomposition, summaries, planning or
  pattern explanations, reflection drafts, suggested-next-step prose, or any
  other generative semantic-v1 behavior.
- The Apple Foundation Models system runtime, Private Cloud Compute, hosted AI,
  cloud inference, remote vector databases, Hugging Face Hub/runtime access in
  normal use, OpenAI APIs, or any private intelligence egress.
- Autonomous actions, continuous reasoning, background agents, tool loops,
  automatic generation over the database, or inference on every keystroke.
- A dedicated learned Capture classifier, fine-tuning, opaque on-device
  training, behavioral profiles, or learning from corrections. Corrections
  remain private product state under their existing owner.
- Context, effort, priority, personality, aptitude, readiness, urgency, or
  sensitive-trait inference.
- Model-driven deadline creation, dependency creation, Goal creation, Goal
  attachment, priority assignment, completion, deletion, or other automatic
  Capture consequence.
- Expansion of canonical Search eligibility to object families not already
  authorized by the selected production Search owner.
- A new semantic History/Memory authority. Existing eligible history-like
  objects may participate only through Search ownership and the same privacy,
  revision, deletion, and evaluation rules as every other object.
- Multilingual semantic-quality claims or a multilingual model track in v1.
  Non-English input retains the current deterministic product behavior without
  a semantic-quality promise.
- Speech recognition, OCR, attachment understanding, image similarity, VLMs,
  image generation, or general computer vision.
- Final semantic-index ownership or schema, vector format, chunking algorithm,
  exact scan versus ANN selection, tokenizer implementation, model precision or
  quantization, compute-unit policy, asset packaging, model-delivery mechanism,
  concrete protocols/types, actor topology, target graph, or file layout.
- Physical Swift-package extraction, an
  `AmbitionsIntelligenceDeterministic` target, an iOS-versioned `CoreAI27`
  target, or any evaluation target linked into the shipping application.
- Creation or execution of evaluation implementation before an initial Design
  is owner-approved and evaluation-only implementation grooming is complete.
- Raising the app, extension, or test deployment target above iOS 26.

## Requirements

### REQ-001 — Deterministic Ambitions is always available and authoritative

Search and Capture must complete their current deterministic work without
waiting for semantic intelligence. Missing, disabled, unsupported, downloading,
corrupt, incompatible, cancelled, pressure-terminated, or crashed intelligence
must leave Search, Capture, canonical state, and action safety fully viable.
Semantic availability can refine an experience; it can never be a prerequisite
for app launch, Search, Capture, object access, or mutation.

### REQ-002 — Intelligence is a logical, nonauthoritative computation boundary

The product shall have one logical `AmbitionsIntelligence` boundary for
framework-neutral, typed, bounded, cancellable, nonmutating semantic work. It
may compute evidence, candidate identities, similarities, proposal signals,
confidence evidence, provider state, or abstention. It may not own canonical
meaning, identity, privacy, Search actions, Capture placement, mutation,
receipts, history, replay, or egress authority.

This Scope deliberately leaves the physical form open between:

1. the logical boundary inside current `LocalRuntimeOS` ownership; and
2. the same logical boundary extracted into a Swift package after dependency
   closure, Search ownership/migration, runtime and generative-runtime
   ownership, build/test routing, repository module policy, and explicit owner
   approval are resolved.

Package extraction is not the default, an evaluation outcome, or an implied
Scope decision. Framework-neutral contracts remain required in either form.

### REQ-003 — Search provides bounded semantic retrieval jobs

For English queries, semantic enhancement may contribute independent candidates
for:

- paraphrases and zero-token-overlap descriptions;
- bounded related objects within Search-authorized families;
- possible duplicate or near-duplicate objects; and
- Goal-related relevance for an eligible result or query.

Semantic retrieval may only return canonical candidate identities already
eligible for the selected Search surface. Search hydrates and validates those
candidates through its current authority before display or action. Semantic
similarity does not expand object-family eligibility or grant access.

### REQ-004 — Exact results, privacy, staleness, and actions remain deterministic

Exact and strong prefix matches, explicit commands, object identity, owner,
revision, tombstone/deletion, privacy eligibility, result-family eligibility,
typed action, consequence, confirmation, stable tie-breaking, and stale-result
suppression remain deterministic Search responsibilities. Semantic refinement
must not hide or demote a valid exact result solely because a model assigns a
different score. A semantic score cannot authorize an action or resurrect a
deleted, stale, privacy-suppressed, or otherwise ineligible object.

### REQ-005 — One production Search owner precedes persistent semantic indexing

Search remains the product owner of retrieval, ranking policy, result identity,
actions, and user-visible meaning. Before Design specifies a persistent
semantic index, the current Memory Lens, FTS, deterministic
`SemanticLocalIndex`, and canonical-generation migration must be resolved to one
approved production Search owner and generation contract.

The evaluation tranche may use disposable candidate stores solely for comparison.
Those stores cannot become production state, establish ownership, constrain the
production migration, or make semantic retrieval a fourth Search authority.

### REQ-006 — Capture receives semantic evidence, not a competing classifier

Within the existing Capture draft flow, semantic intelligence may provide:

- evidence for Step / Goal / Needs a Place route candidates;
- possible duplicate or near-duplicate candidates;
- possible existing Goal associations;
- disagreement or margin evidence supporting ambiguity detection; and
- supplementary evidence for waiting/dependency, optional/someday, and date
  ambiguity.

Existing deterministic rules and date parsing remain authoritative for explicit
language. V1 does not ship a dedicated learned Capture classifier or use a local
LLM for routing.

### REQ-007 — Capture remains the sole owner of proposal and correction

Capture owns draft identity, intake durability, route presentation,
clarification, editing, correction, confirmation, promotion, receipts, history,
undo, and recovery. Intelligence cannot auto-create or attach a Goal, set a hard
deadline, assert a dependency, set priority, complete/delete an object, or
bypass the existing preview and confirmation path. Accepted consequences cross
canonical authority only through the current Capture and runtime contracts.

### REQ-008 — Confidence means calibrated evidence and safe abstention

Raw similarity, logits, or the largest model score are not user-facing
confidence and cannot alone select a result or route. Product confidence must
incorporate Ambitions-specific held-out evidence such as candidate margin,
class/slice, rule agreement, provider/language coverage, source revision, and
candidate availability. Weak, close, contradictory, unsupported, stale, or
out-of-language evidence must abstain and preserve the current clarification
path. No semantic proposal is auto-accepted in v1.

### REQ-009 — Semantic v1 is English-only

The semantic quality commitment, evaluation corpus, calibration, and provider
selection are English-only for v1. Non-English or unsupported mixed-language
input receives the existing deterministic behavior and an honest absence of
semantic enhancement; it must not receive a false quality claim or silent
English-only misclassification. Visible UI strings remain localization-ready.

Granite Embedding Multilingual and EmbeddingGemma are not part of the v1
evaluation tranche.
A multilingual semantic launch requires a separately approved Scope revision
or initiative with language-stratified product requirements and evidence.

### REQ-010 — `NLEmbedding` is the zero-asset semantic baseline and fallback

Apple `NLEmbedding` must be evaluated as the current-target, zero-additional-
asset semantic baseline. Where its required language/revision is available and
qualified, it may provide optional local enhancement. Where it is unavailable
or unqualified, the product falls back to deterministic behavior. Its
OS-controlled model revision must be identified in evaluation and derived-index
compatibility; it is not treated as timeless or automatically sufficient.

### REQ-011 — The initial model evaluation matrix is closed

The required comparison arms are exactly:

1. current deterministic Search and Capture;
2. Apple `NLEmbedding`;
3. Snowflake Arctic Embed XS;
4. BGE Small EN v1.5; and
5. all-MiniLM-L6-v2 as the mature same-size control.

`mxbai-embed-xsmall-v1` may be included only if it reuses the same evaluation
tranche
conversion/runtime path, fixtures, device matrix, license process, and reporting
without adding a framework, architecture branch, corpus, milestone, or material
integration effort. If any of those additions is needed, mxbai is excluded.

No additional embedding model may enter this evaluation tranche unless new primary-source
evidence, reviewed by Devan, demonstrates that it materially changes the
decision rather than merely expanding the survey. Precision variants are
variants of one candidate, not additional model arms.

### REQ-012 — Core Spotlight is an evaluation arm, not an architecture

Core Spotlight semantic search may be evaluated separately using the same
Ambitions fixtures and correctness boundaries. The report must expose its
quality, exact-match preservation, privacy filtering, deletion/tombstone,
staleness/revision, availability, latency, cancellation, rebuild, and OS-revision
behavior. It may return candidate identities only; Ambitions Search remains the
hydration and validation authority.

Scope does not select Core Spotlight as the production index, Search owner, or
fallback. Design may consider a production role only if the evidence meets the
same later-approved criteria as every other provider and the Search ownership
decision permits it.

### REQ-013 — A bounded evaluation tranche must answer a finite evidence set

After an initial provider-neutral Design is owner-approved and evaluation-only
implementation grooming is complete, the non-production evaluation tranche is
limited to answering these questions:

1. **Search quality:** How do deterministic Search, `NLEmbedding`, each required
   external candidate, and Core Spotlight compare on exact/prefix preservation,
   lexical and zero-overlap paraphrases, related-but-irrelevant hard negatives,
   duplicate detection, Goal relevance, result stability, and Recall@K, MRR,
   NDCG where useful?
2. **Search safety:** Does every arm prevent privacy-ineligible, deleted,
   tombstoned, stale-revision, wrong-owner, or unsupported-family results and
   preserve action-token validation and canonical identity?
3. **Capture quality:** At useful coverage, how do the arms compare on route
   evidence, per-class precision/recall, Goal association, duplicate detection,
   ambiguity, calibration, abstention, selective accuracy, correction, and
   unsafe-assumption rate?
4. **Shared-embedding ceiling:** Can one embedding provider materially improve
   both Search and Capture without a dedicated Capture classifier or LLM?
5. **Conversion fidelity:** For each external candidate, do local conversion,
   tokenization, truncation, prompting, pooling, normalization, and compressed
   variants reproduce publisher/reference numerics closely enough to be valid
   evaluation arms?
6. **Runtime behavior:** On representative physical iPhones, what are cold and
   warm load/inference, indexing throughput, incremental work, cancellation,
   peak memory, persistent/high-water storage, compute placement, energy,
   thermal, Low Power Mode, memory-pressure, background-expiration, and app-
   lifecycle behaviors?
7. **Scale behavior:** At representative 1K, 10K, and supported 100K synthetic
   scales, is bounded exact vector scanning sufficient? Only if it is not may
   the tranche add a disposable, minimal ANN comparison to measure the break-even;
   that comparison selects no production index.
8. **Failure and offline behavior:** Do airplane mode, never-downloaded,
   interrupted, missing, corrupt, incompatible, deleted/reclaimed, cancelled,
   pressure-terminated, and crash/restart states always preserve deterministic
   Search and Capture without canonical effect?
9. **Storage and distribution evidence:** What are the actual converted model,
   tokenizer, compiled cache, active/staged index, rollback generation, and App
   Store/archive size consequences? The tranche reports data; it does not choose
   bundle, managed asset pack, or device-tier delivery.
10. **Provenance and licensing:** Can every evaluated artifact be immutably
    pinned, hashed, reproduced, scanned, attributed, licensed for commercial
    distribution, and operated with no Hugging Face account, token, cloud
    runtime, or mutable network dependency?
11. **Decision result:** Does any external candidate materially outperform
    deterministic and `NLEmbedding` baselines on Ambitions-specific user value
    without a hard correctness/privacy failure and with acceptable measured
    device cost? The report must permit the explicit answer “no external model.”

The evaluation tranche cannot expand into new product capabilities, a broad model survey,
multilingual evaluation, generative evaluation, production architecture, or
user-data collection.

### REQ-014 — Evaluation follows approved Design and remains disposable

The required lifecycle sequence is:

1. approved Research;
2. approved Scope;
3. an initial provider-neutral Design;
4. Devan's approval of that Design;
5. evaluation-only implementation grooming;
6. a bounded non-production evaluation tranche;
7. measured evidence;
8. Design amendment/finalization selecting the evidence-dependent production
   decisions;
9. Devan's re-approval of the amended Design; and
10. production implementation grooming.

The first Design must define the framework-neutral computation boundary,
isolation and safety contracts, evaluation architecture, Search and Capture
integration boundaries, evidence requirements, and the conditions under which
the first implementation tranche is evaluation-only. It must remain
provider-neutral wherever measurements are unavailable and must not select a
production model, semantic-index mechanism, or evidence-dependent physical
boundary.

Only after that Design is owner-approved may grooming create the bounded
evaluation implementation required by `REQ-013`. The evaluation tranche must be:

- non-production, disposable, and isolated from the shipping app dependency and
  resource graph;
- incapable of canonical mutation, command execution, Event append, Projection
  write, Receipt creation, durable Capture placement, or product-owner creation;
- unable to become a Search owner, Capture owner, persistent production index,
  runtime authority, or package-extraction precedent;
- limited to synthetic/canonical fixtures and separately governed, explicitly
  consented test material; and
- deleted, archived as non-production evidence, or selectively reimplemented
  only after the amended Design is owner-approved. Evaluation code is never
  promoted wholesale.

Evaluation tooling and challenger assets must never be linked or copied into the
shipping app merely because the tranche exists.

### REQ-015 — Amended Design receives evidence before production selection

After the evaluation tranche, Design must be amended or finalized using the
measured evidence. Only that amended Design may select:

- an external production embedding model or no external model;
- the production semantic-index mechanism;
- the final physical boundary inside `LocalRuntimeOS` or an approved extracted
  package; and
- measured runtime, storage, delivery, lifecycle, and resource decisions that
  the initial provider-neutral Design deliberately left gated.

No external production embedding model may be selected without a reviewed
evaluation report that includes:

- the complete closed matrix and declared exclusions;
- exact checkpoint, file, tokenizer, preprocessing, converter, precision,
  runtime, OS, device, corpus, and fusion/calibration identity;
- paired Ambitions-specific Search and Capture quality results with slice-level
  regressions, calibration, abstention, and a winner/no-winner conclusion;
- zero-tolerance privacy, deletion, stale-object, identity, action-safety,
  canonical-authority, and deterministic-availability results;
- physical-device latency distributions, cancellation, memory, storage, energy,
  thermal, Low Power Mode, lifecycle, failure, and offline evidence;
- actual packaged asset/tokenizer/cache/index size measurements;
- conversion-reference tests, operation/compute placement, license/NOTICE,
  provenance, file hashes, security scan, and supply-chain review; and
- an explicit explanation of why the user-visible lift justifies added download,
  runtime, maintenance, change-management, and rollback burden.

Scope sets no production winner and no numerical “material lift” threshold. The
amended Design must adopt or revise measurable criteria from the evidence and
receive Devan's re-approval before production implementation grooming.
`NLEmbedding` or deterministic-only remains a valid Design outcome.

### REQ-016 — Normal intelligence is fully local and offline-capable

All normal Search/Capture semantic inference, candidate retrieval, scoring,
indexing, correction handling, and fallback must work in airplane mode with no
Hugging Face account/token, OpenAI or other API key, Ambitions server, inference
endpoint, vector-database service, analytics endpoint, or recurring inference
charge. Public model bytes may be bundled or separately downloaded if an
external model later qualifies; Scope does not choose between them.

Before separately delivered bytes are installed, while their download is
interrupted, when external enhancement is disabled, or when any provider fails,
deterministic behavior—and qualified Apple-local behavior where available—
remains complete.

### REQ-017 — External-model enhancement is optional and user-controlled

If amended Design later selects an external model, the enhancement must remain
optional regardless of how its bytes are delivered. The user can disable the
external-model semantic enhancement at any time. Disabling it immediately
returns Search and Capture to deterministic and qualified Apple-local behavior,
preserves every canonical Ambitions object, and permits purge of embeddings,
indexes, caches, and other user-derived semantic data that belong exclusively to
that external model.

The user receives truthful plain-language disclosure of any material storage,
download, update, and fallback consequence:

- **Separately downloaded or on-demand delivery:** disclose the measured
  benefit and actual size before acquisition; support defer, cancel, retry, and
  removal of the downloaded model bytes and its exclusive derived data.
- **Bundled delivery:** do not present fictitious model-download or model-byte
  removal controls. The user can still disable the enhancement and purge its
  exclusive user-derived semantic data; immutable app-bundle bytes remain part
  of the installed application.

Scope chooses neither delivery mechanism. Amended Design may choose bundled or
Apple-hosted/managed delivery only after measured archive size, installed size,
failure, update, rollback, and UX evidence. Normal UI must not expose model
brands, Hugging Face, Core ML/Core AI, tokenizers, quantization, precision,
provider selection, or developer inference terminology. Delivery and update
state cannot block app launch, Search, or Capture.

### REQ-018 — Normal private intelligence egress is prohibited

Private source content, Search queries, Capture text, embeddings/vectors, object
relationships, candidate identities tied to user content, ranks/scores,
confidence/abstention evidence, corrections, prompts, generated artifacts, and
content-bearing diagnostics must not leave the device to provide, evaluate,
debug, monitor, or improve normal intelligence.

No private PCC or hosted-AI path is authorized. Network transfer is limited to
public model/metadata acquisition under approved change management and any
separately scoped, explicit, user-reviewed export or named integration already
permitted by Ambitions egress authority. Higher quality, crash diagnosis,
telemetry, or “anonymous embeddings” is not sufficient justification.

### REQ-019 — Embeddings inherit privacy, deletion, and reclassification semantics

An embedding and its index metadata are private derived user data. They inherit
the source object's owner, privacy classification, allowed purpose, deletion,
reclassification, revision, retention, and protection constraints and use the
same-or-stronger Data Protection behavior. Numeric form is not anonymization.

Source deletion, tombstone, revision, privacy reclassification, owner/purpose
change, model/preprocessing change, or incompatible index generation must make
the old entry immediately ineligible before any asynchronous purge or rebuild.
Deletion and reclassification must remove future influence, avoid replay
resurrection, and rebuild only from still-authorized canonical sources.
Rebuildable derived stores should not create stale backup copies; exact backup
and file-protection mechanics remain Design work constrained by this outcome.

### REQ-020 — Models and tokenizers have immutable provenance and fail closed

Every external evaluation or production artifact must bind publisher/repository,
immutable revision, exact input-file hashes, tokenizer/vocabulary, prompts,
truncation, pooling, normalization, output dimension, converter/toolchain,
compression recipe, compiled asset hash, license/NOTICE obligations,
evaluation identity, compatibility, and revocation state.

Mutable `main`, arbitrary remote code, `trust_remote_code`, pickle-dependent
loading, unsigned replacement, unreviewed executable downloads, or runtime Hub
fetches are prohibited. Inputs must be allowlisted and scanned in an isolated
development supply chain. Hash/signature/license/compatibility failure
quarantines the artifact and preserves the previous qualified provider or
deterministic fallback.

This requirement does not choose a tokenizer library, conversion tool, signing
format, or asset-distribution mechanism.

### REQ-021 — Resource pressure degrades semantics before product viability

Semantic work must be bounded, debounced, cancellable, revision-bound, and
incremental. It must not run inference on every keystroke, keep an unnecessary
large model continuously resident, re-embed the full database after every
mutation, poll continuously, retry indefinitely, or reason over the entire
private graph.

Low Power Mode pauses discretionary bulk indexing and may reduce or suppress
foreground semantic refinement while deterministic work continues. Serious or
critical thermal pressure, memory warnings, background expiration, app
deactivation, query revision, or surface dismissal cancels or unloads optional
work without stale publication or canonical impact. Background work is
opportunistic and checkpointed; it is never required for correctness.

### REQ-022 — Research performance numbers remain experiment hypotheses

Scope adopts no numerical latency, RSS, storage, cancellation-time, energy, or
thermal release threshold. The values in approved Research may be copied into
the post-approved-Design evaluation protocol only as labelled experimental
comparison points that make first measurements falsifiable. They carry no
product, Scope, Design, implementation, or release authority.

After the evaluation tranche, the amended Design must explicitly adopt, revise,
or reject measurable runtime criteria using deterministic baseline and candidate
distributions on physical devices. Product requirements already fixed by
Scope—no deterministic blocking, no stale publication, safe pressure
degradation, and no canonical effect—remain hard regardless of numerical
performance.

### REQ-023 — Rollout and rollback affect only derived intelligence

Semantic enhancement rolls out as progressive, capability-checked local
behavior over an always-available deterministic baseline. A new model,
preprocessing revision, privacy policy, or semantic generation is staged and
validated separately before activation. Readers never observe a mixed or
partially rebuilt generation.

Rollback may activate a previously qualified, compatible, non-revoked provider
and generation or disable semantic enhancement entirely. It never rewrites
accepted Events, Projections, objects, receipts, corrections, or History.
Revoked, withdrawn, corrupt, or privacy-incompatible artifacts cannot be used as
last-known-good. Rollout decisions cannot depend on private remote behavior
telemetry or user profiling.

### REQ-024 — Intelligence appears only as better native Ambitions behavior

V1 uses the current shell: Today, Goals, Time, and You are roots; Capture and
Search are global capabilities. This initiative adds no root, global capability,
AI destination, chat, prompt history, model status badge in primary flows, or
autonomous activity surface.

Search shows deterministic results immediately and may refine them once in a
stable, focus-preserving manner. Helpful explanations use bounded product
language such as “Related wording,” “Same Goal,” or “Possible duplicate,” never
framework/model branding or unsupported certainty. Capture shows concrete
clarification choices, an obvious rejection path, and at most a bounded number
of actionable suggestions rather than scores or inference terminology.
Unavailable intelligence is normally silent because deterministic behavior is
valid; Design may use existing settings or, only when justified, a conditional
new child to expose external-enhancement enablement, derived-data purge, and
applicable delivery or failure state.

### REQ-025 — Semantic refinement is fully accessible

Search and Capture semantic states must preserve VoiceOver order and focus,
Dynamic Type/reflow, Switch Control and supported alternative-input operation,
non-color meaning, and reduced-effects behavior. Search must not announce every
rank change or repeatedly move the active result; at most one concise refinement
announcement is made when useful. Capture ambiguity, alternatives, none-of-
these, correction, and confirmation must be textually understandable and
operable without interpreting a probability.

Conditional enhancement benefit, enablement, storage consequence, derived-data
purge, offline and failure state, and any delivery-specific progress,
cancellation, retry, or removal controls must be accessible. No required meaning
may depend only on animation, spatial position, color, haptics, or model-
generated prose.

### REQ-026 — Existing adjacent initiatives keep their owners

- `private-generative-model-runtime` owns registered generative tasks, model
  sessions, generative envelopes, validators, and any future Foundation Models,
  PCC, hosted, or custom generative mode. Semantic v1 does not invoke or
  duplicate it.
- `intelligence-quality-safety-evaluation` owns durable evaluation identity,
  evidence dimensionality, hard-failure semantics, limitations, and downstream
  evaluation records. This initiative supplies semantic Search/Capture fixtures,
  metrics, and claims through that owner rather than creating a competing
  universal score.
- `intelligence-change-management` owns artifact provenance, compatibility,
  acquisition, verification, staging, promotion, rollback, revocation, and
  purge. If an external model ships, this initiative supplies model-specific
  requirements and does not create another release coordinator.
- Grounded generative destination and Goal Path proposal initiatives own their
  generative product jobs and downstream adoption boundaries. Semantic Search
  or Goal-association evidence may be consumed only through separately approved
  owner contracts; it does not add generation to this Scope.

No adjacent initiative may use this Scope to bypass Search/Capture authority,
private-egress law, deterministic fallback, or the approved-Design evaluation
boundary.

### REQ-027 — The minimum deployment target remains iOS 26

V1 must build and remain useful across Ambitions' current iOS 26 deployment
target. Core ML and Natural Language are the current custom/Apple-local runtime
baseline. iOS 27 Core AI and evolving `LanguageModel` APIs are future,
availability-gated adapter options only after stable platform evidence and a
separately approved product need. They cannot raise the minimum target, define a
version-coupled durable abstraction name, own canonical state, or become a v1
dependency.

## Acceptance criteria

1. **AC-001 (`REQ-001`):** With every semantic provider disabled, missing,
   downloading, corrupt, incompatible, cancelled, or failed, Search and Capture
   complete their deterministic flows and all canonical actions behave exactly
   through existing authority.
2. **AC-002 (`REQ-002`):** Boundary review finds only typed, bounded,
   cancellable, nonmutating inputs/outputs and no dependency or call path to
   canonical writes, raw-store authority, receipts, History, privacy policy, or
   egress authority. The approved Design explicitly records either physical
   form without treating package extraction as presumed.
3. **AC-003 (`REQ-003`):** Ambitions fixtures demonstrate independently retrieved
   English paraphrase, zero-overlap, related, duplicate, and Goal-relevant
   candidates only from Search-eligible object families, subject to the later
   Design quality criteria.
4. **AC-004 (`REQ-004`):** Exact/prefix/action fixtures retain deterministic
   eligibility and consequence; privacy-suppressed, deleted, tombstoned,
   stale-revision, wrong-owner, and unsupported-family candidates are never
   rendered or actionable, regardless of semantic score.
5. **AC-005 (`REQ-005`):** Before any approved Design contains a persistent
   semantic index, it cites the owner-approved single production Search path and
   generation contract. Evaluation stores have no shipping dependency, production
   migration role, or ownership claim.
6. **AC-006 (`REQ-006`, `REQ-007`):** Capture fixtures show route evidence,
   duplicate and Goal-association suggestions inside the current proposal and
   correction flow; no semantic path creates/attaches a Goal, commits a date or
   dependency, changes priority, appends an Event, or bypasses confirmation.
7. **AC-007 (`REQ-008`):** Ambiguous, contradictory, stale, unsupported-language,
   low-margin, no-suitable-Goal, and provider-unavailable cases abstain or show
   concrete clarification; no raw model score is displayed or auto-accepted.
8. **AC-008 (`REQ-009`):** The v1 evidence report is English-only. Unsupported
   language tests retain deterministic behavior and make no semantic-quality
   claim; no multilingual model or metric is silently introduced.
9. **AC-009 (`REQ-010`):** `NLEmbedding` is reported as a distinct zero-asset arm
   with exact language/OS revision and unavailable behavior, and deterministic
   fallback passes when that arm is absent.
10. **AC-010 (`REQ-011`):** The evaluation report contains all five required arms and
    no unapproved model. mxbai appears only with written evidence that every
    low-incremental-cost condition was met.
11. **AC-011 (`REQ-012`):** Core Spotlight results are separately labeled,
    measured across all required correctness/lifecycle slices, hydrate through
    Search authority, and make no production-architecture claim.
12. **AC-012 (`REQ-013`):** The reviewed evaluation report answers each of the eleven
    listed questions with exact methods, per-slice data, limitations, and an
    explicit external-model winner or no-winner result; it contains no
    multilingual, generative, autonomous, or unrelated model work.
13. **AC-013 (`REQ-014`):** No evaluation implementation exists before an
    initial provider-neutral Design is owner-approved and evaluation-only
    grooming is complete. Dependency inspection proves the shipping app and its
    resources cannot reach the tranche, mutation canaries prove no canonical
    effect, and closeout records disposal, non-production archival, or selective
    reimplementation only after amended Design approval.
14. **AC-014 (`REQ-015`):** Initial Design names no evidence-dependent production
    winner. Amended Design cannot select an external model, semantic-index
    mechanism, final physical boundary, or measured runtime policy without the
    complete evidence bundle in `REQ-015`, an explicit user-value/burden
    rationale, and Devan's re-approval. Deterministic or `NLEmbedding`-only
    remains accepted when no candidate qualifies, and production grooming does
    not start before re-approval.
15. **AC-015 (`REQ-016`):** Airplane-mode and no-account/no-token tests pass for
    every normal Search/Capture path after any required public asset is
    available; before separately delivered bytes arrive, while enhancement is
    disabled, or after provider failure, deterministic behavior remains complete
    with zero private network request.
16. **AC-016 (`REQ-017`):** If an external model is selected, the user can disable
    its enhancement and purge exclusive user-derived semantic data without
    affecting canonical data or app viability. Separately downloaded delivery
    proves truthful measured disclosure plus defer/cancel/retry/removal; bundled
    delivery proves truthful storage disclosure without fictitious model-byte
    controls. Amended Design chooses delivery only from measured evidence.
17. **AC-017 (`REQ-018`):** Seeded private canaries appear nowhere in network
    requests, analytics, crash material, benchmark exports, logs, diagnostics,
    prompts, or hosted tools. Public asset downloads contain no stable private
    identity or content-derived request data.
18. **AC-018 (`REQ-019`):** Delete, tombstone, revision, privacy reclassification,
    owner/purpose change, restore, replay, and model-generation tests make old
    vectors immediately ineligible, terminally remove prohibited influence, and
    rebuild only from currently authorized sources.
19. **AC-019 (`REQ-020`):** Every evaluated/shipped external artifact has a
    complete immutable manifest and reproducible reference check; mutable,
    remote-code, pickle, signature/hash/license, incompatible, or revoked cases
    fail closed and retain qualified fallback.
20. **AC-020 (`REQ-021`):** Query changes, navigation, cancellation, Low Power
    Mode, serious/critical thermal state, memory warning, background expiration,
    and app lifecycle tests stop or reduce semantic work, publish no stale
    result, and leave deterministic interaction and canonical state intact.
21. **AC-021 (`REQ-022`):** Scope, Design, test, and release documents do not cite
    a Research number as authority. The evaluation tranche labels any reused
    number “experimental comparison point,” and amended Design explicitly
    adopts, revises, or rejects measured release criteria after reviewing
    physical-device data.
22. **AC-022 (`REQ-023`):** Staged-generation, partial rebuild, incompatible
    update, rollback, revocation, and crash tests expose one valid semantic
    generation or none, never mixed state; accepted canonical state is byte-for-
    byte unaffected by semantic rollback.
23. **AC-023 (`REQ-024`):** Product inspection finds no new root/global
    capability, AI/chat/model surface, inference terminology, repeated result
    reshuffling, or unexplained autonomous behavior. Existing Search/Capture
    surfaces use bounded, provenance-backed product language.
24. **AC-024 (`REQ-025`):** VoiceOver, largest Dynamic Type, Switch Control,
    reduced-effects, non-color, focus, announcement, clarification, and
    conditional external-enhancement control evidence passes on the named
    simulator and physical-device matrix adopted by Design.
25. **AC-025 (`REQ-026`):** Traceability maps every generative, evaluation,
    artifact-change, and grounded-proposal responsibility to its existing owner;
    dependency inspection finds no duplicate runtime, release coordinator,
    universal score, or proposal owner.
26. **AC-026 (`REQ-027`):** App, extension, tests, and any approved production
    semantic target retain iOS 26 deployment. iOS 27 APIs are availability-
    isolated and optional, and their absence leaves all v1 behavior viable.

## Frontend impact contract

- **Surface impact: existing + conditional new-child.** Search and Capture are
  the only primary affected product surfaces. If and only if an external model
  qualifies, Design first determines whether its enablement, derived-data purge,
  disclosure, and delivery-specific controls fit an existing approved settings
  surface. A genuinely new child under the existing You/settings/storage
  hierarchy is conditional material frontend work. No new root or global
  capability is permitted.
- **IA/navigation: none.** The shell remains Today, Goals, Time, and You, with
  Capture and Search as global capabilities. Existing entry points and hierarchy
  do not change; any conditional new child remains inside the existing settings
  hierarchy.
- **Assets/iconography: system-only.** Use existing components and Apple system
  symbols where an icon is needed. No custom AI/model/provider brand asset,
  mascot, sparkle language, or Hugging Face branding is permitted.
- **Visual language: unchanged.** Semantic behavior uses the current native
  Search, Capture, clarification, settings, Trust, and degraded-state visual
  language. It does not introduce chat bubbles, prompt chrome, confidence
  meters, inference dashboards, or a separate intelligence aesthetic.
- **Motion/effects: unchanged.** This classification concerns animation and
  transition effects, not a product destination. Semantic refinement requires
  no special animation and must respect Reduce Motion and stable focus.
- **Copy/localization:** Visible copy describes the user benefit or uncertainty
  in product language—such as “Related wording,” “Same Goal,” “Possible
  duplicate,” “Which did you mean?”, or “Enhanced local understanding.” It must
  not expose model names, numeric confidence, framework/runtime terms, hidden
  certainty, or promotional AI claims. Semantic quality is English-only in v1;
  UI copy remains localization-ready and unsupported language degrades honestly.
- **Accessibility:** `REQ-025` and `AC-024` are mandatory for deterministic,
  refining, ambiguous, duplicate, unavailable, disabled, failed, offline,
  derived-data-purged, and applicable delivery states. Required meaning is
  textual and operable with assistive technology, largest Dynamic Type,
  non-color cues, and reduced effects.
- **Visual proof:** Design must inspect and fixture the current production Search
  and Capture surfaces for deterministic-first, refined, duplicate, ambiguity,
  provider-unavailable, and stale-result suppression states. This bounded work
  inside existing approved surfaces remains bounded existing-surface work and
  does not require a separate visual gate. If amended Design chooses a genuinely
  new child settings/storage surface, that branch is material frontend work and
  must use the `ambitions-unified-frontend-program` workflow. Its subordinate
  `ambitions-native-visual-foundry` may supply the production-intended native
  fixture and bounded native proof, but it creates no separate program or
  approval. Explicit owner visual approval is required before that frontend
  task becomes executable. Later Verification must name runtime, screenshot,
  accessibility, and representative-device evidence.

## Canon impact

No canon change is authorized by this Scope. Current canon and implementation
owners continue to govern until an approved Design identifies and implementation
deliberately updates the owning sources.

Design should identify exact candidate canon changes for:

- the logical, nonauthoritative semantic computation boundary;
- Search semantic candidate intake, deterministic fusion, generation,
  explanation, stale suppression, and fallback after the single production
  Search owner is resolved;
- Capture semantic evidence, abstention, clarification, correction, and
  confirmation without changing Capture authority;
- privacy classification, protection, deletion, reclassification, backup, and
  diagnostics for embeddings and semantic metadata;
- external-enhancement enablement, derived-data purge, conditional delivery
  state, degraded/offline behavior, provenance, change management, rollout,
  rollback, and Trust inspection; and
- evaluation traceability for the exact semantic task/provider/runtime/index
  tuple.

No navigation canon change, private-egress exception, new canonical object,
new receipt/history authority, or iOS deployment-target change is intended. If
Design discovers that any is required, it must return to Scope rather than
inventing the product decision.

## Risks and open decisions

### Resolved product and boundary decisions

- Semantic v1 is an English-only Search and Capture enhancement, not a generic
  AI product.
- Deterministic Search and Capture are always available and authoritative.
- Search owns retrieval/ranking/action meaning; Capture owns placement,
  correction, confirmation, and promotion.
- The intelligence boundary is logical and nonmutating; package extraction is
  neither assumed nor authorized.
- `NLEmbedding` is the required zero-asset baseline/fallback; no external model
  is selected.
- The evaluation matrix is closed, with mxbai allowed only under the explicit
  low-incremental-cost condition and no multilingual track.
- Core Spotlight is an evaluation arm, not a production architecture.
- Normal private intelligence egress, custom generative LLMs, opaque learning,
  autonomous agents, VLMs, and new runtime authority are prohibited.
- External-model enhancement, if later selected, is user-disableable, its
  exclusive derived data is purgeable, and it can never be required for app
  viability. Delivery remains evidence-gated.
- The deployment target remains iOS 26; iOS 27/Core AI is future evolution.

### Dependencies and intentionally gated decisions

| Dependency or unknown | Why it remains gated | Required resolution before Design/implementation relies on it |
|---|---|---|
| Single production Search implementation/generation | Live repository contains Memory Lens, FTS, deterministic `SemanticLocalIndex`, and canonical-generation migration seams | Owner-approved consolidation decision before persistent semantic-index Design; Scope already fixes Search as the owner |
| Initial provider-neutral Design and evaluation-only grooming | Measurements are unavailable before implementation, while lifecycle permits implementation only after approved Design | Initial Design fixes contracts, isolation, evaluation architecture, owner boundaries and evidence requirements; Devan approves it before evaluation-only grooming under `REQ-014` |
| External production model or no model | Public benchmarks cannot decide Ambitions quality or phone cost | Complete closed-matrix evaluation evidence, amended Design decision under `REQ-015`, and Devan's re-approval before production grooming |
| Physical `LocalRuntimeOS` versus Swift-package form | Depends on dependency closure, Search migration, runtime/generative owners, module policy, build/test routing, and measured provider needs | Amended Design plus explicit module/owner approval; the evaluation tranche creates no precedent |
| Core Spotlight production role | OS-controlled ranking/revision and lifecycle behavior are unproven for Ambitions | Separate arm results meeting the same correctness, privacy, quality, latency, lifecycle, and ownership criteria |
| Persistent index, vector and retrieval mechanics | Corpus scale and device measurements may favor different choices | Amended Design after evaluation evidence; no Scope preference for vector format, chunking, exact scan, ANN, storage schema, or generation representation |
| Tokenizer, conversion, pooling, precision and compute policy | Candidate-specific fidelity and device behavior are unmeasured | Evaluation reference-numeric and physical-device evidence; amended Design selects exact production implementation only after a model decision |
| Numerical quality and runtime release criteria | Research values are hypotheses, not product authority | Amended Design explicitly adopts/revises measured criteria using baseline and candidate distributions; hard Scope invariants remain fixed |
| Model delivery mechanism and update UX details | Actual archive size, installed size, failure/update behavior and user burden are unknown | Amended Design chooses bundled or Apple-hosted/managed delivery only after measured evidence; delivery-neutral user control in `REQ-017` is fixed |
| License and attribution clearance | Commercial redistribution and NOTICE obligations vary by selected artifact | Complete provenance/license review and owner/counsel approval before production selection |
| Physical-device access and energy/thermal evidence | Simulator cannot establish memory, compute placement, energy, or thermal fitness | Approved-Design evaluation tranche on oldest, middle, and current representative iPhone tiers before amended Design selection |
| Exact production canon files and build/test routes | Depend on the final Search owner, physical boundary, and provider decision | Initial Design identifies evaluation-only routes; amended Design finalizes production traceability after evidence; no canon/build edit occurs in Scope |
| Adjacent initiative implementation state | Approved documentation does not prove every runtime/evaluation/change owner is implemented | Design must consume live available contracts or declare dependency; it cannot duplicate an owner to bypass missing implementation |

These gates do not leave Design free to invent product behavior. Design may
choose technical means only within the fixed requirements. If evidence demands
multilingual scope, generative behavior, private egress, a new owner, a new
surface, or a weaker deterministic/privacy invariant, the initiative must return
to Scope and owner approval.

## Scope review

**Self-review verdict: PASS — no blocking Scope finding remains; ready for
Devan's separate review and approval.**

- Approved Research is the sole upstream product/evidence authority; the live
  repository head remains the Research-inspected revision
  `0518378bd9b8f11ce7b50f1a290520ebdb947f90`.
- The outcome, exact v1 Search/Capture jobs, English-only boundary, exclusions,
  ownership, offline/privacy, delivery-neutral external-enhancement control,
  accessibility, platform, and rollout behavior are explicit.
- All 27 requirements have observable acceptance coverage, and no acceptance
  criterion silently adopts a Research performance number.
- The external model, Core Spotlight production role, package extraction,
  Search implementation, index mechanics, tokenizer/conversion, quantization,
  packaging, actor topology, and numerical release criteria remain deliberately
  evidence-dependent rather than being selected by Scope.
- The bounded evaluation tranche follows owner-approved initial Design and
  evaluation-only grooming, has a closed matrix and finite questions, and is
  isolated from production, canonical authority, product ownership, and package
  precedent. Measured decisions require amended Design and owner re-approval.
- The frontend contract resolves current surfaces, navigation, assets, visual
  language, effects, copy/localization, accessibility, and conditional visual
  proof without creating an AI product surface.
- Existing generative, evaluation, change-management, and grounded-proposal
  initiatives retain their owners; semantic v1 does not duplicate them.

Only Devan can approve this Scope and authorize initial Design. Scope approval
would not authorize evaluation implementation, package/tool creation, model
conversion, implementation grooming, canon changes, merge, deployment, or
release. Evaluation-only grooming requires owner-approved initial Design;
production grooming requires owner re-approval of amended Design after evidence.

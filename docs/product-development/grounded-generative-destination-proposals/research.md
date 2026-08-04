+++
initiative = "grounded-generative-destination-proposals"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

People rarely name a fully normalized destination. They say “I want work that
helps people,” “maybe astronomy,” “I want a creative life outside my job,” or
“use what I've already learned.” The v1 domain recommenders can compare bounded
typed candidates, but the eventual platform must interpret an open ambition,
discover credible adjacent and aspirational destinations across domains, and
explain alternatives without inventing careers, programs, hobbies, requirements,
or claims about the person.

The user outcome is an editable, sourced Destination Proposal Set. It reflects
the user's stated meaning, distinguishes interpretation from evidence, presents
meaningfully different options, exposes gaps and constraints, and lets the user
select, revise, save for later or dismiss. Selection is still a proposal input;
only the existing destination-adoption owner may create or change a Goal.

## Current truth

### Approved baseline

- Career, education and hobby destination recommenders define domain-specific
  route forms, evidence lanes, comparison semantics and adoption handoffs.
- Capability Continuity/Skill Transference preserves user-approved capability
  and Proof without deciding a new destination.
- Production domain corpora and Relationship Registry supply versioned public
  identities and exact source relationships; Current Authority Registry owns
  current offerings separately.
- Private Generative Runtime owns compute mode, minimal context, read tools,
  structured output, deterministic validation and no-mutation boundaries.
- Evaluation and Change Management own promotion/regression, not this feature.

These are approved documents, not evidence that their runtime behavior exists.

### Live source seams

The tree contains deterministic `RecommendationEngine`, explanation adapter,
Start Here recommendation, Goal Engine draft/planning, Source Atlas query/public
planning bridge, private runtime boundaries and domain/route UI patterns. It has
no production cross-domain generative destination composer. Existing synthetic
fixtures and hardcoded examples cannot authorize named real destinations.

### Evidence-grounded generation pattern

The reliable order is retrieval before generation:

1. capture the user's exact ambition statement;
2. derive an editable **Interpretation Draft** containing only explicit intent
   facets and questions—not hidden traits;
3. deterministically retrieve an allowlisted candidate pool from admitted
   corpus releases and exact relationship profiles;
4. let a registered model task propose a diverse subset and explanations using
   only that pool and typed context;
5. validate every identity, claim, citation, comparison and unsupported unknown;
6. render from the validated semantic result; and
7. hand a selected proposal to the existing adoption confirmation flow.

Apple's current [Generative AI HIG](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
emphasizes disclosure, correction, alternatives, privacy, hallucination
minimization and explicit control. The [Foundation Models framework](https://developer.apple.com/documentation/foundationmodels/)
supports guided structures and tools, but neither structure nor tool calling
makes generated claims true. NIST's [Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial)
reinforces evaluation of confabulation, privacy, bias, information integrity and
human configuration. Ambitions therefore treats the model as a proposal
composer over retrieved facts, not a knowledge source.

### Intent without a hidden person model

An Interpretation Draft may contain user-visible facets such as domain interest,
desired impact, activity preference, learning posture, time horizon, acceptable
uncertainty, geographic scope and explicitly included constraints. Each facet is
`explicit`, `userEdited`, `unknown`, or `notIncluded`; none is inferred as a
stable personality, aptitude, value, identity or employability trait.

The user can correct the interpretation before or after generation. Ambiguity
may yield alternatives (“Do you mean doing astronomy research, working near the
space sector, or learning astronomy as a hobby?”) rather than an invisible
guess. Sensitive text stays on device by default through the private runtime.

### Candidate and evidence boundaries

The model cannot mint a canonical destination ID. A proposal binds:

- exact corpus destination/version and relationship edges;
- route/domain form;
- why it relates to explicit facets;
- known prerequisites/path characteristics as source claims;
- capability continuity evidence as local user-approved bindings;
- current-opportunity claims only when separately current and purpose-approved;
- unknowns, conflicts, evidence limits and missing-source state; and
- model/task/prompt/schema/source/context versions.

“Adjacent” means an inspectable relationship to stated intent or approved
capability; “aspirational” means it may require substantial change, not that the
user is unlikely to succeed. There is no universal fit, potential, prestige,
employability or success score. Option ranking is a transparent presentation
policy with dimension-level reasons and can be disabled or reordered.

### Cross-domain coherence

Career, education and hobby/life destinations are not equivalent. An education
program may support a career path; a hobby may build a reusable capability; a
career identity is not a credential. Relationship Registry edges may support a
specific join purpose but cannot transfer qualification or claims. The proposal
set retains route forms and groups options when comparison dimensions are not
commensurable.

The output can include a primary path family plus option-preserving complements,
such as “explore astronomy through a local observing practice while researching
formal aerospace destinations.” It cannot create multiple Goals or schedule
anything. Multi-Goal portfolio choice belongs downstream.

### Grounding, hallucination and failure

Every factual sentence must be renderable from validated source-bound semantic
fields. If the model references an unknown ID, unsupported requirement, stale
claim, false equivalency, sensitive inference or uncited fact, validation removes
the affected candidate or fails the set. Generated rationales use explicit
“because you said…” language and source-owned “the source describes…” language.

Insufficient coverage returns route-level forms, source-needed state or manual
destination entry. It does not fabricate a plausible destination or broaden a
public remote query with private text. Model unavailable returns deterministic
v1 domain recommendations/manual exploration. Current opportunity unavailable
does not invalidate the destination.

### Privacy, deletion and correction

The ambition text, Interpretation Draft, included constraints, capability
bindings, viewed/dismissed options and feedback are private. Public corpus
retrieval can use finite IDs/shards; private matching remains local. A saved
proposal is a versioned private draft. Clear/delete removes its context snapshot,
model envelope, derived explanations, feedback and evidence bindings as scoped.
Editing intent creates a new revision; stale async results are discarded.

Feedback is explicit (“not what I meant,” “wrong source,” “not for me,” “show
more like this”) and correction-scoped. It must not silently become a stable
profile or train a model. Adaptive learning consumes approved correction events
only through its later contract.

### Direct-user and evaluation needs

Evaluation must cover intent-faithfulness, candidate identity validity, factual
grounding/citation, diversity without tokenism, adjacent/aspirational clarity,
capability-transfer correctness, source/unknown comprehension, sensitive-
inference leakage, bias/dignity, correction responsiveness and usefulness. Test
across sparse corpora, nontraditional paths, disability/access needs, income/
location uncertainty, career breaks and goals not represented in the initial
US corpora.

## Evidence

The approved v1 domains already own their internal recommendation semantics;
the missing capability is a cross-domain generative front door and proposal
composer. Retrieval-constrained generation reuses those owners while allowing
natural language, multiple interpretations and explanation. It also produces a
testable failure mode: no supported candidate is better than a fluent fiction.

## Alternatives

1. **Open chat produces destination names.** Expressive but ungrounded,
   non-replayable and prone to hidden inference. Reject.
2. **Only deterministic forms.** Safe and inspectable but forces users to know
   the taxonomy before Ambitions helps. Retain as fallback.
3. **Embedding nearest-neighbor over mixed corpora.** Useful for candidate
   retrieval but similarity is not equivalence or fit and can leak private text
   if hosted. Use only as an evaluated local candidate signal.
4. **Retrieval-constrained typed proposal set.** Balances generative interpretation
   with exact identity/source validation and user control. Recommend.

## Unknowns and risks

- Production corpora initially cover only bounded US slices; cross-domain
  breadth will be uneven and must be visible.
- Capability continuity may not yet have enough direct-user evidence for strong
  transfer explanations; unknown is preserved.
- Model interpretation can encode stereotypes even without sensitive fields.
- Too many clarification questions can become burdensome; too few can hide
  assumptions. Direct-user evidence must calibrate the threshold.
- Current opportunity and local availability should not dominate long-horizon
  aspirations merely because they are easier to observe.
- Embedding/model updates require exact re-evaluation and cannot silently reorder
  saved proposals.

No hard fork remains: the feature can use validated on-device generation with a
deterministic/manual fallback and expand only as corpora/evidence qualify.

## Recommended direction

Build a two-stage **Interpretation Draft -> Grounded Destination Proposal Set**
experience. Retrieval is deterministic over admitted public identities and
relationships; generation composes only from the candidate/evidence bundle;
validation binds every semantic field; users correct interpretation and choose
among meaningfully different route-preserving options. Adoption remains a
separate explicit owner.

### Five compounding ruthless review passes

1. **Completeness:** added interpretation, retrieval, composition, validation,
   sparse coverage, correction, deletion and evaluation.
2. **Connections/ownership:** separated domain recommenders, corpora,
   relationships, current facts, runtime, capability and adoption.
3. **Privacy/authority/failure:** prohibited hidden profiles, hosted private
   search, minted IDs, uncited prose and model-to-Goal mutation.
4. **Feasibility:** anchored in live recommendation/Goal Engine/Source Atlas
   seams and retained deterministic fallback.
5. **Coherence/value:** preserved cross-domain distinctions, option-preserving
   complements and long-horizon aspirations under sparse current data.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.

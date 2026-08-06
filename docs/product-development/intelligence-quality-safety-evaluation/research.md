+++
initiative = "intelligence-quality-safety-evaluation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions' eventual intelligence loop will influence which destinations a user
considers, which route they inspect, when work is proposed, and how the system
responds when circumstances change. Those outputs can be helpful without being
decision authority, but they can still waste time, narrow a user's options,
misstate a requirement, expose private context, or create false confidence when
their sources, assumptions, or limits are weak.

The user therefore needs more than a technically valid recommendation. They
need an intelligence experience that is observably grounded, useful,
correctable, private, inclusive, and honest about what it does not know. Devan
and the product need a repeatable way to decide whether a particular version of
a corpus, policy, deterministic engine, prompt, or model improved that
experience without silently regressing another population, domain, locale,
device class, or failure state.

The user-facing outcome of this initiative is confidence with evidence rather
than confidence theater:

- a destination or route cites the facts that actually support it;
- unknown, stale, conflicting, unavailable, unsupported, and unauthorized
  remain visible instead of being completed by a model;
- a correction changes the affected output and does not become a global trait;
- the same accepted facts replay to an inspectable result under the identified
  policy and source versions;
- an unavailable model or source degrades to a useful local experience;
- counterfactual identity changes do not narrow opportunity unless a
  user-selected, legitimate constraint actually changes;
- no model output, aggregate metric, or evaluator becomes authority to mutate a
  Goal, Goal Path, Step, placement, Capability, Proof, or external system.

This Research defines the product-quality evidence needed to evaluate those
outcomes. It does not choose an evaluation implementation, approve a model or
corpus, set release policy, authorize collection of user data, or claim that the
approved v1 portfolio has shipped.

## Current truth

### Canonical product laws

Current canon already resolves the non-negotiable evaluation posture:

- `MISSION-FUNCTION-001` and `MISSION-INTEGRATION-001` require one continuous
  loop from intent through path, time fit, action, proof, learning, and
  recovery. An evaluator that scores isolated outputs while missing broken
  handoffs cannot prove product quality.
- `MISSION-NAMING-001` names generative Goal pathing with schedule reflow as a
  core capability, but does not make a generative model the product authority.
- `JOURNEY-GOAL-ACTIVATION-001` keeps a generated path, Steps, dates, Proof
  expectations, and placements as non-durable proposals until review and later
  confirmation.
- `SYSTEM-RUNTIME-ORCHESTRATION-001` requires reasons, relevant sources,
  material uncertainty, user control, policy revision, and correction/reset.
  It prohibits an external or cloud LLM dependency for core behavior.
- `SYSTEM-RUNTIME-SIMULATION-001` requires local, deterministic,
  side-effect-free, inspectable, bounded simulation based only on current facts
  and declared assumptions.
- current privacy canon prohibits Source Atlas, R2, Account, hosted models,
  analytics, and telemetry from receiving the private life graph. A separately
  approved export or named integration may carry only reviewed, selected fields
  under its own contract.

Evaluation must test these laws directly. It must not reinterpret a high model
score as permission to relax them.

### Approved foundational intelligence v1 portfolio

The 13 approved Research, Scope, Design, plan, task, and verification sets under
`docs/product-development/` provide a deliberately bounded evaluation surface:

1. `capability-continuity-foundation` defines evidence-linked, user-controlled
   Capability identity, correction, archive, deletion, and no automatic decay.
2. `public-reference-knowledge-foundation` defines source-native public claims,
   rights, jurisdiction, freshness, conflict, and last-known-good behavior, with
   one exact O*NET 30.3 slice rather than a production corpus.
3. Career, education, and hobby recommendation initiatives define separate
   authority lanes and synthetic verified packs. They do not establish
   production recommendation quality.
4. `destination-adoption-and-pivot` separates a reviewed direction from the
   explicit creation of a provisional Goal.
5. `goal-path-generation` defines source-grounded, inspectable route proposals
   and deterministic validation without hosted private intelligence.
6. `adaptive-path-comparison` compares a bounded set of materially different
   routes qualitatively and without success prediction.
7. `context-quality-scheduling` evaluates Step-specific fit from explicit or
   user-confirmed context without a universal energy, time, health, or person
   score.
8. `life-branch-reconciliation` proves only a bounded
   relocation/caregiving/work/education case, not a general scenario engine.
9. The three import/export initiatives define narrow, local, reviewed exchange
   surfaces rather than a universal profile or automatic write-back.

These documents supply requirements and expected fixtures. They are not
evidence that runtime behavior is complete, that synthetic cases represent real
users, or that future models and production corpora are safe and useful.

### Live source and test seams

The repository contains useful primitives, but no integrated intelligence
quality system:

- `PlanningEvaluator` derives feasibility, pressure, fragility, effort posture,
  and reasons from deterministic plan facts. Its internal numeric values are
  implementation heuristics, not a validated universal measure of a person,
  route, or future outcome.
- `LearningAnticipationService` uses local completion evidence and friction,
  falls back when evidence is sparse, and produces bounded explanations. It
  currently demonstrates a limited within-Goal learning seam; it does not prove
  cross-domain personalization, causal learning, or user usefulness.
- `RecommendationMutationLabModels` can bind a baseline and mutated result to
  reason graphs, counterfactual diffs, replay traces, and inspection seams. This
  is a strong regression primitive for deterministic recommendation behavior.
- `SourceAtlasPublicOnlyBoundaryGate`, the privacy/security classifiers, and
  their tests provide direct seams for proving no private reference egress and
  explicit stale or unusable public-source states.
- the runtime already models external-effect confirmation, idempotency,
  indeterminate results, reconciliation, and compensation boundaries. Those
  states can be evaluated without performing an unrestricted external action.
- golden scenarios, Source Atlas fixture suites, privacy/security tests,
  scheduling tests, and planning tests cover important components, but there is
  no single versioned dataset and evidence record spanning destination quality,
  path quality, schedule usefulness, correction response, bias, privacy,
  source/model change, and user validation.
- `tools/openai/evals/datasets/batch_quality.jsonl` contains three tooling-scope
  checks. It is not a product-intelligence benchmark.
- no current Swift source imports Foundation Models, Core ML personalization,
  or a third-party model SDK. Model-specific evaluation is therefore future
  work, not a present runtime claim.

The feasibility conclusion is positive: Ambitions already has deterministic
traces, source identity, receipts, privacy gates, scenario fixtures, and typed
state distinctions that an evaluation system can consume. The missing product
decision is how those proofs combine without producing one misleading quality
score or collecting private telemetry.

## Evidence

### External standards and platform evidence

The following sources are current as of 2026-08-04 and are treated as guidance,
not as Ambitions product authority:

- NIST's [Generative AI Profile, NIST AI 600-1](https://doi.org/10.6028/NIST.AI.600-1)
  organizes generative-AI risk across governance, content provenance,
  pre-deployment testing, incident disclosure, the model/system/application
  lifecycle, and third-party components. It identifies confabulation, harmful
  bias, data privacy, information security, intellectual-property, and value
  chain risks that map directly to Ambitions' future model and corpus surfaces.
- Apple's [Foundation Models evaluation guidance](https://developer.apple.com/documentation/foundationmodels/evaluating-prompts-to-measure-performance-and-improve-model-responses)
  says prompt changes and model updates can change behavior, recommends
  systematic scenario-based evaluation, and distinguishes deterministic rules,
  ground-truth comparison, semantic measures, and calibrated model-based
  judgment.
- Apple's [Foundation Models update guidance](https://developer.apple.com/documentation/Updates/FoundationModels)
  confirms that the system model changes with OS releases and explicitly calls
  for rerunning prompt and safety evaluations across model versions. A device OS
  update is therefore an intelligence dependency change even if Ambitions ships
  no app update.
- Apple's [Foundation Models safety guidance](https://developer.apple.com/documentation/FoundationModels/improving-the-safety-of-generative-model-output)
  says built-in model and guardrail layers do not remove application-specific
  risk, and calls for bounded inputs/outputs, refusal handling, risk assessment,
  adversarial testing, and monitoring across model or guardrail updates.
- Apple's [Generative AI Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
  require people to remain in control, recommend privacy-preserving on-device
  processing and non-AI fallbacks where possible, and call for visible AI use,
  correction, dismissal, retry, and inclusive testing.
- Apple's [Foundation Models framework documentation](https://developer.apple.com/documentation/FoundationModels)
  provides guided structured generation and tool calling. These constrain
  output shape, but do not verify that a generated claim is true, current,
  licensed, applicable in a jurisdiction, or supported by the cited source.

Together these sources support a layered evaluation program. They do not
support treating a model vendor's benchmark, guardrail, or schema guarantee as
end-to-end Ambitions proof.

### Evaluation object and binding

The smallest durable unit of evaluation should be an **intelligence evaluation
case**, not a free-form prompt and not a private user transcript. Each case must
bind:

- a stable case and suite identifier;
- the product capability and requirement being exercised;
- the exact public source pack, source release, claim identities, rights state,
  jurisdiction, freshness status, and conflict set;
- the exact selected private fixture facts or a declaration that none are used;
- policy, deterministic engine, prompt, model, guardrail, locale, OS, app, and
  schema versions when applicable;
- clock, seed, connectivity, permission, and model/source availability state;
- expected allowed states and forbidden outcomes;
- the produced proposal, source/reason trace, validation result, and any
  correction or replay result;
- evaluator type, evaluator revision, adjudication status, and evidence
  location.

An evaluation result must be invalidated when a bound dependency changes unless
the owning change contract proves compatibility. Reusing an old verdict against
a new model, prompt, corpus, policy, or source release would be false evidence.

### Required evaluation dimensions

No single metric covers the platform. Each intelligence feature needs the
following applicable dimensions, with `not_applicable` requiring a reason:

1. **Input and authority integrity**
   - selected private facts are explicit and within the feature's permission;
   - public and private inputs retain separate identities;
   - unselected or deleted context has no influence;
   - protected or sensitive attributes are not inferred to fill missing facts;
   - each accepted mutation is still validated and owned by its typed owner.

2. **Factual grounding and citation integrity**
   - every externally checkable current or normative claim resolves to a source
     that actually supports it;
   - the cited claim, displayed explanation, and generated proposal agree;
   - source release, freshness, jurisdiction, rights, and known conflicts are
     visible where material;
   - unsupported details are omitted or labeled unknown rather than completed;
   - citation presence is never counted as correctness without entailment.

3. **Structured-output and deterministic-validation integrity**
   - schema-valid output also passes semantic, identity, lifecycle, privacy,
     authority, and expected-version checks;
   - invalid enums, invented identifiers, impossible dependencies, unbound
     sources, duplicate nodes, and prohibited actions fail closed;
   - model prose cannot bypass a typed validator or become a command;
   - repeated validation is deterministic for the same bound input.

4. **Destination recommendation quality**
   - adjacent and aspirational lanes remain distinct and inspectable;
   - capability reuse expands options rather than trapping a user in historical
     similarity;
   - evidence, gaps, unknowns, legal/credential requirements, and current
     availability are not collapsed into compatibility;
   - diverse but irrelevant results do not count as useful coverage;
   - correction, rejection, and disablement have the intended local effect.

5. **Goal Path quality**
   - the path preserves the user's stated outcome and boundary;
   - prerequisites, milestones, Steps, Substeps, Proof expectations, decision
     points, and alternatives are sourced or declared;
   - sequencing is feasible under known dependencies and does not turn typical
     preparation into a universal gate;
   - current opportunities remain separate from structural route facts;
   - partial or unavailable path generation preserves the provisional Goal and
     identifies what is missing.

6. **Scheduling usefulness and safety**
   - placements respect availability, Protected time, transition, recovery,
     recurrence, deadline, and capacity laws;
   - context fit is Step-specific and based only on permitted evidence;
   - a proposal explains why a window fits and what assumption could change it;
   - correction and rejection improve the affected context without creating a
     universal energy, health, disability, discipline, or chronotype model;
   - user studies measure whether proposed placements are understandable and
     usable, not merely whether users click Accept.

7. **Adaptive learning and correction responsiveness**
   - sparse, stale, contradictory, or out-of-distribution evidence yields low
     confidence or no learned pattern;
   - explicit correction outranks inferred preference;
   - learning is bounded to meaningfully similar contexts and reports its
     evidence basis;
   - correction, disablement, archive, deletion, and reset remove future
     influence and invalidate dependent results;
   - a changed fact triggers only the affected resimulation.

8. **Simulation integrity**
   - every compared alternative names current facts, declared assumptions,
     constraints, unavailable facts, and consequences;
   - replay is deterministic and side-effect-free;
   - uncertainty is not rendered as success probability;
   - option-preserving progress is explained through reusable evidence or
     reversible commitments, not a universal option-value score;
   - infeasible, dominated, or incomparable alternatives remain explicit.

9. **Privacy and information security**
   - private graph egress is zero on prohibited paths, including prompts, tool
     arguments, source requests, diagnostics, analytics, caches, crash reports,
     filenames, embeddings, evaluator artifacts, and failure messages;
   - prompt injection or poisoned public content cannot invoke a command,
     disclose private context, rewrite trusted instructions, or fabricate
     provenance;
   - evaluation capture uses the minimum data, has an explicit purpose and
     retention boundary, and supports deletion/reset;
   - shared benchmarks use synthetic, licensed, or irreversibly de-identified
     inputs rather than copied private life graphs.

10. **Bias, dignity, and opportunity preservation**
    - counterfactual cases vary names, pronouns, age descriptions, disability
      context, location, education history, employment gaps, and other relevant
      representations without storing or inferring a hidden demographic model;
    - output differences must be attributable to an explicit legitimate
      constraint, authoritative jurisdiction fact, or user choice;
    - historical similarity does not suppress aspirational routes;
    - language remains non-shaming and never implies deficient character,
      employability, worth, or predicted success;
    - aggregate results are inspected by scenario slice so average performance
      cannot hide a severe subgroup failure.

11. **Resilience and honest degradation**
    - offline, model-unavailable, model-not-ready, unsupported-locale, refusal,
      context-limit, tool failure, missing-source, stale-source, conflict,
      permission-denied, and provider-outage cases each preserve a useful and
      truthful next step;
    - deterministic core behavior remains usable without a generative model;
    - last-known-good data is used only where the source contract permits it;
    - retries do not duplicate proposals or external actions.

12. **Interaction and accessibility quality**
    - reasons, sources, uncertainty, assumptions, comparison deltas, correction,
      and controls are perceivable and operable with VoiceOver, Dynamic Type,
      reduced motion, keyboard/switch access where supported, and localized
      content;
    - loading, partial, blocked, stale, conflict, and failure states do not rely
      on color, animation, or spatial layout alone;
    - generated language remains understandable at the point of decision.

13. **External-effect safety, when applicable**
    - preparation, preview, confirmation, local commit, external attempt,
      reconciliation, retry, compensation, and operator-required states remain
      distinct;
    - evaluation never performs a production external effect unless a separate
      test account and explicit test contract permit it;
    - an indeterminate result is never reported as success or retried blindly.

### Verdict model

The evaluation program must reject a universal intelligence score. One scalar
would hide the difference between a private-egress breach, an unsupported
citation, a weak-but-safe recommendation, and a usability problem.

Instead, each feature/version receives a version-bound evaluation record with:

- **hard invariants**: pass/fail requirements whose failure prevents that
  feature/version from making the affected claim;
- **quality measures**: dimensional results with scenario counts, denominators,
  uncertainty, slice results, and adjudication notes;
- **known limitations**: accepted gaps that remain visible to users and do not
  violate a hard invariant;
- **evidence coverage**: requirements, states, domains, locales, devices, model
  versions, corpus releases, and user-study tasks actually exercised;
- **verdict**: `pass`, `needs_revision`, or `insufficient_evidence` for the named
  feature/version and claim only.

Hard failures include, at minimum:

- prohibited private egress or retention;
- an unauthorized or unconfirmed mutation or external effect;
- fabricated source identity, citation, current opportunity, legal/credential
  requirement, or deterministic success claim;
- treating stale, conflicting, unavailable, unknown, or unsupported input as
  accepted current truth;
- schema-valid output bypassing typed semantic validation;
- deletion/reset leaving hidden future influence;
- a severe opportunity-denying or demeaning counterfactual difference without
  a legitimate explicit basis;
- inability to provide the required non-model local fallback;
- reuse of an evaluation verdict after a bound dependency changed.

### Measurement methods

The program should combine methods because each catches different failures:

- deterministic assertions for identity, state, source binding, privacy,
  replay, mutation, freshness, and typed contract behavior;
- comparison with adjudicated ground truth for externally verifiable facts,
  prerequisites, source entailment, and expected failure states;
- metamorphic and counterfactual tests for stability under irrelevant changes,
  bounded response to relevant changes, and bias/path-dependence detection;
- adversarial suites for prompt injection, poisoned sources, misleading
  citations, conflicting claims, invalid structured output, stale data,
  extreme constraints, and external-effect ambiguity;
- human expert review for high-consequence domain claims and nuanced harm;
- calibrated model-assisted review only for triage or subjective language
  dimensions, never as the sole judge of factual truth, privacy, authority, or
  release readiness;
- direct user research for comprehension, usefulness, trust calibration,
  correction discoverability, perceived control, and whether the result helps a
  user make a better-informed choice.

For any model-based evaluator, agreement with human adjudication must be tested
on the relevant task and slices. The evaluator's model, prompt, and version are
dependencies of the result. A model may not grade its own output as the only
evidence.

### Evaluation corpus design

The portfolio needs a versioned suite composed of independently owned strata:

1. **Contract fixtures** derived from approved v1 acceptance criteria, including
   every named failure, correction, deletion, and privacy state.
2. **Source-grounded golden cases** built from licensed, versioned production
   source slices with expert-adjudicated claims and citations.
3. **Adversarial and boundary cases** covering sparse, conflicting, stale,
   malicious, unsupported, and high-consequence inputs.
4. **Counterfactual pairs and sets** that preserve legitimate facts while
   changing irrelevant identity representation or historical path shape.
5. **Longitudinal replay cases** spanning completion, friction, correction,
   source change, model/policy change, archive, deletion, and reset.
6. **Device and availability cases** spanning supported and unsupported model
   devices, offline operation, locale, memory/context pressure, and permissions.
7. **Human-evaluation cases** with a research protocol, task, consent boundary,
   participant context selected for the task, and qualitative plus observable
   outcome measures.

Private production behavior must not be uploaded to build this corpus. A user
may voluntarily contribute a reviewed, minimized case only through a future
separately approved export/research-consent contract. Local personal evaluation
may remain on device and show its result to the user without becoming shared
telemetry.

### Direct user validation requirements

Synthetic and expert fixtures answer whether an output is internally valid;
they cannot establish whether it helps a person. Before a mature Scope claims
usefulness, the affected initiative needs direct user evidence for the exact
interaction:

- **Destination discovery:** Can users distinguish adjacent from aspirational,
  understand why an option appeared, notice unknown/availability boundaries,
  reject an irrelevant path, and discover a credible option they would not have
  found unaided?
- **Goal Pathing:** Can users identify assumptions and dependencies, edit or
  reject route pieces, understand what remains unverified, and activate only
  what they mean to accept?
- **Scheduling:** Do proposed windows fit users' stated context better than a
  duration-only baseline, and can users correct fit without feeling diagnosed
  or judged?
- **Simulation:** Can users explain the difference among alternatives, identify
  assumptions and irreversible consequences, and understand that the result is
  comparison rather than prediction?
- **Correction and learning:** Can users find, apply, verify, disable, and reset
  learned influence, and does the next affected proposal change as expected?

Acceptance rate, time in app, goal creation, schedule density, or completion
rate alone are not sufficient. They can reflect coercion, novelty, easier
Goals, surveillance, or option narrowing. The evidence must include
comprehension, control, correction success, and the user's own assessment of
usefulness.

## Relationship to the future initiative portfolio

This initiative owns the common evidence vocabulary and evaluation verdict. It
does not own another initiative's product behavior, implementation tests, or
release decision.

- production corpus initiatives own source selection, rights, transformation,
  coverage, and freshness; this initiative specifies how their claims and
  changes are evaluated;
- `private-generative-model-runtime` owns the execution boundary and fallback;
  this initiative evaluates each bound model/prompt/version and failure state;
- grounded destination and Goal Path initiatives own their typed proposals and
  validators; this initiative supplies cross-cutting quality dimensions;
- personal-context and adaptive-learning initiatives own permissions,
  correction, deletion, and learned influence; this initiative tests those
  contracts without centralizing private data;
- multi-Goal and generalized Life Branch initiatives own simulation semantics;
  this initiative evaluates determinism, assumptions, usefulness, and harm;
- external-action orchestration owns confirmation and reconciliation; this
  initiative evaluates its safety without becoming external authority;
- `intelligence-change-management` owns rollout, invalidation, rollback, and
  incident workflow. It consumes the version-bound evaluation record defined
  here.

Each downstream Research may add domain-specific dimensions, fixtures, or hard
failures. It must not weaken the common invariants.

## Alternatives

### 1. Rely on ordinary unit and integration tests

This is necessary but insufficient. Deterministic tests can prove typed state,
privacy, replay, and known fixtures; they do not establish semantic grounding,
user usefulness, bias across scenario slices, or behavior changes introduced by
a probabilistic model or external corpus release.

### 2. Use a single aggregate intelligence-quality score

Rejected. It creates false comparability across harms, invites threshold gaming,
and could become the universal person/system score that canon rejects. A privacy
breach cannot be averaged away by good route prose.

### 3. Use a model as the primary or sole judge

Rejected. It is useful for triage and some calibrated language judgments, but it
can share the producer's failure modes, miss source/authority violations, change
with version updates, and produce a score without reproducible ground truth.

### 4. Depend on model-vendor benchmarks and guardrails

Rejected. Vendor evidence describes a general model boundary, not Ambitions'
sources, prompts, tools, validators, private context, user interface, typed
owners, or failure paths. Application-specific risk remains.

### 5. Optimize live product metrics through broad telemetry or A/B tests

Rejected for the private core. Broad behavioral telemetry conflicts with the
local-first boundary and can optimize engagement rather than agency. Carefully
consented studies and local evaluations can answer product questions without
creating a server-side private life model.

### 6. Freeze one golden benchmark and require exact output matches

Rejected as the complete solution. Golden cases are valuable for factual and
contract invariants, but generative wording can vary, production sources change,
and real users expose cases a static suite misses. The portfolio needs versioned
ground truth plus semantic, adversarial, longitudinal, and human evidence.

### 7. Evaluate only the final answer shown to the user

Rejected. A polished answer can hide private egress, unbound sources, discarded
conflicts, invalid intermediate tool calls, or an unauthorized mutation. The
evaluation unit must cover inputs, traces, validators, state transitions,
corrections, and failure behavior as well as the rendered result.

## Unknowns and risks

### Open product questions

- Which intelligence features are essential on every supported device, and
  which may be optional enhancements when an on-device model is unavailable?
  `private-generative-model-runtime` must resolve this before model-specific
  Scope.
- Which locales, jurisdictions, and source families constitute the first
  production evaluation floor? Corpus Research must answer coverage and rights
  before a benchmark can claim representativeness.
- Which high-consequence claims require an external domain expert rather than
  a general product reviewer? Career licensure, regulated education, finance,
  health, legal, and safety paths need explicit owners.
- How will Ambitions recruit sufficiently varied users without collecting a
  central private behavior dataset? Research operations and consent are outside
  current canon and need a separately approved protocol before data collection.
- Which quality changes are allowed to ship as known limitations, and which are
  hard blockers? Scope must bind the decision to feature-specific user harm and
  claim level rather than invent a universal threshold.
- How should user-reported harmful or incorrect outputs be exported for
  debugging while preserving the private-graph prohibition? No current route is
  authorized.
- How long may evaluation artifacts be retained, who may inspect them, and how
  are deletion and dependency invalidation proven? Shared synthetic fixtures and
  local private cases require different policies.

### Material risks

- **Benchmark overfitting:** prompts or policies may improve a fixed suite while
  becoming worse for unrepresented users or source conditions.
- **Coverage theater:** a high pass rate can hide that only easy career cases,
  one locale, one device, or one source family was tested.
- **Judge bias:** expert and model reviewers can encode the same dominant-path
  assumptions the product is meant to resist.
- **Privacy leakage through evidence:** prompts, traces, screenshots, logs,
  embeddings, filenames, or failure cases can reconstruct private context even
  when obvious identifiers are removed.
- **Synthetic-data comfort:** synthetic cases can prove contracts but not
  ecological usefulness, comprehension, or emotional effect.
- **Dynamic dependency drift:** an OS model, guardrail, source, policy, or
  provider can change independently and invalidate prior evidence.
- **False causality:** completion after a recommendation does not prove the
  recommendation caused success or that the same suggestion is appropriate for
  someone else.
- **Opportunity narrowing:** accuracy optimized against historical transitions
  can suppress aspirational options and reproduce unequal access patterns.
- **Evaluation as authority:** a passing result can be misused to auto-create a
  Goal, change a schedule, infer a trait, or perform an external action. The
  typed owner and confirmation boundaries remain mandatory.

### Data, rights, and retention requirements

- Every external fixture must record source, version, retrieval date,
  jurisdiction, license/terms, allowed transformations, attribution, and
  redistribution limits.
- A fixture derived from a source that cannot be redistributed must store only
  the permitted assertion or a reproducible locator and must not be silently
  committed as open benchmark content.
- Human-study material must have explicit informed consent, purpose limitation,
  minimum fields, retention/deletion behavior, and a claim ceiling. Participation
  must not be required to use the local core.
- Private local evaluation state must be inspectable, correctable, disableable,
  resettable, and deletable with dependent influence removed.
- Aggregate reporting must preserve denominators and slices without creating a
  stable person identifier or hidden profile.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Trust/IntelligenceEvaluationInspectionModels.swift`, `Native/Ambitions/Trust/IntelligenceEvaluationInspectionProjection.swift`, `Native/Ambitions/Trust/IntelligenceEvaluationInspectionView.swift`, `Native/Ambitions/Trust/IntelligenceEvaluationInspectionAccessibility.swift`, `Native/Ambitions/Trust/InspectionSurface.swift`.
- Evidence and unknowns: Repository audit identifies Task 7 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Create a **version-bound, layered intelligence evaluation contract** that
combines deterministic invariants, adjudicated source truth, adversarial and
counterfactual cases, longitudinal replay, accessibility proof, and direct user
validation. Keep the result dimensional and claim-specific. Do not create an
overall intelligence score.

The first Scope should be an evaluation foundation, not a release dashboard. It
should define observable behavior for:

1. registering a versioned evaluation suite and case;
2. binding each run to exact source, policy, model/prompt, locale, OS, schema,
   clock, seed, and availability inputs;
3. running deterministic and permitted probabilistic evaluators without private
   egress;
4. recording pass, needs-revision, or insufficient-evidence by named dimension
   and product claim;
5. showing coverage and known limitations without averaging hard failures;
6. invalidating results when bound dependencies change;
7. attaching separately governed human-study evidence;
8. exporting only reviewed, non-private evidence when sharing is explicitly
   authorized;
9. deleting/resetting private local cases and their derived results;
10. handing a complete evaluation record to intelligence change management.

The evaluation foundation should begin with deterministic v1 fixtures and
synthetic source packs because they are available and privacy-safe. It must label
that baseline as contract evidence, not user usefulness or production quality.
Production corpus, generative-model, and direct-user evidence can be added only
when their owning initiatives provide exact inputs and permissions.

### Evidence required before Scope

Research is complete enough to recommend Scope, but Scope should not be approved
until the following baseline is assembled and reviewed:

- a crosswalk from all 13 v1 verification documents to the evaluation dimensions
  and hard invariants above;
- an inventory of current golden, mutation, Source Atlas, privacy, planning,
  scheduling, accessibility, external-effect, and replay fixtures, including
  what each one actually proves;
- at least one adjudicated end-to-end synthetic case spanning destination,
  provisional Goal, path, scheduling proposal, correction, and resimulation,
  with no claim of real-user validity;
- a first threat model for prompt injection, poisoned public sources, private
  egress through model/evaluator artifacts, and evaluator manipulation;
- a decision from `private-generative-model-runtime` on the first model boundary
  before any model-specific threshold or device matrix is normative;
- named source/rights owners from the production corpus Research before
  production factual-grounding coverage is claimed;
- an approved research-consent and retention protocol before any private user
  transcript, screenshot, or behavior is collected or shared;
- a direct-user study plan for recommendation explanation, Goal Path review,
  context scheduling, simulation comprehension, and correction/reset.

Missing model, production-corpus, or user evidence does not block an evaluation
foundation Scope. It limits the claims that Scope and later Design may make.

## Five-pass ruthless review reconciliation

### Pass 1 — Completeness and unsupported assumptions

Finding: the initial direction could have become a model-output benchmark and
missed deterministic owners, external effects, accessibility, source rights,
and direct user value. Reconciliation: the evaluation object now binds the full
input/trace/state lifecycle; 13 applicable dimensions cover those seams; and
synthetic, model, expert, and user evidence have explicit claim ceilings.

### Pass 2 — Cross-initiative connections, duplication, and missing owners

Finding: evaluation could absorb source governance, model execution, release
management, or domain behavior. Reconciliation: the relationship section assigns
those decisions to production corpus, model runtime, downstream consumer,
external-action, and change-management initiatives. This initiative owns only
the common evaluation vocabulary, evidence binding, and verdict.

### Pass 3 — Privacy, authority, failure, deletion, and external-effect risks

Finding: collecting real prompts and traces could create the centralized private
profile the product forbids, while a passing score could be mistaken for
mutation authority. Reconciliation: shared private telemetry is rejected;
consent, minimization, retention, deletion, local evaluation, typed validation,
and external-effect states are now explicit hard boundaries.

### Pass 4 — Feasibility against live source and architecture

Finding: a greenfield evaluation platform would ignore usable live seams and
overstate current coverage. Reconciliation: the Research identifies planning,
learning, mutation, Source Atlas, privacy, scenario, replay, accessibility, and
external-operation primitives, while explicitly recording the absence of model
integration and a product-level cross-domain benchmark.

### Pass 5 — Product coherence, user value, and long-term fidelity

Finding: technically impressive evaluation could still optimize compliance or
engagement rather than better user decisions. Reconciliation: direct user
questions now test comprehension, agency, usefulness, correction, and
non-predictive simulation; acceptance and completion metrics alone are rejected;
and aspirational opportunity preservation is a first-class quality dimension.

Review verdict: **PASS** for Research completeness and internal consistency.
Devan authorized approval after passing review on 2026-08-04. This is not Scope
approval, implementation authority, or proof that any eventual-intelligence
behavior has shipped.

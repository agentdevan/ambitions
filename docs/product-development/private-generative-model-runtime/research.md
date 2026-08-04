+++
initiative = "private-generative-model-runtime"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions needs generative language/reasoning for destination discovery, Goal
Path proposals, explanations, and replanning, but the app's most useful context
is also its most private. A model runtime must decide where computation happens,
minimize what enters a prompt, constrain what comes out, expose why a mode is
used, and remain useful when a model, device capability, network, policy, or
permission is unavailable.

The user outcome is a private generation service, not a chatbot brain. Product
owners submit bounded typed tasks and receive untrusted typed proposal
candidates plus provenance. Models may propose or summarize. Deterministic
validators and existing domain owners decide whether the result can be shown;
the user decides whether a proposal becomes canonical.

## Current truth

### Ambitions authority

- The constitution calls the technical moat the Private Life Runtime and the
  core capability generative Goal Pathing with schedule reflow.
- Local-learning canon forbids sending observations, feature vectors,
  embeddings, profiles, prompts, or derived influence to hosted AI.
- Existing recommendation, Goal, Step, Time, Capability/Proof, Receipt/History,
  Source Atlas and command owners are typed, local-first and replay-oriented.
- The approved v1 portfolio defines deterministic bounded recommendations,
  path drafts, capability continuity, context-quality scheduling, comparisons,
  adoption and reconciliation. It is approved documentation, not runtime proof.
- Intelligence Evaluation owns claim-bound quality/safety evidence. Intelligence
  Change Management will own model/prompt/policy promotion and rollback.

### Live source seams

The live repository has no production Foundation Models/Core ML generative
runtime. It does have typed planning and recommendation seams under
`Native/Ambitions/Core/LocalRuntimeOS/Planning/`, a private runtime kernel,
Source Atlas public-only boundaries, command executors, persistence/replay,
privacy audits and substantial tests. The existing code therefore supplies
owners and firewalls, not generative capability evidence.

### Platform and provider evidence

Evidence was reviewed 2026-08-04.

Apple's [Foundation Models framework](https://developer.apple.com/documentation/foundationmodels/)
supports on-device and Private Cloud Compute language models, guided Swift
structure generation, tool calling, dynamic profiles and a common model
protocol. On-device capability and context are bounded, and Apple documents
that stronger reasoning/larger context can use PCC or another server provider.
Apple also warns that OS updates can change the system model and prompts must be
retested against each version. Availability depends on compatible hardware,
locale, Apple Intelligence configuration and model state.

Apple's [Generative AI HIG](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
requires transparency, privacy minimization, explicit control, correction/
retry/revert, honest limitations and careful hallucination handling. It
specifically discourages unsourced factual generation where errors can harm and
requires confirmation before consequential actions.

Apple's [Private Cloud Compute security guide](https://security.apple.com/documentation/private-cloud-compute/)
describes stateless request processing, no privileged runtime access,
non-targetability and verifiable transparency for Apple's PCC services. These
are Apple platform guarantees for eligible PCC APIs, not a generic property of
all hosted model vendors or of Ambitions' own prompt construction.

[Core ML](https://developer.apple.com/documentation/CoreML) supports on-device
inference, model deployment and some model-specific on-device updates. This is
useful for bounded classifiers/rankers but does not mean an arbitrary language
model can safely or effectively self-train from Ambitions history. Model
personalization must be separately designed and evaluated.

As one hosted-provider example, OpenAI's current
[API data controls](https://platform.openai.com/docs/models/default-usage-policies-by-endpoint)
distinguish abuse-monitoring logs from application state; default retention and
Zero Data Retention eligibility vary by endpoint/capability, and enhanced
controls require approval. This demonstrates why “not used for training” is not
equivalent to no retention and why a provider adapter needs exact endpoint,
region, retention, tool and change policy. No third-party provider is approved
by this Research.

NIST's [Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial)
frames confabulation, data privacy, bias, information integrity, intellectual
property, security and human-AI configuration as lifecycle risks. Ambitions
must evaluate the complete task system, not a model leaderboard alone.

### Workload decomposition

Ambitions model tasks have different data and capability needs:

| Task | Minimum input | Factual authority | Consequence |
|---|---|---|---|
| Clarify an idea | User-entered text and public vocabulary | User owns intent | Draft questions only |
| Extract a typed candidate | One explicit local object/revision | Input object | Untrusted fields |
| Summarize evidence | Selected local/public evidence excerpts | Source IDs own facts | Draft summary with bindings |
| Propose destinations | Bounded preference/constraint capsule plus public candidates | Source Atlas owns facts | Inspectable candidate set |
| Propose a Goal Path | Approved destination, current constraints, public claims | Domain/source owners | Versioned draft graph |
| Explain/replan | Exact prior plan, changed evidence and allowed context | Existing owners | Draft delta/options |

No workload requires sending the entire private graph. Retrieval should be
deterministic and owner-mediated. Generated prose cannot create a source, fill
an unknown, or turn model confidence into product authority.

### Compute modes

1. **Deterministic/manual:** always available core for forms, rules, validation,
   source retrieval and user editing. This is the fallback and authority layer.
2. **On-device system model:** preferred for bounded tasks when available. It
   keeps prompt processing local but still requires prompt minimization,
   disclosure, cancellation, resource budgets and output validation.
3. **Apple PCC model:** optional for tasks needing capabilities/context beyond
   on-device, only through entitled platform APIs and a disclosed, user-enabled
   privacy mode. Context must still be minimized.
4. **Third-party hosted model:** architectural adapter only. It is disabled
   unless Devan later approves a provider/endpoint/retention/region/terms model
   and the user explicitly enables and confirms the exact data categories.
5. **Downloaded/custom Core ML:** useful for separately evaluated bounded models,
   not an assumed replacement for system generative capability.

Routing must be deterministic policy, not a model choosing where private data
goes. The product should never silently escalate from local to cloud.

### Context minimization and privacy

A `GenerationContextCapsule` should be assembled by typed owners from explicitly
allowed fields, each carrying purpose, sensitivity, source/revision, retention
class and expiry. It uses pseudonymous ephemeral IDs and smallest useful
excerpts. It excludes whole-object stores, contact/address books, raw Proof,
exact location history, free-form journals/notes, unrelated Goals, health/
financial/legal/relationship details and hidden behavioral profiles unless the
specific task both needs the field and the user explicitly includes it.

Hosted modes need a preview that says what categories leave the device, the
provider class, retention mode and fallback. Consent is revocable and
purpose-specific, not a blanket “AI” acceptance. Prompts/responses are not
telemetry. Diagnostic receipts record hashes, versions, categories and reason
codes, never private payloads.

### Structured generation and validation

Every task has a versioned input schema, output schema, instruction/prompt
bundle, allowed read-only tools, budget and validation policy. A generative
response first becomes `UntrustedGenerationEnvelope` containing raw structured
bytes, model/runtime/prompt/schema/source versions, mode, timestamps and stop/
error metadata. Deterministic validation then checks schema, identifiers,
citations, source support, bounds, prohibited claims, duplicates, cycles,
unknown preservation, safety and task-specific invariants.

Repair prompting may retry a bounded number of times using validation errors
that contain no new private data. It cannot invent evidence. After exhaustion,
the app returns a partial or unavailable result with manual recovery. Free-form
prose is derived only from a validated semantic object.

### Read-only tool boundary

Model tools may retrieve allowlisted, purpose-filtered, revision-bound local or
public facts. A tool result is data, not authority delegated to the model. Tools
cannot invoke command executors, mutate repositories, schedule, contact, apply,
purchase, delete, export, browse arbitrary URLs, fetch private remote resources,
or recursively expose the graph. Tool budgets, output schemas and audit hashes
are fixed. Consequential actions remain ordinary preview/confirm/commit flows
outside the model session.

### Availability, failure and deletion

Unavailable model, unsupported locale, disabled Apple Intelligence, low power,
thermal/memory pressure, context overflow, guardrail refusal, network loss,
PCC/provider failure, timeout, rate limit, policy change, invalid structure,
unsupported citation and cancellation are first-class. The user keeps manual
editing, deterministic recommendations where possible, saved local truth and
the ability to retry another enabled mode explicitly.

Ephemeral prompt/session bytes should disappear on completion/cancel. A user may
clear generated drafts, runtime receipts, optional model assets and learned
adapters separately. Deletion-terminal replay cannot restore them. Model/prompt
updates invalidate exact derived drafts; accepted canonical objects remain with
their provenance until their owners offer reconciliation.

### Evaluation dependency

Each task/mode/version needs golden/adversarial datasets and direct-user evidence
for structured validity, grounding, unsupported-claim rate, citation precision/
recall, privacy leakage, sensitive inference, bias/dignity, refusal quality,
correction responsiveness, latency/energy/memory and fallback usefulness. A
model version may pass summarization and fail path generation. There is no global
“AI ready” or person score.

## Evidence

The evidence supports a mode-agnostic task runtime whose safest complete first
product is on-device-first and deterministic around the model. Apple's common
protocol and guided generation make a portable adapter plausible, but changing
system models and availability make prompt/version/evaluation control mandatory.
PCC provides a stronger hosted privacy architecture than ordinary APIs, but it
does not eliminate data minimization or user choice. Third-party retention
differences rule out a generic “cloud AI” toggle.

## Alternatives

1. **One on-device model only.** Strong privacy/offline behavior, but excludes
   incompatible devices and complex tasks. Retain as default, not sole design.
2. **Cloud-first assistant with whole-profile context.** Capable but violates
   local-first privacy, minimization, replay and user-control principles. Reject.
3. **Apple Foundation Models with unrestricted tools.** Convenient, but tool
   calling can perform side effects and model changes can shift behavior. Reject;
   expose only bounded read tools.
4. **Prompt strings embedded in features.** Fast initially, unversioned and
   impossible to evaluate/rollback coherently. Reject.
5. **Typed task runtime with deterministic routing/validation.** More plumbing,
   but isolates providers, protects owners and supports evaluation/rollback.
   Recommend.

## Unknowns and risks

- Exact deployment targets, entitlements, supported locales/devices and PCC
  availability must be verified at implementation time.
- Foundation Models APIs and acceptable-use requirements can change with OS
  releases; Change Management must recertify them.
- Hosted provider approval, commercial terms, retention and regional processing
  are unresolved; third-party mode remains disabled.
- Context minimization can reduce quality; evaluation must find task-specific
  smallest-sufficient capsules rather than expanding by intuition.
- Generated paths can encode socioeconomic, disability, cultural, age or family
  bias even without explicit sensitive fields.
- Tool/prompt injection can enter through source content or user text. All text
  is data; instructions and tool authority remain fixed outside it.
- On-device inference has latency, memory, energy and thermal impacts requiring
  physical-device thresholds.

No hard product fork remains. The architecture can ship with deterministic and
on-device modes while PCC and third-party modes stay unavailable until their
independent gates pass.

## Recommended direction

Create a `PrivateGenerativeRuntime` with a versioned task registry, deterministic
mode policy, capability/availability registry, purpose-bound context assembler,
read-only tool gateway, untrusted structured envelope, deterministic validator,
bounded repair loop, provenance receipt, cancellation/deletion and evaluation/
change-management hooks.

Make on-device the preferred generative mode. PCC is separately user-enabled and
never a silent fallback. Keep a third-party adapter protocol but no enabled
provider. Every product feature retains a useful manual/deterministic fallback.
Models produce proposals only; canonical owners validate accepted mutations.

### Five compounding ruthless review passes

1. **Completeness:** decomposed workloads, modes, context, outputs, failures,
   deletion and evaluation rather than treating “LLM” as one capability.
2. **Connections/ownership:** separated Source Atlas facts, local-learning,
   feature schemas, evaluation, change management and command owners.
3. **Privacy/authority/failure:** prohibited silent cloud escalation, whole-graph
   prompts, write tools, payload telemetry and consent bundling.
4. **Feasibility:** aligned with Apple Foundation Models/Core ML/PCC and live
   typed runtime seams while preserving an unavailable/manual path.
5. **Coherence/value:** ensured better models can be substituted without changing
   product authority, and low-capability devices retain core value.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.

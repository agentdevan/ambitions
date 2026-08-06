+++
initiative = "intelligence-change-management"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Ambitions' intelligence will depend on changing public corpora, crosswalks,
current sources, prompts, system/hosted models, task schemas, validators,
policies, evaluation sets and provider adapters. An update can improve one task
and silently break another, make a claim stale, change a recommendation, violate
rights or invalidate a saved proposal. Users need continued useful behavior and
plain explanations, not invisible personality shifts or accepted plans rewritten
because an upstream package changed.

The outcome is an Intelligence Release & Change service that knows exactly what
artifact/version is active, verifies provenance/signatures/compatibility,
computes dependency impact, requires claim-bound evaluation, stages/promotes or
quarantines releases, rolls back where possible, disables incompatible tasks
where rollback is impossible, purges withdrawn content and reconciles only exact
drafts. Canonical user-owned state remains with its owner.

## Current truth

### Approved platform owners

The future portfolio now defines domain corpus releases, Relationship Registry,
Current Authority Registry, Private Generative Runtime task/model/prompt tuples,
grounded proposal evidence, Context/Learning policies, Portfolio/Life Branch
activation gates, External Action adapter registry and Intelligence Evaluation.
Source Atlas already has signed public packs, freshness/LKG/refresh targets and
foundry release concepts. Each initiative specifies versioned evidence and exact
invalidation; a common change owner is needed to coordinate them without taking
over their semantic approval.

These documents and live source do not prove a secure production release
pipeline, model/corpus regression control or end-user change explanation.

### Live source seams

The repository contains Source Atlas manifest/signature/freshness/cache/
promotion/rollback/refresh, Foundry source locks/certification/release proof,
runtime migrations/journals/LKG, app/version/degraded states, canon/code-quality
workflows and many content hashes. It also contains generated/config artifacts
with varied maturity. No one contract currently ties corpus/model/prompt/policy/
adapter/evaluation compatibility and user-draft impact together.

### External standards and platform evidence

Apple documents [versioning and evaluating prompts when system models change](https://developer.apple.com/documentation/foundationmodels/updating-prompts-for-new-model-versions):
model updates can alter output; prompts should be versioned and prior/new behavior
compared. On-device system models may be OS-owned and not pin-able or roll-backable
by Ambitions, so compatibility detection and task disablement/fallback are as
important as ordinary rollback.

[The Update Framework](https://theupdateframework.github.io/specification/)
defines signed root/timestamp/snapshot/target metadata to resist arbitrary,
rollback, freeze, mix-and-match and wrong-artifact attacks, with version and
expiry checks. Ambitions need not copy its implementation blindly, but its
threat model is directly relevant to remotely delivered public intelligence
artifacts and revocations.

[SLSA 1.2 provenance](https://slsa.dev/spec/v1.2/provenance) describes verifiable
where/when/how an artifact was produced and recommends immutable attestations
associated with artifacts. [NIST SSDF 1.1](https://csrc.nist.gov/pubs/sp/800/218/final)
frames secure development practices across the lifecycle. These inform build/
source provenance, reproducibility, vulnerability response and change audit;
they do not replace Ambitions' product-semantic evaluation.

### Artifact families and compatibility tuple

Managed artifact families:

- public corpus/source/current/relationship releases and rights policies;
- private generative task, prompt/instruction, schema, validator, tool and mode
  policy bundles;
- model/provider capability snapshots and adapters;
- context/local-learning/scenario/branch/external-action policy registries;
- evaluation datasets, rubrics, thresholds and signed results;
- migrations/decoders and UI semantic/copy bundles where independently updated;
- root/trust/revocation/activation metadata.

Every release is immutable/content-addressed and declares artifact ID/family,
semantic/schema version, source/material hashes, builder/provenance, signer,
created/effective/expiry, rights/jurisdiction, compatible app/OS/device/locale/
model/task/policy/source versions, dependencies, supersedes/rollback target,
withdrawal/purge policy, risk class, evaluation claims and release notes.

A runtime `IntelligenceCompatibilityTuple` binds all components for one task.
A corpus release can change independently, but a task is active only when the
whole tuple is compatible and evaluated for its claims.

### Change classification

- `additive`: new supported content/locale/task with existing semantics;
- `correction`: factual/schema/prompt/policy fix that can change output;
- `breaking`: incompatible schema/meaning/owner boundary;
- `sourceChanged`: upstream bytes/terms/authority changed;
- `rightsWithdrawal`: use/retention no longer allowed; purge may be urgent;
- `securityRevocation`: artifact/key/adapter/model/task unsafe; fail closed;
- `modelEnvironmentChange`: OS system model/capability changed outside release;
- `evaluationChange`: dataset/rubric/threshold changed; prior pass doesn't
  automatically transfer; and
- `rollback`: deliberate activation of a prior still-safe tuple, not accepting a
  cryptographic downgrade from the network.

Severity is claim/task specific. A label correction may be low risk for search
and high risk for a current requirement. No universal “minor” classification
can bypass semantic evaluation.

### Lifecycle

`discovered -> acquired -> verified -> compatible -> evaluated -> staged ->
active`, with side states `quarantined`, `revoked`, `withdrawn`, `rollbackReady`,
`purging`, `failed`, `superseded`. Verification checks trust metadata, hashes,
provenance, source/rights locks, schema and anti-rollback/freeze/mix-and-match.

Evaluation uses Intelligence Evaluation claims per affected task/dimension/slice.
Staging installs an immutable generation without exposing it. Promotion is
atomic and produces a release receipt/impact set. Readers lease one generation.
Rollback selects a previously trusted compatible/evaluated release under a
local authorized plan; it cannot resurrect revoked/withdrawn content. If an OS
model changed and cannot roll back, affected task becomes unavailable/manual or
uses another already approved mode/prompt tuple.

### User-visible impact and canonical truth

Change impact uses exact evidence/task/policy dependency IDs. Unaccepted drafts
become `recomputeAvailable`, `staleReview`, `sourceNeeded` or `invalid`. Accepted
Goals/Paths/Steps/Time/Proof remain unchanged and retain their historical
provenance; their owners may offer a reconciliation preview when current facts
matter. No release auto-replans, auto-adopts or rewrites history.

User-facing change notes should say what changed and what it affects in plain
terms: “NASA application information changed; your saved route remains, but its
application step needs review.” They must not expose technical noise or imply
the user caused the change. Users can inspect active sources/model mode/policies,
defer non-safety updates where safe, retry, use LKG/offline, clear packages or
recompute drafts. Security/rights revocation may block use immediately with
honest fallback and required purge.

### Release autonomy and control

Routine low-risk signed public releases may download/stage in background using
finite public IDs and promote only under predeclared evaluation/compatibility
policy. Higher-risk task/model/policy/adapter changes can ship with the app or as
signed public configuration but must never bypass claim-bound evidence. This is
runtime product safety, not a process-only Git/merge approval receipt.

Private data is never sent to determine rollout or evaluation. No remote A/B
profiling. On-device cohorts, if ever used, are content-independent and require
separate privacy/evaluation authority. The safe default is deterministic
compatibility and global public release metadata plus local state.

### Trust root, keys and incident response

Root metadata is pinned in the app and supports versioned threshold rotation.
Online artifact signing is separated from offline/root/revocation authority.
Clients reject expired/older/mixed metadata, excessive roles/depth/size and
unknown algorithms. Key compromise/unsafe artifact triggers signed revocation,
task disablement, fallback, exact purge and visible status. Last-known-good is
allowed only when not revoked/withdrawn and still safe for the exact purpose.

### Deletion, migration and offline

Package removal/purge clears raw/shards/indices/models/prompts/tools/rendered/
caches/exports/prohibited lineage and exact derived draft material. Allowed
minimal receipts retain hashes/IDs, never withdrawn content. Private schema
migrations remain owner-controlled, transactional and recoverable; public
release promotion cannot run arbitrary private mutation.

Offline operation uses bundled/current trusted generation or manual fallback.
Expired trust timestamp may block new updates but should not automatically erase
safe bundled local core; purpose-specific freshness/rights decide existing use.

### Evaluation and direct-user evidence

Change Management itself needs tests for artifact authenticity, compatible
tuple selection, correct impact, stale/rollback/revocation behavior, deletion,
privacy/security, accessibility and comprehension. Each change also needs the
Evaluation service's factual/quality/safety gates. User studies verify that
change notices and fallback explain why recommendations differ without causing
false loss of trust or update pressure.

## Evidence

External standards demonstrate that secure artifact delivery requires more than
TLS and hashes; Apple demonstrates that system-model changes require prompt
versioning/regression. The product portfolio already produces exact versioned
inputs. A unified compatibility/impact/promotion service prevents each feature
from inventing unsafe update logic while preserving semantic ownership.

## Alternatives

1. **Update everything with the app.** Simple but slow for source revocation and
   unable to control OS model changes. Retain for code, not all artifacts.
2. **Dynamic remote config without signed provenance/evaluation.** Fast but
   vulnerable and unreviewable. Reject.
3. **Let every initiative update itself.** Preserves domain knowledge but causes
   inconsistent trust/rollback/impact. Reject; domain validates semantics while
   common service coordinates mechanics.
4. **Signed immutable release graph with compatibility/evaluation/impact.**
   More infrastructure but secure, inspectable and rollback-capable. Recommend.

## Unknowns and risks

- Exact signing/distribution infrastructure and key custody require security
  implementation review.
- System model identity/capability visibility may be coarse; unavailable/fallback
  must handle that honestly.
- Excessive cross-product compatibility can grow; task-specific manifests and
  bounded tuples are needed.
- Emergency revocation must be fast without becoming a remote arbitrary kill
  switch for canonical/private data.
- Reproducibility differs across source/model artifacts; provenance claims must
  be precise, not blanket SLSA labels.

No hard product fork remains. Use app-pinned trust metadata and signed immutable
public releases; disable/fallback where external model rollback is impossible.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Trust/IntelligenceReleases/`.
- Evidence and unknowns: Repository audit identifies Task 9 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

Create `IntelligenceReleaseCoordinator`, immutable artifact/attestation store,
trust metadata verifier, compatibility graph, change classifier, evaluation gate,
staging/atomic promotion/rollback/revocation/purge, exact impact notifier and
user-visible change inspection. Domain owners validate semantics; Evaluation
supplies claim evidence; no update mutates accepted private state.

### Five compounding ruthless review passes

1. Completeness: included all artifact/change classes, trust, lifecycle,
   compatibility, evaluation, user impact, rollback/revocation/purge/offline.
2. Connections: separated domain semantics, artifact mechanics, evaluation,
   source rights, runtime consumers and canonical owners.
3. Privacy/authority: rejected private rollout profiling, arbitrary remote config,
   unsafe LKG resurrection, automatic replanning and public private migration.
4. Feasibility: handled both pin-able artifacts and OS-owned unrollbackable
   models; used existing Source Atlas generation/LKG seams.
5. Coherence/value: added plain change notes, manual fallback and exact draft
   impact while preserving accepted/history truth.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.

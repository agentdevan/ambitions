+++
initiative = "scoped-automation-authority"
document_type = "research"
status = "draft"
upstream = ""
+++

## Idea and user problem

Ambitions is meant to adapt, schedule, recover, and coordinate useful work while
the user remains the final authority over meaningful consequences. The current
product can classify proposed actions as suggest-only, draftable,
confirmation-required, locally executable, prohibited, or unsupported. That is
a strong static safety ceiling, but it does not yet answer a different user
question: “Can I delegate this exact kind of recurring local upkeep, for this
bounded set of objects and consequences, until I pause or revoke it?”

Without bounded delegation, Ambitions must either request repeated confirmation
for semantically similar actions or rely on broad automation settings that are
hard to understand and too easy to overgeneralize. Repeated prompts create
fatigue and encourage reflexive acceptance. Broad modes risk granting more
authority than the user intended. Inferring permission from observed behavior,
silence, successful prior runs, or lack of correction would violate the
product's local-first and user-authority laws.

The research problem is whether a user-owned, revocable, explicitly scoped
automation authority can reduce repetitive confirmation without creating a
second command system, hidden privilege escalation, administrative burden, or
an impression that Ambitions owns the user's decisions.

## Current truth

This Research inspected repository `main` at
`ccaed087708facd99780c5fb84590be4bde90d88`, current canon, live source, tests,
and the approved adjacent product-development initiatives.

The Constitution's `CONTROL-FORCE-NOTHING-001` permits scheduling only within
granted authority, requires that delegated authority be withdrawable, and calls
automation a revocable permission. Material consequences still require explicit
confirmation under their owning law. The You and Goals specifications expose an
automation policy or level, but they do not define a persisted user-owned grant
with identity, revision, scope, expiry, suspension, revocation, or use limits.

Current source provides a substantial static policy foundation:

- `SafeAutomationPolicyModels.swift` defines action kinds, permission levels,
  confirmation requirements, safety classes, Undo rules, reasons, and
  deterministic policy decisions.
- `SafeAutomationProposedAction.swift` evaluates an action, source, and targets
  against those fixed policy rules.
- `PolicyGuardedCommandExecutor.swift` keeps policy checks in the sanctioned
  runtime path and records safe failures or confirmation requirements.
- focused tests cover local, external, destructive, privacy-sensitive,
  broad-reflow, and unsupported cases.

No current source type represents a durable user-authored automation grant or a
grant lifecycle. A static `executeLocalOnly` result is therefore not evidence
that a person granted a recurring semantic operation, and a prior confirmation
is not reusable authority.

Adjacent lifecycle owners remain separate:

- Personal Context and Constraint Controls owns permission to use specific
  context categories for named purposes. It does not authorize mutations.
- External Action Integration Orchestration owns prepared and external effects,
  provider reconciliation, and external result truth. It does not grant local
  semantic authority.
- LocalRuntimeOS owns commands, Events, Projections, Receipts, replay, and
  commit-time validation. Any future authority model must constrain that path,
  not replace it.
- each object and surface owner retains its own semantic invariants and
  confirmation rules.

The earlier Linear GAL dossier was useful hypothesis material but was based on
an older repository revision and is not authority. This Research restates only
the current, repository-supported problem and does not import its old program,
patent, or implementation posture.

## Evidence

Repository evidence supports both the need and the safety boundary:

- the Constitution explicitly distinguishes capability from revocable user
  authority;
- current policy code already separates suggestion, preparation,
  confirmation, local execution, prohibition, and unsupported behavior;
- current tests show why external, destructive, privacy-sensitive, and broad
  changes need narrower treatment than reversible local upkeep;
- the runtime already has the Receipt, replay, expected-revision, and
  fail-closed seams needed to test authority without creating an alternate
  mutation path.

External platform evidence reinforces the distinction between discoverable
capability and permission to execute. Apple's App Intents contract exposes app
actions to system experiences while providing explicit confirmation APIs for
sensitive actions; discoverability itself is not authorization:
<https://developer.apple.com/documentation/appintents/appintent>.

Least-privilege guidance likewise favors granting only the authority necessary
for a specific operation instead of a broad standing capability. NIST SP
800-53 AC-6 is relevant security evidence, but enterprise access-control
terminology should not be copied into the Ambitions interface:
<https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final>.

The minimum useful evidence is not a schema or policy unit test alone. A bounded
experiment must compare repeated confirmation, a broad global automation mode,
and explicit scoped delegation for a small number of reversible local actions.
It must measure prompt reduction, comprehension, surprise, correction, revoke
success, stale-target rejection, aggregate materiality, and attempts to widen
authority through batching or repeated behavior.

## Alternatives

1. **Confirm every meaningful action.** This is safest against silent
   escalation and remains the fallback, but repeated equivalent prompts may
   create fatigue and reduce meaningful attention.
2. **Use only global Manual, Guided, or Adaptive modes.** This is easy to
   explain but too coarse for differences between actions, objects, time
   horizons, consequences, and external surfaces.
3. **Keep the static safety ceiling and add explicit scoped, revocable user
   authority beneath it.** This can preserve hard product limits while allowing
   narrowly delegated local upkeep. It adds lifecycle, inspection, and UX
   complexity and must prove that the benefit exceeds that cost.
4. **Infer authority from behavior or prior confirmations.** This could reduce
   prompts but is incompatible with current product law. Evidence may support a
   suggestion to offer a grant; it cannot create or widen one.
5. **Treat context-purpose grants as automation grants.** Reusing one word may
   appear simpler, but permission to read or use context is not permission to
   mutate a Goal, Step, schedule, or external system. Combining them would blur
   privacy and action authority.

## Unknowns and risks

- Which reversible local actions, if any, produce enough repetitive prompt cost
  to justify standing authority?
- Can users understand action, object, consequence, time, surface, and budget
  scope without being asked to administer a permissions dashboard?
- Should authority be one-time, time-bounded, use-bounded, object-bounded, or a
  carefully limited combination, and what defaults avoid accidental breadth?
- How are aggregate materiality and batch splitting detected when individually
  small actions create a broad plan change?
- What happens to prepared or queued work when a grant expires, is suspended,
  is revoked, the target revision changes, privacy sensitivity increases, or
  another principal becomes affected?
- How are grant history and Receipts preserved while deletion and privacy rules
  prevent stale or rejected authority from reappearing?
- Can App Intents, widgets, notifications, or other compact surfaces ever use a
  grant directly, or must they remain narrower than in-app authority?
- A detailed grant system may create more anxiety and administration than
  repeated confirmation. That outcome should kill or sharply reduce the idea.
- A grant model could be mistaken for autonomous-agent permission, enterprise
  access control, or implementation readiness. Research must keep the product
  problem and current proof ceiling explicit.

## Recommended direction

Continue to Research a **scoped automation authority** layered beneath current
static safety ceilings and above the sanctioned command path. The working
hypothesis is that the user may explicitly delegate a bounded reversible local
semantic operation, inspect recent use, pause or revoke it immediately, and
receive truthful Receipts, while evidence and prior success can never create or
widen authority.

The next phase should not assume a universal grant object or commit an
architecture. Research should first select two realistic, low-risk repetitive
actions; define a broad-mode and repeated-confirmation baseline; test expiry,
revocation, stale revisions, protected state, compact surfaces, batching,
aggregate materiality, and another-principal effects; and determine whether the
scoped model materially improves comprehension and prompt burden without
increasing surprise.

If that experiment does not outperform existing confirmation and static policy
with acceptable user and engineering cost, end the initiative and retain the
current Safe Automation owners. This draft authorizes no Scope, Design,
implementation, migration, or autonomous execution.

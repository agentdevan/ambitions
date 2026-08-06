+++
initiative = "capability-continuity-foundation"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

Completed Goals, milestones, Steps, reflections, and saved Proof can leave the
user with reusable skills, knowledge, or methods. Ambitions currently preserves
the work and its history, but it does not give the user one durable,
user-correctable place to say what capability the work developed. Changing a
Goal can therefore make real progress feel stranded, and later recommendation
or path systems would have no trustworthy private input to reuse.

The product opportunity is capability continuity: help the user retain an
evidence-linked Life Capital interpretation of what they practiced or learned,
without treating completion as mastery, turning personality into a skill,
building a public resume, or allowing an inference to become authoritative
before the user confirms it.

This is a foundation initiative, not a recommendation feature. Its value is
that a person can inspect and correct a capability record today and later decide
whether a separately approved consumer may ask to use it. The foundation must
remain useful and honest even while no recommendation, simulation, or scheduling
consumer exists.

## Current truth

This Research uses baseline main SHA: `40894e92c61de55841c31fd797fd5ae39625c5dc`
and the portfolio synthesis
at `docs/product-development/adaptive-skills-and-pathways/research.md`. It
inspected current canon, live source, and tests; source presence and test code
are implementation evidence, not proof that this experience ships.

Canon already establishes most of the governing laws:

- `MISSION-ORIGIN-OUTCOME-001` and `MISSION-INTEGRATION-001` require useful
  skills, knowledge, Proof, and learning to survive and improve later choice.
- `OBJ-LIFE-CAPITAL-EDITABILITY-001` makes Life Capital user-editable and
  inspectable, while `OBJ-LIFE-CAPITAL-ANTI-GAMIFICATION-001` rejects scores,
  ranks, streaks, and comparative worth.
- `SYSTEM-LEARNING-LOCAL-001` permits bounded local capability inference only
  with evidence, uncertainty, correction, disablement, and non-judgmental copy.
  `SYSTEM-LEARNING-CONTROL-001` requires inspection, correction, reset, archive,
  deletion, downstream consequence disclosure, and no automatic decay.
- `OBJ-PROOF-IDENTITY-001` keeps Proof user-approved and ungraded. Proof can
  support continuity, but a Receipt only attests a mutation and is not practice
  evidence by itself.
- Goal, History, Receipt, archive, Trash, permanent-deletion, privacy, replay,
  accessibility, and no-silent-mutation laws continue to govern their own
  objects. A capability control cannot rewrite the source event that truthfully
  happened.

No canonical Capability object currently owns durable private identity,
plain-language meaning, evidence relationships across multiple Goals, or a
separate lifecycle. Life Area owns Life Capital placement; Local Learning owns
learned influences; Proof owns user evidence; none should be overloaded to own
all capability semantics.

Live source contains adjacent seams rather than an end-to-end solution:

- `ProofResourceGraphModels.swift` represents evidence anchors, freshness,
  contradiction, and pivot-preservation outcomes between already-known objects.
- `LearningAnticipationService.swift` derives bounded goal-local patterns and
  corrections, but not durable cross-Goal capabilities.
- History, Receipt, replay, Trust inspection, and LocalRuntimeOS mutation paths
  provide the general integrity machinery a future design can reuse.
- `SourceAtlasCapabilityGraph` describes public reference concepts and paths;
  it is not the private user's capability identity and cannot receive private
  evidence.

The inspected tests assert pieces of those models. They do not establish
manual capability creation, safe proposals, confirmation, cumulative evidence,
archive/Trash/deletion, protected-output handling, or a user-facing Life Capital
collection.

## Evidence

The umbrella Research compared O*NET, ESCO, Proof, credential, career,
education, and time-quality semantics. Its strongest relevant conclusions are:

- Everyday “soft” and “hard” skill language is too coarse for internal truth.
  A capability may be an ability, body of knowledge, or useful method;
  experience is context or evidence, not automatically the capability itself.
- User-stated, practiced, Proof-linked, and issuer-credentialed information are
  independent provenance facets, not a strength ladder. This foundation can
  establish the first three while credential import remains separate.
- Completion is ambiguous. An accepted activity may support practice only when
  the capability-bearing activity or explicit reflection says what was
  practiced. Buying a leadership book does not prove practiced leadership, and
  completion behavior cannot justify traits such as discipline or aptitude.
- Capability evidence can remain valid when a Goal ends or changes direction.
  Relevance to a later destination is a separate comparison and must never
  downgrade or erase the original Life Capital record.
- Sensitive derived output matters as much as sensitive input. A label or linked
  context can reveal health, disability, religion, finances, relationships,
  citizenship, age, or other protected facts even when the source object did
  not carry a convenient sensitive flag.

External occupation and credential standards reinforce the separation rather
than defining this private object. The O*NET Content Model distinguishes skills,
knowledge, abilities, work styles, experience, credentials, and work context;
Open Badges distinguishes an issuer assertion and supporting evidence from
universal competence. Neither source establishes what this particular user
possesses. Those facts remain user-owned local interpretations.

The initiating scenario supplies the core continuity test: a user pursuing an
astronaut Goal may complete education, technical work, communication practice,
or Proof. If the destination changes, those records should remain inspectable
and potentially reusable without Ambitions declaring the user qualified for a
different career or automatically creating one.

## Alternatives

### Manual capability list only

A manual list is maximally legible and avoids inference risk. It also creates
maintenance burden and fails to connect completed work with retained value.
Manual entry should remain a valid path, but manual-only behavior leaves much of
the continuity opportunity unrealized.

### Automatic skills from completion

Automatically converting every completed Goal or Step into a skill is low
friction but untrustworthy. It confuses exposure, assistance, practice, and
mastery; encourages personality inference; and creates noisy identity claims.
This alternative conflicts with canon's evidence, uncertainty, and user-control
requirements.

### Capability as a Proof subtype

This appears economical because Proof can support Life Capital. It would
collapse the evidence artifact into the reusable interpretation, prevent manual
claims without Proof, and make correction or deletion semantics unclear.

### Capability as Local Learning state only

Keeping capability meaning as hidden learned state avoids a new object, but it
would make identity, lifecycle, multi-source evidence, and user ownership
fragile. Local Learning can propose or remember dismissals; it should not own a
confirmed canonical claim.

### Evidence-backed, user-owned capability continuity

A durable capability interpretation with independent evidence relationships,
manual entry, bounded proposals, explicit confirmation, correction, lifecycle,
privacy classification, and default-off future-use eligibility best fits the
evidence. It adds a real product concept, but it keeps that concept narrow and
prevents downstream engines from inventing their own incompatible person model.

## Unknowns and risks

- Users may read “practiced” or “Proof-linked” as proficiency or mastery even
  when the product does not score them. Interaction research must test the
  plain-language distinction.
- Proposal timing can become noisy. Research supports calm review and Life
  Capital inspection moments, but Design must express a deterministic eligible
  state without interrupting Step completion.
- Similar labels can represent different capabilities, and different labels
  can represent the same practice. Silent taxonomy merging would destroy user
  meaning; user-controlled evidence accumulation is safer.
- Privacy classification can produce false positives. The product needs a way
  to correct ordinary classification error without allowing genuinely protected
  content into an unauthorized later consumer.
- Archive, Trash, permanent deletion, suggestion reset, and source deletion are
  distinct. Their consequences must not be collapsed into a single “remove”
  control.
- A generic future-use permission cannot be advance consent for unknown future
  features. A later consumer needs its own approved Scope, disclosure, and fresh
  consent.
- No user research yet proves that people prefer a persistent collection,
  contextual proposals, or both. The foundation can support both for prototype
  validation without claiming demand.
- Persistence representation, indexes, receiving service, and migration are
  Design questions. Current Proof-capital and public capability graph types are
  evidence, not automatic architectural authority.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/You/CapabilityCollectionView.swift`, `Native/Ambitions/Surfaces/Goals/CapabilityProposalCard.swift`.
- Evidence and unknowns: Repository audit identifies Task 5 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

The evidence favors a focused capability-continuity foundation: an inspectable
Life Capital collection containing user-owned capability meanings and explicit,
non-ranked relationships to accepted practice and user-approved Proof. Manual
entry remains valid. Ambitions may offer conservative, evidence-linked proposals
at calm moments, but a proposal has no ownership or influence until the user
confirms it.

The candidate product direction preserves source truth while giving the user
independent controls over capability meaning, evidence relevance, learned
proposal state, archive, Trash, deletion, and future-use eligibility. It avoids
automatic decay, proficiency scores, personality inference, a new root surface,
and any current planning consumer.

This foundation is a hard dependency for capability-based career, education,
and hobby matching, confirmed profile claims that become Capabilities, and
Capability export. It is conditional elsewhere: direct destination adoption,
Goal Path generation from an already-adopted Goal, scheduling of existing
Steps, and credential storage/Proof can work without a Capability. Those
initiatives require this foundation only when they actually read, relate, or
disclose a Capability, and then only under their own approved behavior and
consent contracts. None may expand this foundation into a recommendation, Goal,
route, schedule, credential, or public profile.

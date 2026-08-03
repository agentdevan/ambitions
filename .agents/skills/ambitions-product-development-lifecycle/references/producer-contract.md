# Creation guidance

Work conversationally with Devan. Before creating or revising a document,
inspect the relevant canon, source, tests, existing initiative files, and
available evidence. Use the phase template at the canonical initiative path and
keep the document self-contained enough for the next phase to use without chat
history.

Research records the problem, current truth, evidence, alternatives, risks, and
a recommended direction. It does not commit Scope or implementation. Scope is
created from approved Research and resolves product behavior, exclusions,
requirements, and acceptance criteria without forcing Design to invent a product
decision. Design is created from approved Scope and resolves the flows, states,
architecture, data, privacy, accessibility, traceability, and verification
needed for implementation grooming.

Give every Scope requirement a unique `REQ-###` identifier, and map every one in
Design's requirement traceability section. After approved Design, produce all
three grooming files. The plan covers affected components, interfaces, data
flow, persistence, migrations, canon changes, rollout concerns, and
implementation order. Tasks are small and ordered and name exact files,
dependencies, acceptance criteria, and tests. Verification names the affected
automated, build, runtime, accessibility, privacy, migration, performance, and
device evidence. Use an explicit `N/A` with a reason for categories that do not
apply. This is authoring guidance, not a request for the structural checker to
judge the substance of the prose.

If evidence, repository access, or a product decision is missing, stop and
explain what is needed. Do not require extra process artifacts, recorded
integrity state, repository-history replay, or an isolated reviewer session.

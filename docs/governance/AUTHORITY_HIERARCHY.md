# Ambitions Authority Hierarchy

## Purpose

Defines the official authority order for Ambitions execution, canon, proof, governance, and remaining-work decisions.

This hierarchy exists to prevent:

- conflicting execution truth
- stale roadmap drift
- superseded implementation authority
- false completion claims
- duplicate operational ownership

---

# Tier 1 — Active Truth Files

Primary location:

- `docs/truth/`

Examples:
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`

Responsibilities:
- product truth
- IA truth
- naming truth
- visual truth
- implementation/source truth
- release/proof truth
- Codex operating truth
- historical cleanup policy

`docs/canon/`, `docs/AmbitionsCanon/`, `docs/codex/`, `.codex/`, and `.agents/` are supporting or historical unless an active truth file explicitly promotes a specific file.

Truth files do NOT determine implementation completion. Live source, project, test, script, and current proof evidence determine implementation and validation claims.

---

# Tier 2 — Live Source And Project Evidence

Primary locations:

- `Native/`
- `Sources/`
- `AppUI/Sources/`
- `Packages/`
- `project.yml`
- `Package.swift`
- current tests and scripts

Responsibilities:
- implementation evidence
- project/package wiring
- runtime and service ownership
- validation command ownership

Live source may not override product, release, Codex-process, or historical-cleanup truth, but it wins over docs when deciding what is currently implemented.

---

# Tier 3 — Governance Truth

Primary location:

- docs/governance/
- `.codex/os/`
- `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.json`

Responsibilities:
- reconciliation rules
- proof normalization
- authority rules
- execution-state integrity
- release-claim safety
- operational governance

Governance determines whether operational routing is valid. Governance does not prove app behavior, release readiness, device behavior, accessibility conformance, privacy/legal approval, or App Store/TestFlight readiness.

---

# Tier 4 — Execution Truth

Primary location:

- `docs/codex/GLOBAL_BATCH_SEQUENCE.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/BATCH_REGISTRY.md`
- `.codex/state/active-batch.yml`

Responsibilities:
- active train state
- execution ordering
- blocked state
- completion state
- operational queue

Execution truth must obey active truth files, live source, governance, and proof evidence. Non-`IOS26-*` historical batch IDs are not autonomous runnable batch authority unless a human explicitly provides a scoped override.

---

# Tier 5 — Remaining Work Truth

Primary location:

- GLOBAL_FULL_STACK_COMPLETION_ORDER.md

Responsibilities:
- remaining execution order
- train dependency sequencing
- execution layering

Remaining-work truth may not contradict:
- reconciled registry state
- governance rules
- proof-backed implementation state

---

# Tier 6 — Proof Truth

Primary locations:

- docs/audits/
- build/reports/
- focused tests
- implementation evidence
- commits

Responsibilities:
- implementation verification
- test verification
- evidence verification
- release-claim boundaries

Proof determines whether completion claims are valid.

---

# Tier 7 — Historical Truth

Locations:

- historical docs
- superseded prompts
- archived trains
- old implementation eras

Historical truth:
- preserves evidence
- preserves reasoning
- preserves lineage

Historical truth is NOT active execution authority.

---

# Critical Rule

If conflict exists:

1. governance truth outranks execution prose
2. proof truth outranks narrative completion claims
3. `docs/truth/*` outranks stale implementation direction
4. reconciled execution truth outranks append-only historical sections

---

# Current Repo Status

Current status:

- authority reconciliation active
- registry not fully normalized
- proof-backed execution graph not fully generated
- historical and active execution states still partially intermixed

Until reconciliation completes:

- no speculative completion claims are allowed
- no inferred next-batch authority is allowed
- implementation proof is mandatory for completion assertions

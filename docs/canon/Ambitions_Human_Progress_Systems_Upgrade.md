# Ambitions Human Progress Systems Upgrade
<!-- markdownlint-disable MD013 -->

Status: Active-scope source truth / pre-AOS and pre-LDI upgrade lock. No production Swift implementation in this file.
Date: 2026-05-06
Train: HPS01-HPS12 Human Progress Systems Upgrade

## Product thesis

Ambitions is the private operating system for verified human progress.

Locked tagline:

> Find your life. Keep your promises. Build your future. Enjoy today.

Consumer wedge:

> Start here every day.

Platform thesis:

> Turn a person’s life context, commitments, dreams, requirements, proof, sources, time, and pivots into trusted daily action.

HPS exists because Ambitions must become a market-creating product without widening into a cluttered app. HPS strengthens the underlying operating system, not the visible surface area.

## Scope law

HPS is an internal architecture, quality, governance, evaluation, and moat layer. It must not create visible sprawl.

Allowed:

- source truth
- internal object models
- API contracts
- gates
- test/fixture strategy
- review protocols
- privacy boundaries
- no-claim rules
- vertical strategy
- acquisition-readiness strategy
- Codex OS skills/scripts
- global-order overlays
- AOS/LDI/FCP/PFC integration maps

Forbidden:

- sixth tab
- Life Graph tab
- AI Advisor tab
- dashboard of life areas
- productivity/KPI scoreboards
- generic AI memory chatbot
- school LMS
- parent/teacher/counselor product
- enterprise admin surface
- proof marketplace
- public credential product
- API marketplace
- hosted AI backend
- user-data server
- official education/career requirement database
- career advisor replacement claim
- medical/legal/financial/professional advice product

## HPS primitives

### 1. Human Progress Graph

Internal graph connecting life threads, commitments, goals, requirements, proof, sources, time, pivots, identity, open loops, and privacy states.

It is not a visible graph dashboard by default. It is the operating substrate behind Today, Goals, Capture, Plan, You, AOS, and LDI.

Minimum node families:

- LifeThread
- Commitment
- OpenLoop
- GoalPath
- Requirement
- Proof
- SourceClaim
- TimeCapacity
- Pivot
- IdentityDirection
- PrivacyPermission
- Receipt

Minimum edge families:

- supports
- proves
- dependsOn
- conflictsWith
- supersedes
- transfersTo
- blockedBy
- sourcedFrom
- verifiedBy
- hiddenFrom
- scheduledWithin
- stillCountsToward

### 2. Verified Proof Ledger

Tracks what the user actually did, what it proves, what source or verifier supports it, what privacy class applies, and what future paths it supports.

Proof is not a score. Proof is user-owned evidence of progress.

Future verifier roles may include user, parent, teacher, counselor, manager, coach, or institution, but no multi-user verification product is implemented by HPS.

### 3. Source Truth / Requirement Graph

Every requirement, recommendation, and path claim must have claim state, source quality, freshness, uncertainty, and review path.

Claim states include:

- official
- semi-official
- expert
- community
- user-confirmed
- imported
- inferred
- stale
- disputed
- unsupported
- private

No requirement is treated as official without source proof.

### 4. Commitment Memory / Searchable Life Recall

Ambitions should help the user remember commitments, promises, errands, birthdays, follow-ups, parked projects, abandoned loops, and life context.

Recall must show source, freshness, privacy, and correction path. Inferred memories are never facts until reviewed.

### 5. Start Here Recommendation Quality

Start Here must not be an AI suggestion card. It is a grounded daily decision surface.

A Start Here candidate must be able to explain:

- why this
- why now
- why not the alternatives
- what source supports it
- what proof or commitment it advances
- how it fits time/capacity
- what privacy constraints apply
- what happens if skipped
- what still counts if adapted

Use evidence strength instead of fake confidence scores.

### 6. Option Value / Pivot Preservation

Ambitions must preserve value across pivots.

The system should answer:

> What does this still count toward?

Prior proof can transfer across adjacent paths when source, requirement, and evidence overlap.

### 7. Living Dream Compiler

LDI must become a compiler from vague dream to safe meaning, requirements, path portfolio, proof needed, capacity fit, next evidence, and Today step.

Dream handling must include seriousness ladder, dream-to-domain classification, feasibility spectrum, North Star extraction, source boundaries, safety/legal/professional limits, mutation permissions, and blast-radius review.

### 8. Privacy / Memory Permission Kernel

Sensitive life memory must be user-owned, private by default, correctable, rejectable, forgettable, and reviewable.

Permission states include:

- remember
- private
- hide
- ask later
- reject
- forget
- correct
- stale
- source-backed
- inferred

External surfaces must use private-by-default redaction for sensitive life content.

### 9. Local Intelligence Adapter

AOS may use deterministic extraction/classification first and optional local/on-device model adapters later. Model-driven behavior must not be required for core correctness.

Any future model use must have:

- deterministic fallback
- user review path
- source/freshness label
- privacy boundary
- performance/battery budget
- no hidden mutation
- no hosted AI/user-data-server claim unless explicitly implemented and legally reviewed

### 10. AI Governance / Evaluation Lab

AOS and LDI require permanent evaluation infrastructure.

Minimum evaluation classes:

- ADHD overload
- new baby / family pressure
- forgotten promise
- relationship commitment
- work deadline
- stale source
- private goal
- career false-certainty
- education eligibility ambiguity
- minor/student-data risk
- professional-boundary risk
- unsafe dream
- memory hallucination
- open-loop recovery
- path pivot
- proof revocation
- no-claim release copy

### 11. Vertical Expansion Architecture

HPS may define future vectors but must not implement them now:

- education
- career
- workforce upskilling
- coaching/advising
- family coordination
- verified proof economy
- source-pack marketplace
- platform/API licensing

### 12. Singular Experience / Acquisition Readiness

HPS must make the app more coherent, not broader.

The five-tab experience remains:

- Today: one grounded daily decision surface
- Goals: path/proof/option-value system, not project board
- Capture: minimal life-fragment entry, not inbox
- Plan: LifeShape capacity/reflow, not calendar dashboard
- You: Personal System Center, not settings dump

Acquisition readiness means acquirer-readable architecture, testability, privacy posture, proof ledger, API map, and governance evidence. It does not mean acquisition is guaranteed or claimed.

## Completion standard

HPS is complete only when:

- HPS01-HPS12 are defined in train source truth
- HPS gates cover no-sprawl, rendered visual proof, recommendation quality, proof/source contract, privacy memory, AI governance, and acquisition readiness
- AOS cannot start without HPS inheritance
- LDI cannot start without HPS inheritance
- remaining FCP surface maturity is governed by HPS no-dashboard rules
- PFC legal/privacy/security/performance references include HPS risks
- CQS/FVQ know when HPS review is required
- no implementation/release/legal/cloud/AI-runtime claim exceeds evidence

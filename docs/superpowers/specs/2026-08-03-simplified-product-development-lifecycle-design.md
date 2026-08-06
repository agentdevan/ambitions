# Simplified Ambitions Product-Development Lifecycle

**Status:** Approved

**Supersedes:** `docs/superpowers/specs/2026-08-02-ambitions-product-development-lifecycle-design.md`

## Purpose

Turn a product idea into approved Research, Scope, and Design documents, then
groom the approved Design into implementation documentation. The workflow must
help Devan and ChatGPT make product decisions; it must not require sealing,
contract hashes, provenance packets, isolated reviewer sessions, consumer lanes,
or repository-freshness replay.

## Canonical initiative layout

Each initiative lives at:

```text
docs/product-development/<initiative>/
├── research.md
├── scope.md
├── design.md
└── implementation/
    ├── plan.md
    ├── tasks.md
    └── verification.md
```

These repository files are the durable handoff. They are canonical project
documents, but they do not themselves become files under `docs/canon/`. Current
product canon continues to govern until implementation work deliberately updates
the owning canon sources.

## Lifecycle

1. Devan brings an idea. ChatGPT inspects relevant canon, source, tests, and
   evidence and creates `research.md`.
2. Devan reviews Research. ChatGPT reviews it for completeness and consistency,
   revises it with Devan's agreement, and marks it approved only after Devan
   explicitly approves and ChatGPT has no blocking findings.
3. ChatGPT creates `scope.md` from approved Research. The same human-review,
   ChatGPT-review, revision, and approval loop applies.
4. ChatGPT creates `design.md` from approved Scope. The same review loop applies.
5. After Design is approved, ChatGPT or Codex creates the three implementation
   grooming documents.

Research must be approved before Scope can be approved. Scope must be approved
before Design can be approved. Reviews may occur in the same conversation as
authoring and revision.

## Document metadata

Every phase document records only:

- initiative;
- document type;
- `status: draft` or `status: approved`;
- upstream document path for Scope and Design.

Approval requires both Devan's explicit approval and a ChatGPT review with no
blocking findings. ChatGPT may then edit the repository file to set
`status: approved`. There are no seals, revision hashes, review JSON files,
approval receipts, owner attestations, or transition event logs.

## Phase templates

### Research

Research defines the idea and user problem, current repository and canon truth,
evidence, alternatives, unknowns, risks, and a recommended direction. It does not
commit product scope or authorize implementation.

### Scope

Scope defines the committed outcome, included and excluded behavior,
requirements, acceptance criteria, risks, dependencies, potential canon changes,
and unresolved product decisions. It must use approved Research as its upstream
input and must not leave decisions that would force implementation to invent
product behavior.

### Design

Design defines user flows, states, interactions, recovery, architecture, data,
privacy, accessibility, testing, and requirement-to-design traceability. It must
use approved Scope as its upstream input and be detailed enough to groom without
inventing behavior.

## Review behavior

ChatGPT performs an ordinary editorial and product review:

- `PASS` means the document is complete, internally consistent, grounded in the
  repository, and ready for Devan's approval or the next phase.
- `NEEDS REVISION` returns a concise list of blocking findings.

When Devan agrees with the findings, ChatGPT revises the document directly and
reviews it again. Review output is conversational; no separate JSON artifact,
reviewer process, or memory-isolated session is required.

## Implementation grooming

After Design approval, ChatGPT or Codex creates:

- `implementation/plan.md`: affected components, interfaces, data flow,
  persistence, migrations, canon changes, rollout concerns, and implementation
  order;
- `implementation/tasks.md`: small ordered engineering tasks with exact files,
  dependencies, acceptance criteria, and tests;
- `implementation/verification.md`: automated, build, runtime, accessibility,
  privacy, migration, performance, and device evidence required by the change.

Every implementation task traces to a Design decision, and every Design decision
traces to a Scope requirement. Grooming may resolve technical detail but may not
invent product behavior. A newly discovered product decision returns to Scope or
Design for normal revision and reapproval.

When implementation requires canon changes, grooming names the owning canon
files and the implementation updates them alongside the feature.

## Lightweight tooling

The lifecycle tool supports only:

```bash
ambitions_product_docs.py new <research|scope|design> --initiative <slug>
ambitions_product_docs.py check docs/product-development/<initiative>
```

`new` creates a document from the appropriate template and links Scope or Design
to its upstream file. `check` is read-only and verifies:

- canonical path and required headings;
- valid draft or approved status;
- no unresolved placeholders in approved documents;
- approval ordering across Research, Scope, and Design;
- complete requirement-to-design traceability;
- required grooming files once grooming has begun.

Diagnostics are short and actionable. The tool never reviews content, changes
approval state, seals, hashes, commits, or enforces process authorization.

## Error handling

ChatGPT stops and explains what is missing when repository access, evidence, or a
product decision is unavailable. The validator rejects malformed structure,
premature downstream approval, unresolved approved placeholders, and incomplete
traceability. It does not block work for package drift, chat provenance, review
serialization, repository freshness, or historical transition reconstruction.

## Testing

Tests cover template creation, required headings, valid status values, approval
ordering, placeholder rejection, upstream links, Design traceability, grooming
file requirements, and one complete idea-to-grooming fixture. Tests for sealing,
contract hashes, review JSON, package provenance, freshness replay, historical
review authentication, and formal transition states are removed with those
features.

## Boundaries

- The workflow does not authorize implementation, merging, deployment, or
  release merely because a document is approved.
- Research and Scope do not authorize implementation.
- Approved Design enables grooming; the resulting engineering plan governs
  implementation only after normal repository review.
- Existing Code Quality, privacy, security, accessibility, migration, and runtime
  verification remain unchanged.
- No process-only authorization, owner receipt, attestation, or merge gate is
  introduced.

## Acceptance criteria

1. A user can start with an idea and produce Research, Scope, and Design in one
   continuing ChatGPT conversation.
2. Each phase advances only after explicit human approval and a blocking-free
   ChatGPT review.
3. Repository files under `docs/product-development/<initiative>/` are the only
   durable handoff required between phases.
4. The normal workflow requires no seal, hash, review JSON, provenance packet,
   isolated session, consumer lane, or freshness replay.
5. Approved Design can be groomed into plan, tasks, and verification documents
   without product invention.
6. The lightweight validator catches structural and ordering mistakes without
   becoming a workflow engine.

# Consumer contract

Read the active `AGENTS.md` instruction chain, lifecycle skill, and this
contract. Then read target frontmatter and the Agent handoff summary before
upstream summaries, linked IDs, current owning canon, declared deltas, current
source and tests, and only the full sections needed for the decision.

Verify the committed input at its canonical path. Verify its historical package
and template hashes at the recorded baseline, current schema/template
compatibility, sealed contract hash, revision-bound reviews, upstream bindings,
and evidence hashes. Compare the baseline with current `HEAD` using derived
freshness paths; inspect relevant intersecting drift semantically. Unrelated
drift is reported but does not alone reject a document.

Verify authority class, owner-path completeness, traceability, and that no next
phase requires unauthorized inference. Return `PASS` only when the document is
current, bounded, self-contained, and actionable. Otherwise return `NEEDS
REVISION` with exact IDs and sections. Consumer review is not product approval,
implementation authorization, or merge authority.

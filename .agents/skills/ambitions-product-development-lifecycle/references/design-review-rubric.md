# Design review rubric

Review Design conversationally with Devan. Confirm that approved Scope is its
upstream input; user flows, states, failures, and recovery are complete; the
architecture and data approach preserves local-first behavior and relevant
persistence, migration, concurrency, and replay invariants; and privacy,
accessibility, requirement traceability, verification, and open decisions are
clear. Confirm that Design is detailed enough to groom implementation without
inventing product behavior.

Return `PASS` in prose when there are no blocking findings and Design is ready for Devan's approval. Only after Devan's explicit approval is it ready for implementation grooming. Otherwise return `NEEDS REVISION` in prose followed by a concise list of blocking findings and the revisions needed.

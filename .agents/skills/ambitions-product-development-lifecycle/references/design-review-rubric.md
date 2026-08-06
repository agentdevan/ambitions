# Design review rubric

Review Design conversationally with Devan. Confirm that approved Scope is its
upstream input; user flows, states, failures, and recovery are complete; the
architecture and data approach preserves local-first behavior and relevant
persistence, migration, concurrency, and replay invariants; and privacy,
accessibility, requirement traceability, verification, and open decisions are
clear. Confirm that Design is detailed enough to groom implementation without
inventing product behavior.
Confirm that Design repeats Scope's frontend classifications exactly; resolves
routes, hierarchy, components, visible and recovery states, assets, copy,
motion, accessibility, and proof; and assigns the risk-tiered visual gate.
Material visual work cannot become executable before native visual calibration
and explicit owner approval.

Return `PASS` in prose when there are no blocking findings and Design is ready for Devan's approval. Only after Devan's explicit approval is it ready for implementation grooming. Otherwise return `NEEDS REVISION` in prose followed by a concise list of blocking findings and the revisions needed.

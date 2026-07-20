# Ambitions product and engineering principles

Ambitions is local-first and private by default. Product specifications and
engineering standards in this directory guide implementation; live source,
tests, builds, and generated project state determine whether a change works.

The offline core is fully useful for core value without account sign-in and without network access. Hosted services, including R2, MUST NOT own, store, synchronize, profile, or infer from the private life graph. R2 is public-only:
it MUST NOT receive, store, infer from, personalize from, or transmit private
life data. Ambitions MUST NOT become a generic AI destination, a hosted-intelligence or cloud-profiling path.

The repository is solo-maintained. Documentation does not authorize edits,
require attestations, or impose process-only merge gates. Changes are accepted
through concrete engineering evidence: compilation, tests, static analysis,
generated-project checks, security/privacy checks, and data-safety validation
when the changed scope requires them.

Do not weaken behavioral, persistence, migration, replay, concurrency,
accessibility, privacy, or security tests merely to obtain a passing build.

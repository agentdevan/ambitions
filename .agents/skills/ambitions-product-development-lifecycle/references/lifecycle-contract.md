# Lifecycle contract

Research, Scope, and Design are immutable versioned document shapes. Research is
`evidence`, Scope is `product-commitment`, and Design is
`implementation-design`. They are pre-canon provenance: current canon, source,
tests, and runtime evidence remain authoritative.

Canonical documents live at `docs/product-development/<initiative>/<phase>.md`.
They begin as revision 1 drafts. An authority-bearing edit is allowed only while
the document is a draft. Sealing derives freshness paths and binds the current
body and included frontmatter to a contract hash. Content and consumer reviews
must bind that same sealed revision and hash.

Allowed statuses are `draft`, `sealed`, `content-reviewed`,
`needs-revision`, `passed`, `stale`, and `superseded`. A passed document has
both review lanes passed for its current revision and contract hash. A stale or
needs-revision document reopens as a new draft revision before authority-bearing
content changes. A superseded document records its replacement without changing
its authority-bearing body.

Consumers verify the historical package at the baseline commit and require the
active package to support the document schema and template. A proposal for a
canon delta is not active law until the owning canon changes and its compiler
passes. This workflow never grants edit, approval, merge, or release authority.

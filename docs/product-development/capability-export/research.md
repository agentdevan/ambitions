+++
initiative = "capability-export"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

A private Capability collection becomes more useful when the user can carry a
carefully selected portion into a resume, application, portfolio, advisor
conversation, or another user-chosen tool. But export reverses Ambitions'
default privacy posture: data intentionally leaves the private graph, often into
a destination whose retention, audience, and onward use Ambitions cannot
control.

The user needs a selective, understandable disclosure rather than a dump of
everything Ambitions inferred. They must know which capability meaning,
evidence, dates, uncertainty, and sensitive context will leave; what is omitted;
whether the destination was actually reached; and how to create a safer new
export when local records change.

## Current truth

This Research uses `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, the portfolio synthesis,
and current privacy, import/export, External Writes, Trust, History, Receipt,
Proof, and accessibility canon/source/tests.

Privacy canon permits only explicitly user-controlled reviewed egress with
minimum fields, destination preview, confirmation, Receipt/History, and a
durable external-result boundary where applicable. Private graph data may not
be routed through Account, R2, Source Atlas, hosted AI, analytics, telemetry, or
an Ambitions backend. Export preview must remain available offline; no network
destination is required for the local core.

Current source has general export, redaction, diagnostic, share, outbox, and
external-write seams. It does not have a Capability schema, capability-specific
selection policy, credential presentation, resume/profile export, or proven
end-to-end disclosure flow. Existing diagnostics export is deliberately
redacted and is not a model for user-selected product content.

## Evidence

Capability data can combine several claims that must not be flattened:

- the user's plain-language capability meaning;
- user-stated, practiced, Proof-linked, or issuer-backed provenance;
- source Goal, Step, experience, or Proof context;
- uncertainty, freshness, contradiction, expiry, or revocation;
- handling classification and whether linked context reveals protected facts;
- whether a particular receiver has accepted or relied on the claim.

Different export purposes need different minimum fields. A resume may need a
short user-authored label and selected example; an advisor packet may need more
context; a machine-readable backup may preserve provenance and IDs. One default
“export all” contract would either over-disclose or omit the evidence needed to
interpret a claim honestly.

The first bounded purpose is now resolved: **share a human-readable capability
summary with a career or education advisor chosen by the user**. The first
output class is one local UTF-8 plain-text (`.txt`) artifact. It can contain only
the user-selected capability name, a user-reviewed short meaning, selected
plain-language provenance/evidence labels and dates, and an explicit uncertainty
or freshness note. It excludes internal IDs, hidden learned state, full source
objects, attachments, third-party names, consumer history, and credentials.
Protected content is excluded by default and can cross the boundary only through
the deliberate per-segment disclosure rule below. The user can still copy the
text into another document; this first purpose does not promise resume
formatting or machine interchange.

Export is not synchronization. Once a local file is handed to Files, Share
Sheet, email, or another application, Ambitions cannot promise deletion,
revocation, audience control, or update. A later local correction does not alter
an earlier external copy. The product can preserve the exact exported revision
and warn when it no longer matches current local truth.

An imported LinkedIn archive provides no permission to write back. A verified
credential provides no permission to disclose it. Source agreements may impose
attribution or redistribution limits on public reference excerpts, while
private evidence may expose third parties. Field-level minimization and source
rights matter independently.

### Free text, deliberate disclosure, and export-record lifetime

A field allowlist cannot make free text safe. Before preview, Ambitions treats
every user-authored meaning and evidence label as potentially containing
protected or third-party information. Known third-party identifiers are not
eligible for this first export. Unknown classification fails closed: the segment
stays excluded until the user edits it into an eligible summary or removes it.

Known protected content is also excluded by default, but the user may
deliberately include a specific segment about themself. That action is
per-segment rather than a document-wide toggle: it shows the exact text, named
destination, protected-content reason, minimum-purpose warning, and the fact
that Ambitions cannot recall or update an outside copy. Confirmation applies
only to that rendered revision and destination; changing the text, selected
Capability, or destination requires a new decision. No inferred protected fact,
third-party identifier, hidden learned state, or unreviewed source excerpt can
be disclosed through this exception.

The final preview is the exact artifact bytes and marks each deliberately
included protected segment. Cancellation creates no file and no export result.
A local file can be retained only when the user chooses a local save; a direct
handoff does not keep a second rendered copy inside Ambitions after the handoff
is resolved.

The durable export record is deliberately content-minimized. It retains the
purpose, selected Capability revision references, categories of fields included
or excluded, redaction and deliberate-disclosure decisions, artifact
fingerprint, destination class, time, and separate local-creation and external-
handoff outcomes. It does not retain the rendered text, third-party values,
recipient identity, or protected segments. The user can delete an Ambitions-
retained local artifact separately from this record, or delete the detailed
record and artifact together. Receipt/History then keeps at most a
non-reconstructive fact that an export occurred and its outside-copy warning.

Deleting or permanently removing a Capability deletes its private references
from detailed export records and any Ambitions-retained artifact containing it.
Before deletion, Ambitions warns when a known prior handoff may have left an
external copy. After deletion, a content-free warning may remain that an outside
copy could still exist, but no name, meaning, evidence, recipient, or artifact
bytes remain locally. Ambitions cannot recall, redact, or prove deletion of the
copy held by Files, a share recipient, or another application.

## Alternatives

### No export

This is safest and preserves local-first privacy, but forces users to retype
their own information and limits practical value.

### Full data dump

A complete backup is useful for portability but unsafe as the default sharing
surface. It can expose private evidence, inferred context, third parties, and
internal metadata the receiver does not need.

### Direct profile synchronization

Automatic LinkedIn or employer-profile updates appear convenient but require
restricted APIs, persistent identity linkage, external failure recovery, and
ongoing consent. They create far more authority than a local export.

### Purpose-bound selective export

Start from a user-selected purpose, choose exact records and fields, preview the
rendered bytes and destination, warn about sensitive or stale content, then
create or hand off one immutable artifact. This matches current privacy law.

## Unknowns and risks

- The first purpose and format are a user-reviewed advisor summary in UTF-8
  plain text. Demand for resume layouts, PDF, CSV/JSON backup, and credential
  presentation remains unvalidated and outside that boundary. Credential
  presentation is an excluded, uncommitted future idea rather than an implied
  extension of this initiative.
- Free-text classification can miss nuance. Exact-byte preview and deliberate
  per-segment disclosure reduce accidental sharing but cannot establish that a
  recipient will use sensitive information fairly.
- A destination app may fail, cancel, retain a temporary copy, or report an
  ambiguous result. Local artifact creation and external handoff need separate
  outcomes.
- Exporting a credential may require selective-disclosure and presentation
  semantics not established by credential import.
- Public source excerpts can have attribution or redistribution requirements.
- Accessibility must cover field selection, exclusions, warnings, preview,
  progress, cancellation, result, and recovery without relying on visual layout.
- A stale or deleted local Capability can still exist in an outside copy. The
  content-free warning is honest but cannot identify every copy the user made
  after export.

## Recommended direction

Research favors a first purpose-bound advisor-summary export in UTF-8 plain
text. The user starts the action,
chooses exact Capability records and evidence fields, sees exclusions and
sensitive-context warnings, resolves every unknown segment, explicitly includes
any protected self-information one segment at a time, reviews the final rendered
content and named destination, and confirms one immutable local artifact or
external handoff. Third-party identifiers and inferred protected facts remain
ineligible in this first boundary.

The export record should preserve purpose, selected record revisions, included
and excluded fields, redactions, source/attribution obligations, format,
artifact fingerprint, destination class, time, local creation result, external
handoff result, and limitations without retaining rendered content or recipient
identity. The user can delete an Ambitions-retained artifact and the detailed
record; only a content-free History fact and outside-copy warning may survive.
Corrections after export make the prior record stale locally; Capability
deletion removes its local export references and retained artifacts, but neither
action implies external recall.

This direction excludes automatic publishing, continuous synchronization,
scraping, unsolicited employer/school disclosure, broad “export everything,”
and use of an Ambitions backend. It depends on Capability continuity, while
credential presentation and any named-platform write-back remain excluded,
uncommitted future ideas with no implied Scope in this portfolio.

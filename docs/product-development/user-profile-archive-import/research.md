+++
initiative = "user-profile-archive-import"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

People may already have years of career and education history in a service such
as LinkedIn. Re-entering every position, project, course, certification, and
self-declared skill would make Ambitions' private capability foundation costly
to adopt. A user-requested archive could reduce that burden, but imported profile
data is not automatically true, current, verified, relevant, or safe to retain.

The product problem is to help the user review and selectively convert their own
archive into Ambitions-owned claims without scraping, silent synchronization,
write-back, bulk identity profiling, or presenting another platform's fields as
canonical truth.

## Current truth

This Research uses `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, the portfolio Research,
and current import, privacy, Source Reference, Capability-adjacent, History,
Receipt, replay, and Trust canon/source/tests.

`SYSTEM-IMPORT-EXPORT-REPAIR` already establishes the relevant pattern: external
input is staged, identified, fingerprinted, diffed, reviewed, and committed at
explicit per-record boundaries. Changed input invalidates confirmation. Partial
results preserve completed and failed identities. Imported copies do not edit
the external source. Privacy canon classifies joined identifiers and derived
facts as private graph data and requires minimum fields, explicit reviewed
egress, retention, deletion, and inspection.

The repository has mature calendar-import and generic import/repair contracts,
but no profile-archive adapter, schema support, capability mapping flow, or
tests for LinkedIn-style archives. Source Atlas cannot receive an archive: once
public-looking career facts are joined to a person, they are private.

LinkedIn's official “Download your account data” documentation was rechecked on
2026-08-03. A member can request selected categories or a larger archive. The
available categories can include Skills, Positions, Projects, Education,
Courses, Certifications, Languages, Honors, recommendations, job preferences,
and other highly sensitive account data. The archive contains only categories
applicable to the account and may also contain other people's information. It is
therefore heterogeneous private input, not a stable capability file.

The format investigation found that LinkedIn documents archive categories and
their meaning but does not publish a stable, versioned schema contract for each
downloaded table. No representative private archive is available in this
repository, so Research cannot honestly promise automatic ZIP recognition or
specific LinkedIn column names. That absence is a result, not a reason to make
Scope guess.

## Evidence

The official archive route supplies a legitimate user-controlled acquisition
mechanism ([LinkedIn Help: Download your account data](https://www.linkedin.com/help/linkedin/answer/a1339364)).
LinkedIn also exposes limited partner or regional portability APIs, but those
are not a generally available foundation. Its terms and API restrictions make
scraping or an assumed write-back relationship unsafe. Ambitions should depend
only on a file the user deliberately obtains and selects.

Archive fields have different meanings:

- a Skills row is a user-entered profile claim;
- a Position or Project is experience context, not proof of every implied skill;
- an endorsement is another user's social claim, not assessment;
- a Certification row names a claim but is not cryptographic issuer
  verification;
- a course record does not establish completion, transfer value, or competence;
- job applications, contacts, recommendations, messages, addresses, birth date,
  and advertising data are unrelated or excessively sensitive for capability
  import.

This supports field allowlisting and item-level review rather than whole-archive
ingestion. Imported items should remain user-provided claims with archive
provenance until the user confirms a separate Ambitions meaning. A later
verifiable-credential initiative can attach issuer-backed evidence without
retroactively upgrading an ordinary archive row.

External archives are also untrusted files. They may be malformed, partial,
oversized, duplicated, stale, encoding-damaged, unexpectedly nested, or contain
hostile paths and content. Existing bounded streaming, cancellation, quarantine,
fingerprint, partial-commit, and replay laws are directly relevant.

### Bounded first-format investigation

The first defensible validation boundary is a **single user-selected UTF-8
delimited table with explicit column mapping**, not an automatically trusted
LinkedIn ZIP. The user identifies which visible column contains a capability
name and may map optional source/context columns. Every row remains a
user-provided claim. A table taken from LinkedIn's documented Skills category
can use this route, but Ambitions makes no claim that a filename or header is a
stable LinkedIn contract.

The Research fixture matrix is therefore source-independent and observable:

- valid header plus one skill row;
- renamed/reordered header requiring explicit mapping;
- duplicate and blank rows kept visible for review;
- UTF-8 BOM, quoted commas, embedded line breaks, and invalid encoding;
- spreadsheet-formula prefixes retained as inert text;
- unknown extra columns excluded unless deliberately mapped;
- oversized row/file, cancellation, and partial parsing; and
- a ZIP or nested path presented as unsupported rather than extracted.

This matrix is sufficient to bound a first import Scope without fabricating a
private LinkedIn schema. Automatic archive discovery, Positions/Projects/
Education mapping, and ZIP extraction remain later format research after a
consenting user supplies representative fixtures.

### Source lifetime, excluded data, and deletion boundaries

Selecting a table creates a private staged copy only for the active import and
its explicit crash/interruption recovery. The user can resume that review or
discard it. Cancel or discard removes the staged file, parsed row values,
uncommitted edits, and candidate matches. After a complete or partially
committed import is resolved, Ambitions retains only the fields the user
accepted plus minimum source provenance needed to explain those accepted
claims; it does not retain the whole table, ignored columns, rejected rows, or
an archive ZIP. The original file outside Ambitions remains under Files or its
source app and is not deleted by an Ambitions action.

Third-party names, recommendations, contacts, messages, endorsements, and
relationship fields are ineligible for the first import. Ambitions may show a
redacted transient warning so the user understands why content was excluded,
but the value itself is neither staged as a candidate nor persisted. The durable
result records only an excluded category/count and reason without a name,
message, or reconstructive fingerprint. Unknown columns are likewise ignored
and disposed unless the user deliberately maps an eligible source/context
column before review.

Research distinguishes four deletion actions so the later product contract
does not conflate them:

- **Discard an active import** deletes only uncommitted staged material. Any
  rows already accepted through a partial commit remain visible and must be
  selected separately for deletion.
- **Delete the import source record** removes the retained source label,
  fingerprint, field mapping, and relationships. Accepted Ambitions claims and
  Capabilities remain, visibly marked as no longer source-linked, and the source
  can no longer support evidence or duplicate decisions.
- **Delete an imported claim** removes that accepted claim and its evidence
  relationship. A related Capability remains user-owned, but the deleted claim
  cannot support confidence, provenance, or later recommendation/simulation
  use. Other claims from the same import remain unchanged.
- **Delete a Capability** follows the Capability deletion contract. It removes
  the Capability and its relationship to imported claims, but does not silently
  delete an independently retained import source record or other accepted
  claims; the deletion preview must offer those as separate selected removals.
  Any retained claim is unlinked and cannot reconstruct or influence through
  the deleted Capability.

Receipt/History may preserve that an import, source removal, claim deletion, or
Capability deletion occurred, but after the relevant content is deleted the
record must be non-reconstructive. A combined “delete everything from this
import” action can select source record and imported claims together, with a
preview of Capabilities that will remain or be separately deleted; it is never
an ambiguous cascading delete.

## Alternatives

### Manual re-entry only

This maximizes user attention and minimizes parser risk, but creates high setup
cost and loses source provenance. It remains the fallback.

### Live LinkedIn integration

An OAuth/API sync could appear convenient, but access is restricted, policies
can change, and continuous external identity linkage conflicts with Ambitions'
local-first model. Silent refresh or write-back would create a new authority and
privacy surface.

### Import the entire archive

Bulk ingestion is easy to describe but would collect unrelated private data,
create a dossier, and make correction/deletion incomprehensible.

### Selective reviewed archive import

Parse locally, show recognized and ignored categories, quarantine unsafe input,
preview item-level changes, and let the user confirm only selected claims. This
best fits current canon and preserves a no-network fallback.

## Unknowns and risks

- LinkedIn archive schemas and filenames can change without notice. The first
  boundary avoids automatic schema claims through explicit column mapping;
  representative archives are still required before any later LinkedIn-specific
  auto-detection claim.
- An archive may hide third-party or protected content inside an apparently
  eligible free-text column. Unknown classification remains excluded rather
  than relying on a field name or a single warning.
- Duplicate matching can silently merge different positions, projects, or skill
  meanings. A label match must remain a review candidate, not equivalence.
- Partial commit can leave accepted claims after the user discards the remaining
  import. The resolved deletion preview must make those survivors explicit.
- Large or hostile archives require resource limits, safe path handling,
  cancellation, quarantine, and deterministic recovery.
- Archive provenance may become stale. Ambitions should not imply ongoing
  LinkedIn verification or synchronization.
- Current user demand and representative archive variability have not been
  validated. The format contract should remain narrow until fixtures exist.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: `Native/Ambitions/Surfaces/You/ProfileArchiveImportView.swift`.
- Evidence and unknowns: Repository audit identifies Task 5 as the first frontend-affecting task. Earlier tasks are non-frontend foundations; no unapproved root, route, asset, or visual-language expansion is permitted.

## Recommended direction

The evidence favors an optional, user-initiated, local-only tabular profile
import that can accept a deliberately selected table from a user-requested
archive. The first boundary supports one mapped capability-name column plus
optional mapped context, explains every ignored column and unsupported file,
and stages every recognized row as an uncommitted user-provided claim. It does
not claim automatic LinkedIn archive support.

The candidate direction preserves archive identity and fingerprint, source
field, imported value, user edits, duplicate decisions, and completed/failed
item IDs only to the minimum extent needed for accepted claims and deterministic
recovery. Raw source bytes, ignored columns, rejected rows, and third-party
values are disposed when their review or recovery purpose ends. History,
Receipt, replay, removal, and deletion consequences remain inspectable without
retaining deleted claim content. The flow performs no scraping, account login,
background synchronization, employer verification, credential verification, or
write-back.

The recommended lifecycle makes active-import discard, import-source deletion,
imported-claim deletion, and Capability deletion separate, named actions with
separate previews. Source removal never silently deletes native claims; claim
deletion never silently deletes a Capability; Capability deletion never
silently erases unrelated source records or claims. A user may deliberately
select a combined deletion, but Ambitions does not infer the cascade.

This initiative depends on the Capability foundation for confirmed claim
ownership. It remains separate from verifiable credential import and outbound
Capability export because those flows have different trust and privacy
boundaries.

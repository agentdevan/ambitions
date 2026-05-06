# Ambitions Terms Privacy Policy Legal Review Packet
<!-- markdownlint-disable MD013 -->

Status: Active PFC26 legal-review packet
Date: 2026-05-05
Owner: Legal / Privacy / Product
Result: Green legal-review checklist; no legal compliance claim

## Purpose

This packet prepares Ambitions for human legal/privacy review. It identifies
privacy policy needs, terms needs, data rights, minors posture, professional
advice boundaries, subscription/monetization boundaries, liability review, and
release-gated legal artifacts.

It is not a privacy policy, terms of service, legal opinion, App Store
submission, compliance certification, or launch approval.

## Source Truth

- Apple App Review Guidelines, especially Guidelines 2.1, 2.3, 3.1, 5.1, and
  related legal/privacy sections:
  `https://developer.apple.com/app-store/review/guidelines`
- Apple App Privacy Details:
  `https://developer.apple.com/app-store/app-privacy-details/`
- Apple App Store Connect privacy reference:
  `https://developer.apple.com/help/app-store-connect/reference/app-privacy/`
- Apple App Store Connect manage app privacy guidance:
  `https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy`
- Apple privacy manifest documentation:
  `https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk`
- Apple User Privacy and Data Use:
  `https://developer.apple.com/app-store/user-privacy-and-data-use/`
- `docs/canon/Ambitions_App_Store_Release_Compliance.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_Privacy_Data_Map_And_App_Privacy_Labels.md`
- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/canon/Ambitions_StoreKit_Monetization_Strategy.md`
- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/codex/Release_Candidate_Review_Checklist.md`
- `docs/codex/Human_Release_Review_Handoff.md`

## Current Repo Legal Posture

- Ambitions is local-first in current repo evidence.
- Current repo evidence does not prove account creation, backend, cloud sync,
  third-party login, subscriptions, IAP, ads, analytics, tracking, or external
  service data collection.
- PFC24 drafts App Privacy labels as Data Not Collected and No Tracking based
  on current repo behavior.
- PFC25 leaves `PrivacyInfo.xcprivacy` unchanged based on active source scans.
- App Store submission remains blocked on live privacy/support URLs, final
  signed-binary review, App Store Connect validation, physical-device proof,
  manual accessibility proof, screenshots, reviewer notes, and human approval.

## Privacy Policy Needs

Apple requires a privacy policy link in App Store Connect metadata and inside
the app in an easily accessible manner. The final Ambitions privacy policy must
be written and reviewed by a qualified human legal/privacy owner before
submission.

The policy should cover, at minimum:

- what data Ambitions stores locally;
- whether the developer collects any data from the app;
- current no-account and local-first posture;
- Calendar and Reminders permission purpose and user control;
- notifications, widgets, Live Activities, App Intents, Share Extension, and
  custom route boundaries;
- data retention, deletion, correction, and export posture;
- whether any third party receives data;
- how users can revoke consent or permissions;
- how users can request deletion or support;
- children/minors posture;
- education, school, and student-data posture;
- professional-boundary disclaimers;
- future change process if account, sync, analytics, StoreKit, AI runtime, or
  external services are added.

## Terms Of Service Needs

Terms of service are required for human review before launch if Ambitions adds
accounts, subscriptions, cloud/backend services, user-generated sharing,
external communities, or any paid entitlement. Even without those features, a
terms review is recommended before public launch because Ambitions handles
personal life planning, recovery, proof, and external-surface actions.

Terms review should cover:

- acceptable use and user responsibility;
- no professional advice posture;
- no emergency/crisis service posture;
- permission and external-surface responsibilities;
- local data and backup responsibility;
- export/delete/correction limitations;
- disclaimers for goal, planning, calendar, reminder, and recommendation
  outputs;
- limitation of liability language;
- dispute, governing law, and jurisdiction choices;
- update/change notification process;
- subscription, refund, cancellation, and restore terms if monetization is
  later approved.

Terms must not imply that Ambitions provides legal, medical, financial,
therapeutic, education-placement, employment-placement, admissions, crisis, or
professional advice. If future AOS/LDI work introduces recommendation kernels,
source packs, or living-dream planning, terms must describe them as
source-grounded planning support with user review, not as guaranteed outcomes.

## Data Rights And User Control Checklist

Human legal/privacy review must decide how Ambitions describes:

- access to local data;
- correction of local records, memory, receipts, and source states;
- deletion of memory, captures, goals, plans, proof, and receipts where
  implemented;
- export/import availability and limitations;
- portability boundaries for local snapshot export, legacy import, App Group
  handoff, and any future sync/cloud account surface;
- correction/deletion boundaries for Found Life, Commitment Memory, Searchable
  Life Recall, Weekly Life Sweep, AOS projections, and LDI source packs when
  those features are implemented;
- revocation of Calendar, Reminders, notifications, and external-surface
  permissions;
- support process for privacy questions;
- retention of local records after app deletion or backup restore;
- future account/cloud/sync rights if those features are approved later.

## Minors / Children Posture

PFC26 does not approve Ambitions as a child-directed product. Before public
launch, human legal/product review must decide:

- intended age rating;
- whether Ambitions is directed to children or general audience;
- whether parental consent, school use, family sharing, or youth-specific
  language is in scope;
- whether life-planning, calendar, reminders, and proof data can create
  additional review obligations for minors.

Default until reviewed: do not market Ambitions to children or minors.

## Education / Student-Data Future Risk

Ambitions may eventually touch education planning, school deadlines, admissions
requirements, scholarships, student work, or youth goals if users enter those
contexts or if future LDI/AOS source packs are approved.

PFC26 does not approve Ambitions as an education service, school service,
student-data processor, learning management system, or admissions/career
advisor. Before any school, student, family, under-18, classroom, or education
institution use is marketed or implemented, human legal/privacy review must
decide:

- whether FERPA, COPPA, state student privacy laws, school-contract terms, or
  equivalent jurisdiction-specific student-data obligations apply;
- whether education records, school names, grades, transcripts, disability
  accommodations, financial aid, scholarship, or admissions data can be entered,
  stored, exported, deleted, or surfaced externally;
- whether parent/guardian, school, district, or student consent is required;
- whether AOS/LDI source packs about education requirements can be treated as
  current enough for user-facing planning;
- what disclaimers are required so education/career suggestions remain
  user-reviewed planning support, not admissions, credential, or employment
  advice.

Default until reviewed: do not market Ambitions to schools, students, minors,
or education institutions, and do not claim student-data compliance.

## Professional Advice Boundaries

Ambitions may touch health-related, financial, legal, career, family,
relationship, and crisis-adjacent life contexts because users may write those
contexts into goals, captures, plans, proof, and memory.

PFC26 does not approve professional advice behavior. Future product and legal
review must ensure Ambitions:

- does not present medical, legal, financial, tax, therapy, crisis, or safety
  instructions as professional advice;
- routes crisis/safety-sensitive content to safe support language where
  implemented;
- avoids deterministic claims about outcomes;
- keeps recommendations reviewable and user-controlled;
- preserves PFC27 as the dedicated safety/professional-boundary policy batch.

Career and education planning are professional-boundary-adjacent. Future
recommendations must avoid guarantees about admission, employment, earnings,
credential value, legal eligibility, licensing, immigration, health, financial,
or regulated-profession outcomes.

## Found Life / Searchable Life Recall Boundaries

Found Life, Commitment Memory, Open Loop Registry, Searchable Life Recall,
Option Value, and Weekly Life Sweep make Ambitions legally and privacy
sensitive because they may hold the user's real life context even when the app
reveals only what matters now.

Human legal/privacy review must cover:

- whether life inventory, commitment memory, recall answers, source state,
  freshness state, proof links, and receipts are described as local app data;
- how users correct, delete, export, park, hide, or review Found Life records
  where implemented;
- how sensitive/private life context is kept out of widgets, Live Activities,
  notifications, App Intents, Spotlight, shared storage, logs, screenshots, and
  review artifacts by default;
- how recall distinguishes user-entered fact, source-backed fact, stale source,
  inferred candidate, not found, hidden/private, and review-required states;
- how legal copy avoids surveillance, omniscient memory, or permanent-record
  claims.

PFC26 does not approve runtime memory, searchable recall, cloud recall,
server-side memory, or legal/privacy compliance for Found Life.

## AOS / LDI Legal Boundary

AmbitionsOS and Living Dream Intelligence remain source-grounded future
execution scope until named batches implement and prove them. Their legal
review must cover:

- recommendation source, freshness, uncertainty, and review boundaries;
- no hidden commitment mutation or silent plan mutation;
- safety, legality, feasibility, regulated-profession, and crisis triage;
- source-pack provenance, update cadence, jurisdiction, and stale-source
  behavior;
- refusal and redirect language for unsafe, illegal, medical, legal,
  financial, crisis, or professional-advice requests;
- option-value and pivot guidance without deterministic outcome promises;
- no user-data server, sync, cloud, or hosted AI claim unless implemented and
  legally reviewed.

PFC27 owns the next safety/professional-boundary policy. LDI-specific legality
and professional-boundary failures remain Hard Red if they cannot be corrected
without legal/product decisions.

## Monetization And Subscription Boundary

PFC21 sets launch default to no StoreKit, no subscription, no IAP, no paywall,
no ads, and no external purchase link. If future monetization is approved,
legal/business review must cover:

- product ids, pricing, subscriptions, trials, offers, cancellation, restore,
  and Family Sharing;
- App Review-safe paywall copy;
- refund/support posture;
- no dark patterns;
- no paywalling trust/privacy/data-control basics;
- external purchase/link posture only with jurisdiction-aware legal review.

If StoreKit is later approved, App Store review artifacts must cover
subscription duration, price, renewal, cancellation, restore, entitlement
access, free-tier dignity, refund/support posture, and any first-subscription
submission requirements. PFC26 does not approve product ids, App Store Connect
setup, purchase flows, price points, subscription groups, or paywall copy.

## App Store Privacy Labels / Privacy Manifest Relationship

PFC24 and PFC25 are inputs to legal review, not substitutes for it.

- App Privacy labels must match actual data collection by the final signed
  binary, including third-party partners and SDK code.
- Apple App Store Connect requires a privacy policy URL for all apps and app
  privacy responses that stay accurate as practices change.
- `PrivacyInfo.xcprivacy` must declare collected data and required-reason API
  categories used by the app or bundled third-party SDKs.
- The release operator must reconcile privacy labels, privacy policy,
  permission strings, privacy manifest, entitlements, dependencies, and archive
  privacy report before submission.

PFC26 does not change `PrivacyInfo.xcprivacy`, does not enter App Store Connect
privacy answers, and does not publish a privacy policy.

## Third-Party SDK / Analytics / Logging / Crash Boundary

Current repo evidence found no active analytics, crash-reporting, ads,
tracking, or third-party network SDK surface. If future work adds telemetry,
crash reporting, diagnostics, attribution, analytics, ads, or third-party SDKs,
human legal/privacy review must cover:

- what data leaves the device;
- whether data is linked to the user;
- whether data is used for tracking;
- retention and deletion;
- consent and opt-out;
- privacy labels and privacy manifest changes;
- SDK privacy manifests, signatures, licenses, and data-processing terms;
- no private goal, capture, proof, receipt, memory, health, money, career,
  family, relationship, or crisis content in logs or events.

PFC29 owns the logging/analytics/observability policy. PFC28 owns security and
secrets audit.

## User-Generated Content / Proof / Evidence Boundary

Captures, goals, plans, proof, receipts, attachments, source notes, and shared
items may contain user-generated sensitive life data even when Ambitions does
not collect that data from the device.

Legal review must decide how Ambitions describes:

- user ownership of local content;
- proof/evidence privacy and correction;
- uploaded/imported/shared evidence if future cloud, account, share, or support
  flows are added;
- local backup/restore and app deletion behavior;
- screenshots, previews, external surfaces, and review artifacts that may
  expose private content;
- support requests that users voluntarily send to the developer.

## Required Legal Review Artifacts

Before App Store submission, the release operator must provide:

- live privacy policy URL;
- live support URL;
- in-app path to privacy policy where required;
- final App Store privacy disclosures;
- final permission-purpose string review;
- terms review if required by launch scope;
- professional-boundary copy review;
- minors/age-rating review;
- education/student-data review if any education, school, student, or minors
  posture is introduced;
- Found Life / Searchable Life Recall / AOS / LDI legal-boundary review before
  those capabilities influence recommendations or recall;
- monetization legal review if StoreKit/IAP/subscriptions are added;
- third-party SDK, analytics, logging, and crash-reporting review if any
  collection surface is added;
- App Store reviewer notes;
- human legal/privacy approval record.

## Stop Conditions

Stop and re-open PFC26 if future work adds:

- accounts, login, cloud, sync, backend, external service, or server-side data;
- analytics, crash reporting, telemetry, ads, attribution, or tracking;
- StoreKit, subscriptions, IAP, paywall, or external purchase links;
- health, medical, legal, financial, crisis, school, child, or regulated
  functionality beyond current local planning posture;
- public claims about privacy compliance, legal compliance, App Store
  readiness, TestFlight readiness, release readiness, accessibility
  conformance, or physical-device proof;
- legal copy that has not been reviewed by a qualified human owner.

## PFC26 Decision

PFC26 closes as a legal-review packet and checklist. It prepares the evidence a
human legal/privacy owner needs, but it does not approve launch, certify
compliance, publish legal pages, or authorize legal/privacy claims.

# PLOS Runtime Red Gates

These conditions stop PLOS execution. Do not repair around them unless the active issue explicitly scopes the repair and the repair itself is allowed by truth files.

## Identifier Red

- Linear access uses `PLOS-M##` or `PLOS-###` instead of `AMB-*`.
- A phase or child issue lacks a live `AMB-*` binding.
- A synthetic issue is invented to fill a queue gap.

## Phase Red

- M01 runs before M00 is Green or accepted Yellow.
- M10 or broad runtime expansion runs before the M00-M09 foundation and Golden Slice gates are satisfied.
- A later phase changes the meaning of an earlier truth/gate without explicit owner approval.

## Architecture Red

- Required cloud LLM or hosted planning runtime for core behavior.
- Required custom backend or server account infrastructure without active truth authority.
- Duplicate runtime or Source Atlas architecture when existing ownership can be extended.
- Silent user-data mutation or recommendation change without receipt.

## Privacy / Source Red

- Private user data enters R2, public Source Atlas objects, source packs, seeds, or public references.
- Source pack lacks source binding, freshness, revocation, release receipt, or rollback.
- Runtime uses a Source Atlas pack without eligibility proof.

## Product / Proof Red

- Release, TestFlight, App Store, accessibility, privacy/legal, device, or performance readiness claimed without evidence.
- UI collapses into generic task list, dashboard, chatbot, calendar clone, score, streak, or shame mechanics.
- Screenshot path is presented as visual proof without visual evaluation.

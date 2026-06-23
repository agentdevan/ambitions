# AMB-1199 — Final Proof / Accessibility / Release Gate

## Objective

Run the final proof, accessibility, visual regression, drilldown-depth, and release-gate validation after remediation trains have produced current proof.

## Covered Linear issues

- `AMB-1190` parent train
- `AMB-1199` execution bundle
- QA/accessibility/proof leaves under `AMB-1190`

## Product law

Final proof is a verification gate, not an implementation train. Do not start until repair trains have produced current screenshots, audits, accessibility proof, and known-issues updates.

## Architecture law

Verify the complete Stage OS and surface system: Theme, Shell, Capture, Goals, Today, Search, Time, You, route depth, proof, persistence, privacy/local-first boundaries, and accessibility.

## Runtime honesty law

Final proof may not hide missing validation. Missing proof keeps status Red/Yellow. Source-only work cannot close runtime-visible defects.

## Required implementation

This bundle should primarily verify. It may only implement small QA harness/reporting fixes required to produce proof. New product behavior belongs in the relevant parent bundle.

## Required proof matrix

- root screenshot matrix for Today/Goals/Time/You,
- Capture full flow proof,
- Search full flow proof,
- Time day/week/month/year/list proof,
- Goal root/detail lifecycle proof,
- Today valid/no-step/low-capacity/free-step/thought/proof states,
- You settings row proof,
- Light/Dark/System live-switch proof,
- VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, haptics where testable,
- route-depth proof that root dock hides in drilldowns,
- no-cloud/no-private-upload audit for Search/Capture/core runtime,
- persistence reload proof for Capture, Steps, Goals, Time placement, protected time, proof.

## Required docs updates

- `docs/qa/KNOWN_ISSUES.md`
- new final proof report under `docs/qa/validation/` or equivalent
- Linear project update with status ceiling

## Files likely in scope

- QA scripts
- validation reports
- screenshot manifest
- accessibility proof notes
- known issues register
- proof manifests

## Files forbidden unless justified

- product implementation files except tiny proof-harness defects
- truth canon files unless final proof discovers canon conflict

## Accessibility requirements

This train must verify accessibility, not retrofit it. If a surface fails, reopen/send back to the owning implementation train.

## Status ceiling

No device proof = no Visual Green. No accessibility proof = no Release Green. Any open P0 = project remains Red.

## Closeout template

Use the global closeout template plus a final Red/Yellow/Green table by surface and by modality.

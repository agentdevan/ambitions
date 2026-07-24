# Validation results

Date: 2026-07-23

Rendered source SHA: `53324b5fc60229958497b75ed3828b7e0d224492`

Device: VC14 iPhone 17 Pro Simulator, iOS 26.5 (`23F77`),
`EDE1E954-C663-47FB-855B-95F96AE2DBDD`

Status: **CLOSEOUT VALIDATION COMPLETE**

The media above remains bound to the rendered SHA. Closeout validation ran
against the subsequent narrow accessibility-target repair that becomes the B01
branch tip.

## Fresh results

- Foundry package tests: **31 passed, 0 failed**.
- Focused Start Here target repair tests: **2 passed, 0 failed**.
- Complete fixture-host UI suite after repair: **14 passed, 0 failed**.
- SwiftLint across the changed Swift envelope: **0 violations**.
- Canon build/check: **66 documents, 466 requirements, 47 UX items, 39 visual
  items, 16 links, and 35 JSON artifacts; clean**.
- Focused canon/compiler suite: **44 passed, 0 failed**.
- Local-first boundary scan: **passed**.
- Runtime direct-write audit: **passed** with the existing 55 classified
  markers; no B01 product integration was introduced.
- Weak-implementation scan: **passed** after repairing one documentation-only
  phrase that matched the scanner vocabulary.
- Full current-material and R02-to-B01 Gitleaks scans: **passed, no leaks**.
- Screenshot, recording, comparison, and reference-hash validation: **passed**.
- `git diff --check`: **passed**.

## Defect found and repaired

The first fresh complete fixture-host UI run reported two assertions with one
cause: `tfcs-open-start-here` exposed an accessibility frame height of 32
points. The repair applies the 44-point minimum to the label inside the native
button and supplies a rectangular content shape. The two failed tests passed
in a focused rerun and the complete 14-test suite passed afterward.

A successful build does not constitute visual or owner approval. B01 remains
rejected as flagship visual calibration evidence and closed by the explicit
request for B02.

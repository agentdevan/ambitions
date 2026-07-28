# Phase 0 Baseline Validation

Source SHA: `ac7ed07d090d65bdc469a9a2309f6899dc6135e6`

Device: B02 Recording iPhone 17 Pro Simulator

UDID: `396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E`

iOS: 26.5

## Immutable B02 visual baseline

- `../2026-07-23-today-open-continuity-field-b02-r00/screenshots/TFCS-F01-today-light.png`
  - SHA-256: `914c036e6d6a6fc66ca41dc2d981140e5cef5ca1a4e50d599ac5452188aefd37`
  - bytes: 293436
- `../2026-07-23-today-open-continuity-field-b02-r00/screenshots/TFCS-F02-today-dark.png`
  - SHA-256: `207993b7b80de0d14a159bfe0fcd119f396275eb9eaa964e96211588ad667af5`
  - bytes: 292746
- `../2026-07-23-today-open-continuity-field-b02-r00/contact-sheets/B02-C01-full-matrix.png`
  - SHA-256: `07ab7815aa3b27c4f5efe7b3f8d6a7d1322d5e63d31ad4b111212ede5f60cb5a`
  - bytes: 5556340

The complete B02 screenshot contract remains in
`../2026-07-23-today-open-continuity-field-b02-r00/screenshot-metadata.json`
with rendered source SHA `75fb51f96d911cd6da92094b72b2248c99922ea1`.

## Commands and outcomes

```sh
swift build --package-path Packages/AmbitionsPresentation \
  --target AmbitionsNativeVisualFoundry
```

PASS — target build completed successfully; final cached compilation reported
0.41 seconds after waiting for an earlier SwiftPM process to release the shared
build directory.

```sh
swift test --package-path Packages/AmbitionsPresentation
```

PASS — 50 tests executed, 0 failures, 0 unexpected failures in 0.613 seconds.

```sh
xcodebuild -project Ambitions.xcodeproj \
  -scheme AmbitionsNativeFoundryHost \
  -destination 'platform=iOS Simulator,id=396F4B4A-2DAD-4345-B26E-ABD2EF69BF5E' \
  build CODE_SIGNING_ALLOWED=NO
```

PASS during preflight — fixture-host Simulator build completed on iPhone 17 Pro,
iOS 26.5. The final task will rerun this command fresh after source changes.

Proof ceiling: these are source/B02 baseline checks, not R13 visual approval or
direct-device proof.

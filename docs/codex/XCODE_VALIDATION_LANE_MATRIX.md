# Xcode Validation Lane Matrix

Date: 2026-05-11

## Active batch-to-lane guidance

| Lane | Area type | Default lane | Notes |
| --- | --- | --- | --- |
| L0_NONE | prompt/governance | `none` | docs/prompt-only updates only |
| L1_BUILD | service extraction and package/wiring changes | `build` | compile path only |
| L2_BUILD_FOR_TESTING | focused performance fixture/cache setup | `build-for-testing` | produces build-for-testing `.xcresult` |
| L3_FOCUSED_TEST | Prompt/gov and implementation owner seams | `focused-test` | target seam tests only |
| L4_SEGMENT_TEST | named feature batch segments | `test-plan` | where explicit test plan exists |
| L5_FULL_TEST | full batch gates | `build` + `build-for-testing` + broad suite as allowed by gate | reserved for late validation gates |
| L6_UI_PROOF | UI/FET/FVQ/PX | `ui-proof` | simulator + screenshot/evidence path |
| L7_TERMINAL_DEVICE_PROOF | terminal DPTG/release proof | `terminal-device-proof` | terminal only when gate requires |

## Required lane mapping

- Service extraction: `focused-test`
- Storage/storage-like extraction: `focused-test`
- Side effects / privacy / source-atlas seam: `focused-test`
- Intelligence boundary: `focused-test`
- Performance/fixtures: `build-for-testing` or `focused-test`
- Package extraction: `build` for compile plus focused validation if seam changes tests
- UI/FVQ/PX: `ui-proof`
- Terminal DPTG: `terminal-device-proof`

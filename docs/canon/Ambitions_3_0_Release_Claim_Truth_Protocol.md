# Ambitions 3.0 Release Claim Truth Protocol

Status: Active release governance

## Purpose

Ambitions release language must match evidence. Codex may not upgrade claims from canonized or implemented to release-ready without the specific proof required by the release gates.

## Claim States

- Canonized: accepted in Ambitions 3.0 docs.
- Designed: UX, copy, or visual behavior is specified.
- Implementation-scoped: files, seams, and validation are identified.
- Implemented: repo code exists for the behavior.
- Previewed: SwiftUI preview or fixture evidence exists.
- Tested: automated tests or documented manual proof exist.
- Device-verified: physical-device evidence exists.
- Release-ready: all required gates pass, including human/device/platform evidence where required.

## Blocking Rules

- Screenshots must not imply unimplemented automation, sync, AI certainty, account behavior, or accessibility verification.
- `Candidate prepared; human approval required` remains the conservative release posture until stronger repo and human evidence exists.
- TestFlight, App Store, public accessibility, real-device, and final RC claims require explicit evidence.

## Evidence Format

Every release claim must map to files, tests, previews, device proof where needed, and the exact gate that permits the wording.

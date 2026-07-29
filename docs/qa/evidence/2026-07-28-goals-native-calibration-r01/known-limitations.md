# Known limitations

- The entire slice is fixture-driven and non-mutating.
- Production Goals data, selection persistence, navigation, restoration, Proof, and Goal Path generation are not integrated.
- The supporting relationship is inspection-only; no synchronization or mutation exists.
- Schedule-fit copy is contextual and cannot edit Time.
- F02 and F03 are intentionally byte-identical because the Dark root’s ordinary semantic state is already the explicit selected Home/Goal state.
- F08 is one natural-scroll viewport of the accessibility journey; UI assertions, not a recording, verify the complete hierarchy and reachable action.
- Goal Path haptics and final cross-root motion are documented but not physically proven.
- The Crowned Edge Dock remains `PROVISIONAL_HIGH_RISK_HYPOTHESIS`.
- No physical-device proof exists for reach, gestures, haptics, low-brightness, or assistive technologies.
- Final tokens, node geometry, localization/RTL, and component APIs remain deferred to cross-root synthesis.
- Screenshots are evaluation references, not production baselines.


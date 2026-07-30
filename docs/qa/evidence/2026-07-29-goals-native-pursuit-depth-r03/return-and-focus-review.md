# Return and focus review

Fixture journey state owns stable semantic focus anchors rather than screen coordinates.

- Focused Goal → Path selects `pathnode.paint-wall`.
- Path Evidence → Path restores the exact selected node.
- Path → focused Goal restores current movement.
- Relationship → focused Goal restores the relationship entry.
- Recovery → current Path selects the interrupted current node.
- Recovery Path → recovery restores the recovery state.
- Keep unresolved → focused Goal restores the recovery entry.
- Closure History → closure restores the closure surface without dismissal.

Framework `NavigationStack` and native Back restore every asserted semantic target in the final UI batch. XCUI edge-swipe synthesis was not reliable enough to claim interactive-edge proof; physical interactive Back remains a direct-device obligation. No focus target is assigned to the provisional dock.

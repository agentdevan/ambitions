# Known-Issues Status Delta

`docs/qa/KNOWN_ISSUES.md` was updated conservatively.

## Rows Updated

| Row | Old status | New status | Reason |
|---|---|---|---|
| `AMB-ISSUE-0807` | Still open | Automated evidence candidate / manual proof pending | Automated accessibility evidence-contract suite passed, but manual VoiceOver/device proof is missing. |
| `AMB-ISSUE-1801` | New | Automated evidence candidate / manual and device proof pending | Explicit AMB-1199 checklist plus automated source-contract coverage exists; runtime settings proof still missing. |
| `AMB-ISSUE-1802` | New | Open / contract evidence aligned | Evidence contracts preserve manual proof limitations and do not replace device review. |

## Rows Not Closed

No row was marked `Closed - verified`.

No Runtime Green, Visual Green, Accessibility Green, Release Green, or Done status was assigned.

## Visual Findings Preserved

AMB-1199 root screenshots show current simulator evidence, but visual defects remain:

- Goals root has clipped/split `Quiet` text.
- Goals, Time, and You root screenshots show the root dock overlapping content.
- Light/System Mode, device proof, Capture/Search, proposal/receipt, and full drilldown screenshots were not produced.


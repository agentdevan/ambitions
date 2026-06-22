# Screenshot Index — 2026-06-22 Device Review

This index maps the screenshot sequence from `More issues.zip` to the runtime QA findings in `docs/qa/device_review_20260622_more_issues.md` and `docs/qa/KNOWN_ISSUES.md`.

## Evidence archive

- Linear issue: `AMB-1181`
- Attached archive: `More issues.zip`
- Screenshot range: `IMG_8475.PNG` through `IMG_8499.PNG`

## Screenshot map

| Screenshot | Primary evidence |
|---|---|
| `IMG_8475.PNG` | Today root. Start Here/Meridian toggle, internal rail copy, CTA stack, random rail icons, bordered dock with labels. |
| `IMG_8476.PNG` | Today Meridian state. Toggle changes selection only; product object does not meaningfully change. |
| `IMG_8477.PNG` | Capture bottom sheet. Half-screen, internal header/chips, input-alternative explanation, dead mic, routing copy, text field buried. |
| `IMG_8478.PNG` | Closure top. Directionally acceptable; issue is that Today can launch it without a step. |
| `IMG_8479.PNG` | Goals root. Header exposes Constellation Atlas; object is explanatory and card-like. |
| `IMG_8480.PNG` | Goals lower. Thread Focus is diagnostic console; duplicate create affordance; source/proof/context rows. |
| `IMG_8481.PNG` | Time root. Improved versus prior build but unclear dots/bars/Now line; Place Step appears without real step context. |
| `IMG_8482.PNG` | Time lower. Rows under object still feel like list/card fallback. |
| `IMG_8483.PNG` | You root. Improved but system-facing header/copy, dividers, status-heavy rows, bottom glow. |
| `IMG_8484.PNG` | You rows. Dividers and status labels dominate; many rows appear non-actionable. |
| `IMG_8485.PNG` | You rows. Capture/Session/Appearance/Privacy statuses; row density and dividers remain. |
| `IMG_8486.PNG` | You rows. Receipts/Sources/Local data/Export rows are mostly status wrappers. |
| `IMG_8487.PNG` | You lower. Help/About rows; local/status posture dominates. |
| `IMG_8488.PNG` | Appearance detail in Light mode. Detail remains dark and illegible; theme change not reflected correctly. |
| `IMG_8489.PNG` | You Light mode. Low contrast, grey dock, hard-coded tone problems. |
| `IMG_8490.PNG` | Time Light mode. Low-contrast object and dock; Light mode not mature. |
| `IMG_8491.PNG` | Goals Light mode. Object model remains weak and header still exposes internal name. |
| `IMG_8492.PNG` | Today Light mode. Washed/dimmed content; unusable. |
| `IMG_8493.PNG` | Closure. Default options clearer; still needs mutation proof. |
| `IMG_8494.PNG` | Closure advanced. More options acceptable if default remains fast. |
| `IMG_8495.PNG` | Closure receipt/review. V1 acceptable; still needs Today mutation proof. |
| `IMG_8496.PNG` | Search over You. Search sheet is shallow and results are abstract. |
| `IMG_8497.PNG` | Search full view. Result rows expose internal labels and are not useful. |
| `IMG_8498.PNG` | Goals expanded Thread Focus. Diagnostic/internal rows dominate; root object is not user-facing. |
| `IMG_8499.PNG` | Goals lower. CTA/floating plus duplication; source/proof/why-this/root diagnostic language. |

## Surface coverage

| Surface | Screenshots |
|---|---|
| Today | `IMG_8475.PNG`, `IMG_8476.PNG`, `IMG_8492.PNG` |
| Capture | `IMG_8477.PNG` |
| Closure | `IMG_8478.PNG`, `IMG_8493.PNG`, `IMG_8494.PNG`, `IMG_8495.PNG` |
| Goals | `IMG_8479.PNG`, `IMG_8480.PNG`, `IMG_8491.PNG`, `IMG_8498.PNG`, `IMG_8499.PNG` |
| Time | `IMG_8481.PNG`, `IMG_8482.PNG`, `IMG_8490.PNG` |
| You | `IMG_8483.PNG`, `IMG_8484.PNG`, `IMG_8485.PNG`, `IMG_8486.PNG`, `IMG_8487.PNG`, `IMG_8488.PNG`, `IMG_8489.PNG`, `IMG_8496.PNG` |
| Search | `IMG_8496.PNG`, `IMG_8497.PNG` |
| Shell | all root screenshots |
| Light Mode | `IMG_8488.PNG`, `IMG_8489.PNG`, `IMG_8490.PNG`, `IMG_8491.PNG`, `IMG_8492.PNG` |
| Accessibility | not tested in this evidence set |

## Usage rule

This index preserves what was observed. It does not by itself prove a fix. Each fix still requires fresh proof from the repaired build.

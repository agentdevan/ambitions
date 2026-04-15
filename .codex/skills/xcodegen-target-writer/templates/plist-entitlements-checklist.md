# Plist And Entitlements Checklist

- Verify `INFOPLIST_FILE` points at a real file.
- Verify `CODE_SIGN_ENTITLEMENTS` points at a real file when capabilities are needed.
- Add only the usage strings or extension keys required by shipped behavior.
- Check app groups, Live Activities, widget configuration, NSExtension keys, and intent metadata deliberately.
- Keep bundle IDs, app groups, and deep-link schemes consistent across app and extension.
- Re-read `Native/Ambitions/Support/Info.plist` and current entitlements before assuming a capability is missing.

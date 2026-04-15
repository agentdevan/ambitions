# Extension Target Checklist

- Confirm the extension type and entry-point files.
- Confirm whether a new target is actually required.
- Add or update the target in `project.yml`.
- Set `type`, `platform`, and deployment target to match current repo conventions.
- Wire source paths, excluded files, and resources deliberately.
- Add scheme build/test inclusion if needed.
- Verify bundle ID and product name.
- Verify target dependencies and shared Swift package usage.
- Check whether manual-test notes or docs must be updated.

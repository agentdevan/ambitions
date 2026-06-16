#!/usr/bin/env python3
from __future__ import annotations

from report_reconstruction_support import read, replace_required, replace_all, require_markers, write, write_proof

YOU = "Native/Ambitions/Features/You/YouRootSurface.swift"

NEW_HEADER = r'''    private var objectStageHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(AmbitionsIOS26SemanticTokens.Fill.tertiaryDark)
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? 54 : 48, height: dynamicTypeSize.isAccessibilitySize ? 54 : 48)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 30 : 27, weight: .semibold))
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(profileProjection.hero.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "You" : profileProjection.hero.title)
                    .font(dynamicTypeSize.isAccessibilitySize ? AmbitionsIOS26SemanticTokens.Typography.title3 : AmbitionsIOS26SemanticTokens.Typography.title2)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .accessibilityIdentifier("you.root-title")

                Text("Ambitions runs on this iPhone")
                    .font(AmbitionsIOS26SemanticTokens.Typography.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)

                Text("User System Profile")
                    .font(AmbitionsIOS26SemanticTokens.Typography.caption1.weight(.semibold))
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("you.object-stage-header")
        .accessibilityLabel("User System Profile")
        .accessibilityValue("Ambitions runs on this iPhone.")
    }
'''


def main() -> int:
    text = read(YOU)
    text = replace_required(
        text,
        r'''    private var objectStageHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(primitiveContract.productObject)
                .font(theme.typography.micro)
                .foregroundStyle(LivingTabContext.you.accent(in: theme))

            Text(profileProjection.hero.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityIdentifier("you.root-title")

            Text(profileProjection.hero.dominantTruth)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, theme.spacing.sm)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(LivingTabContext.you.accent(in: theme).opacity(0.55))
                .frame(width: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("you.object-stage-header")
    }
''',
        NEW_HEADER,
    )
    text = replace_all(text, {
        "subtitle: \"Trust, personal context, and receipts stay inspectable before deeper controls.\"": "subtitle: \"Profile, time defaults, privacy, and trust stay under your control.\"",
        "title: \"Runtime Preferences\"": "title: \"Preferences\"",
        "subtitle: \"Execution controls stay explicit and local.\"": "subtitle: \"Capture, notifications, sessions, appearance, and privacy.\"",
        "title: \"History & Trust\"": "title: \"Privacy & Trust\"",
        "title: \"Support / System\"": "title: \"App\"",
    })
    write(YOU, text)
    require_markers(YOU, ["Ambitions runs on this iPhone", "User System Profile", "person.crop.circle.fill", "Privacy & Trust", "title: \"App\""])
    write_proof(
        "REPORT_BATCH_24_YOU_USER_SYSTEM_PROFILE.md",
        """
# Batch 24 — You native User System Profile rewrite

Status: applied.

Scope:
- Rebuilt the You first viewport header into a recognizable User System Profile header.
- Added native iOS 26 token bridge typography/fill usage.
- Removed the left governance rail from the root profile header.
- Reframed root sections toward profile/settings language: Preferences, Privacy & Trust, App.

Atlas gates:
- You remains User System Profile / Personal Runtime / Trust object.
- You is not a Profile tab or social profile.
- Root starts from recognizable local profile/control posture.
- Native grouped settings direction is established for the next detail-surface pass.
""",
    )
    print("Applied Batch 24 You native User System Profile rewrite.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

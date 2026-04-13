import { Ionicons } from "@expo/vector-icons";
import { ReactNode } from "react";
import { Pressable, View } from "react-native";

import { useAccessibilityPreferences } from "../../design/accessibility/useAccessibilityPreferences";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "../ui/Text";

interface DrillInRowProps {
  title: string;
  subtitle?: string | null;
  detail?: string | null;
  actionLabel?: string | null;
  badge?: ReactNode;
  leading?: ReactNode;
  onPress: () => void;
}

export function DrillInRow({
  title,
  subtitle = null,
  detail = null,
  actionLabel = "Open",
  badge = null,
  leading = null,
  onPress,
}: DrillInRowProps) {
  const theme = useResolvedTheme();
  const { reduceMotionEnabled } = useAccessibilityPreferences();

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityHint={actionLabel ? `${actionLabel} ${title}` : undefined}
      className="rounded-[24px]"
      hitSlop={4}
      onPress={onPress}
      style={({ pressed }) => [
        {
          opacity: pressed ? 0.96 : 1,
          transform: [{ scale: pressed && !reduceMotionEnabled ? 0.994 : 1 }],
        },
      ]}
    >
      {({ pressed }) => (
        <View
          className="flex-row items-center gap-3 px-4 py-4"
          style={{
            borderRadius: theme.radius.row,
            backgroundColor: pressed
              ? theme.colors.background.accentWash
              : theme.colors.background.elevatedSecondary,
            borderWidth: 1,
            borderColor: pressed
              ? theme.colors.border.accent
              : theme.colors.border.subtle,
            shadowColor: theme.colors.shadow.color,
            shadowOpacity: theme.mode === "dark" ? 0.1 : 0.04,
            shadowRadius: 12,
            shadowOffset: { width: 0, height: 4 },
          }}
        >
          {leading ? (
            <View
              className="items-center justify-center px-3 py-3"
              style={{
                borderRadius: theme.radius.compactControl,
                backgroundColor: pressed
                  ? theme.colors.background.accentWashStrong
                  : theme.colors.background.elevatedSecondary,
              }}
            >
              {leading}
            </View>
          ) : null}
          <View className="flex-1 gap-1">
            <View className="flex-row flex-wrap items-center gap-2">
              <AppText variant="section" style={{ flexShrink: 1 }}>
                {title}
              </AppText>
              {badge}
            </View>
            {subtitle ? (
              <AppText tone="secondary" variant="caption">
                {subtitle}
              </AppText>
            ) : null}
          </View>
          <View className="items-end gap-1 pl-2">
            <View
              className="flex-row items-center gap-1 rounded-full px-2.5 py-1.5"
              style={{
                backgroundColor: pressed
                  ? theme.colors.background.accentWashStrong
                  : theme.colors.background.canvas,
                borderWidth: 1,
                borderColor: pressed
                  ? theme.colors.border.accent
                  : theme.colors.border.subtle,
              }}
            >
              <AppText
                tone={pressed ? "accent" : "secondary"}
                variant="micro"
                numberOfLines={1}
                style={{ textTransform: "uppercase", letterSpacing: 0.45 }}
              >
                {actionLabel}
              </AppText>
              <Ionicons
                color={pressed ? theme.colors.accent.primary : theme.colors.text.tertiary}
                name="chevron-forward"
                size={16}
              />
            </View>
            {detail ? (
              <AppText tone="secondary" variant="caption" style={{ textAlign: "right", maxWidth: 132 }}>
                {detail}
              </AppText>
            ) : null}
          </View>
        </View>
      )}
    </Pressable>
  );
}

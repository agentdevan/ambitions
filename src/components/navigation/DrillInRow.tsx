import { Ionicons } from "@expo/vector-icons";
import { ReactNode } from "react";
import { Pressable, View } from "react-native";

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

  return (
    <Pressable
      className="rounded-[22px]"
      onPress={onPress}
      style={({ pressed }) => [
        {
          opacity: pressed ? 0.96 : 1,
          transform: [{ scale: pressed ? 0.994 : 1 }],
        },
      ]}
    >
      {({ pressed }) => (
        <View
          className="flex-row items-center gap-3 rounded-[22px] px-4 py-3.5"
          style={{
            backgroundColor: pressed
              ? theme.colors.background.accentWash
              : theme.colors.background.elevated,
            borderWidth: 1,
            borderColor: pressed
              ? theme.colors.border.accent
              : theme.colors.border.strong,
            shadowColor: theme.colors.shadow.color,
            shadowOpacity: theme.mode === "dark" ? 0.14 : 0.04,
            shadowRadius: 10,
            shadowOffset: { width: 0, height: 5 },
          }}
        >
          {leading ? (
            <View
              className="items-center justify-center rounded-[16px] px-3 py-3"
              style={{
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
              <AppText variant="section" numberOfLines={2} style={{ flexShrink: 1 }}>
                {title}
              </AppText>
              {badge}
            </View>
            {subtitle ? (
              <AppText tone="secondary" variant="caption" numberOfLines={2}>
                {subtitle}
              </AppText>
            ) : null}
          </View>
          <View className="items-end gap-1 pl-2">
            <View className="flex-row items-center gap-1">
              <AppText
                tone={pressed ? "accent" : "secondary"}
                variant="micro"
                numberOfLines={1}
                style={{ textTransform: "uppercase" }}
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
              <AppText tone="tertiary" variant="caption" numberOfLines={1}>
                {detail}
              </AppText>
            ) : null}
          </View>
        </View>
      )}
    </Pressable>
  );
}

import { Ionicons } from "@expo/vector-icons";
import { ReactNode } from "react";
import { Pressable, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "../ui/Text";

interface DrillInRowProps {
  title: string;
  subtitle?: string | null;
  detail?: string | null;
  badge?: ReactNode;
  onPress: () => void;
}

export function DrillInRow({
  title,
  subtitle = null,
  detail = null,
  badge = null,
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
          className="flex-row items-center gap-4 rounded-[22px] px-4 py-4"
          style={{
            backgroundColor: pressed
              ? theme.colors.background.sunken
              : theme.colors.background.elevated,
            borderWidth: 1,
            borderColor: pressed
              ? `${theme.colors.accent.primary}33`
              : theme.colors.border.subtle,
          }}
        >
          <View className="flex-1 gap-1.5">
            <View className="flex-row flex-wrap items-center gap-2">
              <AppText variant="section">{title}</AppText>
              {badge}
            </View>
            {subtitle ? (
              <AppText tone="secondary" numberOfLines={2}>
                {subtitle}
              </AppText>
            ) : null}
          </View>
          <View className="items-end gap-1">
            {detail ? (
              <AppText tone="tertiary" variant="caption" numberOfLines={1}>
                {detail}
              </AppText>
            ) : null}
            <Ionicons
              color={pressed ? theme.colors.accent.primary : theme.colors.text.tertiary}
              name="chevron-forward"
              size={18}
            />
          </View>
        </View>
      )}
    </Pressable>
  );
}

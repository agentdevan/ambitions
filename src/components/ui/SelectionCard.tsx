import { PropsWithChildren, ReactNode } from "react";
import { Pressable, PressableProps, StyleProp, View, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface SelectionCardProps
  extends PropsWithChildren,
    Omit<PressableProps, "children" | "style"> {
  selected?: boolean;
  eyebrow?: string;
  trailing?: ReactNode;
  style?: StyleProp<ViewStyle>;
}

export function SelectionCard({
  children,
  selected = false,
  eyebrow,
  trailing,
  style,
  ...props
}: SelectionCardProps) {
  const theme = useResolvedTheme();

  return (
    <Pressable
      {...props}
      className="px-4 py-4"
      style={({ pressed }) => [
        {
          borderRadius: theme.radius.card,
          borderWidth: 1,
          borderColor: selected ? theme.colors.border.accent : theme.colors.border.subtle,
          backgroundColor: selected
            ? theme.colors.background.accentWash
            : theme.colors.background.elevatedSecondary,
          shadowColor: theme.colors.text.primary,
          shadowOpacity: selected ? 0.1 : 0.04,
          shadowRadius: selected ? 16 : 8,
          shadowOffset: { width: 0, height: selected ? 10 : 4 },
          elevation: selected ? 2 : 0,
          opacity: props.disabled ? 0.5 : pressed ? 0.95 : 1,
        },
        style,
      ]}
    >
      <View className="gap-3">
        <View className="flex-row items-start justify-between gap-3">
          <View className="flex-1 gap-2">
            <View className="flex-row items-center gap-2">
              <View
                className="h-2 w-2 rounded-full"
                style={{
                  backgroundColor: selected
                    ? theme.colors.accent.primary
                    : theme.colors.border.strong,
                }}
              />
              {eyebrow ? (
                <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                  {eyebrow}
                </AppText>
              ) : null}
            </View>
          </View>
          {trailing}
        </View>
        {children}
      </View>
    </Pressable>
  );
}

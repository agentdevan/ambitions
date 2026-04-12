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
      className="rounded-[22px] px-4 py-4"
      style={({ pressed }) => [
        {
          borderWidth: 1,
          borderColor: selected ? theme.colors.text.primary : theme.colors.border.subtle,
          backgroundColor: selected
            ? theme.colors.background.elevated
            : theme.colors.background.canvas,
          shadowColor: theme.colors.text.primary,
          shadowOpacity: selected ? 0.07 : 0.03,
          shadowRadius: selected ? 10 : 6,
          shadowOffset: { width: 0, height: selected ? 6 : 3 },
          elevation: selected ? 2 : 0,
          opacity: props.disabled ? 0.5 : pressed ? 0.92 : 1,
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
                    ? theme.colors.text.primary
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

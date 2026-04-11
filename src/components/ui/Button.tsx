import { ReactNode } from "react";
import { ActivityIndicator, Pressable, PressableProps, ViewStyle } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface ButtonProps extends Omit<PressableProps, "children" | "style"> {
  children?: ReactNode;
  tone?: "primary" | "secondary" | "ghost";
  busy?: boolean;
  style?: ViewStyle | ViewStyle[];
}

export function Button({
  children,
  tone = "primary",
  busy = false,
  disabled,
  style,
  ...props
}: ButtonProps) {
  const theme = useResolvedTheme();
  const palette = {
    primary: {
      backgroundColor: theme.colors.text.primary,
      borderColor: theme.colors.text.primary,
      textTone: "inverse" as const,
    },
    secondary: {
      backgroundColor: theme.colors.background.elevated,
      borderColor: theme.colors.border.strong,
      textTone: "primary" as const,
    },
    ghost: {
      backgroundColor: "transparent",
      borderColor: theme.colors.border.subtle,
      textTone: "secondary" as const,
    },
  }[tone];

  return (
    <Pressable
      {...props}
      disabled={disabled || busy}
      className="min-h-12 items-center justify-center rounded-full border px-5"
      style={[
        {
          backgroundColor: palette.backgroundColor,
          borderColor: palette.borderColor,
          opacity: disabled ? 0.5 : 1,
        },
        style,
      ]}
    >
      {busy ? (
        <ActivityIndicator color={tone === "primary" ? theme.colors.text.inverse : theme.colors.text.primary} />
      ) : (
        <AppText tone={palette.textTone} variant="caption">
          {children}
        </AppText>
      )}
    </Pressable>
  );
}

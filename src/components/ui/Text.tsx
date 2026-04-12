import { PropsWithChildren } from "react";
import { Text as RNText, TextProps } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

type Tone = "primary" | "secondary" | "tertiary" | "inverse" | "accent";
type Variant = "hero" | "title" | "section" | "body" | "caption" | "micro";

interface AppTextProps extends PropsWithChildren, TextProps {
  tone?: Tone;
  variant?: Variant;
}

const variantMap: Record<
  Variant,
  { fontSize: number; lineHeight: number; fontWeight: "400" | "500" | "600" | "700"; letterSpacing?: number }
> = {
  hero: { fontSize: 31, lineHeight: 37, fontWeight: "600", letterSpacing: -0.95 },
  title: { fontSize: 23, lineHeight: 29, fontWeight: "600", letterSpacing: -0.55 },
  section: { fontSize: 17, lineHeight: 22, fontWeight: "600", letterSpacing: -0.3 },
  body: { fontSize: 15, lineHeight: 21, fontWeight: "400", letterSpacing: -0.15 },
  caption: { fontSize: 13, lineHeight: 18, fontWeight: "600", letterSpacing: -0.05 },
  micro: { fontSize: 11, lineHeight: 14, fontWeight: "700", letterSpacing: 0.5 },
};

export function AppText({
  children,
  style,
  tone = "primary",
  variant = "body",
  ...props
}: AppTextProps) {
  const theme = useResolvedTheme();
  const toneMap: Record<Tone, string> = {
    primary: theme.colors.text.primary,
    secondary: theme.colors.text.secondary,
    tertiary: theme.colors.text.tertiary,
    inverse: theme.colors.text.inverse,
    accent: theme.colors.text.accent,
  };

  return (
    <RNText
      {...props}
      style={[
        {
          color: toneMap[tone],
          letterSpacing: variantMap[variant].letterSpacing ?? -0.2,
        },
        variantMap[variant],
        style,
      ]}
    >
      {children}
    </RNText>
  );
}

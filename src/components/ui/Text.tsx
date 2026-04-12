import { PropsWithChildren } from "react";
import { Text as RNText, TextProps } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

type Tone = "primary" | "secondary" | "tertiary" | "inverse";
type Variant = "hero" | "title" | "section" | "body" | "caption" | "micro";

interface AppTextProps extends PropsWithChildren, TextProps {
  tone?: Tone;
  variant?: Variant;
}

const variantMap: Record<
  Variant,
  { fontSize: number; lineHeight: number; fontWeight: "400" | "500" | "600" | "700"; letterSpacing?: number }
> = {
  hero: { fontSize: 28, lineHeight: 34, fontWeight: "600", letterSpacing: -0.7 },
  title: { fontSize: 21, lineHeight: 27, fontWeight: "600", letterSpacing: -0.45 },
  section: { fontSize: 17, lineHeight: 22, fontWeight: "600", letterSpacing: -0.2 },
  body: { fontSize: 15, lineHeight: 21, fontWeight: "400", letterSpacing: -0.1 },
  caption: { fontSize: 13, lineHeight: 18, fontWeight: "500", letterSpacing: 0 },
  micro: { fontSize: 11, lineHeight: 13, fontWeight: "600", letterSpacing: 0.45 },
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

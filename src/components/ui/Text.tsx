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
  {
    fontSize: number;
    lineHeight: number;
    fontWeight: "400" | "500" | "600" | "700";
    letterSpacing?: number;
    maxFontSizeMultiplier: number;
  }
> = {
  hero: { fontSize: 36, lineHeight: 40, fontWeight: "600", letterSpacing: -1.15, maxFontSizeMultiplier: 1.35 },
  title: { fontSize: 27, lineHeight: 32, fontWeight: "600", letterSpacing: -0.72, maxFontSizeMultiplier: 1.4 },
  section: { fontSize: 18, lineHeight: 24, fontWeight: "600", letterSpacing: -0.35, maxFontSizeMultiplier: 1.45 },
  body: { fontSize: 15, lineHeight: 22, fontWeight: "400", letterSpacing: -0.12, maxFontSizeMultiplier: 1.65 },
  caption: { fontSize: 13, lineHeight: 18, fontWeight: "600", letterSpacing: 0, maxFontSizeMultiplier: 1.45 },
  micro: { fontSize: 11, lineHeight: 14, fontWeight: "700", letterSpacing: 0.6, maxFontSizeMultiplier: 1.25 },
};

export function AppText({
  children,
  style,
  tone = "primary",
  variant = "body",
  ...props
}: AppTextProps) {
  const theme = useResolvedTheme();
  const { maxFontSizeMultiplier, ...variantStyle } = variantMap[variant];
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
      allowFontScaling={props.allowFontScaling ?? true}
      maxFontSizeMultiplier={props.maxFontSizeMultiplier ?? maxFontSizeMultiplier}
      style={[
        {
          color: toneMap[tone],
          letterSpacing: variantStyle.letterSpacing ?? -0.2,
          fontFamily: "System",
          flexShrink: 1,
        },
        variantStyle,
        style,
      ]}
    >
      {children}
    </RNText>
  );
}

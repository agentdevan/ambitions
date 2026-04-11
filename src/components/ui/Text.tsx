import { PropsWithChildren } from "react";
import { Text as RNText, TextProps } from "react-native";

type Tone = "primary" | "secondary" | "tertiary" | "inverse";
type Variant = "hero" | "title" | "section" | "body" | "caption" | "micro";

interface AppTextProps extends PropsWithChildren, TextProps {
  tone?: Tone;
  variant?: Variant;
}

const toneMap: Record<Tone, string> = {
  primary: "#18181A",
  secondary: "#4B4B53",
  tertiary: "#7A7A84",
  inverse: "#F8F8FA",
};

const variantMap: Record<Variant, { fontSize: number; lineHeight: number; fontWeight: "500" | "600" | "700" }> =
  {
    hero: { fontSize: 34, lineHeight: 38, fontWeight: "700" },
    title: { fontSize: 24, lineHeight: 30, fontWeight: "700" },
    section: { fontSize: 17, lineHeight: 22, fontWeight: "600" },
    body: { fontSize: 15, lineHeight: 21, fontWeight: "500" },
    caption: { fontSize: 13, lineHeight: 18, fontWeight: "500" },
    micro: { fontSize: 11, lineHeight: 15, fontWeight: "600" },
  };

export function AppText({
  children,
  style,
  tone = "primary",
  variant = "body",
  ...props
}: AppTextProps) {
  return (
    <RNText
      {...props}
      style={[
        {
          color: toneMap[tone],
          letterSpacing: -0.2,
        },
        variantMap[variant],
        style,
      ]}
    >
      {children}
    </RNText>
  );
}

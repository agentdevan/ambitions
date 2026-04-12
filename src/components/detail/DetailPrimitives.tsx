import { ReactNode } from "react";
import { View } from "react-native";

import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface DetailHeroProps {
  eyebrow?: string | null;
  title: string;
  description?: string | null;
  badges?: ReactNode;
  meta?: ReactNode;
  action?: ReactNode;
  tone?: "default" | "accent";
}

export function DetailHero({
  eyebrow = null,
  title,
  description = null,
  badges = null,
  meta = null,
  action = null,
  tone = "accent",
}: DetailHeroProps) {
  return (
    <Surface tone={tone} className="gap-3">
      <View className="gap-2">
        {eyebrow ? (
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            {eyebrow}
          </AppText>
        ) : null}
        {badges ? <View className="flex-row flex-wrap items-center gap-2">{badges}</View> : null}
        <View className="gap-1.5">
          <AppText variant="title">{title}</AppText>
          {description ? <AppText tone="secondary">{description}</AppText> : null}
        </View>
      </View>
      {meta}
      {action}
    </Surface>
  );
}

interface DetailSectionProps {
  title: string;
  description?: string | null;
  action?: ReactNode;
  children: ReactNode;
}

export function DetailSection({
  title,
  description = null,
  action = null,
  children,
}: DetailSectionProps) {
  return (
    <View className="gap-3">
      <View className="flex-row items-end justify-between gap-3">
        <View className="flex-1 gap-0.5">
          <AppText variant="section">{title}</AppText>
          {description ? (
            <AppText tone="secondary" variant="caption">
              {description}
            </AppText>
          ) : null}
        </View>
        {action}
      </View>
      {children}
    </View>
  );
}

export function DetailMetaGroup({
  items,
}: {
  items: Array<{ label: string; value: string }>;
}) {
  return (
    <View className="flex-row flex-wrap gap-3">
      {items.map((item) => (
        <View key={`${item.label}:${item.value}`} className="min-w-[46%] flex-1 gap-1">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            {item.label}
          </AppText>
          <AppText variant="caption">{item.value}</AppText>
        </View>
      ))}
    </View>
  );
}

export function DetailSummaryStrip({
  items,
}: {
  items: Array<{ label: string; value: string; detail?: string | null }>;
}) {
  return (
    <View className="flex-row flex-wrap gap-3">
      {items.map((item) => (
        <Surface
          key={`${item.label}:${item.value}`}
          tone="sunken"
          className="min-w-[46%] flex-1 gap-1 px-4 py-4 mb-0"
        >
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            {item.label}
          </AppText>
          <AppText variant="section">{item.value}</AppText>
          {item.detail ? (
            <AppText tone="secondary" variant="caption">
              {item.detail}
            </AppText>
          ) : null}
        </Surface>
      ))}
    </View>
  );
}

export function QuietMetaLine({ items }: { items: string[] }) {
  return (
    <View className="flex-row flex-wrap gap-x-4 gap-y-2">
      {items.map((item) => (
        <AppText key={item} tone="tertiary" variant="caption">
          {item}
        </AppText>
      ))}
    </View>
  );
}

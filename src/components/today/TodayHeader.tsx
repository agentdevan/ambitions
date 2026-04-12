import { View } from "react-native";

import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface TodayHeaderProps {
  dateLabel: string;
  liveContext: boolean;
}

export function TodayHeader({ dateLabel, liveContext }: TodayHeaderProps) {
  return (
    <Surface tone={liveContext ? "accent" : "default"} className="gap-6 pt-1">
      <View className="flex-row items-start justify-between gap-3">
        <View className="flex-1 gap-3">
          <View className="flex-row flex-wrap items-center gap-2">
            <Pill label="Today" tone="accent" />
            <Pill
              label={liveContext ? "Live context on" : "Saved schedule baseline"}
              tone={liveContext ? "accent" : "neutral"}
            />
          </View>
          <View className="gap-2">
            <AppText variant="hero">Today</AppText>
            <AppText tone="secondary" variant="section">
              {dateLabel}
            </AppText>
          </View>
          <AppText tone="secondary" style={{ maxWidth: 320 }}>
            Daily execution reads as a working surface now: brief first, then task cards, then supporting context.
          </AppText>
        </View>
        <View className="items-end gap-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Daily execution
          </AppText>
          <View className="rounded-[24px] bg-[#FFFFFF66] px-4 py-3">
            <AppText variant="caption" tone="secondary">
              Context
            </AppText>
            <AppText variant="section">
              {liveContext ? "Calendar grounded" : "Baseline mode"}
            </AppText>
          </View>
        </View>
      </View>
    </Surface>
  );
}

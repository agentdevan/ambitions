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
    <Surface tone={liveContext ? "accent" : "default"} className="gap-5 pt-1">
      <View className="flex-row items-center justify-between gap-3">
        <View className="flex-row flex-wrap items-center gap-2">
          <Pill label="Today" tone="accent" />
          <Pill
            label={liveContext ? "Live context on" : "Saved schedule baseline"}
            tone={liveContext ? "accent" : "neutral"}
          />
        </View>
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Daily execution
        </AppText>
      </View>

      <View className="gap-3">
        <AppText variant="hero">Today</AppText>
        <AppText tone="secondary" variant="section">
          {dateLabel}
        </AppText>
      </View>

      <View className="gap-2">
        <AppText tone="secondary" style={{ maxWidth: 320 }}>
          A measured daily plan with enough structure to act on and enough restraint to stay believable.
        </AppText>
        <View className="flex-row flex-wrap gap-2">
          <Pill label="Actionable task cards" tone="quiet" />
          <Pill label="Quiet metadata" tone="quiet" />
        </View>
      </View>
    </Surface>
  );
}

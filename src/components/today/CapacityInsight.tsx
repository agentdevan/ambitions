import { View } from "react-native";

import { CapacityProfile } from "../../data/models";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface CapacityInsightProps {
  capacity: CapacityProfile;
  focus: string;
}

export function CapacityInsight({ capacity, focus }: CapacityInsightProps) {
  return (
    <Surface tone="accent" className="gap-4">
      <View className="gap-1">
        <AppText tone="secondary" variant="caption">
          Capacity insight
        </AppText>
        <AppText variant="section">
          {capacity.focusBudgetMinutes} minutes of credible focus room today.
        </AppText>
      </View>

      <AppText tone="secondary">{focus}</AppText>

      <View className="flex-row gap-3">
        <View className="flex-1 rounded-[20px] bg-[#EFF3EE] px-3 py-3">
          <AppText tone="tertiary" variant="micro">
            Mental load
          </AppText>
          <AppText variant="section" style={{ textTransform: "capitalize" }}>
            {capacity.mentalLoad}
          </AppText>
        </View>

        <View className="flex-1 rounded-[20px] bg-[#EFF3EE] px-3 py-3">
          <AppText tone="tertiary" variant="micro">
            Meeting load
          </AppText>
          <AppText variant="section">{capacity.meetingLoadMinutes} min</AppText>
        </View>
      </View>
    </Surface>
  );
}

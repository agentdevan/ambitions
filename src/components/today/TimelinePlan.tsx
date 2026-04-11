import { View } from "react-native";

import { PlanBlock } from "../../data/models";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface TimelinePlanProps {
  blocks: PlanBlock[];
}

const stateAccentMap = {
  complete: "#6A8368",
  scheduled: "#6C7483",
  rolled: "#A17A56",
  deferred: "#9A978E",
};

export function TimelinePlan({ blocks }: TimelinePlanProps) {
  return (
    <Surface className="gap-5">
      <View className="gap-1">
        <AppText tone="secondary" variant="caption">
          Time-blocked plan
        </AppText>
        <AppText variant="section">A realistic shape for the day</AppText>
      </View>

      <View className="gap-4">
        {blocks.map((block) => (
          <View key={block.id} className="flex-row gap-3">
            <View className="items-center">
              <AppText variant="micro" tone="tertiary">
                {block.startsAt}
              </AppText>
              <View
                className="mt-2 w-[2px] flex-1 rounded-full"
                style={{ backgroundColor: `${stateAccentMap[block.state]}30`, minHeight: 52 }}
              />
            </View>

            <View className="flex-1 gap-2 pb-3">
              <View
                className="rounded-[22px] border px-4 py-3"
                style={{
                  borderColor: `${stateAccentMap[block.state]}25`,
                  backgroundColor: "#FBFAF7",
                }}
              >
                <View className="flex-row items-start justify-between gap-3">
                  <View className="flex-1 gap-1">
                    <AppText variant="section">{block.title}</AppText>
                    <AppText tone="secondary">
                      {block.endsAt} finish • {block.note}
                    </AppText>
                  </View>
                  <View
                    className="rounded-full px-2.5 py-1"
                    style={{ backgroundColor: `${stateAccentMap[block.state]}16` }}
                  >
                    <AppText
                      variant="micro"
                      style={{
                        color: stateAccentMap[block.state],
                        textTransform: "capitalize",
                      }}
                    >
                      {block.state}
                    </AppText>
                  </View>
                </View>
              </View>
            </View>
          </View>
        ))}
      </View>
    </Surface>
  );
}

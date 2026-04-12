import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatLongDate, formatTimeLabel } from "../../utils/date";
import { TodayStackParamList } from "../../navigation/types";

type Props = NativeStackScreenProps<TodayStackParamList, "TodayHome">;

function SummaryStat({
  label,
  value,
  detail,
}: {
  label: string;
  value: string;
  detail: string;
}) {
  return (
    <View className="min-w-[46%] flex-1 gap-1 rounded-[18px] px-4 py-4">
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section">{value}</AppText>
      <AppText tone="secondary" variant="caption">
        {detail}
      </AppText>
    </View>
  );
}

export function TodayScreen({ navigation }: Props) {
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const planDate = useAppStore((state) => state.planDate);

  if (!today) {
    const emptyBody =
      bootStatus === "loading"
        ? "Loading today's execution layer."
        : goals.length === 0
          ? "Add a goal first. Ambitions will shape the first day from there."
          : "Today's plan is missing. Open Plan to rebuild it.";

    return (
      <Screen>
        <View className="gap-5">
          <PageHeader
            eyebrow="Today"
            title="Execution starts here."
            description={formatLongDate(planDate)}
          />
          <EmptyStateCard
            title={bootStatus === "loading" ? "Loading today" : "No plan yet"}
            body={emptyBody}
            action={
              bootStatus !== "loading" ? (
                <View className="flex-row gap-3 pt-1">
                  <Button style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Goals")}>
                    Go to goals
                  </Button>
                  <Button
                    tone="tertiary"
                    style={{ flex: 1 }}
                    onPress={() => navigation.getParent()?.navigate("Plan")}
                  >
                    Open plan
                  </Button>
                </View>
              ) : null
            }
          />
        </View>
      </Screen>
    );
  }

  const activeBlock = today.blocks.find((block) => block.state === "active") ?? null;
  const nextBlock =
    today.blocks.find((block) => block.state === "scheduled") ??
    today.blocks.find((block) => block.state === "rolled") ??
    null;
  const usefulAction =
    today.replanSuggestions[0]?.title ??
    today.adaptiveGuidance[0] ??
    "Use the next open block well.";
  const pendingReviewCount = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const freeTimeLabel =
    today.capacity.unusedCapacityMinutes > 0
      ? `${today.capacity.unusedCapacityMinutes} min open`
      : "Day is spoken for";

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Today"
          title="See what needs attention next."
          description={formatLongDate(today.date)}
        />

        <Surface tone="accent" className="gap-5">
          <View className="gap-3">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill
                label={today.integration.usingLiveCalendar ? "Live context" : "Saved baseline"}
                tone="accent"
              />
              {pendingReviewCount > 0 ? (
                <Pill
                  label={`${pendingReviewCount} review${pendingReviewCount === 1 ? "" : "s"} waiting`}
                  tone="quiet"
                />
              ) : null}
            </View>
            <AppText variant="title">{today.focus}</AppText>
            <AppText tone="secondary">
              {today.adaptiveGuidance[0] ?? "Start with the easiest useful step."}
            </AppText>
          </View>

          <View className="flex-row flex-wrap gap-2 rounded-[22px]">
            <SummaryStat
              label="Now"
              value={activeBlock ? activeBlock.title : "Nothing in progress"}
              detail={
                activeBlock
                  ? `Until ${formatTimeLabel(activeBlock.endsAt)}`
                  : "You have room to choose the next useful move."
              }
            />
            <SummaryStat
              label="Next"
              value={nextBlock ? nextBlock.title : "No fixed next block"}
              detail={
                nextBlock
                  ? `${formatTimeLabel(nextBlock.startsAt)}`
                  : "The plan is flexible from here."
              }
            />
            <SummaryStat
              label="Free time"
              value={freeTimeLabel}
              detail={`${today.capacity.usableMinutes} usable minutes today`}
            />
            <SummaryStat
              label="Use this time"
              value={usefulAction}
              detail="Keep the next step concrete and light enough to start."
            />
          </View>
        </Surface>

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Timeline
              </AppText>
              <AppText variant="title">A compact view of today</AppText>
              <AppText tone="secondary">
                Open any session for details and the right action.
              </AppText>
            </View>
            <Button tone="secondary" onPress={() => navigation.navigate("TodayTimeline")}>
              Full timeline
            </Button>
          </View>

          <View className="gap-3">
            {today.blocks.slice(0, 4).map((block) => (
              <CompactTimelineRow
                key={block.id}
                block={block}
                onPress={() =>
                  navigation.navigate("TodaySessionDetail", {
                    blockId: block.id,
                  })
                }
              />
            ))}
          </View>
        </Surface>

        <View className="gap-3">
          <DrillInRow
            title="Capacity"
            subtitle={`Pressure is ${today.capacity.planPressure}. ${freeTimeLabel}.`}
            detail={`${Math.round(today.capacity.confidence * 100)}% confidence`}
            onPress={() => navigation.navigate("TodayCapacity")}
          />
          <DrillInRow
            title="Context"
            subtitle={today.integration.calendarDetail}
            detail={today.integration.calendarStatusLabel}
            onPress={() => navigation.navigate("TodayContext")}
          />
          {pendingReviewCount > 0 ? (
            <DrillInRow
              title="Plan review"
              subtitle="Changes are waiting before they replace the current structure."
              detail={`${pendingReviewCount} pending`}
              onPress={() => navigation.getParent()?.navigate("Plan")}
            />
          ) : null}
        </View>
      </View>
    </Screen>
  );
}

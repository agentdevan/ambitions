import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { LinearGradient } from "expo-linear-gradient";
import { useEffect, useMemo, useRef, useState } from "react";
import { Animated, View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { TodayStackParamList } from "../../navigation/types";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { TodayRecommendation } from "../../state/viewModels/today";
import { formatLongDate, formatTimeLabel } from "../../utils/date";

type Props = NativeStackScreenProps<TodayStackParamList, "TodayHome">;

function StatusTile({
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

function OpportunityCard({
  recommendation,
  onPrimaryPress,
  onSecondaryPress,
  busy,
}: {
  recommendation: TodayRecommendation;
  onPrimaryPress: () => void;
  onSecondaryPress: (() => void) | null;
  busy: boolean;
}) {
  const theme = useResolvedTheme();
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(10)).current;
  const recommendationKey = useMemo(
    () => `${recommendation.kind}:${recommendation.taskId ?? recommendation.blockId ?? "none"}`,
    [recommendation.blockId, recommendation.kind, recommendation.taskId],
  );

  useEffect(() => {
    opacity.setValue(0);
    translateY.setValue(10);

    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: 220,
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: 0,
        duration: 220,
        useNativeDriver: true,
      }),
    ]).start();
  }, [opacity, recommendationKey, translateY]);

  return (
    <Animated.View
      style={{
        opacity,
        transform: [{ translateY }],
      }}
    >
      <Surface className="gap-4">
        <View className="gap-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Use this time
          </AppText>
          <AppText variant="title">{recommendation.title}</AppText>
          <AppText variant="section">{recommendation.summary}</AppText>
          <AppText tone="secondary">{recommendation.emphasis}</AppText>
        </View>

        {recommendation.options.length > 1 ? (
          <View
            className="gap-3 rounded-[18px] px-4 py-4"
            style={{
              backgroundColor: theme.colors.background.sunken,
              borderWidth: 1,
              borderColor: theme.colors.border.subtle,
            }}
          >
            {recommendation.options.slice(1, 3).map((option) => (
              <View key={option.taskId} className="gap-1.5">
                <View className="flex-row flex-wrap items-center gap-2">
                  <AppText variant="caption">{option.title}</AppText>
                  <Pill label={`${option.estimatedMinutes} min`} tone="quiet" />
                  <Pill label={option.fitLabel} tone="accent" />
                </View>
                <AppText tone="secondary" variant="caption">
                  {option.reason}
                </AppText>
              </View>
            ))}
          </View>
        ) : null}

        <View className="flex-row flex-wrap gap-3">
          <Button busy={busy} style={{ flex: 1 }} onPress={onPrimaryPress}>
            {recommendation.primaryLabel}
          </Button>
          {onSecondaryPress && recommendation.secondaryLabel ? (
            <Button tone="secondary" style={{ flex: 1 }} onPress={onSecondaryPress}>
              {recommendation.secondaryLabel}
            </Button>
          ) : null}
        </View>
      </Surface>
    </Animated.View>
  );
}

export function TodayScreen({ navigation }: Props) {
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const planDate = useAppStore((state) => state.planDate);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const theme = useResolvedTheme();

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

  const todayVm = today;

  const pendingReviewCount = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const openTimeValue =
    todayVm.openWindow?.label ?? (todayVm.next ? "Protected until next block" : "Flexible");
  const openTimeDetail =
    todayVm.openWindow?.detail ??
    (todayVm.next
      ? `Next up at ${formatTimeLabel(todayVm.next.startsAt)}.`
      : "No strong next block is locked yet.");

  async function handleRecommendedAction() {
    if (todayVm.recommendation.taskId && todayVm.recommendation.suggestedAction) {
      setBusyTaskId(todayVm.recommendation.taskId);

      try {
        await applyTaskAction(
          todayVm.recommendation.taskId,
          todayVm.recommendation.suggestedAction,
        );
      } finally {
        setBusyTaskId(null);
      }

      return;
    }

    if (todayVm.recommendation.blockId) {
      navigation.navigate("TodaySessionDetail", { blockId: todayVm.recommendation.blockId });
      return;
    }

    if (todayVm.openWindow) {
      navigation.navigate("TodayOpenTime");
      return;
    }

    if (todayVm.next) {
      navigation.navigate("TodaySessionDetail", { blockId: todayVm.next.id });
      return;
    }

    navigation.navigate("TodayTimeline");
  }

  function handleSecondaryAction() {
    if (todayVm.recommendation.options.length > 1 || todayVm.openWindow) {
      navigation.navigate("TodayOpenTime");
      return;
    }

    if (todayVm.next) {
      navigation.navigate("TodaySessionDetail", { blockId: todayVm.next.id });
      return;
    }

    navigation.navigate("TodayTimeline");
  }

  return (
    <Screen>
      <View className="gap-6">
        <PageHeader
          eyebrow="Today"
          title="Know where the day stands."
          description={formatLongDate(todayVm.date)}
        />

        <Surface tone="accent" className="gap-5 overflow-hidden">
          <LinearGradient
            colors={["rgba(255,255,255,0.46)", "rgba(233,214,186,0.16)", "rgba(255,255,255,0)"]}
            end={{ x: 1, y: 1 }}
            start={{ x: 0, y: 0 }}
            style={{
              position: "absolute",
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
            }}
          />
          <View className="gap-3">
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill
                label={todayVm.integration.usingLiveCalendar ? "Live context" : "Saved baseline"}
                tone="accent"
              />
              <Pill
                label={todayVm.status.mode === "in_block" ? "In motion" : "Open day read"}
                tone="quiet"
              />
              {pendingReviewCount > 0 ? (
                <Pill
                  label={`${pendingReviewCount} review${pendingReviewCount === 1 ? "" : "s"} waiting`}
                  tone="quiet"
                />
              ) : null}
            </View>
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                {todayVm.status.eyebrow}
              </AppText>
              <AppText variant="title">{todayVm.status.title}</AppText>
              <AppText tone="secondary">{todayVm.status.detail}</AppText>
              <AppText tone="secondary" variant="caption">
                {todayVm.status.warmth}
              </AppText>
            </View>
          </View>

          <View className="flex-row flex-wrap gap-2 rounded-[22px]">
            <StatusTile
              label="Now"
              value={todayVm.now ? todayVm.now.title : "Open space"}
              detail={
                todayVm.now
                  ? `Until ${formatTimeLabel(todayVm.now.endsAt)}`
                  : todayVm.openWindow
                    ? todayVm.openWindow.detail
                    : "No live block right now."
              }
            />
            <StatusTile
              label="Next"
              value={todayVm.next ? todayVm.next.title : "No fixed next block"}
              detail={
                todayVm.next
                  ? `${formatTimeLabel(todayVm.next.startsAt)}`
                  : "This part of the day is still flexible."
              }
            />
            <StatusTile label="Open time" value={openTimeValue} detail={openTimeDetail} />
            <StatusTile
              label="Best move"
              value={todayVm.recommendation.summary}
              detail={todayVm.recommendation.emphasis}
            />
          </View>
        </Surface>

        <OpportunityCard
          recommendation={todayVm.recommendation}
          onPrimaryPress={() => void handleRecommendedAction()}
          onSecondaryPress={
            todayVm.recommendation.secondaryLabel ? () => handleSecondaryAction() : null
          }
          busy={busyTaskId === todayVm.recommendation.taskId}
        />

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Timeline
              </AppText>
              <AppText variant="title">A calm read on the rest of today</AppText>
              <AppText tone="secondary">
                The current block and the next useful turns, without the whole day taking over.
              </AppText>
            </View>
            <Button tone="secondary" onPress={() => navigation.navigate("TodayTimeline")}>
              Full timeline
            </Button>
          </View>

          <View className="gap-3">
            {todayVm.timelinePreview.map((block) => (
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
          {todayVm.openWindow ? (
            <DrillInRow
              title="Use this window"
              subtitle={
                todayVm.recommendation.options.length > 0
                  ? `${todayVm.openWindow.availableMinutes} minutes open. See the best fits and alternate options.`
                  : `${todayVm.openWindow.availableMinutes} minutes open. Keep it protected if nothing sensible fits.`
              }
              detail={todayVm.openWindow.label}
              onPress={() => navigation.navigate("TodayOpenTime")}
            />
          ) : null}
          <DrillInRow
            title="Capacity"
            subtitle={`Pressure is ${todayVm.capacity.planPressure}. ${todayVm.capacity.unusedCapacityMinutes} minutes are still free across the day.`}
            detail={`${Math.round(todayVm.capacity.confidence * 100)}% confidence`}
            onPress={() => navigation.navigate("TodayCapacity")}
          />
          <DrillInRow
            title="Context"
            subtitle={todayVm.integration.calendarDetail}
            detail={todayVm.integration.calendarStatusLabel}
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

        <View
          className="rounded-[22px] px-4 py-4"
          style={{
            backgroundColor: theme.colors.background.sunken,
            borderWidth: 1,
            borderColor: theme.colors.border.subtle,
          }}
        >
          <AppText tone="secondary" variant="caption">
            {todayVm.focus}
          </AppText>
        </View>
      </View>
    </Screen>
  );
}

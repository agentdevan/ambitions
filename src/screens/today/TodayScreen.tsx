import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import { useEffect, useMemo, useRef, useState } from "react";
import { Animated, View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
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

function MetricTile({
  label,
  value,
  detail,
}: {
  label: string;
  value: string;
  detail: string;
}) {
  const theme = useResolvedTheme();

  return (
    <View
      className="flex-1 gap-1 rounded-[22px] px-4 py-4"
      style={{
        minWidth: "47%",
        backgroundColor: theme.colors.background.elevated,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
      }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section" numberOfLines={1}>
        {value}
      </AppText>
      <AppText tone="secondary" variant="caption" numberOfLines={2}>
        {detail}
      </AppText>
    </View>
  );
}

function TodayHero({
  title,
  detail,
  warmth,
  focus,
}: {
  title: string;
  detail: string;
  warmth: string;
  focus: string;
}) {
  const theme = useResolvedTheme();

  return (
    <Surface tone="hero" className="gap-5">
      <LinearGradient
        colors={
          theme.mode === "dark"
            ? ["rgba(255,255,255,0.05)", "rgba(255,255,255,0)", "rgba(0,0,0,0.08)"]
            : ["rgba(255,255,255,0.65)", "rgba(255,248,235,0.25)", "rgba(255,255,255,0)"]
        }
        end={{ x: 1, y: 1 }}
        start={{ x: 0, y: 0 }}
        style={{ position: "absolute", top: 0, right: 0, bottom: 0, left: 0 }}
      />
      <View className="gap-3">
        <Pill label="Today" tone="accent" />
        <View className="gap-2">
          <AppText variant="title">{title}</AppText>
          <AppText tone="secondary">{detail}</AppText>
          <AppText tone="secondary" variant="caption">
            {warmth}
          </AppText>
        </View>
      </View>
      <View
        className="rounded-[22px] px-4 py-4"
        style={{
          backgroundColor: theme.colors.background.elevated,
          borderWidth: 1,
          borderColor: theme.colors.border.subtle,
        }}
      >
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          Focus
        </AppText>
        <AppText style={{ marginTop: 6 }}>{focus}</AppText>
      </View>
    </Surface>
  );
}

function SuggestedActionCard({
  recommendation,
  busy,
  onPrimaryPress,
  onSecondaryPress,
}: {
  recommendation: TodayRecommendation;
  busy: boolean;
  onPrimaryPress: () => void;
  onSecondaryPress: (() => void) | null;
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
    <Animated.View style={{ opacity, transform: [{ translateY }] }}>
      <Surface className="gap-4">
        <View className="flex-row items-start justify-between gap-3">
          <View className="flex-1 gap-1.5">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Suggested next action
            </AppText>
            <AppText variant="title">{recommendation.summary}</AppText>
            <AppText tone="secondary" variant="caption">
              {recommendation.emphasis}
            </AppText>
          </View>
          <View
            className="rounded-[18px] px-3 py-3"
            style={{ backgroundColor: theme.colors.background.accentWash }}
          >
            <Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />
          </View>
        </View>

        {recommendation.options.length > 1 ? (
          <View className="gap-3">
            {recommendation.options.slice(1, 3).map((option) => (
              <View
                key={option.taskId}
                className="rounded-[20px] px-4 py-3"
                style={{
                  backgroundColor: theme.colors.background.elevatedSecondary,
                  borderWidth: 1,
                  borderColor: theme.colors.border.subtle,
                }}
              >
                <View className="flex-row flex-wrap items-center gap-2">
                  <AppText variant="caption">{option.title}</AppText>
                  <Pill label={`${option.estimatedMinutes} min`} tone="quiet" />
                  <Pill label={option.fitLabel} tone="neutral" />
                </View>
              </View>
            ))}
          </View>
        ) : null}

        <View className="flex-row gap-3">
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
        ? "Loading today."
        : goals.length === 0
          ? "Add a goal to start the day."
          : "Open Plan to rebuild today.";

    return (
      <Screen>
        <View className="gap-5">
          <PageHeader eyebrow="Today" title="Today" description={formatLongDate(planDate)} />
          <EmptyStateCard
            title={bootStatus === "loading" ? "Loading" : "No day yet"}
            body={emptyBody}
            action={
              bootStatus !== "loading" ? (
                <View className="flex-row gap-3 pt-1">
                  <Button style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Goals")}>
                    Goals
                  </Button>
                  <Button
                    tone="secondary"
                    style={{ flex: 1 }}
                    onPress={() => navigation.getParent()?.navigate("Plan")}
                  >
                    Plan
                  </Button>
                </View>
              ) : null
            }
          />
        </View>
      </Screen>
    );
  }

  const pendingReviewCount = goals.filter((goal) => getGoalReviewDraft(goal) !== null).length;
  const todayVm = today;
  const openTimeValue =
    todayVm.openWindow?.label ?? (todayVm.next ? "Protected until next block" : "Flexible");
  const openTimeDetail =
    todayVm.openWindow?.detail ??
    (todayVm.next ? `Next at ${formatTimeLabel(todayVm.next.startsAt)}.` : "Nothing fixed yet.");
  const completedRatio =
    todayVm.progress.scheduled > 0 ? todayVm.progress.completed / todayVm.progress.scheduled : 0;

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
      <View className="gap-5">
        <PageHeader
          eyebrow="Today"
          title={todayVm.status.mode === "in_block" ? "In motion." : "See the day fast."}
          description={formatLongDate(todayVm.date)}
        />

        <TodayHero
          title={todayVm.status.title}
          detail={todayVm.status.detail}
          warmth={todayVm.status.warmth}
          focus={todayVm.focus}
        />

        <View className="flex-row flex-wrap gap-3">
          <MetricTile
            label="Focus now"
            value={todayVm.now ? todayVm.now.title : "Open space"}
            detail={
              todayVm.now
                ? `Until ${formatTimeLabel(todayVm.now.endsAt)}`
                : todayVm.openWindow
                  ? todayVm.openWindow.detail
                  : "No live block."
            }
          />
          <MetricTile
            label="Up next"
            value={todayVm.next ? todayVm.next.title : "Nothing fixed"}
            detail={todayVm.next ? formatTimeLabel(todayVm.next.startsAt) : "Still flexible"}
          />
          <MetricTile label="Free time" value={openTimeValue} detail={openTimeDetail} />
          <MetricTile
            label="Completed"
            value={`${todayVm.progress.completed}/${todayVm.progress.scheduled || 0}`}
            detail={
              todayVm.progress.recovery > 0
                ? `${todayVm.progress.recovery} need reshaping`
                : "Steady day"
            }
          />
        </View>

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Day progress
              </AppText>
              <AppText variant="title">Quiet momentum</AppText>
            </View>
            <AppText tone="secondary" variant="caption">
              {Math.round(completedRatio * 100)}%
            </AppText>
          </View>
          <ProgressBar progress={completedRatio} />
          <View className="flex-row flex-wrap gap-2">
            <Pill
              label={todayVm.integration.usingLiveCalendar ? "Live context" : "Saved baseline"}
              tone="neutral"
            />
            <Pill label={`${todayVm.capacity.unusedCapacityMinutes} min open`} tone="quiet" />
            {pendingReviewCount > 0 ? (
              <Pill
                label={`${pendingReviewCount} review${pendingReviewCount === 1 ? "" : "s"}`}
                tone="accent"
              />
            ) : null}
          </View>
        </Surface>

        <SuggestedActionCard
          recommendation={todayVm.recommendation}
          onPrimaryPress={() => void handleRecommendedAction()}
          onSecondaryPress={
            todayVm.recommendation.secondaryLabel ? () => handleSecondaryAction() : null
          }
          busy={busyTaskId === todayVm.recommendation.taskId}
        />

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Schedule
              </AppText>
              <AppText variant="title">Up next</AppText>
            </View>
            <Button tone="inline" onPress={() => navigation.navigate("TodayTimeline")}>
              Full day
            </Button>
          </View>

          <View className="gap-3">
            {todayVm.timelinePreview.map((block) => (
              <CompactTimelineRow
                key={block.id}
                block={block}
                onPress={() => navigation.navigate("TodaySessionDetail", { blockId: block.id })}
              />
            ))}
          </View>
        </Surface>

        <View className="gap-3">
          {todayVm.openWindow ? (
            <DrillInRow
              title="Open time"
              subtitle={`${todayVm.openWindow.availableMinutes} min available`}
              detail="Use well"
              leading={<Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />}
              onPress={() => navigation.navigate("TodayOpenTime")}
            />
          ) : null}
          <DrillInRow
            title="Capacity"
            subtitle={`${todayVm.capacity.unusedCapacityMinutes} min open`}
            detail={`${Math.round(todayVm.capacity.confidence * 100)}% confidence`}
            leading={
              <Ionicons color={theme.colors.text.secondary} name="speedometer-outline" size={18} />
            }
            onPress={() => navigation.navigate("TodayCapacity")}
          />
          <DrillInRow
            title="Context"
            subtitle={todayVm.integration.usingLiveCalendar ? "Live calendar" : "Saved schedule"}
            detail={todayVm.integration.calendarStatusLabel}
            leading={
              <Ionicons color={theme.colors.text.secondary} name="calendar-clear-outline" size={18} />
            }
            onPress={() => navigation.navigate("TodayContext")}
          />
        </View>
      </View>
    </Screen>
  );
}

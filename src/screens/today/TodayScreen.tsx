import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { LinearGradient } from "expo-linear-gradient";
import { Ionicons } from "@expo/vector-icons";
import type { ReactNode } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { Animated, View } from "react-native";

import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { GuidancePanel } from "../../components/today/GuidancePanel";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { ProgressBar } from "../../components/ui/ProgressBar";
import { Screen } from "../../components/ui/Screen";
import { SegmentedControl } from "../../components/ui/SegmentedControl";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import {
  DailyRitualCarryDecision,
  DailyRitualClarityRating,
  DailyRitualDayLoadRating,
  DailyRitualEnergyRating,
  DailyRitualOpeningFocus,
  DailyRitualRecoveryMode,
} from "../../domain/models";
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
      className="flex-1 gap-1.5 rounded-[20px] px-4 py-3.5"
      style={{
        minWidth: "47%",
        backgroundColor: theme.colors.background.elevated,
        borderWidth: 1,
        borderColor: theme.colors.border.strong,
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
    <Surface tone="hero" className="gap-4">
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
      <View className="gap-2.5">
        <Pill label="Today" tone="accent" />
        <View className="gap-2">
          <AppText variant="title">{title}</AppText>
          <AppText tone="secondary" numberOfLines={2}>{detail}</AppText>
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
      <Surface tone="accent" className="gap-4">
        <View className="flex-row items-start justify-between gap-3">
          <View className="flex-1 gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Recommended next action
            </AppText>
            <AppText variant="title" numberOfLines={2}>
              {recommendation.summary}
            </AppText>
            <AppText tone="secondary" variant="caption" numberOfLines={2}>
              {recommendation.emphasis}
            </AppText>
          </View>
          <View
            className="rounded-[18px] px-3 py-3"
            style={{ backgroundColor: theme.colors.background.elevated }}
          >
            <Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />
          </View>
        </View>

        {recommendation.options[0] ? (
          <View
            className="gap-2 rounded-[20px] px-4 py-3.5"
            style={{
              backgroundColor: theme.colors.background.elevated,
              borderWidth: 1,
              borderColor: theme.colors.border.strong,
            }}
          >
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill
                label={`${recommendation.options[0].estimatedMinutes} min`}
                tone="quiet"
              />
              <Pill label={recommendation.options[0].fitLabel} tone="accent" />
              {recommendation.options[0].goalTitle ? (
                <Pill label={recommendation.options[0].goalTitle} tone="neutral" />
              ) : null}
            </View>
            {recommendation.options.length > 1 ? (
              <AppText tone="secondary" variant="caption" numberOfLines={2}>
                Alternate path: {recommendation.options[1]?.title}
              </AppText>
            ) : null}
          </View>
        ) : null}

        <View className="gap-2.5">
          <Button busy={busy} onPress={onPrimaryPress}>
            {recommendation.primaryLabel}
          </Button>
          {onSecondaryPress && recommendation.secondaryLabel ? (
            <Button tone="secondary" onPress={onSecondaryPress}>
              {recommendation.secondaryLabel}
            </Button>
          ) : null}
        </View>
      </Surface>
    </Animated.View>
  );
}

function RitualCard({
  children,
  label,
}: {
  children: ReactNode;
  label: string;
}) {
  return (
    <Surface tone="accent" className="gap-4">
      <Pill label={label} tone="accent" />
      {children}
    </Surface>
  );
}

export function TodayScreen({ navigation }: Props) {
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const planDate = useAppStore((state) => state.planDate);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const openDay = useAppStore((state) => state.openDay);
  const recoverDay = useAppStore((state) => state.recoverDay);
  const closeDay = useAppStore((state) => state.closeDay);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [ritualBusy, setRitualBusy] = useState<string | null>(null);
  const [selectedFocus, setSelectedFocus] = useState<DailyRitualOpeningFocus | null>(null);
  const [selectedRecoveryMode, setSelectedRecoveryMode] = useState<DailyRitualRecoveryMode | null>(
    null,
  );
  const [dayLoadRating, setDayLoadRating] = useState<DailyRitualDayLoadRating | null>(null);
  const [energyRating, setEnergyRating] = useState<DailyRitualEnergyRating | null>(null);
  const [clarityRating, setClarityRating] = useState<DailyRitualClarityRating | null>(null);
  const [carryDecision, setCarryDecision] = useState<DailyRitualCarryDecision>(
    DailyRitualCarryDecision.DeferDecision,
  );
  const [reflectionNote, setReflectionNote] = useState("");
  const theme = useResolvedTheme();

  useEffect(() => {
    if (today?.ritual?.kind === "opening") {
      setSelectedFocus(today.ritual.openingOptions?.[0]?.focus ?? null);
    }

    if (today?.ritual?.kind === "recovery") {
      setSelectedRecoveryMode(today.ritual.recommendedRecoveryMode ?? null);
    }

    if (today?.ritual?.kind === "closeout") {
      setCarryDecision(
        today.ritual.closeSummary?.defaultDecision ?? DailyRitualCarryDecision.DeferDecision,
      );
      setReflectionNote("");
      setDayLoadRating(null);
      setEnergyRating(null);
      setClarityRating(null);
    }
  }, [today?.date, today?.ritual]);

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

  async function handleOpenDay() {
    setRitualBusy("open");
    try {
      await openDay(selectedFocus);
    } finally {
      setRitualBusy(null);
    }
  }

  async function handleRecoverDay() {
    if (!selectedRecoveryMode) {
      return;
    }

    setRitualBusy("recover");
    try {
      await recoverDay(selectedRecoveryMode);
    } finally {
      setRitualBusy(null);
    }
  }

  async function handleCloseDay() {
    setRitualBusy("close");
    try {
      await closeDay({
        dayLoadRating,
        energyRating,
        clarityRating,
        reflectionNote,
        carryDecision,
      });
    } finally {
      setRitualBusy(null);
    }
  }

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="Today"
          title={todayVm.status.mode === "in_block" ? "In motion." : "See the day fast."}
          description={formatLongDate(todayVm.date)}
          action={
            <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("TodayTimeline")}>
              Open timeline
            </Button>
          }
        />

        <TodayHero
          title={todayVm.status.title}
          detail={todayVm.status.detail}
          warmth={todayVm.status.warmth}
          focus={todayVm.focus}
        />

        {todayVm.ritual?.kind === "opening" ? (
          <RitualCard label="Opening ritual">
            <View className="gap-2">
              <AppText variant="title">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
              <AppText tone="secondary" variant="caption">
                {todayVm.ritual.detail}
              </AppText>
            </View>
            <View className="flex-row flex-wrap gap-2">
              <Pill label={`${todayVm.capacity.usableMinutes} usable min`} tone="quiet" />
              <Pill label={todayVm.recommendation.summary} tone="neutral" />
            </View>
            <View
              className="gap-2 rounded-[20px] px-4 py-3.5"
              style={{
                backgroundColor: theme.colors.background.elevated,
                borderWidth: 1,
                borderColor: theme.colors.border.subtle,
              }}
            >
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Main constraint
              </AppText>
              <AppText>{todayVm.ritual.keyConstraint}</AppText>
            </View>
            {todayVm.ritual.openingOptions?.length ? (
              <View className="gap-2">
                <AppText tone="secondary" variant="caption">
                  Optional focus
                </AppText>
                <View className="flex-row flex-wrap gap-2">
                  {todayVm.ritual.openingOptions.map((option) => (
                    <OptionChip
                      key={option.focus}
                      selected={selectedFocus === option.focus}
                      onPress={() => setSelectedFocus(option.focus)}
                    >
                      {option.label}
                    </OptionChip>
                  ))}
                </View>
              </View>
            ) : null}
            <Button busy={ritualBusy === "open"} onPress={() => void handleOpenDay()}>
              {todayVm.ritual.primaryLabel}
            </Button>
          </RitualCard>
        ) : null}

        {todayVm.ritual?.kind === "recovery" ? (
          <RitualCard label="Recovery ritual">
            <View className="gap-2">
              <AppText variant="title">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
              <AppText tone="secondary" variant="caption">
                {todayVm.ritual.detail}
              </AppText>
            </View>
            <View
              className="gap-2 rounded-[20px] px-4 py-3.5"
              style={{
                backgroundColor: theme.colors.background.elevated,
                borderWidth: 1,
                borderColor: theme.colors.border.subtle,
              }}
            >
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                What changed
              </AppText>
              <AppText>{todayVm.ritual.keyConstraint}</AppText>
              {todayVm.ritual.recoveryReasons?.map((reason) => (
                <AppText key={reason} tone="secondary" variant="caption">
                  {reason}
                </AppText>
              ))}
            </View>
            <View className="flex-row flex-wrap gap-2">
              {todayVm.ritual.recoveryOptions?.map((option) => (
                <OptionChip
                  key={option.mode}
                  selected={selectedRecoveryMode === option.mode}
                  onPress={() => setSelectedRecoveryMode(option.mode)}
                >
                  {option.label}
                </OptionChip>
              ))}
            </View>
            <Button busy={ritualBusy === "recover"} onPress={() => void handleRecoverDay()}>
              {todayVm.ritual.primaryLabel}
            </Button>
          </RitualCard>
        ) : null}

        {todayVm.ritual?.kind === "closeout" ? (
          <RitualCard label="Evening close">
            <View className="gap-2">
              <AppText variant="title">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
            </View>
            {todayVm.ritual.closeSummary ? (
              <View className="flex-row flex-wrap gap-3">
                <MetricTile
                  label="Completed"
                  value={String(todayVm.ritual.closeSummary.completedCount)}
                  detail="Moved cleanly"
                />
                <MetricTile
                  label="Unfinished"
                  value={String(todayVm.ritual.closeSummary.unfinishedCount)}
                  detail="Needs a deliberate next step"
                />
                <MetricTile
                  label="Carried"
                  value={String(todayVm.ritual.closeSummary.carriedCount)}
                  detail="Already sitting in carry states"
                />
                <MetricTile
                  label="Changes"
                  value={String(todayVm.ritual.closeSummary.structuralChangeCount)}
                  detail="Structural shifts today"
                />
              </View>
            ) : null}
            <View className="gap-3">
              <SegmentedControl
                options={[
                  { label: "Light", value: DailyRitualDayLoadRating.Light },
                  { label: "Balanced", value: DailyRitualDayLoadRating.Balanced },
                  { label: "Overloaded", value: DailyRitualDayLoadRating.Overloaded },
                ]}
                value={dayLoadRating ?? DailyRitualDayLoadRating.Balanced}
                onChange={(value) => setDayLoadRating(value as DailyRitualDayLoadRating)}
              />
              <SegmentedControl
                options={[
                  { label: "Low", value: DailyRitualEnergyRating.Low },
                  { label: "Normal", value: DailyRitualEnergyRating.Normal },
                  { label: "High", value: DailyRitualEnergyRating.High },
                ]}
                value={energyRating ?? DailyRitualEnergyRating.Normal}
                onChange={(value) => setEnergyRating(value as DailyRitualEnergyRating)}
              />
              <SegmentedControl
                options={[
                  { label: "Clear", value: DailyRitualClarityRating.Clear },
                  { label: "Crowded", value: DailyRitualClarityRating.Crowded },
                  { label: "Unrealistic", value: DailyRitualClarityRating.Unrealistic },
                ]}
                value={clarityRating ?? DailyRitualClarityRating.Clear}
                onChange={(value) => setClarityRating(value as DailyRitualClarityRating)}
              />
            </View>
            <View className="gap-2">
              <AppText tone="secondary" variant="caption">
                Unfinished work
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {[
                  [DailyRitualCarryDecision.CarryForward, "Carry forward"],
                  [DailyRitualCarryDecision.SendToReview, "Send to review"],
                  [DailyRitualCarryDecision.DeferDecision, "Defer decision"],
                ].map(([value, label]) => (
                  <OptionChip
                    key={String(value)}
                    selected={carryDecision === value}
                    onPress={() => setCarryDecision(value as DailyRitualCarryDecision)}
                  >
                    {label}
                  </OptionChip>
                ))}
              </View>
            </View>
            <TextField
              label="Quick note (optional)"
              multiline
              onChangeText={setReflectionNote}
              value={reflectionNote}
            />
            <Button busy={ritualBusy === "close"} onPress={() => void handleCloseDay()}>
              {todayVm.ritual.primaryLabel}
            </Button>
          </RitualCard>
        ) : null}

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

        {todayVm.adaptiveGuidance.length > 0 ? (
          <GuidancePanel items={todayVm.adaptiveGuidance.slice(0, 3)} />
        ) : null}

        <Surface className="gap-4">
          <View className="flex-row items-end justify-between gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Schedule
              </AppText>
              <AppText variant="title">Up next</AppText>
            </View>
            <Button size="compact" tone="tertiary" onPress={() => navigation.navigate("TodayTimeline")}>
              Open timeline
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
              detail={todayVm.openWindow.opensUntilLabel ? `Until ${todayVm.openWindow.opensUntilLabel}` : "Open window"}
              actionLabel="Use time"
              leading={<Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />}
              onPress={() => navigation.navigate("TodayOpenTime")}
            />
          ) : null}
          <DrillInRow
            title="Capacity"
            subtitle={`${todayVm.capacity.unusedCapacityMinutes} min open`}
            detail={`${Math.round(todayVm.capacity.confidence * 100)}% confidence`}
            actionLabel="Open"
            leading={
              <Ionicons color={theme.colors.text.secondary} name="speedometer-outline" size={18} />
            }
            onPress={() => navigation.navigate("TodayCapacity")}
          />
          <DrillInRow
            title="Context"
            subtitle={todayVm.integration.usingLiveCalendar ? "Live calendar" : "Saved schedule"}
            detail={todayVm.integration.calendarStatusLabel}
            actionLabel="Open"
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

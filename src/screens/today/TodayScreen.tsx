import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import type { ReactNode } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { Animated, View } from "react-native";

import {
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { CompactTimelineRow } from "../../components/navigation/CompactTimelineRow";
import { DrillInRow } from "../../components/navigation/DrillInRow";
import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
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
import {
  TodayRecommendation,
  TodayWorkspaceSlot,
  TodayWorkspaceSummary,
} from "../../state/viewModels/today";
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

function WorkspaceRow({ slot }: { slot: TodayWorkspaceSlot }) {
  const theme = useResolvedTheme();
  const accentColor =
    slot.tone === "accent"
      ? theme.colors.accent.primary
      : slot.tone === "neutral"
        ? theme.colors.accent.secondary
        : theme.colors.border.strong;

  return (
    <View
      className="flex-row gap-3 rounded-[22px] px-4 py-4"
      style={{
        backgroundColor: theme.colors.background.elevated,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
      }}
    >
      <View
        className="rounded-full"
        style={{
          width: 4,
          backgroundColor: accentColor,
          opacity: slot.tone === "quiet" ? 0.72 : 1,
        }}
      />
      <View className="flex-1 gap-1.5">
        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
          {slot.label}
        </AppText>
        <AppText variant="section">{slot.title}</AppText>
        <AppText tone="secondary" variant="caption">
          {slot.detail}
        </AppText>
      </View>
    </View>
  );
}

function SummaryRow({
  label,
  summary,
}: {
  label: string;
  summary: TodayWorkspaceSummary;
}) {
  const theme = useResolvedTheme();

  return (
    <View
      className="gap-1 rounded-[20px] px-4 py-3.5"
      style={{
        backgroundColor: theme.colors.background.elevated,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
      }}
    >
      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
        {label}
      </AppText>
      <AppText variant="section">{summary.title}</AppText>
      <AppText tone="secondary" variant="caption">
        {summary.detail}
      </AppText>
    </View>
  );
}

function ExecutionHeroCard({
  recommendation,
  statusTitle,
  statusDetail,
  focus,
  now,
  next,
  busy,
  onPrimaryPress,
  onSecondaryPress,
  progressLabel,
  roomLabel,
  usingLiveCalendar,
}: {
  recommendation: TodayRecommendation;
  statusTitle: string;
  statusDetail: string;
  focus: string;
  now: TodayWorkspaceSlot;
  next: TodayWorkspaceSlot;
  busy: boolean;
  onPrimaryPress: () => void;
  onSecondaryPress: (() => void) | null;
  progressLabel: string;
  roomLabel: string;
  usingLiveCalendar: boolean;
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
      <Surface tone="hero" className="gap-4">
        <View className="gap-3">
          <View className="flex-row flex-wrap items-center justify-between gap-2">
            <Pill
              label={
                recommendation.kind === "stay_on_current_block" ||
                recommendation.kind === "continue_in_progress"
                  ? "Now"
                  : "Best next"
              }
              tone="accent"
            />
            <View className="flex-row flex-wrap gap-2">
              <Pill label={progressLabel} tone="quiet" />
              <Pill label={roomLabel} tone="neutral" />
              <Pill
                label={usingLiveCalendar ? "Live calendar" : "Saved baseline"}
                tone="quiet"
              />
            </View>
          </View>

          <View className="gap-2">
            <AppText variant="hero">{recommendation.summary}</AppText>
            <AppText tone="secondary">{recommendation.emphasis}</AppText>
            <AppText tone="secondary" variant="caption">
              {statusTitle} {statusDetail}
            </AppText>
          </View>
        </View>

        <View
          className="gap-3 rounded-[24px] px-4 py-4"
          style={{
            backgroundColor: theme.colors.background.elevated,
            borderWidth: 1,
            borderColor: theme.colors.border.subtle,
          }}
        >
          <WorkspaceRow slot={now} />
          <WorkspaceRow slot={next} />
        </View>

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

        <View
          className="rounded-[20px] px-4 py-3.5"
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
    </Animated.View>
  );
}

function SupportCard({
  label,
  children,
}: {
  label: string;
  children: ReactNode;
}) {
  return (
    <Surface className="gap-4">
      <Pill label={label} tone="quiet" />
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
                  <Button
                    style={{ flex: 1 }}
                    onPress={() => navigation.getParent()?.navigate("Goals")}
                  >
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
  const completedRatio =
    todayVm.progress.scheduled > 0 ? todayVm.progress.completed / todayVm.progress.scheduled : 0;
  const progressLabel = `${todayVm.progress.completed}/${todayVm.progress.scheduled || 0} moved`;
  const roomLabel =
    todayVm.openWindow?.label ??
    (todayVm.capacity.unusedCapacityMinutes > 0
      ? `${todayVm.capacity.unusedCapacityMinutes} min open`
      : "Day is full");
  const returnItems = [
    {
      label: "Movement",
      value: progressLabel,
      detail:
        todayVm.progress.recovery > 0
          ? `${todayVm.progress.recovery} task${todayVm.progress.recovery === 1 ? "" : "s"} still need reshaping`
          : "Completion is moving without extra churn right now",
    },
    {
      label: "Room",
      value: roomLabel,
      detail: todayVm.openWindow?.detail ?? todayVm.workspace.room.detail,
    },
    {
      label: todayVm.workspace.changed ? "Changed" : "Continuity",
      value: todayVm.workspace.changed?.title ?? todayVm.workspace.fixed.title,
      detail: todayVm.workspace.changed?.detail ?? todayVm.workspace.fixed.detail,
    },
    {
      label: "Next",
      value: todayVm.recommendation.primaryLabel,
      detail: todayVm.recommendation.emphasis,
    },
  ];
  const returnReads = [
    todayVm.status.detail,
    todayVm.integration.calendarStatusLabel,
    pendingReviewCount > 0
      ? `${pendingReviewCount} review${pendingReviewCount === 1 ? "" : "s"} are waiting outside today's execution line.`
      : "No review backlog is pressing on today's execution line.",
    todayVm.goalPressure
      ? `${todayVm.goalPressure.goalTitle} is the main pressure signal underneath today.`
      : "No single goal is pressuring today's line more than the rest.",
  ];
  const supportReads = [
    ...todayVm.adaptiveGuidance.slice(0, 2),
    ...(todayVm.recoverySnapshot ? [todayVm.recoverySnapshot.impact] : []),
  ].slice(0, 3);

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
          title="Today"
          description={formatLongDate(todayVm.date)}
          action={
            <Button
              size="compact"
              tone="tertiary"
              onPress={() => navigation.navigate("TodayTimeline")}
            >
              Open timeline
            </Button>
          }
        />

        <ExecutionHeroCard
          recommendation={todayVm.recommendation}
          statusTitle={todayVm.status.title}
          statusDetail={todayVm.status.detail}
          focus={todayVm.focus}
          now={todayVm.workspace.now}
          next={todayVm.workspace.next}
          busy={busyTaskId === todayVm.recommendation.taskId}
          onPrimaryPress={() => void handleRecommendedAction()}
          onSecondaryPress={
            todayVm.recommendation.secondaryLabel ? () => handleSecondaryAction() : null
          }
          progressLabel={progressLabel}
          roomLabel={roomLabel}
          usingLiveCalendar={todayVm.integration.usingLiveCalendar}
        />

        <Surface className="gap-5">
          <DetailSection
            title="Return line"
            description="What changed, what still fits, and the cleanest next useful move."
          >
            <View className="gap-4">
              <DetailSummaryStrip items={returnItems} />
              <QuietMetaLine items={returnReads} />
            </View>
          </DetailSection>
        </Surface>

        {todayVm.ritual?.kind === "opening" ? (
          <SupportCard label="Opening">
            <View className="gap-2">
              <AppText variant="section">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
              <AppText tone="secondary" variant="caption">
                {todayVm.ritual.keyConstraint}
              </AppText>
            </View>
            {todayVm.ritual.openingOptions?.length ? (
              <View className="gap-2">
                <AppText tone="secondary" variant="caption">
                  Set the opening bias
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
          </SupportCard>
        ) : null}

        {todayVm.ritual?.kind === "recovery" ? (
          <SupportCard label="Recovery">
            <View className="gap-2">
              <AppText variant="section">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
              <AppText tone="secondary" variant="caption">
                {todayVm.recoverySnapshot?.impact ?? todayVm.ritual.keyConstraint}
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
                Why it showed up
              </AppText>
              {(todayVm.ritual.recoveryReasons ?? []).map((reason) => (
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
          </SupportCard>
        ) : null}

        <Surface className="gap-4">
          <DetailSection
            title="Execution line"
            description="Reopen the day quickly, then see the structural split underneath it."
          >
            <View className="gap-5">
              <View className="gap-3">
                <WorkspaceRow slot={todayVm.workspace.now} />
                <WorkspaceRow slot={todayVm.workspace.next} />
                <WorkspaceRow slot={todayVm.workspace.later} />
              </View>

              <View className="gap-3">
                <SummaryRow label="Fixed" summary={todayVm.workspace.fixed} />
                <SummaryRow label="Flexible" summary={todayVm.workspace.flexible} />
                <SummaryRow label="Room left" summary={todayVm.workspace.room} />
                {todayVm.workspace.optional ? (
                  <SummaryRow label="Optional" summary={todayVm.workspace.optional} />
                ) : null}
                {todayVm.workspace.changed ? (
                  <SummaryRow label="Changed" summary={todayVm.workspace.changed} />
                ) : null}
              </View>
            </View>
          </DetailSection>
        </Surface>

        {todayVm.recoverySnapshot && todayVm.ritual?.kind !== "recovery" ? (
          <Surface tone="sunken" className="gap-3">
            <View className="gap-1">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Recovery
              </AppText>
              <AppText variant="section">{todayVm.recoverySnapshot.title}</AppText>
            </View>
            <AppText tone="secondary">{todayVm.recoverySnapshot.detail}</AppText>
            <AppText tone="secondary" variant="caption">
              {todayVm.recoverySnapshot.impact}
            </AppText>
          </Surface>
        ) : null}

        {todayVm.timelinePreview.length > 0 || supportReads.length > 0 || todayVm.goalPressure ? (
          <Surface className="gap-5">
            {todayVm.timelinePreview.length > 0 ? (
              <DetailSection
                title="Protected line"
                description="The next part of the day that is already holding."
                action={
                  <Button
                    size="compact"
                    tone="tertiary"
                    onPress={() => navigation.navigate("TodayTimeline")}
                  >
                    Open timeline
                  </Button>
                }
              >
                <View className="gap-3">
                  {todayVm.timelinePreview.slice(0, 3).map((block) => (
                    <CompactTimelineRow
                      key={block.id}
                      block={block}
                      onPress={() => navigation.navigate("TodaySessionDetail", { blockId: block.id })}
                    />
                  ))}
                </View>
              </DetailSection>
            ) : null}

            {supportReads.length > 0 ? (
              <DetailSection
                title="Quiet guidance"
                description="Calm reads from recent movement and the current shape of day."
              >
                <QuietMetaLine items={supportReads} />
              </DetailSection>
            ) : null}

            {todayVm.goalPressure ? (
              <DetailSection
                title="Goal pressure"
                description="Direction tension that still matters, even while Today stays execution-first."
              >
                <View className="gap-2">
                  <AppText variant="section">{todayVm.goalPressure.goalTitle}</AppText>
                  <AppText tone="secondary">{todayVm.goalPressure.summary}</AppText>
                </View>
              </DetailSection>
            ) : null}
          </Surface>
        ) : null}

        {todayVm.ritual?.kind === "closeout" ? (
          <SupportCard label="Closeout">
            <View className="gap-2">
              <AppText variant="section">{todayVm.ritual.title}</AppText>
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
          </SupportCard>
        ) : null}

        <Surface className="gap-4">
          <DetailSection
            title="Drill in"
            description="Open the parts of today that deserve a closer read without crowding the main line."
          >
            <View className="gap-3">
              {todayVm.openWindow ? (
                <DrillInRow
                  title="Open time"
                  subtitle={`${todayVm.openWindow.availableMinutes} min available`}
                  detail={
                    todayVm.openWindow.opensUntilLabel
                      ? `Until ${todayVm.openWindow.opensUntilLabel}`
                      : "Open window"
                  }
                  actionLabel="Use time"
                  leading={
                    <Ionicons color={theme.colors.accent.primary} name="sparkles-outline" size={18} />
                  }
                  onPress={() => navigation.navigate("TodayOpenTime")}
                />
              ) : null}
              <DrillInRow
                title="Capacity"
                subtitle={todayVm.workspace.room.title}
                detail={todayVm.workspace.room.detail}
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
                  <Ionicons
                    color={theme.colors.text.secondary}
                    name="calendar-clear-outline"
                    size={18}
                  />
                }
                onPress={() => navigation.navigate("TodayContext")}
              />
            </View>
          </DetailSection>
        </Surface>

        {pendingReviewCount > 0 ? (
          <AppText tone="tertiary" variant="caption">
            {pendingReviewCount} review{pendingReviewCount === 1 ? "" : "s"} are waiting in Plan
            or Goals. Today is keeping them out of the main execution line.
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}

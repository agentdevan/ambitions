import { useScrollToTop } from "@react-navigation/native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { Ionicons } from "@expo/vector-icons";
import type { ReactNode } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { View } from "react-native";
import { useShallow } from "zustand/react/shallow";

import { DetailSummaryStrip } from "../../components/detail/DetailPrimitives";
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
import { TodayRecommendation, TodayWorkspaceSlot } from "../../state/viewModels/today";
import { formatLongDate } from "../../utils/date";

type Props = NativeStackScreenProps<TodayStackParamList, "TodayHome">;

function getGreeting() {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  if (hour < 18) return "Good afternoon";
  return "Good evening";
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
        style={{ width: 4, backgroundColor: accentColor, opacity: slot.tone === "quiet" ? 0.72 : 1 }}
      />
      <View className="flex-1 gap-1.5">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          {slot.label}
        </AppText>
        <AppText variant="section">{slot.title}</AppText>
        <AppText tone="secondary">{slot.detail}</AppText>
      </View>
    </View>
  );
}

function ExecutionHeroCard({
  recommendation,
  focus,
  now,
  busy,
  onPrimaryPress,
  onSecondaryPress,
  progressLabel,
  roomLabel,
  usingLiveCalendar,
}: {
  recommendation: TodayRecommendation;
  focus: string;
  now: TodayWorkspaceSlot;
  busy: boolean;
  onPrimaryPress: () => void;
  onSecondaryPress: (() => void) | null;
  progressLabel: string;
  roomLabel: string;
  usingLiveCalendar: boolean;
}) {
  return (
    <Surface tone="hero" className="gap-4">
      <View className="gap-3">
        <View className="flex-row flex-wrap items-center gap-2">
          <Pill
            label={
              recommendation.kind === "stay_on_current_block" ||
              recommendation.kind === "continue_in_progress"
                ? "Now"
                : "Best move"
            }
            tone="accent"
          />
          <Pill label={progressLabel} tone="quiet" />
          <Pill label={roomLabel} tone="neutral" />
          <Pill label={usingLiveCalendar ? "Live calendar" : "Saved schedule"} tone="quiet" />
        </View>
        <View className="gap-2">
          <AppText variant="hero">{recommendation.summary}</AppText>
          <AppText tone="secondary">{recommendation.emphasis}</AppText>
        </View>
      </View>

      <WorkspaceRow slot={now} />

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

      <View className="gap-1">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Focus
        </AppText>
        <AppText tone="secondary">{focus}</AppText>
      </View>
    </Surface>
  );
}

function SupportCard({ label, children }: { label: string; children: ReactNode }) {
  return (
    <Surface className="gap-4">
      <Pill label={label} tone="quiet" />
      {children}
    </Surface>
  );
}

export function TodayScreen({ navigation }: Props) {
  const { today, goals, bootStatus, planDate, applyTaskAction, openDay, recoverDay, closeDay } =
    useAppStore(
      useShallow((state) => ({
        today: state.today,
        goals: state.goals,
        bootStatus: state.bootStatus,
        planDate: state.planDate,
        applyTaskAction: state.applyTaskAction,
        openDay: state.openDay,
        recoverDay: state.recoverDay,
        closeDay: state.closeDay,
      })),
    );
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [ritualBusy, setRitualBusy] = useState<string | null>(null);
  const [selectedFocus, setSelectedFocus] = useState<DailyRitualOpeningFocus | null>(null);
  const [selectedRecoveryMode, setSelectedRecoveryMode] = useState<DailyRitualRecoveryMode | null>(null);
  const [dayLoadRating, setDayLoadRating] = useState<DailyRitualDayLoadRating | null>(null);
  const [energyRating, setEnergyRating] = useState<DailyRitualEnergyRating | null>(null);
  const [clarityRating, setClarityRating] = useState<DailyRitualClarityRating | null>(null);
  const [carryDecision, setCarryDecision] = useState<DailyRitualCarryDecision>(
    DailyRitualCarryDecision.DeferDecision,
  );
  const [reflectionNote, setReflectionNote] = useState("");
  const theme = useResolvedTheme();
  const scrollRef = useRef<any>(null);

  useScrollToTop(scrollRef);

  useEffect(() => {
    if (today?.ritual?.kind === "opening") {
      setSelectedFocus(today.ritual.openingOptions?.[0]?.focus ?? null);
    }
    if (today?.ritual?.kind === "recovery") {
      setSelectedRecoveryMode(today.ritual.recommendedRecoveryMode ?? null);
    }
    if (today?.ritual?.kind === "closeout") {
      setCarryDecision(today.ritual.closeSummary?.defaultDecision ?? DailyRitualCarryDecision.DeferDecision);
      setReflectionNote("");
      setDayLoadRating(null);
      setEnergyRating(null);
      setClarityRating(null);
    }
  }, [today?.date, today?.ritual]);

  if (!today) {
    const emptyBody =
      bootStatus === "loading"
        ? "Pulling today's execution line into view."
        : goals.length === 0
          ? "Create one active goal so Today can protect a believable line."
          : "Today's line has not been rebuilt yet. Open Plan and shape the day from the week's real room.";

    return (
      <Screen ref={scrollRef}>
        <View className="gap-5">
          <PageHeader eyebrow="Today" title="Today" description={formatLongDate(planDate)} />
          <EmptyStateCard
            eyebrow={bootStatus === "loading" ? "Preparing" : goals.length === 0 ? "Start here" : "Needs shaping"}
            title={bootStatus === "loading" ? "Loading today" : "Today is not shaped yet"}
            body={emptyBody}
            action={
              bootStatus !== "loading" ? (
                <View className="flex-row gap-3 pt-1">
                  <Button style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Goals")}>
                    Goals
                  </Button>
                  <Button tone="secondary" style={{ flex: 1 }} onPress={() => navigation.getParent()?.navigate("Plan")}>
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

  const pendingReviewCount = useMemo(() => goals.filter((goal) => getGoalReviewDraft(goal) !== null).length, [goals]);
  const todayVm = today;
  const progressLabel = `${todayVm.progress.completed}/${todayVm.progress.scheduled || 0} moved`;
  const roomLabel =
    todayVm.openWindow?.label ??
    (todayVm.capacity.unusedCapacityMinutes > 0 ? `${todayVm.capacity.unusedCapacityMinutes} min open` : "Day is full");

  async function handleRecommendedAction() {
    if (todayVm.recommendation.taskId && todayVm.recommendation.suggestedAction) {
      setBusyTaskId(todayVm.recommendation.taskId);
      try {
        await applyTaskAction(todayVm.recommendation.taskId, todayVm.recommendation.suggestedAction);
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
    if (!selectedRecoveryMode) return;
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
      await closeDay({ dayLoadRating, energyRating, clarityRating, reflectionNote, carryDecision });
    } finally {
      setRitualBusy(null);
    }
  }

  return (
    <Screen ref={scrollRef}>
      <View className="gap-5">
        <PageHeader
          eyebrow="Today"
          title={getGreeting()}
          description={formatLongDate(todayVm.date)}
          action={
            <Button size="compact" tone="secondary" onPress={() => navigation.navigate("TodayTimeline")}>
              Timeline
            </Button>
          }
        />

        <ExecutionHeroCard
          recommendation={todayVm.recommendation}
          focus={todayVm.focus}
          now={todayVm.workspace.now}
          busy={busyTaskId === todayVm.recommendation.taskId}
          onPrimaryPress={() => void handleRecommendedAction()}
          onSecondaryPress={todayVm.recommendation.secondaryLabel ? () => handleSecondaryAction() : null}
          progressLabel={progressLabel}
          roomLabel={roomLabel}
          usingLiveCalendar={todayVm.integration.usingLiveCalendar}
        />

        {todayVm.ritual?.kind === "opening" ? (
          <SupportCard label="Opening">
            <View className="gap-2">
              <AppText variant="section">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
            </View>
            <View className="flex-row flex-wrap gap-2">
              {todayVm.ritual.openingOptions?.map((option) => (
                <OptionChip key={option.focus} selected={selectedFocus === option.focus} onPress={() => setSelectedFocus(option.focus)}>
                  {option.label}
                </OptionChip>
              ))}
            </View>
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
            </View>
            <View className="flex-row flex-wrap gap-2">
              {todayVm.ritual.recoveryOptions?.map((option) => (
                <OptionChip key={option.mode} selected={selectedRecoveryMode === option.mode} onPress={() => setSelectedRecoveryMode(option.mode)}>
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
          <View className="flex-row items-start justify-between gap-3">
            <View className="flex-1 gap-1">
              <AppText variant="section">Next</AppText>
              <AppText tone="secondary">{todayVm.workspace.next.detail}</AppText>
            </View>
            <Button
              size="compact"
              tone="secondary"
              onPress={() => (todayVm.next ? navigation.navigate("TodaySessionDetail", { blockId: todayVm.next.id }) : navigation.navigate("TodayTimeline"))}
            >
              Open
            </Button>
          </View>
          <WorkspaceRow slot={todayVm.workspace.next} />
        </Surface>

        {todayVm.openWindow ? (
          <Surface className="gap-4">
            <View className="gap-1">
              <AppText variant="section">Open window</AppText>
              <AppText tone="secondary">{todayVm.openWindow.detail}</AppText>
            </View>
            <DetailSummaryStrip
              items={[
                { label: "Available", value: `${todayVm.openWindow.availableMinutes} min`, detail: todayVm.openWindow.label },
                { label: "Until", value: todayVm.openWindow.opensUntilLabel ?? "Open ended", detail: "Before the next block starts" },
              ]}
            />
            <Button onPress={() => navigation.navigate("TodayOpenTime")}>Use this window</Button>
          </Surface>
        ) : null}

        <Surface className="gap-4">
          <View className="gap-1">
            <AppText variant="section">Momentum</AppText>
            <AppText tone="secondary">A quick read on whether today is still moving.</AppText>
          </View>
          <DetailSummaryStrip
            items={[
              {
                label: "Moved",
                value: progressLabel,
                detail: todayVm.progress.recovery > 0 ? `${todayVm.progress.recovery} still need reshaping` : "Clean movement so far",
              },
              {
                label: "Pressure",
                value: todayVm.goalPressure?.goalTitle ?? "No goal pressure",
                detail: todayVm.goalPressure?.summary ?? "No single goal is crowding the day",
              },
              {
                label: "Reviews",
                value: pendingReviewCount > 0 ? String(pendingReviewCount) : "Clear",
                detail: pendingReviewCount > 0 ? "Changes waiting outside Today" : "Nothing waiting on review",
              },
              {
                label: "Calendar",
                value: todayVm.integration.usingLiveCalendar ? "Live" : "Fallback",
                detail: todayVm.integration.calendarStatusLabel,
              },
            ]}
          />
        </Surface>

        <Surface className="gap-3">
          <AppText variant="section">Open more</AppText>
          <DrillInRow
            title="Today timeline"
            subtitle="See the full protected line"
            detail={todayVm.timelinePreview.length > 0 ? `${todayVm.timelinePreview.length} visible sessions` : "No sessions yet"}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.accent.primary} name="today-outline" size={18} />}
            onPress={() => navigation.navigate("TodayTimeline")}
          />
          <DrillInRow
            title="Capacity"
            subtitle={todayVm.workspace.room.title}
            detail={todayVm.workspace.room.detail}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="speedometer-outline" size={18} />}
            onPress={() => navigation.navigate("TodayCapacity")}
          />
          <DrillInRow
            title="Calendar and context"
            subtitle={todayVm.integration.usingLiveCalendar ? "Using live calendar" : "Using saved schedule"}
            detail={todayVm.integration.calendarStatusLabel}
            actionLabel="Open"
            leading={<Ionicons color={theme.colors.text.secondary} name="calendar-clear-outline" size={18} />}
            onPress={() => navigation.navigate("TodayContext")}
          />
        </Surface>

        {!todayVm.integration.usingLiveCalendar ? (
          <Surface tone="sunken" className="gap-2">
            <AppText variant="caption">Using saved schedule right now.</AppText>
            <AppText tone="secondary" variant="caption">
              {todayVm.integration.calendarDetail}
            </AppText>
          </Surface>
        ) : null}

        {todayVm.ritual?.kind === "closeout" ? (
          <SupportCard label="Closeout">
            <View className="gap-2">
              <AppText variant="section">{todayVm.ritual.title}</AppText>
              <AppText tone="secondary">{todayVm.ritual.summary}</AppText>
            </View>
            {todayVm.ritual.closeSummary ? (
              <DetailSummaryStrip
                items={[
                  { label: "Completed", value: String(todayVm.ritual.closeSummary.completedCount), detail: "Moved cleanly" },
                  { label: "Unfinished", value: String(todayVm.ritual.closeSummary.unfinishedCount), detail: "Need a next destination" },
                ]}
              />
            ) : null}
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
            <View className="flex-row flex-wrap gap-2">
              {[
                [DailyRitualCarryDecision.CarryForward, "Carry forward"],
                [DailyRitualCarryDecision.SendToReview, "Send to review"],
                [DailyRitualCarryDecision.DeferDecision, "Decide later"],
              ].map(([value, label]) => (
                <OptionChip key={String(value)} selected={carryDecision === value} onPress={() => setCarryDecision(value as DailyRitualCarryDecision)}>
                  {label}
                </OptionChip>
              ))}
            </View>
            <TextField label="Quick note" multiline onChangeText={setReflectionNote} value={reflectionNote} />
            <Button busy={ritualBusy === "close"} onPress={() => void handleCloseDay()}>
              {todayVm.ritual.primaryLabel}
            </Button>
          </SupportCard>
        ) : null}
      </View>
    </Screen>
  );
}

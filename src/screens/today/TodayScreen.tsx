import { useState } from "react";
import { View } from "react-native";
import { useNavigation } from "@react-navigation/native";

import { AccountStatusCard } from "../../components/account/AccountStatusCard";
import { CapacityInsight } from "../../components/today/CapacityInsight";
import { IntegrationStatusCard } from "../../components/today/IntegrationStatusCard";
import { ScheduleContext } from "../../components/today/ScheduleContext";
import { TimelinePlan } from "../../components/today/TimelinePlan";
import { TodayHeader } from "../../components/today/TodayHeader";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";
import { formatLongDate, formatTimeLabel } from "../../utils/date";

function MetaLine({ items }: { items: string[] }) {
  return (
    <View className="flex-row flex-wrap gap-x-4 gap-y-2">
      {items.map((item) => (
        <AppText key={item} tone="secondary" variant="caption">
          {item}
        </AppText>
      ))}
    </View>
  );
}

export function TodayScreen() {
  const navigation = useNavigation();
  const theme = useResolvedTheme();
  const today = useAppStore((state) => state.today);
  const bootStatus = useAppStore((state) => state.bootStatus);
  const goals = useAppStore((state) => state.goals);
  const planDate = useAppStore((state) => state.planDate);
  const applyTaskAction = useAppStore((state) => state.applyTaskAction);
  const calendarConnectionState = useAppStore((state) => state.calendarConnectionState);
  const notificationPermissionStatus = useAppStore(
    (state) => state.notificationPermissionStatus,
  );
  const requestCalendarAccess = useAppStore((state) => state.requestCalendarAccess);
  const requestNotificationAccess = useAppStore((state) => state.requestNotificationAccess);
  const refreshIntegration = useAppStore((state) => state.refreshIntegration);
  const account = useAppStore((state) => state.account);
  const authState = useAppStore((state) => state.authState);
  const attachmentState = useAppStore((state) => state.attachmentState);
  const syncState = useAppStore((state) => state.syncState);
  const syncConflicts = useAppStore((state) => state.syncConflicts);
  const signInWithApple = useAppStore((state) => state.signInWithApple);
  const attachLocalDataToAccount = useAppStore((state) => state.attachLocalDataToAccount);
  const deferLocalDataAttachment = useAppStore((state) => state.deferLocalDataAttachment);
  const syncAccountData = useAppStore((state) => state.syncAccountData);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [integrationBusy, setIntegrationBusy] = useState<string | null>(null);
  const [accountBusy, setAccountBusy] = useState<string | null>(null);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const pendingReviewGoals = goals.filter((goal) => getGoalReviewDraft(goal) !== null);
  const nextBlock =
    today?.blocks.find((block) => block.state === "active") ??
    today?.blocks.find((block) => block.state === "scheduled") ??
    null;

  async function runIntegrationAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setIntegrationBusy(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setIntegrationBusy(null);
    }
  }

  async function handleTaskAction(taskId: string, action: Parameters<typeof applyTaskAction>[1]) {
    setBusyTaskId(taskId);
    setRuntimeMessage(null);

    try {
      await applyTaskAction(taskId, action);
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error
          ? error.message
          : "That change could not be applied to today's plan.",
      );
    } finally {
      setBusyTaskId(null);
    }
  }

  async function runAccountAction(
    key: string,
    action: () => Promise<void>,
    fallbackError: string,
  ) {
    setAccountBusy(key);
    setRuntimeMessage(null);

    try {
      await action();
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : fallbackError);
    } finally {
      setAccountBusy(null);
    }
  }

  if (!today) {
    const emptyBody =
      bootStatus === "loading"
        ? "Loading your planning foundation."
        : goals.length === 0
          ? "Start with a goal. Ambitions will shape the first day from there."
          : "Your goals are here, but today has not been generated yet. Open Plan to rebuild it.";

    return (
      <Screen>
        <View className="gap-4">
          <TodayHeader
            liveContext={false}
            dateLabel={bootStatus === "error" ? "Unable to load plan" : formatLongDate(planDate)}
          />
          <EmptyStateCard
            title={bootStatus === "loading" ? "Loading today" : "No plan yet"}
            body={emptyBody}
            tone="sunken"
            action={
              bootStatus !== "loading" ? (
                <View className="flex-row gap-3 pt-1">
                  <Button style={{ flex: 1 }} onPress={() => navigation.navigate("Goals" as never)}>
                    Go to goals
                  </Button>
                  <Button
                    tone="tertiary"
                    style={{ flex: 1 }}
                    onPress={() => navigation.navigate("Plan" as never)}
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

  return (
    <Screen>
      <View className="gap-8">
        <TodayHeader
          dateLabel={formatLongDate(today.date)}
          liveContext={today.integration.usingLiveCalendar}
        />

        <Surface tone="accent" className="gap-6">
          <View className="gap-3">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Right now
            </AppText>
            <AppText variant="title">{today.focus}</AppText>
            <AppText tone="secondary" style={{ maxWidth: 330 }}>
              {today.adaptiveGuidance[0] ?? "Start with the easiest meaningful move."}
            </AppText>
          </View>

          <MetaLine
            items={[
              `${today.blocks.length} sessions`,
              `${today.progress.completed} done`,
              `${today.replanSuggestions.length} fallback options`,
              today.integration.usingLiveCalendar ? "Live context on" : "Saved baseline mode",
            ]}
          />

          {nextBlock ? (
            <View
              className="gap-2 rounded-[18px] px-4 py-4"
              style={{
                backgroundColor: theme.colors.background.elevated,
                borderWidth: 1,
                borderColor: theme.colors.border.strong,
              }}
            >
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Next up
              </AppText>
              <AppText variant="section">{nextBlock.title}</AppText>
              <AppText tone="secondary">
                {formatTimeLabel(nextBlock.startsAt)}
                {nextBlock.state === "active" ? " in progress now." : " is the next session."}
              </AppText>
            </View>
          ) : null}

          <View
            className="gap-2 rounded-[18px] px-4 py-4"
            style={{
              backgroundColor: theme.colors.background.elevated,
              borderWidth: 1,
              borderColor: theme.colors.border.strong,
            }}
          >
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Stay steady
            </AppText>
            <AppText tone="secondary">
              {today.replanSuggestions.length > 0
                ? "If the day slips, recover with the lightest useful adjustment."
                : "The schedule has enough room to stay steady without extra reshuffling."}
            </AppText>
          </View>
        </Surface>

        <TimelinePlan
          blocks={today.blocks}
          onTaskAction={handleTaskAction}
          busyTaskId={busyTaskId}
        />

        <View className="gap-4 px-1">
          <View className="gap-2">
            <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
              Keep the day steady
            </AppText>
            <AppText variant="section">Context that supports execution</AppText>
            <AppText tone="secondary">
              Capacity, setup, and continuity stay nearby without competing with the work itself.
            </AppText>
          </View>

          <CapacityInsight capacity={today.capacity} focus={today.focus} />

          <Surface tone="sunken" className="gap-4">
            <View className="gap-2">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Context
              </AppText>
              <AppText variant="section">Surrounding conditions</AppText>
              <AppText tone="secondary">{today.integration.calendarDetail}</AppText>
            </View>
            {today.adaptiveGuidance.length > 1 ? (
              <MetaLine items={today.adaptiveGuidance.slice(1, 3)} />
            ) : null}
            <ScheduleContext items={today.scheduleContext} />
          </Surface>

          <IntegrationStatusCard
            calendarConnectionState={calendarConnectionState}
            notificationPermissionStatus={notificationPermissionStatus}
            onRequestCalendarAccess={() =>
              runIntegrationAction(
                "calendar",
                requestCalendarAccess,
                "Calendar access could not be refreshed.",
              )
            }
            onRequestNotificationAccess={() =>
              runIntegrationAction(
                "notifications",
                requestNotificationAccess,
                "Notification access could not be refreshed.",
              )
            }
            onRefreshIntegration={() =>
              runIntegrationAction(
                "refresh",
                () => refreshIntegration(today.date),
                "Calendar context could not be refreshed.",
              )
            }
            usingLiveCalendar={today.integration.usingLiveCalendar}
            calendarDetail={today.integration.calendarDetail}
            busyAction={
              integrationBusy === "calendar" ||
              integrationBusy === "notifications" ||
              integrationBusy === "refresh"
                ? integrationBusy
                : null
            }
          />

          <AccountStatusCard
            account={account}
            authState={authState}
            attachmentState={attachmentState}
            syncState={syncState}
            conflicts={syncConflicts}
            busyAction={
              accountBusy === "sign_in" ||
              accountBusy === "attach" ||
              accountBusy === "sync" ||
              accountBusy === "defer"
                ? (accountBusy as "sign_in" | "attach" | "sync" | "defer")
                : null
            }
            onSignIn={() =>
              runAccountAction("sign_in", signInWithApple, "Sign in with Apple could not start.")
            }
            onAttach={() =>
              runAccountAction(
                "attach",
                attachLocalDataToAccount,
                "Local data could not be attached to the account.",
              )
            }
            onDefer={() =>
              runAccountAction(
                "defer",
                deferLocalDataAttachment,
                "The local-only path could not be preserved.",
              )
            }
            onSync={() =>
              runAccountAction("sync", () => syncAccountData(), "Account sync could not complete.")
            }
          />

          {pendingReviewGoals.length > 0 ? (
            <Surface tone="sunken" className="gap-3">
              <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                Pending review
              </AppText>
              <AppText variant="section">{pendingReviewGoals[0]?.title}</AppText>
              <AppText tone="secondary">
                A change is ready for review before it replaces the current plan.
              </AppText>
              <MetaLine
                items={[
                  `${pendingReviewGoals.length} goal${pendingReviewGoals.length === 1 ? "" : "s"} waiting`,
                ]}
              />
              <Button onPress={() => navigation.navigate("Plan" as never)}>
                Review changes
              </Button>
            </Surface>
          ) : null}
        </View>

        {runtimeMessage || integrationBusy ? (
          <Surface tone="sunken">
            <View className="gap-2">
              {runtimeMessage ? <AppText tone="secondary">{runtimeMessage}</AppText> : null}
              {integrationBusy ? (
                <AppText tone="tertiary" variant="caption">
                  Updating live context...
                </AppText>
              ) : null}
            </View>
          </Surface>
        ) : null}
      </View>
    </Screen>
  );
}

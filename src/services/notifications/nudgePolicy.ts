import { ReminderType, Task, TaskStatus, TimeBlock } from "../../domain/models";
import { SchedulingOutput } from "../../engines";

import { NotificationDraft, NotificationPlanContext } from "./types";

function parseIso(value: string) {
  return new Date(value);
}

function minutesBetween(start: Date, end: Date) {
  return Math.max(0, Math.round((end.getTime() - start.getTime()) / 60000));
}

function withLeadTime(startsAt: string, leadTimeMinutes: number) {
  return new Date(parseIso(startsAt).getTime() - (leadTimeMinutes * 60 * 1000));
}

function isWithinQuietHours(date: Date, quietHoursStart: string | null, quietHoursEnd: string | null) {
  if (!quietHoursStart || !quietHoursEnd) {
    return false;
  }

  const minutes = (date.getHours() * 60) + date.getMinutes();
  const [startHour, startMinute] = quietHoursStart.split(":").map(Number);
  const [endHour, endMinute] = quietHoursEnd.split(":").map(Number);
  const quietStart = (startHour * 60) + startMinute;
  const quietEnd = (endHour * 60) + endMinute;

  if (quietStart <= quietEnd) {
    return minutes >= quietStart && minutes < quietEnd;
  }

  return minutes >= quietStart || minutes < quietEnd;
}

function nextPendingTask(tasks: Task[], timeBlocks: TimeBlock[], block: TimeBlock) {
  const taskById = new Map(tasks.map((task) => [task.id, task]));

  return block.taskId ? taskById.get(block.taskId) ?? null : null;
}

function buildTaskReminders(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.TimeBlockStart && item.enabled,
  );

  if (!preference) {
    return;
  }

  const upcomingBlocks = context.timeBlocks
    .filter((block) => block.taskId)
    .sort((left, right) => left.startsAtDateTime.localeCompare(right.startsAtDateTime))
    .slice(0, 2);

  for (const block of upcomingBlocks) {
    const triggerDate = withLeadTime(block.startsAtDateTime, preference.leadTimeMinutes);

    if (triggerDate <= now || isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)) {
      continue;
    }

    const task = nextPendingTask(context.tasks, context.timeBlocks, block);
    if (!task || [TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status)) {
      continue;
    }

    drafts.push({
      id: `task-reminder-${block.id}`,
      kind: "task_reminder",
      title: "Upcoming block",
      body: `${block.title} starts in ${preference.leadTimeMinutes} minutes.`,
      scheduledAt: triggerDate.toISOString(),
      metadata: {
        blockId: block.id,
        taskId: task.id,
      },
    });
  }
}

function isFutureDate(target: Date, now: Date) {
  return target.getTime() > now.getTime();
}

function buildMorningRitualReminder(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.MorningStart && item.enabled,
  );

  if (!preference || context.dailyRitual?.openedAt) {
    return;
  }

  const [hour, minute] = context.productPreferences.schedule.workdayStart.split(":").map(Number);
  const triggerDate = new Date(`${context.date}T00:00:00`);
  triggerDate.setHours(hour, minute - preference.leadTimeMinutes, 0, 0);

  if (
    !isFutureDate(triggerDate, now) ||
    isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)
  ) {
    return;
  }

  drafts.push({
    id: `morning-ritual-${context.date}`,
    kind: "morning_ritual",
    title: "Open the day",
    body: "Take a quiet minute to see today's shape before the day starts moving.",
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      date: context.date,
    },
  });
}

function buildEveningCloseReminder(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.EveningClose && item.enabled,
  );

  if (!preference || context.dailyRitual?.closedAt) {
    return;
  }

  const [hour, minute] = context.productPreferences.schedule.workdayEnd.split(":").map(Number);
  const triggerDate = new Date(`${context.date}T00:00:00`);
  triggerDate.setHours(hour, minute - preference.leadTimeMinutes, 0, 0);

  if (
    !isFutureDate(triggerDate, now) ||
    isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)
  ) {
    return;
  }

  drafts.push({
    id: `evening-close-${context.date}`,
    kind: "evening_close",
    title: "Close the day",
    body: "A short closeout will capture what moved and what should happen next.",
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      date: context.date,
    },
  });
}

function buildRecoveryPrompt(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.RecoveryPrompt && item.enabled,
  );

  if (!preference || !context.schedule || !context.dailyRitual?.openedAt || context.dailyRitual.closedAt) {
    return;
  }

  const overdueTasks = context.tasks.filter((task) =>
    [TaskStatus.Missed, TaskStatus.Deferred, TaskStatus.Split, TaskStatus.Substituted].includes(
      task.status,
    ),
  ).length;
  const openMinutes = context.schedule.capacitySummary.unusedCapacityMinutes;
  const alreadyRecoveredRecently =
    context.dailyRitual.recoveryMoments.at(-1)?.occurredAt &&
    now.getTime() - new Date(context.dailyRitual.recoveryMoments.at(-1)!.occurredAt).getTime() <
      90 * 60 * 1000;

  if (
    alreadyRecoveredRecently ||
    (overdueTasks < 2 && !(context.schedule.signals.overloadWarning && openMinutes >= 30))
  ) {
    return;
  }

  const triggerDate = new Date(now.getTime() + 3 * 60 * 1000);
  if (isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)) {
    return;
  }

  drafts.push({
    id: `recovery-prompt-${context.date}`,
    kind: "recovery_prompt",
    title: "Reset the rest of the day",
    body: "Ambitions can salvage what still matters without rebuilding the whole day.",
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      date: context.date,
    },
  });
}

function buildWeeklyReviewReminder(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.WeeklyReview && item.enabled,
  );

  if (!preference) {
    return;
  }

  const reviewDate = new Date(`${context.date}T12:00:00`);
  if (reviewDate.getDay() !== context.productPreferences.weeklyReviewDay) {
    return;
  }

  const [hour, minute] = context.productPreferences.weeklyReviewTime.split(":").map(Number);
  const triggerDate = new Date(`${context.date}T00:00:00`);
  triggerDate.setHours(hour, minute - preference.leadTimeMinutes, 0, 0);

  if (
    !isFutureDate(triggerDate, now) ||
    isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)
  ) {
    return;
  }

  if (
    context.weeklyReviewState?.reviewedAt &&
    (!context.productPreferences.autoPromptNextWeekShaping || context.nextWeekReviewState?.nextWeekShapedAt)
  ) {
    return;
  }

  const body = context.weeklyReviewState?.reviewedAt
    ? "Shape next week while the current week is still fresh."
    : "Take a quiet weekly read before unfinished work quietly rolls forward.";

  drafts.push({
    id: `weekly-review-${context.date}`,
    kind: "weekly_review",
    title: context.weeklyReviewState?.reviewedAt ? "Shape next week" : "Weekly review",
    body,
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      date: context.date,
      weekStartDate: context.weeklyReviewState?.weekStartDate ?? context.date,
    },
  });
}

function buildMonthlyReviewReminder(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  const preference = context.preferences.find(
    (item) => item.reminderType === ReminderType.MonthlyReview && item.enabled,
  );

  if (!preference) {
    return;
  }

  const reviewDate = new Date(`${context.date}T12:00:00`);
  const reviewDay = Number(context.productPreferences.monthlyReviewDay ?? 1);
  if (reviewDate.getDate() !== reviewDay) {
    return;
  }

  const [hour, minute] = context.productPreferences.monthlyReviewTime.split(":").map(Number);
  const triggerDate = new Date(`${context.date}T00:00:00`);
  triggerDate.setHours(hour, minute - preference.leadTimeMinutes, 0, 0);

  if (
    !isFutureDate(triggerDate, now) ||
    isWithinQuietHours(triggerDate, preference.quietHoursStart, preference.quietHoursEnd)
  ) {
    return;
  }

  if (
    context.monthlyReviewState?.reviewedAt &&
    (!context.productPreferences.autoPromptNextMonthShaping || context.nextMonthReviewState?.strategySetAt)
  ) {
    return;
  }

  const body = context.monthlyReviewState?.reviewedAt
    ? "Set next month while this month is still readable."
    : "Take a calm monthly read before pressure quietly carries itself forward.";

  drafts.push({
    id: `monthly-review-${context.date}`,
    kind: "monthly_review",
    title: context.monthlyReviewState?.reviewedAt ? "Shape next month" : "Monthly review",
    body,
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      date: context.date,
      monthStartDate: context.monthlyReviewState?.monthStartDate ?? context.date.slice(0, 8) + "01",
    },
  });
}

function buildStartSmallNudge(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  if (!context.schedule) {
    return;
  }

  const firstLargeBlock = context.timeBlocks
    .filter((block) => {
      const task = block.taskId ? context.tasks.find((entry) => entry.id === block.taskId) : null;
      return task && task.estimatedMinutes >= 25;
    })
    .sort((left, right) => left.startsAtDateTime.localeCompare(right.startsAtDateTime))[0];

  if (!firstLargeBlock) {
    return;
  }

  const task = context.tasks.find((entry) => entry.id === firstLargeBlock.taskId);
  if (!task) {
    return;
  }

  const triggerDate = withLeadTime(firstLargeBlock.startsAtDateTime, 8);
  if (triggerDate <= now) {
    return;
  }

  drafts.push({
    id: `start-small-${firstLargeBlock.id}`,
    kind: "start_small_nudge",
    title: "Keep the entry light",
    body: `Start ${task.title.toLowerCase()} with the 10-minute step first.`,
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      blockId: firstLargeBlock.id,
      taskId: task.id,
    },
  });
}

function buildFreeWindowNudge(
  context: NotificationPlanContext,
  now: Date,
  drafts: NotificationDraft[],
) {
  if (!context.schedule) {
    return;
  }

  const candidateWindow = context.schedule.usableWindows
    .filter((window) => window.minutes >= 20 && window.minutes <= 40)
    .find((window) => parseIso(window.start) > now);
  const candidateTask = context.tasks.find(
    (task) =>
      [TaskStatus.Unscheduled, TaskStatus.Deferred, TaskStatus.Split, TaskStatus.Substituted].includes(
        task.status,
      ) && task.estimatedMinutes <= 25,
  );

  if (!candidateWindow || !candidateTask) {
    return;
  }

  const triggerDate = new Date(parseIso(candidateWindow.start).getTime() - (5 * 60 * 1000));
  if (triggerDate <= now) {
    return;
  }

  drafts.push({
    id: `free-window-${candidateTask.id}`,
    kind: "free_window_nudge",
    title: "Brief opening",
    body: `You have ${candidateWindow.minutes} minutes free. Good time for ${candidateTask.title.toLowerCase()}.`,
    scheduledAt: triggerDate.toISOString(),
    metadata: {
      taskId: candidateTask.id,
      windowId: candidateWindow.id,
    },
  });
}

export function buildNotificationDrafts(context: NotificationPlanContext) {
  const now = new Date();
  const drafts: NotificationDraft[] = [];

  buildMorningRitualReminder(context, now, drafts);
  buildTaskReminders(context, now, drafts);
  buildStartSmallNudge(context, now, drafts);
  buildFreeWindowNudge(context, now, drafts);
  buildRecoveryPrompt(context, now, drafts);
  buildEveningCloseReminder(context, now, drafts);
  buildWeeklyReviewReminder(context, now, drafts);
  buildMonthlyReviewReminder(context, now, drafts);

  return drafts
    .sort((left, right) => left.scheduledAt.localeCompare(right.scheduledAt))
    .filter((draft, index, items) => {
      if (index === 0) {
        return true;
      }

      const previous = parseIso(items[index - 1].scheduledAt);
      const current = parseIso(draft.scheduledAt);
      return minutesBetween(previous, current) >= 20;
    })
    .slice(0, 3);
}

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

  buildTaskReminders(context, now, drafts);
  buildStartSmallNudge(context, now, drafts);
  buildFreeWindowNudge(context, now, drafts);

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

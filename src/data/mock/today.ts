import { CapacityProfile, DailyPlan } from "../models";

export const mockCapacity: CapacityProfile = {
  mentalLoad: "balanced",
  focusBudgetMinutes: 185,
  meetingLoadMinutes: 70,
};

export const mockDailyPlan: DailyPlan = {
  date: "2026-04-11",
  focus: "Protect uninterrupted morning work and keep the afternoon lighter.",
  blocks: [
    {
      id: "block-1",
      title: "Weekly plan refinement",
      startsAt: "08:30",
      endsAt: "09:10",
      energy: "steady",
      state: "complete",
      note: "Clarify two commitments before the day accelerates.",
    },
    {
      id: "block-2",
      title: "Ambitions product architecture",
      startsAt: "09:30",
      endsAt: "11:15",
      energy: "deep",
      state: "scheduled",
      note: "High-focus build window for core structure decisions.",
    },
    {
      id: "block-3",
      title: "Admin and response sweep",
      startsAt: "11:45",
      endsAt: "12:15",
      energy: "light",
      state: "scheduled",
      note: "Use the narrow window instead of letting it bleed outward.",
    },
    {
      id: "block-4",
      title: "Calendar recovery buffer",
      startsAt: "15:30",
      endsAt: "16:00",
      energy: "light",
      state: "rolled",
      note: "Reserved in case the earlier day runs long.",
    },
  ],
};

export const mockScheduleContext = [
  { label: "Existing events", value: "2 meetings, 70 min total" },
  { label: "Best deep work window", value: "09:30-11:15" },
  { label: "Last realistic finish", value: "17:40 without overload" },
];

export const mockAdaptiveGuidance = [
  "Protect the first deep block instead of overcommitting the afternoon.",
  "Keep the recovery buffer open; your rollover rate rises when late tasks stack.",
];

export const mockProgress = {
  completed: 1,
  scheduled: 2,
  rolled: 1,
};

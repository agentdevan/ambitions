import { create } from "zustand";

import {
  mockAdaptiveGuidance,
  mockCapacity,
  mockDailyPlan,
  mockProgress,
  mockScheduleContext,
} from "../data/mock/today";

interface AppState {
  bootstrapped: boolean;
  today: {
    capacity: typeof mockCapacity;
    plan: typeof mockDailyPlan;
    scheduleContext: typeof mockScheduleContext;
    adaptiveGuidance: typeof mockAdaptiveGuidance;
    progress: typeof mockProgress;
  };
  markBootstrapped: () => void;
}

export const useAppStore = create<AppState>((set) => ({
  bootstrapped: false,
  today: {
    capacity: mockCapacity,
    plan: mockDailyPlan,
    scheduleContext: mockScheduleContext,
    adaptiveGuidance: mockAdaptiveGuidance,
    progress: mockProgress,
  },
  markBootstrapped: () => set({ bootstrapped: true }),
}));

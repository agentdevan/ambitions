import { NavigatorScreenParams } from "@react-navigation/native";

export type TodayStackParamList = {
  TodayHome: undefined;
  TodayTimeline: undefined;
  TodaySessionDetail: { blockId: string };
  TodayOpenTime: undefined;
  TodayCapacity: undefined;
  TodayContext: undefined;
};

export type GoalsStackParamList = {
  GoalsHome: undefined;
  GoalDetail: { goalId: string };
  GoalMilestones: { goalId: string };
  GoalProgress: { goalId: string };
  GoalHistory: { goalId: string };
  GoalEdit: { goalId?: string };
};

export type PlanStackParamList = {
  PlanHome: undefined;
  PlanReview: { goalId?: string };
  PlanDetail: undefined;
  PlanStructure: { goalId?: string };
};

export type InsightsStackParamList = {
  InsightsHome: undefined;
  InsightContinuity: undefined;
  InsightActivity: undefined;
  InsightPlanChanges: undefined;
  InsightCapacity: undefined;
};

export type ProfileStackParamList = {
  ProfileHome: undefined;
  ProfileHistory: undefined;
  ProfileAccount: undefined;
  ProfileAppearance: undefined;
  ProfileScheduleDefaults: undefined;
  ProfileIntegrations: undefined;
  ProfileNotifications: undefined;
  ProfilePlanningPreferences: undefined;
};

export type RootTabParamList = {
  Today: NavigatorScreenParams<TodayStackParamList>;
  Goals: NavigatorScreenParams<GoalsStackParamList>;
  Plan: NavigatorScreenParams<PlanStackParamList>;
  Insights: NavigatorScreenParams<InsightsStackParamList>;
  Profile: NavigatorScreenParams<ProfileStackParamList>;
};

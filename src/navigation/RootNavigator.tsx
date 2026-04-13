import { Ionicons } from "@expo/vector-icons";
import { StackActions } from "@react-navigation/native";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { Text } from "react-native";

import { useResolvedTheme } from "../design/theme/useResolvedTheme";
import { GoalsScreen } from "../screens/goals/GoalsScreen";
import {
  AmbitionDetailScreen,
  AmbitionEditScreen,
} from "../screens/goals/AmbitionDetailScreens";
import {
  GoalDetailScreen,
  GoalHistoryScreen,
  GoalMilestonesScreen,
  GoalProgressScreen,
} from "../screens/goals/GoalDetailScreens";
import { GoalComposerScreen } from "../screens/goals/GoalComposerScreen";
import { InsightsScreen } from "../screens/insights/InsightsScreen";
import {
  InsightActivityScreen,
  InsightCapacityScreen,
  InsightContinuityScreen,
  InsightMonthlyReviewScreen,
  InsightPlanChangesScreen,
} from "../screens/insights/InsightDetailScreens";
import { OnboardingScreen } from "../screens/onboarding/OnboardingScreen";
import { PlanScreen } from "../screens/plan/PlanScreen";
import {
  PlanDetailScreen,
  PlanReviewScreen,
  PlanStructureScreen,
} from "../screens/plan/PlanDetailScreens";
import { ProfileScreen } from "../screens/profile/ProfileScreen";
import {
  ProfileAccountScreen,
  ProfileAppearanceScreen,
  ProfileHistoryScreen,
  ProfileIntegrationsScreen,
  ProfileNotificationsScreen,
  ProfilePlanningPreferencesScreen,
  ProfileScheduleDefaultsScreen,
} from "../screens/profile/ProfileDetailScreens";
import { TodayScreen } from "../screens/today/TodayScreen";
import {
  TodayCapacityScreen,
  TodayContextScreen,
  TodayOpenTimeScreen,
  TodaySessionDetailScreen,
  TodayTimelineScreen,
} from "../screens/today/TodayDetailScreens";
import { useAppStore } from "../state/useAppStore";
import {
  GoalsStackParamList,
  InsightsStackParamList,
  PlanStackParamList,
  ProfileStackParamList,
  RootTabParamList,
  TodayStackParamList,
} from "./types";

const Tab = createBottomTabNavigator<RootTabParamList>();
const TodayStack = createNativeStackNavigator<TodayStackParamList>();
const GoalsStack = createNativeStackNavigator<GoalsStackParamList>();
const PlanStack = createNativeStackNavigator<PlanStackParamList>();
const InsightsStack = createNativeStackNavigator<InsightsStackParamList>();
const ProfileStack = createNativeStackNavigator<ProfileStackParamList>();

const iconMap: Record<
  keyof RootTabParamList,
  { inactive: keyof typeof Ionicons.glyphMap; active: keyof typeof Ionicons.glyphMap }
> = {
  Today: { inactive: "today-outline", active: "today" },
  Goals: { inactive: "flag-outline", active: "flag" },
  Plan: { inactive: "layers-outline", active: "layers" },
  Insights: { inactive: "analytics-outline", active: "analytics" },
  Profile: { inactive: "person-circle-outline", active: "person-circle" },
};

function useStackOptions() {
  const theme = useResolvedTheme();

  return {
    gestureEnabled: true,
    headerShadowVisible: false,
    headerBackTitleVisible: false,
    headerBackButtonDisplayMode: "minimal" as const,
    headerTintColor: theme.colors.text.primary,
    headerStyle: {
      backgroundColor: theme.colors.background.canvas,
    },
    headerTitleStyle: {
      fontSize: 18,
      fontWeight: "700" as const,
      letterSpacing: -0.35,
    },
    contentStyle: {
      backgroundColor: theme.colors.background.canvas,
    },
  };
}

function TodayNavigator() {
  const stackOptions = useStackOptions();

  return (
    <TodayStack.Navigator screenOptions={stackOptions}>
      <TodayStack.Screen
        name="TodayHome"
        component={TodayScreen}
        options={{ headerShown: false }}
      />
      <TodayStack.Screen
        name="TodayTimeline"
        component={TodayTimelineScreen}
        options={{ title: "Today Timeline" }}
      />
      <TodayStack.Screen
        name="TodaySessionDetail"
        component={TodaySessionDetailScreen}
        options={{ title: "Session" }}
      />
      <TodayStack.Screen
        name="TodayOpenTime"
        component={TodayOpenTimeScreen}
        options={{ title: "Open Window" }}
      />
      <TodayStack.Screen
        name="TodayCapacity"
        component={TodayCapacityScreen}
        options={{ title: "Capacity" }}
      />
      <TodayStack.Screen
        name="TodayContext"
        component={TodayContextScreen}
        options={{ title: "Calendar & Context" }}
      />
    </TodayStack.Navigator>
  );
}

function GoalsNavigator() {
  const stackOptions = useStackOptions();

  return (
    <GoalsStack.Navigator screenOptions={stackOptions}>
      <GoalsStack.Screen
        name="GoalsHome"
        component={GoalsScreen}
        options={{ headerShown: false }}
      />
      <GoalsStack.Screen
        name="AmbitionDetail"
        component={AmbitionDetailScreen}
        options={{ title: "Ambition" }}
      />
      <GoalsStack.Screen
        name="AmbitionEdit"
        component={AmbitionEditScreen}
        options={({ route }) => ({ title: route.params?.ambitionId ? "Edit Ambition" : "New Ambition" })}
      />
      <GoalsStack.Screen
        name="GoalDetail"
        component={GoalDetailScreen}
        options={{ title: "Goal" }}
      />
      <GoalsStack.Screen
        name="GoalMilestones"
        component={GoalMilestonesScreen}
        options={{ title: "Milestones" }}
      />
      <GoalsStack.Screen
        name="GoalProgress"
        component={GoalProgressScreen}
        options={{ title: "Goal Progress" }}
      />
      <GoalsStack.Screen
        name="GoalHistory"
        component={GoalHistoryScreen}
        options={{ title: "Goal History" }}
      />
      <GoalsStack.Screen
        name="GoalEdit"
        component={GoalComposerScreen}
        options={({ route }) => ({ title: route.params?.goalId ? "Edit Goal" : "New Goal" })}
      />
    </GoalsStack.Navigator>
  );
}

function PlanNavigator() {
  const stackOptions = useStackOptions();

  return (
    <PlanStack.Navigator screenOptions={stackOptions}>
      <PlanStack.Screen
        name="PlanHome"
        component={PlanScreen}
        options={{ headerShown: false }}
      />
      <PlanStack.Screen
        name="PlanReview"
        component={PlanReviewScreen}
        options={{ title: "Goal Review" }}
      />
      <PlanStack.Screen
        name="PlanDetail"
        component={PlanDetailScreen}
        options={{ title: "Plan Detail" }}
      />
      <PlanStack.Screen
        name="PlanStructure"
        component={PlanStructureScreen}
        options={{ title: "Structure" }}
      />
    </PlanStack.Navigator>
  );
}

function InsightsNavigator() {
  const stackOptions = useStackOptions();

  return (
    <InsightsStack.Navigator screenOptions={stackOptions}>
      <InsightsStack.Screen
        name="InsightsHome"
        component={InsightsScreen}
        options={{ headerShown: false }}
      />
      <InsightsStack.Screen
        name="InsightMonthlyReview"
        component={InsightMonthlyReviewScreen}
        options={{ title: "Monthly Review" }}
      />
      <InsightsStack.Screen
        name="InsightContinuity"
        component={InsightContinuityScreen}
        options={{ title: "Continuity" }}
      />
      <InsightsStack.Screen
        name="InsightActivity"
        component={InsightActivityScreen}
        options={{ title: "Recent Activity" }}
      />
      <InsightsStack.Screen
        name="InsightPlanChanges"
        component={InsightPlanChangesScreen}
        options={{ title: "Plan Movement" }}
      />
      <InsightsStack.Screen
        name="InsightCapacity"
        component={InsightCapacityScreen}
        options={{ title: "Capacity" }}
      />
    </InsightsStack.Navigator>
  );
}

function ProfileNavigator() {
  const stackOptions = useStackOptions();

  return (
    <ProfileStack.Navigator
      screenOptions={{
        ...stackOptions,
        headerBackTitle: "Profile",
        headerBackButtonDisplayMode: "minimal",
      }}
    >
      <ProfileStack.Screen
        name="ProfileHome"
        component={ProfileScreen}
        options={{ headerShown: false }}
      />
      <ProfileStack.Screen
        name="ProfileHistory"
        component={ProfileHistoryScreen}
        options={{ title: "Recent Movement" }}
      />
      <ProfileStack.Screen
        name="ProfileAppearance"
        component={ProfileAppearanceScreen}
        options={{ title: "Appearance" }}
      />
      <ProfileStack.Screen
        name="ProfileScheduleDefaults"
        component={ProfileScheduleDefaultsScreen}
        options={{ title: "Schedule Defaults" }}
      />
      <ProfileStack.Screen
        name="ProfileIntegrations"
        component={ProfileIntegrationsScreen}
        options={{ title: "Integrations" }}
      />
      <ProfileStack.Screen
        name="ProfileNotifications"
        component={ProfileNotificationsScreen}
        options={{ title: "Notifications" }}
      />
      <ProfileStack.Screen
        name="ProfilePlanningPreferences"
        component={ProfilePlanningPreferencesScreen}
        options={{ title: "Planning Preferences" }}
      />
      <ProfileStack.Screen
        name="ProfileAccount"
        component={ProfileAccountScreen}
        options={{ title: "Account" }}
      />
    </ProfileStack.Navigator>
  );
}

export function RootNavigator() {
  const theme = useResolvedTheme();
  const onboardingCompleted = useAppStore(
    (state) => state.productPreferences?.onboardingCompleted ?? false,
  );

  function buildRetapListener() {
    return ({ navigation, route }: { navigation: any; route: any }) => ({
      tabPress: (event: any) => {
        if (!navigation.isFocused()) {
          return;
        }

        const nestedState = route.state;
        if (nestedState?.index > 0 && nestedState?.key) {
          event.preventDefault();
          navigation.dispatch({
            ...StackActions.popToTop(),
            target: nestedState.key,
          });
        }
      },
    });
  }

  if (!onboardingCompleted) {
    return <OnboardingScreen />;
  }

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: theme.colors.tabBar.active,
        tabBarInactiveTintColor: theme.colors.tabBar.inactive,
        tabBarActiveBackgroundColor: theme.colors.tabBar.pill,
        tabBarHideOnKeyboard: true,
        tabBarStyle: {
          backgroundColor: theme.colors.tabBar.background,
          borderTopColor: theme.colors.tabBar.border,
          borderTopWidth: 1,
          height: 88,
          paddingTop: 10,
          paddingBottom: 14,
          paddingHorizontal: 10,
          shadowColor: theme.colors.shadow.color,
          shadowOpacity: theme.mode === "dark" ? 0.28 : 0.08,
          shadowRadius: theme.mode === "dark" ? 18 : 14,
          shadowOffset: { width: 0, height: -6 },
          elevation: 18,
        },
        tabBarItemStyle: {
          marginHorizontal: 6,
          marginVertical: 6,
          borderRadius: 22,
        },
        tabBarLabel: ({ focused, color, children }) => (
          <Text
            style={{
              color,
              fontSize: focused ? 11.5 : 10.5,
              fontWeight: focused ? "800" : "700",
              letterSpacing: focused ? 0.2 : 0.1,
              marginTop: 2,
            }}
          >
            {children}
          </Text>
        ),
        tabBarIcon: ({ color, size, focused }) => (
          <Ionicons
            color={color}
            name={focused ? iconMap[route.name].active : iconMap[route.name].inactive}
            size={focused ? size + 2 : size}
          />
        ),
        sceneStyle: {
          backgroundColor: theme.colors.background.canvas,
        },
      })}
    >
      <Tab.Screen
        name="Today"
        component={TodayNavigator}
        listeners={buildRetapListener()}
      />
      <Tab.Screen
        name="Goals"
        component={GoalsNavigator}
        listeners={buildRetapListener()}
      />
      <Tab.Screen
        name="Plan"
        component={PlanNavigator}
        listeners={buildRetapListener()}
      />
      <Tab.Screen
        name="Insights"
        component={InsightsNavigator}
        listeners={buildRetapListener()}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileNavigator}
        listeners={buildRetapListener()}
      />
    </Tab.Navigator>
  );
}

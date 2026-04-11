import {
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  ConstraintSource,
  ScheduleConstraint,
} from "../../domain/models";

function isFallbackConstraint(constraint: ScheduleConstraint) {
  return constraint.metadata.fallback === true || constraint.metadata.fallback === "true";
}

export function shouldUseLiveCalendar(connectionState: CalendarConnectionState | null) {
  return (
    connectionState?.permissionState === CalendarPermissionState.Granted &&
    connectionState.connectionStatus === CalendarSyncState.Ready
  );
}

export function selectConstraintsForScheduling(
  constraints: ScheduleConstraint[],
  connectionState: CalendarConnectionState | null,
) {
  if (!shouldUseLiveCalendar(connectionState)) {
    return constraints.filter((constraint) => constraint.source !== ConstraintSource.Calendar);
  }

  return constraints.filter((constraint) => !isFallbackConstraint(constraint));
}

import AmbitionsDesignSystem
import Foundation

struct TimeLifeSuiteProjector: Sendable {}

extension TimeLifeSuiteProjector {
    func project(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        mode: TimeSurfaceMode
    ) -> TimeLifeSuiteState {
        let shapes = [
            dayShape(weekDays: weekDays, calendarAwareness: calendarAwareness),
            weekShape(
                weekDays: weekDays,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                calendarAwareness: calendarAwareness,
                mode: mode
            ),
            lifeShape(activeGoalCount: activeGoalCount, calendarAwareness: calendarAwareness)
        ]
        return TimeLifeSuiteState(
            title: "Shape Time",
            subtitle: "Open time, goal time, protected time, pressure, source state, and user choice stay inspectable.",
            shapes: shapes,
            field: lifeShapeField(
                shapes: shapes,
                weekDays: weekDays,
                calendarAwareness: calendarAwareness,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                mode: mode
            ),
            drillDown: lifeShapeDrillDown(
                weekDays: weekDays,
                activeGoalCount: activeGoalCount,
                openCaptureCount: openCaptureCount
            ),
            calendarBoundaryLabel: calendarAwareness.canRequestCalendarRead ? "Calendar stays optional" : "Manual shaping still works",
            manualFallbackLabel: "User choice available",
            trustLabel: "No silent calendar changes"
        )
    }

}

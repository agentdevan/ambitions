import Foundation

public enum TodayFlagshipCalibrationFixture {
    private enum TimelineDensity: Equatable {
        case standard
        case quiet
        case dense
        case veryDense
    }

    /// Synthetic evaluation content. This fixture is not canon, runtime truth,
    /// persistence proof, or a production screenshot baseline.
    public static let preparingForBaby = makePreparingForBaby()

    private static func makePreparingForBaby(
        longContent: Bool = false,
        timelineDensity: TimelineDensity = .standard,
        contextCondition: TodayFlagshipContextCondition? = nil,
        inverseEligible: Bool = false
    ) -> TodayFlagshipCalibrationContent {
        let proposal = TodayFlagshipStillCountsProposal(
            outcomeTitle: "Still counts",
            proposedTruth: "I primed the wall and tested the new color.",
            settledTruth: "I primed the wall and tested the new color.",
            exactConsequence: "This Step will leave Start Here and remain visible in Today.",
            affectedLineage: "Welcome our baby home",
            proofRequirement: "A history entry will be saved on this device.",
            createsProof: true,
            createsReceipt: true,
            appearsInHistory: true,
            inverseAvailable: inverseEligible,
            commitActionTitle: "Record progress"
        )
        let primaryTitle = longContent
            ? "Make the nursery ready for the crib before protected family time begins"
            : "Make the nursery ready for the crib"
        let primaryStep = TodayFlagshipStepSnapshot(
            id: "step.nursery-ready-for-crib",
            title: primaryTitle,
            parentPursuitID: "goal.welcome-baby-home",
            parentPursuitTitle: "Welcome our baby home",
            currentAcceptedTruth: "The corner is cleared and the paint sample is chosen.",
            whyItFitsNow: "This is the smallest useful step before protected family time.",
            materialConsequence: "It keeps the room moving without taking over the evening.",
            startHereSummary: "A small move now keeps the nursery moving and family time protected.",
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "2:00 PM",
                relationship: "Available now · before 2:00 PM handoff",
                owner: "Time"
            ),
            primaryActionTitle: "Continue nursery setup",
            stillCountsProposal: proposal
        )
        let revealedStep = TodayFlagshipStepSnapshot(
            id: "step.send-launch-brief",
            title: longContent
                ? "Send the launch brief that keeps the meaningful work commitment on track"
                : "Send the launch brief",
            parentPursuitID: "goal.meaningful-work-commitment",
            parentPursuitTitle: "Keep the launch promise",
            currentAcceptedTruth: "The brief is drafted and waiting for one final read.",
            whyItFitsNow: "The nursery progress is recorded and the 2:00 PM handoff is next.",
            materialConsequence: "Sending it protects the work promise without entering family time.",
            startHereSummary: "One final read protects the work promise before family time.",
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "2:00 PM",
                relationship: "Fixed work handoff",
                owner: "Time"
            ),
            primaryActionTitle: "Review launch brief",
            stillCountsProposal: proposal
        )
        var timeline: [TodayFlagshipTimelineObject]
        switch timelineDensity {
        case .standard:
            timeline = baseTimeline
        case .quiet:
            timeline = quietTimeline
        case .dense, .veryDense:
            timeline = baseTimeline
            timeline.insert(
                TodayFlagshipTimelineObject(
                    id: "timeline.prenatal-appointment-notes",
                    canonicalObjectID: "step.prenatal-appointment-notes",
                    objectTitle: "Bring appointment notes",
                    timeLabel: "1:10 PM",
                    relationship: "Baby preparation · Health",
                    acceptedState: "Protected health context",
                    isProtected: true,
                    role: .protected
                ),
                at: 1
            )
            timeline.append(
                TodayFlagshipTimelineObject(
                    id: "timeline.family-dinner",
                    canonicalObjectID: "event.family-dinner",
                    objectTitle: "Family dinner",
                    timeLabel: "6:30 PM",
                    relationship: "Protected family time",
                    acceptedState: "Protected",
                    isProtected: true,
                    isFixed: true,
                    role: .protected
                )
            )

            if timelineDensity == .veryDense {
                timeline.append(contentsOf: veryDenseAdditions)
                timeline.sort { lhs, rhs in
                    let lhsIndex = veryDenseTimelineOrder.firstIndex(of: lhs.id) ?? .max
                    let rhsIndex = veryDenseTimelineOrder.firstIndex(of: rhs.id) ?? .max
                    return lhsIndex < rhsIndex
                }
            }
        }

        if contextCondition == .staleExternalContext,
           let staleIndex = timeline.firstIndex(where: {
               $0.canonicalObjectID == revealedStep.id
           }) {
            let staleItem = timeline[staleIndex]
            timeline[staleIndex] = TodayFlagshipTimelineObject(
                id: staleItem.id,
                canonicalObjectID: staleItem.canonicalObjectID,
                objectTitle: staleItem.objectTitle,
                timeLabel: staleItem.timeLabel,
                relationship: staleItem.relationship,
                acceptedState: staleItem.acceptedState,
                role: .external
            )
        }

        let contextSeam = makeContextSeam(
            condition: contextCondition,
            primaryStep: primaryStep,
            revealedStep: revealedStep
        )
        let receipt = TodayFlagshipReceiptSnapshot(
            id: "receipt.step.nursery-ready-for-crib.still-counts",
            historyID: "history.step.nursery-ready-for-crib",
            recordedLabel: "Recorded on this device",
            receiptSummary: "Meaningful nursery progress recorded",
            historySummary: proposal.settledTruth,
            proofLabel: "Added to Welcome our baby home"
        )

        return TodayFlagshipCalibrationContent(
            familyID: "today-flagship/preparing-for-baby/still-counts/v1",
            isSynthetic: true,
            interfaceCopy: englishInterfaceCopy,
            presentContext: TodayFlagshipPresentContext(
                dateISO8601: "2026-07-23",
                relationship: "Thursday · Home before dinner",
                crownTitle: "Today"
            ),
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStep,
            timeline: timeline,
            receipt: receipt,
            returnContract: TodayFlagshipReturnContract(
                settledStepID: "step.nursery-ready-for-crib",
                newStartHereStepID: "step.send-launch-brief",
                focusAnchorID: "today.settled.step.nursery-ready-for-crib",
                settledLocationTitle: "Progress recorded today"
            ),
            recovery: TodayFlagshipRecoverySnapshot(
                stepID: "step.nursery-ready-for-crib",
                interruptionTitle: "Pick up where you left off",
                interruptionDetail: "Your saved progress is still here.",
                lastSavedProgress: proposal.settledTruth,
                availableChoices: [
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.continue-saved-progress",
                        title: "Continue where you left off",
                        consequence: "Return to this Step with your saved work in place."
                    ),
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.keep-step",
                        title: "Leave this for later",
                        consequence: "Keep this Step and saved work for later."
                    )
                ]
            ),
            contextSeam: contextSeam,
            supporting: makeSupportingSnapshots(
                primaryStep: primaryStep,
                receipt: receipt,
                inverseEligible: inverseEligible
            )
        )
    }

    private static func makeSupportingSnapshots(
        primaryStep: TodayFlagshipStepSnapshot,
        receipt: TodayFlagshipReceiptSnapshot,
        inverseEligible: Bool
    ) -> TodayFlagshipSupportingSnapshots {
        TodayFlagshipSupportingSnapshots(
            goal: TodayFlagshipGoalContextSnapshot(
                id: primaryStep.parentPursuitID,
                title: primaryStep.parentPursuitTitle,
                whyItMatters: "Prepare a calm, safe home for the baby and the family welcoming them.",
                currentPosture: "The nursery is moving forward in small, protected steps.",
                nextStepID: primaryStep.id
            ),
            timeTransfer: TodayFlagshipTimeTransferSnapshot(
                title: "Open in Time?",
                body: "Exact chronology changes belong in Time. This evaluation does not provide that route.",
                sourceOwner: "Today",
                destinationOwner: "Time",
                isReadOnly: true,
                isHostEvaluationOnly: true,
                isProductRouteAvailable: false
            ),
            history: TodayFlagshipHistoryEntrySnapshot(
                id: receipt.historyID,
                recordedAtISO8601: "2026-07-23T10:30:00-04:00",
                recordedTruth: primaryStep.stillCountsProposal.settledTruth,
                stepID: primaryStep.id,
                goalID: primaryStep.parentPursuitID,
                isLocalOnly: true
            ),
            inverse: TodayFlagshipInverseSnapshot(
                commandID: "CMD-TODAY-DETAIL-CLOSURE-REVIEW-001-INVERSE",
                title: "Reopen Still counts Step",
                triggerReceiptID: receipt.id,
                currentReceiptID: inverseEligible ? receipt.id : nil,
                stepRevisionIsCurrent: inverseEligible,
                dependenciesAreCurrent: inverseEligible,
                hasNewerDependentCommand: false,
                preservesHistory: true
            ),
            commitFailure: TodayFlagshipCommitFailureSnapshot(
                affectedStepID: primaryStep.id,
                title: "Progress wasn’t recorded",
                body: "Your current truth is unchanged. You can try again or return to the Step.",
                retryTitle: "Try again",
                dismissTitle: "Return to Step",
                preservesAcceptedTruth: true
            )
        )
    }

    private static func makeArabicSupportingSnapshots(
        primaryStep: TodayFlagshipStepSnapshot,
        receipt: TodayFlagshipReceiptSnapshot
    ) -> TodayFlagshipSupportingSnapshots {
        TodayFlagshipSupportingSnapshots(
            goal: TodayFlagshipGoalContextSnapshot(
                id: primaryStep.parentPursuitID,
                title: primaryStep.parentPursuitTitle,
                whyItMatters: "نُهيّئ بيتًا هادئًا وآمنًا لطفلنا ولعائلتنا.",
                currentPosture: "تتقدّم الغرفة بخطوات صغيرة تحمي وقت العائلة.",
                nextStepID: primaryStep.id
            ),
            timeTransfer: TodayFlagshipTimeTransferSnapshot(
                title: "الفتح في الوقت غير متاح هنا",
                body: "تعديل التوقيت الدقيق يخص الوقت، ولا يوفّر هذا التقييم مسارًا إليه.",
                sourceOwner: "اليوم",
                destinationOwner: "الوقت",
                isReadOnly: true,
                isHostEvaluationOnly: true,
                isProductRouteAvailable: false
            ),
            history: TodayFlagshipHistoryEntrySnapshot(
                id: receipt.historyID,
                recordedAtISO8601: "2026-07-23T10:30:00-04:00",
                recordedTruth: primaryStep.stillCountsProposal.settledTruth,
                stepID: primaryStep.id,
                goalID: primaryStep.parentPursuitID,
                isLocalOnly: true
            ),
            inverse: TodayFlagshipInverseSnapshot(
                commandID: "CMD-TODAY-DETAIL-CLOSURE-REVIEW-001-INVERSE",
                title: "أعد فتح خطوة ما زال يُحتسب",
                triggerReceiptID: receipt.id,
                currentReceiptID: nil,
                stepRevisionIsCurrent: false,
                dependenciesAreCurrent: false,
                hasNewerDependentCommand: false,
                preservesHistory: true
            ),
            commitFailure: TodayFlagshipCommitFailureSnapshot(
                affectedStepID: primaryStep.id,
                title: "لم يُسجّل التقدّم",
                body: "حالتك الحالية لم تتغيّر. يمكنك المحاولة مجددًا أو العودة إلى الخطوة.",
                retryTitle: "حاول مجددًا",
                dismissTitle: "العودة إلى الخطوة",
                preservesAcceptedTruth: true
            )
        )
    }

    private static let baseTimeline: [TodayFlagshipTimelineObject] = [
        TodayFlagshipTimelineObject(
            id: "timeline.nursery-paint-sample",
            canonicalObjectID: "step.nursery-paint-sample",
            objectTitle: "Paint the nursery sample",
            timeLabel: "10:30 AM",
            relationship: "Baby preparation · Home",
            acceptedState: "Ready now",
            role: .ordinary
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.work-launch-brief",
            canonicalObjectID: "step.send-launch-brief",
            objectTitle: "Send the launch brief",
            timeLabel: "2:00 PM",
            relationship: "One meaningful work commitment",
            acceptedState: "Fixed",
            isFixed: true,
            role: .fixed
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.family-prenatal-walk",
            canonicalObjectID: "event.family-prenatal-walk",
            objectTitle: "Take the prenatal walk together",
            timeLabel: "5:30 PM",
            relationship: "Family time · Health",
            acceptedState: "Protected",
            isProtected: true,
            role: .protected
        )
    ]

    private static let quietTimeline: [TodayFlagshipTimelineObject] = [
        TodayFlagshipTimelineObject(
            id: "timeline.open-afternoon",
            canonicalObjectID: "lane.open-afternoon",
            objectTitle: "Room for what matters",
            timeLabel: "3:00 PM",
            relationship: "Flexible before family time",
            acceptedState: "Open",
            isOpenLane: true,
            role: .openLane
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.family-prenatal-walk",
            canonicalObjectID: "event.family-prenatal-walk",
            objectTitle: "Take the prenatal walk together",
            timeLabel: "5:30 PM",
            relationship: "Family time · Health",
            acceptedState: "Protected",
            isProtected: true,
            role: .protected
        )
    ]

    private static let veryDenseTimelineOrder = [
        "timeline.nursery-paint-sample",
        "timeline.midwife-call",
        "timeline.open-lunch-lane",
        "timeline.prenatal-appointment-notes",
        "timeline.work-launch-brief",
        "timeline-order-crib-sheet",
        "timeline-work-close",
        "timeline.family-prenatal-walk",
        "timeline.family-dinner",
        "timeline-family-call"
    ]

    private static let veryDenseAdditions: [TodayFlagshipTimelineObject] = [
        TodayFlagshipTimelineObject(
            id: "timeline.midwife-call",
            canonicalObjectID: "event.midwife-call",
            objectTitle: "Midwife check-in",
            timeLabel: "11:40 AM",
            relationship: "External health context",
            acceptedState: "Last known time",
            role: .external
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.open-lunch-lane",
            canonicalObjectID: "lane.open-lunch",
            objectTitle: "Open lane before the handoff",
            timeLabel: "12:20 PM",
            relationship: "Flexible capacity",
            acceptedState: "Open",
            isOpenLane: true,
            role: .openLane
        ),
        TodayFlagshipTimelineObject(
            id: "timeline-order-crib-sheet",
            canonicalObjectID: "step.order-crib-sheet",
            objectTitle: "Order the crib sheet",
            timeLabel: "3:20 PM",
            relationship: "Welcome our baby home",
            acceptedState: "Fits later",
            role: .ordinary
        ),
        TodayFlagshipTimelineObject(
            id: "timeline-family-call",
            canonicalObjectID: "event.family-call",
            objectTitle: "Call the grandparents",
            timeLabel: "7:15 PM",
            relationship: "Protected family connection",
            acceptedState: "Protected",
            isProtected: true,
            role: .protected
        ),
        TodayFlagshipTimelineObject(
            id: "timeline-work-close",
            canonicalObjectID: "event.work-close",
            objectTitle: "Close the workday",
            timeLabel: "4:45 PM",
            relationship: "Meaningful work boundary",
            acceptedState: "Fixed",
            isFixed: true,
            role: .fixed
        )
    ]

    private static func makeContextSeam(
        condition: TodayFlagshipContextCondition?,
        primaryStep: TodayFlagshipStepSnapshot,
        revealedStep: TodayFlagshipStepSnapshot
    ) -> TodayFlagshipContextSeamSnapshot? {
        guard let condition else { return nil }

        switch condition {
        case .offlineLocalTruth:
            return TodayFlagshipContextSeamSnapshot(
                condition: condition,
                title: englishInterfaceCopy.offlineLocalTitle,
                body: englishInterfaceCopy.offlineLocalBody,
                affectedObjectID: primaryStep.id,
                ownerTitle: englishInterfaceCopy.todayNavigationTitle,
                accessibilityLabel: "Available on this device. Your saved nursery progress is still here."
            )
        case .staleExternalContext:
            return TodayFlagshipContextSeamSnapshot(
                condition: condition,
                title: englishInterfaceCopy.staleExternalTitle,
                body: englishInterfaceCopy.staleExternalBody,
                affectedObjectID: revealedStep.id,
                ownerTitle: englishInterfaceCopy.todayNavigationTitle,
                accessibilityLabel: "Work context may be out of date. The launch handoff remains visible with its last known time."
            )
        case .conflictTransfer:
            return TodayFlagshipContextSeamSnapshot(
                condition: condition,
                title: englishInterfaceCopy.conflictTransferTitle,
                body: englishInterfaceCopy.conflictTransferBody,
                affectedObjectID: primaryStep.id,
                ownerTitle: englishInterfaceCopy.timeNavigationTitle,
                accessibilityLabel: "The nursery Step still belongs before family time. Its placement review belongs in Time."
            )
        }
    }

    private static let englishInterfaceCopy = TodayFlagshipInterfaceCopy(
        localeIdentifier: "en-US",
        startHereTitle: "Start Here",
        stepTitle: "Step",
        rightNowTitle: "Right now",
        whyItFitsTitle: "Why it fits now",
        consequenceTitle: "What this protects",
        reviewTitle: "Record this progress?",
        reviewChangeTitle: "What will change",
        reviewRelationshipTitle: "Also updates",
        detailsTitle: "Details",
        historyTrustCue: "A history entry will be saved on this device.",
        cancelTitle: "Not now",
        savingTitle: "Recording progress",
        savingBody: "Your current status remains unchanged until this finishes.",
        settlementTitle: "Progress recorded",
        settlementRelationshipPrefix: "Added to",
        viewHistoryTitle: "View history",
        returnTodayTitle: "Return to Today",
        recoveryEntryTitle: "Pick up where you left off",
        recoveryTitle: "Pick up where you left off",
        recoveryBody: "Your saved progress is still here.",
        timelineTitle: "Today’s Timeline",
        ambitionsWordmark: "Ambitions",
        todayAccessibilityHeading: "Today",
        nowAnchorTitle: "Now",
        nextFixedAnchorTitle: "Next fixed",
        protectedAnchorTitle: "Protected",
        openLaneAnchorTitle: "Open lane",
        viewFullDayTitle: "View Full Day",
        fullDayTitle: "Full Day",
        scrollToNowTitle: "Scroll to Now",
        rootsGroupTitle: "Roots",
        globalActionsGroupTitle: "Global actions",
        selectedRootValue: "Selected root",
        openNavigationHint: "Shows roots and global actions",
        closeNavigationHint: "Closes navigation",
        partOfRelationshipPrefix: "Part of",
        todayNavigationTitle: "Today",
        goalsNavigationTitle: "Goals",
        timeNavigationTitle: "Time",
        youNavigationTitle: "You",
        searchNavigationTitle: "Search",
        captureNavigationTitle: "Capture",
        timeOwnerTitle: "Time",
        offlineLocalTitle: "Available on this device",
        offlineLocalBody: "Your saved nursery progress is still here.",
        staleExternalTitle: "Work context may be out of date",
        staleExternalBody: "The launch handoff remains visible with its last known time.",
        conflictTransferTitle: "Nursery placement needs a closer look",
        conflictTransferBody: "The nursery Step still belongs before family time. Review its placement in Time.",
        savingAnnouncement: "Recording progress",
        settlementAnnouncement: "Progress recorded",
        interruptionAnnouncement: "Progress paused",
        recoveryAnnouncement: "Saved progress is ready",
        returnAnnouncement: "Returned to the recorded nursery progress in Today",
        timelineContextTitle: "Your day, in context",
        openStartHereHint: "Opens this Step without changing it",
        fallbackTodayTitle: "Today",
        fallbackTodayBody: "That object is no longer here. Today remains available.",
        stillCountsRationale: "Keep the useful progress without marking the Step done.",
        chooseOutcomeTitle: "Choose an outcome",
        reviewStillCountsHint: "Reviews what Still counts will change",
        lastSavedProgressTitle: "Last saved progress",
        addedToRelationshipTitle: "Added to",
        historyAvailableDetail: "History is available on this device.",
        recordIdentifierPrefix: "Record",
        returnTodayHint: "Returns to the recorded Step in Today",
        interruptedStepTitle: "Progress paused",
        receiptAvailableDetail: "A local record is available.",
        savedHistoryDetail: "The history entry stays on this device.",
        commitProgressHint: "Records this progress for the Step",
        cancelReviewHint: "Keeps the current Step unchanged",
        openNavigationLabel: "Open navigation",
        navigationCommandsHint: "Shows Today, Goals, Time, You, Search, and Capture",
        closeNavigationLabel: "Close navigation",
        currentStateAccessibilityTitle: "Current",
        proposedStateAccessibilityTitle: "Proposed",
        settledStateAccessibilityTitle: "Settled",
        interruptedStateAccessibilityTitle: "Interrupted"
    )
}

public extension TodayFlagshipCalibrationContent {
    var longContent: Self {
        TodayFlagshipCalibrationFixture.makeLongContent()
    }

    var denseToday: Self {
        TodayFlagshipCalibrationFixture.makeDenseToday()
    }

    var quietToday: Self {
        TodayFlagshipCalibrationFixture.makeQuietToday()
    }

    var veryDenseToday: Self {
        TodayFlagshipCalibrationFixture.makeVeryDenseToday()
    }

    var offlineLocalTruth: Self {
        TodayFlagshipCalibrationFixture.makeOfflineLocalTruth()
    }

    var staleExternalContext: Self {
        TodayFlagshipCalibrationFixture.makeStaleExternalContext()
    }

    var conflictTransfer: Self {
        TodayFlagshipCalibrationFixture.makeConflictTransfer()
    }

    var undoAvailableEvaluation: Self {
        TodayFlagshipCalibrationFixture.makeUndoAvailableEvaluation()
    }

    var arabicSaudiEvaluation: Self {
        TodayFlagshipCalibrationFixture.makeArabicSaudiEvaluation()
    }
}

private extension TodayFlagshipCalibrationFixture {
    static func makeLongContent() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(longContent: true)
    }

    static func makeDenseToday() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(timelineDensity: .dense)
    }

    static func makeQuietToday() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(timelineDensity: .quiet)
    }

    static func makeVeryDenseToday() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(timelineDensity: .veryDense)
    }

    static func makeOfflineLocalTruth() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(contextCondition: .offlineLocalTruth)
    }

    static func makeStaleExternalContext() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(contextCondition: .staleExternalContext)
    }

    static func makeConflictTransfer() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(contextCondition: .conflictTransfer)
    }

    static func makeUndoAvailableEvaluation() -> TodayFlagshipCalibrationContent {
        makePreparingForBaby(inverseEligible: true)
    }

    static func makeArabicSaudiEvaluation() -> TodayFlagshipCalibrationContent {
        let locale = Locale(identifier: "ar_SA")
        let timeZone = TimeZone(identifier: "America/New_York") ?? .gmt
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let date = calendar.date(
            from: DateComponents(year: 2026, month: 7, day: 23, hour: 16, minute: 30)
        ) ?? Date(timeIntervalSince1970: 1_785_353_400)
        let dateText = date.formatted(
            Date.FormatStyle(
                date: .complete,
                time: .omitted,
                locale: locale,
                calendar: calendar,
                timeZone: timeZone
            )
        )

        func localizedTime(hour: Int, minute: Int) -> String {
            let value = calendar.date(
                from: DateComponents(year: 2026, month: 7, day: 23, hour: hour, minute: minute)
            ) ?? date
            return value.formatted(
                Date.FormatStyle(
                    date: .omitted,
                    time: .shortened,
                    locale: locale,
                    calendar: calendar,
                    timeZone: timeZone
                )
            )
        }

        let copy = TodayFlagshipInterfaceCopy(
            localeIdentifier: "ar-SA",
            startHereTitle: "ابدأ من هنا",
            stepTitle: "خطوة",
            rightNowTitle: "الآن",
            whyItFitsTitle: "لماذا يناسب الآن",
            consequenceTitle: "ما الذي يحميه",
            reviewTitle: "هل تريد تسجيل هذا التقدّم؟",
            reviewChangeTitle: "ما الذي سيتغيّر",
            reviewRelationshipTitle: "يحدّث أيضًا",
            detailsTitle: "التفاصيل",
            historyTrustCue: "سيُحفظ إدخال في السجل على هذا الجهاز.",
            cancelTitle: "ليس الآن",
            savingTitle: "جارٍ تسجيل التقدّم",
            savingBody: "تبقى حالتك الحالية كما هي حتى يكتمل الحفظ.",
            settlementTitle: "تم تسجيل التقدّم",
            settlementRelationshipPrefix: "أُضيف إلى",
            viewHistoryTitle: "عرض السجل",
            returnTodayTitle: "العودة إلى اليوم",
            recoveryEntryTitle: "تابع من حيث توقفت",
            recoveryTitle: "تابع من حيث توقفت",
            recoveryBody: "ما حفظته من تقدّم ما زال هنا.",
            timelineTitle: "ما تبقّى اليوم",
            ambitionsWordmark: "Ambitions S10",
            todayAccessibilityHeading: "اليوم",
            nowAnchorTitle: "الآن",
            nextFixedAnchorTitle: "الموعد الثابت التالي",
            protectedAnchorTitle: "محمي",
            openLaneAnchorTitle: "وقت متاح",
            viewFullDayTitle: "عرض اليوم كاملًا",
            fullDayTitle: "اليوم كاملًا",
            scrollToNowTitle: "الانتقال إلى الآن",
            rootsGroupTitle: "الجذور",
            globalActionsGroupTitle: "الإجراءات العامة",
            selectedRootValue: "الجذر المحدد",
            openNavigationHint: "يعرض الجذور والإجراءات العامة",
            closeNavigationHint: "يغلق التنقل",
            partOfRelationshipPrefix: "جزء من",
            todayNavigationTitle: "اليوم",
            goalsNavigationTitle: "الأهداف",
            timeNavigationTitle: "الوقت",
            youNavigationTitle: "أنت",
            searchNavigationTitle: "البحث",
            captureNavigationTitle: "التقاط",
            timeOwnerTitle: "الوقت",
            offlineLocalTitle: "متاح على هذا الجهاز",
            offlineLocalBody: "ما حفظته من تقدّم في تجهيز الغرفة ما زال هنا.",
            staleExternalTitle: "قد يكون سياق العمل قديمًا",
            staleExternalBody: "يبقى تسليم الموجز ظاهرًا بآخر وقت معروف.",
            conflictTransferTitle: "يحتاج الوقت إلى مراجعة أدق",
            conflictTransferBody: "يبقى وقت العائلة محميًا هنا.",
            savingAnnouncement: "جارٍ تسجيل التقدّم",
            settlementAnnouncement: "تم تسجيل التقدّم",
            interruptionAnnouncement: "توقف التقدّم مؤقتًا",
            recoveryAnnouncement: "التقدّم المحفوظ جاهز",
            returnAnnouncement: "عُدت إلى تقدّم الغرفة المسجّل في اليوم",
            timelineContextTitle: "يومك في سياقه",
            openStartHereHint: "يفتح هذه الخطوة من دون تغييرها",
            fallbackTodayTitle: "اليوم",
            fallbackTodayBody: "لم يعد هذا العنصر هنا، وما زال اليوم متاحًا.",
            stillCountsRationale: "احتفظ بالتقدّم المفيد من دون إنهاء الخطوة.",
            chooseOutcomeTitle: "اختر نتيجة",
            reviewStillCountsHint: "يراجع ما سيتغيّر عند احتساب التقدّم",
            lastSavedProgressTitle: "آخر تقدّم محفوظ",
            addedToRelationshipTitle: "أُضيف إلى",
            historyAvailableDetail: "السجل متاح على هذا الجهاز.",
            recordIdentifierPrefix: "سجل",
            returnTodayHint: "يعود إلى الخطوة المسجّلة في اليوم",
            interruptedStepTitle: "توقف التقدّم مؤقتًا",
            receiptAvailableDetail: "يتوفر سجل محلي.",
            savedHistoryDetail: "يبقى إدخال السجل على هذا الجهاز.",
            commitProgressHint: "يسجّل هذا التقدّم للخطوة",
            cancelReviewHint: "يبقي الخطوة الحالية من دون تغيير",
            openNavigationLabel: "فتح التنقل",
            navigationCommandsHint: "يعرض اليوم والأهداف والوقت وأنت والبحث والالتقاط",
            closeNavigationLabel: "إغلاق التنقل",
            currentStateAccessibilityTitle: "الحالي",
            proposedStateAccessibilityTitle: "المقترح",
            settledStateAccessibilityTitle: "المستقر",
            interruptedStateAccessibilityTitle: "المتوقف"
        )
        let proposal = TodayFlagshipStillCountsProposal(
            outcomeTitle: "ما زال يُحتسب",
            proposedTruth: "سجّل إخلاء الزاوية واختيار عيّنة الطلاء كتقدّم ذي معنى.",
            settledTruth: "إخلاء الزاوية واختيار عيّنة الطلاء يُحتسبان الآن ضمن تجهيز الغرفة.",
            exactConsequence: "ستغادر هذه الخطوة «ابدأ من هنا» وتبقى ظاهرة في اليوم.",
            affectedLineage: "نستقبل طفلنا في منزلنا",
            proofRequirement: "سيُحفظ إدخال في السجل على هذا الجهاز.",
            createsProof: true,
            createsReceipt: true,
            appearsInHistory: true,
            inverseAvailable: false,
            commitActionTitle: "سجّل التقدّم"
        )
        let primaryStep = TodayFlagshipStepSnapshot(
            id: "step.nursery-ready-for-crib",
            title: "جهّز زاوية سرير الطفل في Ambitions S10",
            parentPursuitID: "goal.welcome-baby-home",
            parentPursuitTitle: "نستقبل طفلنا في منزلنا",
            currentAcceptedTruth: "أُخليت الزاوية واختيرت عيّنة الطلاء.",
            whyItFitsNow: "هذه أصغر خطوة مفيدة قبل وقت العائلة المحمي.",
            materialConsequence: (
                "تحافظ هذه الخطوة الهادئة على تقدّم تجهيز الغرفة من دون أن تستحوذ على المساء، "
                    + "وتترك وقت العائلة والمشي الصحي كما خُطّط لهما."
            ),
            startHereSummary: "خطوة صغيرة الآن تحافظ على تقدّم الغرفة ووقت العائلة المحمي.",
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: localizedTime(hour: 16, minute: 30),
                relationship: "قبل وقت العائلة",
                owner: "Time"
            ),
            primaryActionTitle: "تابع تجهيز غرفة الطفل",
            stillCountsProposal: proposal
        )
        let revealedStep = TodayFlagshipStepSnapshot(
            id: "step.send-launch-brief",
            title: "أرسل موجز الإطلاق",
            parentPursuitID: "goal.meaningful-work-commitment",
            parentPursuitTitle: "حافظ على وعد الإطلاق",
            currentAcceptedTruth: "الموجز مكتوب وينتظر مراجعة أخيرة.",
            whyItFitsNow: "سُجّل تقدّم الغرفة، والتسليم التالي في الموعد المحدد.",
            materialConsequence: "إرساله يحمي وعد العمل من دون أن يدخل في وقت العائلة.",
            startHereSummary: "مراجعة أخيرة تحمي وعد العمل قبل وقت العائلة.",
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: localizedTime(hour: 14, minute: 0),
                relationship: "لاحقًا اليوم",
                owner: "Time"
            ),
            primaryActionTitle: "راجع موجز الإطلاق",
            stillCountsProposal: proposal
        )
        let timeline = [
            TodayFlagshipTimelineObject(
                id: "timeline.nursery-paint-sample",
                canonicalObjectID: "step.nursery-paint-sample",
                objectTitle: "اطلِ عيّنة لون غرفة الطفل",
                timeLabel: localizedTime(hour: 10, minute: 30),
                relationship: "الاستعداد للطفل · المنزل",
                acceptedState: "جاهزة الآن"
            ),
            TodayFlagshipTimelineObject(
                id: "timeline.work-launch-brief",
                canonicalObjectID: "step.send-launch-brief",
                objectTitle: "أرسل موجز الإطلاق",
                timeLabel: localizedTime(hour: 14, minute: 0),
                relationship: "التزام عمل مهم",
                acceptedState: "موعد ثابت",
                isFixed: true
            ),
            TodayFlagshipTimelineObject(
                id: "timeline.family-prenatal-walk",
                canonicalObjectID: "event.family-prenatal-walk",
                objectTitle: "امشيا معًا قبل الولادة",
                timeLabel: localizedTime(hour: 17, minute: 30),
                relationship: "وقت العائلة · الصحة",
                acceptedState: "وقت محمي",
                isProtected: true
            )
        ]

        let receipt = TodayFlagshipReceiptSnapshot(
            id: "receipt.step.nursery-ready-for-crib.still-counts",
            historyID: "history.step.nursery-ready-for-crib",
            recordedLabel: "حُفظ على هذا الجهاز",
            receiptSummary: "سُجّل تقدّم ذو معنى في تجهيز الغرفة",
            historySummary: proposal.settledTruth,
            proofLabel: "أُضيف إلى نستقبل طفلنا في منزلنا"
        )

        return TodayFlagshipCalibrationContent(
            familyID: "today-flagship/preparing-for-baby/still-counts/v1",
            isSynthetic: true,
            interfaceCopy: copy,
            presentContext: TodayFlagshipPresentContext(
                dateISO8601: "2026-07-23",
                relationship: "\(dateText) · في المنزل قبل العشاء",
                crownTitle: "اليوم"
            ),
            primaryStep: primaryStep,
            revealedStartHereStep: revealedStep,
            timeline: timeline,
            receipt: receipt,
            returnContract: TodayFlagshipReturnContract(
                settledStepID: "step.nursery-ready-for-crib",
                newStartHereStepID: "step.send-launch-brief",
                focusAnchorID: "today.settled.step.nursery-ready-for-crib",
                settledLocationTitle: "تقدّم سُجّل اليوم"
            ),
            recovery: TodayFlagshipRecoverySnapshot(
                stepID: "step.nursery-ready-for-crib",
                interruptionTitle: "تابع من حيث توقفت",
                interruptionDetail: "ما حفظته من تقدّم ما زال هنا.",
                lastSavedProgress: "أُخليت زاوية السرير وحُفظ قرار عيّنة الطلاء.",
                availableChoices: [
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.continue-saved-progress",
                        title: "تابع من حيث توقفت",
                        consequence: "عُد إلى الخطوة مع العمل المحفوظ."
                    ),
                    TodayFlagshipRecoveryChoice(
                        id: "recovery.keep-step",
                        title: "اترك هذا لوقت لاحق",
                        consequence: "احتفظ بالخطوة والعمل المحفوظ لوقت لاحق."
                    )
                ]
            ),
            supporting: makeArabicSupportingSnapshots(
                primaryStep: primaryStep,
                receipt: receipt
            )
        )
    }
}

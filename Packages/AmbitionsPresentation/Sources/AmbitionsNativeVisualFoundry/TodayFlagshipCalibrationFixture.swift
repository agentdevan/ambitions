import Foundation

public enum TodayFlagshipCalibrationFixture {
    /// Synthetic evaluation content. This fixture is not canon, runtime truth,
    /// persistence proof, or a production screenshot baseline.
    public static let preparingForBaby = makePreparingForBaby()

    private static func makePreparingForBaby(
        longContent: Bool = false,
        denseToday: Bool = false
    ) -> TodayFlagshipCalibrationContent {
        let proposal = TodayFlagshipStillCountsProposal(
            outcomeTitle: "Still counts",
            proposedTruth: "Record the cleared corner and paint sample as meaningful progress.",
            settledTruth: "The cleared corner and paint sample now count toward the nursery.",
            exactConsequence: "This Step will leave Start Here and remain visible in Today.",
            affectedLineage: "Welcome our baby home",
            proofRequirement: "A history entry will be saved on this device.",
            createsProof: true,
            createsReceipt: true,
            appearsInHistory: true,
            inverseAvailable: false,
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
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "4:30 PM",
                relationship: "Before family time",
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
            temporalContext: TodayFlagshipTemporalContext(
                exactTime: "2:00 PM",
                relationship: "Fixed work handoff",
                owner: "Time"
            ),
            primaryActionTitle: "Review launch brief",
            stillCountsProposal: proposal
        )
        var timeline = baseTimeline
        if denseToday {
            timeline.insert(
                TodayFlagshipTimelineObject(
                    id: "timeline.prenatal-appointment-notes",
                    canonicalObjectID: "step.prenatal-appointment-notes",
                    objectTitle: "Bring appointment notes",
                    timeLabel: "1:10 PM",
                    relationship: "Baby preparation · Health",
                    acceptedState: "Protected health context",
                    isProtected: true
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
                    isFixed: true
                )
            )
        }

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
            receipt: TodayFlagshipReceiptSnapshot(
                id: "receipt.step.nursery-ready-for-crib.still-counts",
                historyID: "history.step.nursery-ready-for-crib",
                recordedLabel: "Recorded on this device",
                receiptSummary: "Meaningful nursery progress recorded",
                historySummary: "The cleared corner and paint sample now count toward the nursery.",
                proofLabel: "Added to Welcome our baby home"
            ),
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
                lastSavedProgress: "Cleared the crib corner and kept the paint sample decision.",
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
            acceptedState: "Ready now"
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.work-launch-brief",
            canonicalObjectID: "step.send-launch-brief",
            objectTitle: "Send the launch brief",
            timeLabel: "2:00 PM",
            relationship: "One meaningful work commitment",
            acceptedState: "Fixed",
            isFixed: true
        ),
        TodayFlagshipTimelineObject(
            id: "timeline.family-prenatal-walk",
            canonicalObjectID: "event.family-prenatal-walk",
            objectTitle: "Take the prenatal walk together",
            timeLabel: "5:30 PM",
            relationship: "Family time · Health",
            acceptedState: "Protected",
            isProtected: true
        )
    ]

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
        timelineTitle: "Today’s Timeline"
    )
}

public extension TodayFlagshipCalibrationContent {
    var longContent: Self {
        TodayFlagshipCalibrationFixture.makeLongContent()
    }

    var denseToday: Self {
        TodayFlagshipCalibrationFixture.makeDenseToday()
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
        makePreparingForBaby(denseToday: true)
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
            timelineTitle: "ما تبقّى اليوم"
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
            receipt: TodayFlagshipReceiptSnapshot(
                id: "receipt.step.nursery-ready-for-crib.still-counts",
                historyID: "history.step.nursery-ready-for-crib",
                recordedLabel: "حُفظ على هذا الجهاز",
                receiptSummary: "سُجّل تقدّم ذو معنى في تجهيز الغرفة",
                historySummary: proposal.settledTruth,
                proofLabel: "أُضيف إلى نستقبل طفلنا في منزلنا"
            ),
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
            )
        )
    }
}

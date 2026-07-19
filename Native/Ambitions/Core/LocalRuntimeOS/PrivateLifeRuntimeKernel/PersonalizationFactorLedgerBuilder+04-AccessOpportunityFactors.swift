import Foundation

extension PersonalizationFactorLedgerBuilder {
    func appendAccessAndOpportunityFactors(
        to factors: inout [PersonalizationFactorLedgerFactor],
        projection: LifeContextRuntimeProjection?,
        runtimeSelectedLabel: String
    ) {
        if let travelModel = projection?.travelModel {
            let transportLabel = travelModel.transportationAccess.rawValue.replacingOccurrences(of: "_", with: " ")
            let accessDetail = travelModel.locationLabel ?? "unknown location"
            let availabilityReason = travelModel.radiusMinutes.map { "\($0) minute travel window" } ?? "No travel radius captured"
            let travelFreshness = freshnessState(for: projection)

            factors.append(
                factor(
                    id: "factor.availability_window",
                    type: .availabilityWindow,
                    category: .timing,
                    reason: "\(availabilityReason) and \(accessDetail) shape what can happen now.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: PersonalizationFactorFreshnessProjection(
                        state: travelFreshness,
                        lastAffectedLabel: runtimeSelectedLabel,
                        needsReview: travelFreshness != .current,
                        reviewReason: travelFreshness == .current ? nil : "Travel and access should be reviewed."
                    ),
                    userControlled: true,
                    runtimeWeight: travelModel.radiusMinutes.map { max(0.3, min(1.0, Double($0) / 40.0)) } ?? 0.5,
                    affectedRecommendationArea: "Time fit",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use broader timing defaults until the travel window is known again.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue, travelModel.locationPrecision.rawValue]
                )
            )

            factors.append(
                factor(
                    id: "factor.travel_fit",
                    type: .travelFit,
                    category: .access,
                    reason: "Travel fit uses the current radius, precision, and access posture.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Travel fit", fallbackReason: "Travel fit should be rechecked when location precision changes."),
                    userControlled: true,
                    runtimeWeight: 0.9,
                    affectedRecommendationArea: "Travel fit",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Fall back to local-only opportunities and shorter windows.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue, travelModel.locationPrecision.rawValue, accessDetail]
                )
            )

            factors.append(
                factor(
                    id: "factor.transportation_constraint",
                    type: .transportationConstraint,
                    category: .access,
                    reason: "Transportation is \(transportLabel); that directly narrows what is reachable.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Transportation", fallbackReason: "Transportation should be reviewed when access changes."),
                    userControlled: true,
                    runtimeWeight: transportWeight(for: travelModel.transportationAccess),
                    affectedRecommendationArea: "Access and travel",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use neutral access assumptions until transportation is re-entered.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue]
                )
            )
        }

        if let anchors = projection?.availableOpportunityAnchors, anchors.isEmpty == false {
            let facilityLabels = anchors.map(\.title).sorted()
            factors.append(
                factor(
                    id: "factor.facility_access",
                    type: .facilityAccess,
                    category: .access,
                    reason: "Available facilities include \(facilityLabels.prefix(3).joined(separator: ", ")).",
                    source: sourceProjection(kind: .lifeContext, sourceID: "facilities", label: "Facilities & equipment", freshness: freshnessState(for: projection), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Facilities", fallbackReason: "Facility access should be rechecked before a recommendation changes."),
                    userControlled: true,
                    runtimeWeight: min(1, 0.5 + Double(anchors.count) * 0.1),
                    affectedRecommendationArea: "Facility access",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Only use facility-light recommendations until access is restored.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: anchors.map(\.id)
                )
            )

            let equipmentDetail = anchors.map(\.detail).joined(separator: " ")
            factors.append(
                factor(
                    id: "factor.equipment_access",
                    type: .equipmentAccess,
                    category: .access,
                    reason: equipmentDetail.isEmpty ? "Equipment access is not fully described yet." : "Equipment access is described by the current opportunity detail.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "equipment", label: "Facilities & equipment", freshness: freshnessState(for: projection), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Equipment", fallbackReason: "Equipment access should be refreshed when the opportunity detail changes."),
                    userControlled: true,
                    runtimeWeight: equipmentDetail.isEmpty ? 0.4 : 0.8,
                    affectedRecommendationArea: "Equipment fit",
                    allowedForRuntimeUse: equipmentDetail.isEmpty == false,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use equipment-light suggestions until gear access is explicit again.",
                    active: equipmentDetail.isEmpty == false,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: equipmentDetail.isEmpty ? .needsReview : .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [equipmentDetail]
                )
            )

            if anchors.contains(where: { $0.detail.localizedCaseInsensitiveContains("season") }) {
                factors.append(
                    factor(
                        id: "factor.seasonality",
                        type: .seasonality,
                        category: .timing,
                        reason: "The current opportunity detail includes seasonal availability.",
                        source: sourceProjection(kind: .lifeContext, sourceID: "seasonality", label: "Opportunity seasonality", freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Seasonality", fallbackReason: "Seasonal availability should be refreshed when the opportunity changes."),
                        userControlled: true,
                        runtimeWeight: 0.6,
                        affectedRecommendationArea: "Seasonality",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Assume year-round availability until seasonality is captured again.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: anchors.map(\.detail)
                    )
                )
            }
        }
    }
}

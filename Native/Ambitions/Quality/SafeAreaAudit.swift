import CoreGraphics
import Foundation

enum SafeAreaAudit {
    struct Report: Equatable {
        let findings: [String]

        var passed: Bool { findings.isEmpty }
    }

    static let owner = "Stage/StageSafeAreaPolicy"
    static let rule = "Surface files do not own root safe-area or keyboard clearance policy."

    static func audit(policy: StageChromePolicy) -> Report {
        var findings: [String] = []

        if policy.dockClearance < minimumInteractiveClearance {
            findings.append("Dock clearance must preserve the minimum interactive clearance.")
        }

        if policy.showsRootDock {
            if policy.stageContentBottomClearance < policy.dockClearance {
                findings.append("Root content must reserve at least the visible dock clearance.")
            }
            if policy.captureComposerClearance < policy.dockClearance {
                findings.append("Capture composer must not sit under the visible root dock.")
            }
            if policy.continuityReceiptBottomClearance < policy.dockClearance {
                findings.append("Continuity receipts must not sit under the visible root dock.")
            }
        } else {
            if policy.stageContentBottomClearance != 0 {
                findings.append("Routes without root dock must not reserve root dock bottom clearance.")
            }
            if policy.captureComposerClearance <= 0 {
                findings.append("Routes without root dock still need positive composer clearance.")
            }
            if policy.continuityReceiptBottomClearance <= 0 {
                findings.append("Routes without root dock still need positive receipt clearance.")
            }
        }

        if StageSafeAreaPolicy.drilldownBottomClearance(
            dynamicTypeIsAccessibilitySize: policy.dynamicTypeIsAccessibilitySize
        ) <= 0 {
            findings.append("Drilldown routes must keep a positive bottom gesture clearance.")
        }

        return Report(findings: findings)
    }

    static func auditDynamicTypeExpansion(
        regular: StageChromePolicy,
        accessibility: StageChromePolicy
    ) -> Report {
        var findings: [String] = []

        if accessibility.dockClearance <= regular.dockClearance {
            findings.append("Accessibility Dynamic Type must increase dock clearance.")
        }
        if accessibility.stageContentBottomClearance < regular.stageContentBottomClearance {
            findings.append("Accessibility Dynamic Type must not reduce stage bottom clearance.")
        }

        return Report(findings: findings)
    }

    private static let minimumInteractiveClearance: CGFloat = 44
}

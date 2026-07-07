import Foundation

extension AmbitionGraphSnapshot {
    func privacyClasses(
        for commitmentIDs: [String],
        proofIDs: [String],
        constraintIDs: [String]
    ) -> [AmbitionPrivacyClass] {
        let commitmentSet = Set(commitmentIDs)
        let proofSet = Set(proofIDs)
        let constraintSet = Set(constraintIDs)

        let commitmentClasses = commitments
            .filter { commitmentSet.contains($0.id) }
            .map { _ in AmbitionPrivacyClass.privateUserText }
        let proofClasses = proofs
            .filter { proofSet.contains($0.id) }
            .map(\.privacyClass)
        let constraintClasses = constraints
            .filter { constraintSet.contains($0.id) }
            .map(\.privacyClass)

        return commitmentClasses + proofClasses + constraintClasses + [ambition.privacyClass]
            .filter { $0 != .systemOwned }
    }
}

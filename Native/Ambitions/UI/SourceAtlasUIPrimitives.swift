import SwiftUI

public struct SourceBadge: View {
    let sourceState: String
    
    public init(sourceState: String) {
        self.sourceState = sourceState
    }
    
    public var body: some View {
        Text(sourceState)
            .font(.caption)
            .padding(4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
    }
}

public struct FreshnessBadge: View {
    let freshness: String
    
    public init(freshness: String) {
        self.freshness = freshness
    }
    
    public var body: some View {
        Text(freshness)
            .font(.caption)
            .padding(4)
            .background(Color.green.opacity(0.1))
            .cornerRadius(4)
    }
}

public struct SourceNeededFold: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Source Needed")
                .font(.headline)
            Text("This requirement is missing an official source.")
                .font(.subheadline)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8)
    }
}

public struct RequirementSourceFold: View {
    public init() {}
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Requirement Source")
                .font(.headline)
            SourceBadge(sourceState: "official")
        }
    }
}

public struct ClaimReviewDrawer: View {
    public init() {}
    public var body: some View {
        VStack {
            Text("Claim Review")
                .font(.title3)
            Text("Review required for this claim.")
        }
    }
}

public struct SourceBinderReviewSheet: View {
    public init() {}
    public var body: some View {
        Text("Source Binder Review")
    }
}

public struct PackUpdateReceipt: View {
    public init() {}
    public var body: some View {
        Text("Pack Updated")
    }
}

public struct PrivateSourceShield: View {
    public init() {}
    public var body: some View {
        HStack {
            Image(systemName: "lock.shield")
            Text("Private Source")
        }
        .foregroundColor(.secondary)
    }
}

public struct OCRReviewNotice: View {
    public init() {}
    public var body: some View {
        Text("OCR Review Needed")
            .foregroundColor(.orange)
    }
}

public struct SourceImpactReceipt: View {
    public init() {}
    public var body: some View {
        Text("Source Impact: Validated")
    }
}

public struct ProjectionReceiptFold: View {
    public init() {}
    public var body: some View {
        Text("Projection Receipt")
    }
}

public struct SkillSliceIndicator: View {
    public init() {}
    public var body: some View {
        Text("Skill Slice")
    }
}

public struct AlternativePathReceipt: View {
    public init() {}
    public var body: some View {
        Text("Alternative Path Available")
    }
}

public struct OptionValueFold: View {
    public init() {}
    public var body: some View {
        Text("Option Value Reserved")
    }
}

struct SourceAtlasUIPrimitives_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            SourceBadge(sourceState: "official")
            FreshnessBadge(freshness: "stale")
            SourceNeededFold()
            RequirementSourceFold()
            PrivateSourceShield()
            OCRReviewNotice()
        }
        .padding()
    }
}

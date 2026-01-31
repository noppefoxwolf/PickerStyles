import SwiftUI

public struct GaugeButton<Value: BinaryFloatingPoint>: View {
    public let value: Value
    public let range: ClosedRange<Value>
    public let threshold: Value?
    public let isSelected: Bool
    
    public init(value: Value, range: ClosedRange<Value>, threshold: Value? = nil, isSelected: Bool) {
        self.value = value
        self.range = range
        self.threshold = threshold
        self.isSelected = isSelected
    }
    
    public var body: some View {
        baseCircle
            .overlay {
                icon
            }
            .overlay {
                gaugeRing
            }
    }
}

private extension GaugeButton {
    var isBelowThreshold: Bool {
        guard let threshold else {
            return false
        }
        return value < threshold
    }

    var ringBaseColor: Color {
        let base = isBelowThreshold ? Color.secondary : Color.accentColor
        return base.opacity(0.2)
    }

    var ringProgressColor: Color {
        isBelowThreshold ? .secondary : .accentColor
    }

    var progress: Double {
        let span = range.upperBound - range.lowerBound
        guard span > .zero else {
            return 0
        }
        let normalized = (value - range.lowerBound) / span
        let raw = Double(normalized)
        guard raw.isFinite else {
            return 0
        }
        return min(max(raw, 0), 1)
    }
    
    @ViewBuilder
    var baseCircle: some View {
        Circle()
            .frame(width: 54, height: 54)
            .foregroundStyle(isSelected ? Color.black : Color.white)
    }
    
    @ViewBuilder
    var icon: some View {
        Image(systemName: "wand.and.sparkles.inverse")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(isSelected ? Color.white : Color.black)
    }
    
    @ViewBuilder
    var gaugeRing: some View {
        Circle()
            .stroke(ringBaseColor, lineWidth: 2)
            .overlay {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        ringProgressColor,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
    }
}

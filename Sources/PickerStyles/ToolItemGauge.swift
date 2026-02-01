import SwiftUI

public struct ToolItemGauge<Value: BinaryFloatingPoint>: View {
    public let value: Value
    public let range: ClosedRange<Value>
    public let threshold: Value?
    public let showsValue: Bool
    public let isSelected: Bool
    
    public init(
        value: Value,
        range: ClosedRange<Value>,
        threshold: Value? = nil,
        showsValue: Bool = false,
        isSelected: Bool
    ) {
        self.value = value
        self.range = range
        self.threshold = threshold
        self.showsValue = showsValue
        self.isSelected = isSelected
    }
    
    public var body: some View {
        baseCircle
            .overlay {
                content
            }
            .overlay {
                gaugeRing
            }
    }
}

private extension ToolItemGauge {
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
            .foregroundStyle(isSelected ? Color(red: 0.321, green: 0.321, blue: 0.321) : Color(red: 0.958, green: 0.958, blue: 0.958))
    }
    
    @ViewBuilder
    var content: some View {
        if showsValue {
            valueLabel
        } else {
            icon
        }
    }

    @ViewBuilder
    var icon: some View {
        Image(systemName: "wand.and.sparkles.inverse")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(isSelected ? Color.white : Color.black)
    }

    @ViewBuilder
    var valueLabel: some View {
        Text(Double(value), format: .number.precision(.fractionLength(2)))
            .font(.caption.weight(.semibold))
            .monospacedDigit()
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

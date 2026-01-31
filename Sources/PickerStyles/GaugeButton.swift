import SwiftUI

public struct GaugeButton<Value: BinaryFloatingPoint>: View {
    public let value: Value
    public let range: ClosedRange<Value>
    public let isSelected: Bool
    
    public init(value: Value, range: ClosedRange<Value>, isSelected: Bool) {
        self.value = value
        self.range = range
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
            .strokeBorder(.tertiary, lineWidth: 2)
            .overlay {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        .tint,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
    }
}

import SwiftUI

public struct AdjustmentSlider<Value: BinaryFloatingPoint>: View {
    @Binding
    private var value: Value
    private let inRange: ClosedRange<Value>
    private let step: Value

    @Environment(\.displayScale)
    private var displayScale

    @State
    private var scrollID: Int?

    @State
    private var isUpdatingValueFromScroll: Bool = false

    @State
    private var lastSnappedID: Int?

    public init(
        value: Binding<Value>,
        in inRange: ClosedRange<Value>,
        step: Value
    ) {
        self._value = value
        self.inRange = inRange
        self.step = step
    }

    public var body: some View {
        GeometryReader { proxy in
            scrollSlider(in: proxy.size)
        }
        .frame(height: sliderHeight)
        .accessibilityRepresentation {
            Slider(
                value: doubleValue,
                in: doubleRange,
                step: doubleStep
            )
        }
    }

    private func scrollSlider(in size: CGSize) -> some View {
        let sidePadding = max(0, (size.width - lineWidth) / 2)

        return ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                tickStack(sidePadding: sidePadding)
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrollID, anchor: .center)
            .onScrollPhaseChange { _, newPhase in
                if newPhase == .idle {
                    snapToCurrentID(using: proxy)
                }
            }
            .onAppear {
                syncScrollToValue(animated: false)
            }
            .onChange(of: value) { _, _ in
                if isUpdatingValueFromScroll {
                    isUpdatingValueFromScroll = false
                    return
                }
                syncScrollToValue(animated: true)
            }
            .onChange(of: scrollID) { _, newValue in
                updateValue(for: newValue)
            }
            .mask(scrollMask)
        }
    }

    private func tickStack(sidePadding: CGFloat) -> some View {
        LazyHStack(alignment: .bottom, spacing: tickSpacing) {
            ForEach(ticks) { tick in
                tickMark(
                    isSelected: tick.id == scrollID,
                    isAnchor: showsAnchorMarker && isAnchorValue(tick.value),
                    isMajor: isMajorTick(tick.id)
                )
                .id(tick.id)
            }
        }
        .scrollTargetLayout()
        .padding(.horizontal, sidePadding)
    }

    @ViewBuilder
    private func tickMark(
        isSelected: Bool,
        isAnchor: Bool,
        isMajor: Bool
    ) -> some View {
        Rectangle()
            .fill(tickColor(isSelected: isSelected, isMajor: isMajor))
            .frame(width: lineWidth, height: tickHeight)
            .mask(Capsule())
            .overlay(alignment: .top) {
                if isAnchor {
                    anchorDot(isSelected: isSelected)
                }
            }
    }

    private func tickColor(isSelected: Bool, isMajor: Bool) -> Color {
        if isSelected {
            return Color.accentColor
        }
        return Color.secondary.opacity(isMajor ? 0.55 : 0.3)
    }

    private func anchorDot(isSelected: Bool) -> some View {
        Circle()
            .fill(anchorDotColor(isSelected: isSelected))
            .frame(width: anchorDotSize, height: anchorDotSize)
            .offset(y: -(anchorDotSize + anchorDotGap))
    }

    private func anchorDotColor(isSelected: Bool) -> Color {
        if isSelected {
            return Color.accentColor
        }
        return Color.primary.opacity(0.6)
    }

    private func isMajorTick(_ index: Int) -> Bool {
        guard ticks.count > 1 else {
            return true
        }
        return index % majorTickStride == 0
    }

    private var doubleValue: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { newValue in
                value = steppedValue(Value(newValue))
            }
        )
    }

    private var doubleRange: ClosedRange<Double> {
        Double(inRange.lowerBound)...Double(inRange.upperBound)
    }

    private var doubleStep: Double {
        step > 0 ? Double(step) : 0
    }

    private var showsAnchorMarker: Bool {
        inRange.contains(.zero)
    }

    private var sliderHeight: CGFloat { 44 }
    private var tickHeight: CGFloat { 16 }
    private var majorTickStride: Int { 5 }
    private var tickSpacing: CGFloat { 6 }
    private var lineWidth: CGFloat { 2 }
    private var anchorDotSize: CGFloat { 6 }
    private var anchorDotGap: CGFloat { 2 }

    private var scrollMask: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .clear, location: 0),
                Gradient.Stop(color: .black, location: 0.2),
                Gradient.Stop(color: .black, location: 0.8),
                Gradient.Stop(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var ticks: [Tick] {
        let lower = inRange.lowerBound
        let upper = inRange.upperBound
        guard step > 0 else {
            return [
                Tick(id: 0, value: lower),
                Tick(id: 1, value: upper),
            ]
        }

        let totalSteps = Double((upper - lower) / step)
        let count = max(0, Int(totalSteps.rounded(.down)))
        var values: [Tick] = []
        values.reserveCapacity(count + 2)

        for index in 0...count {
            let tickValue = lower + (step * Value(index))
            values.append(Tick(id: index, value: tickValue))
        }

        if let last = values.last, !isApproximatelyEqual(last.value, upper) {
            values.append(Tick(id: values.count, value: upper))
        }

        return values
    }

    private func syncScrollToValue(animated: Bool) {
        guard let targetID = nearestTickID(for: value) else {
            return
        }
        guard scrollID != targetID else {
            return
        }
        lastSnappedID = targetID
        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                scrollID = targetID
            }
        } else {
            scrollID = targetID
        }
    }

    private func updateValue(for id: Int?) {
        guard let id, let tick = ticks.first(where: { $0.id == id }) else {
            return
        }
        let newValue = steppedValue(tick.value)
        if !isApproximatelyEqual(newValue, value) {
            isUpdatingValueFromScroll = true
            value = newValue
        }
    }

    private func snapToCurrentID(using proxy: ScrollViewProxy) {
        guard let scrollID else {
            lastSnappedID = nil
            return
        }
        guard scrollID != lastSnappedID else {
            return
        }
        lastSnappedID = scrollID
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(scrollID, anchor: .center)
        }
    }

    private func nearestTickID(for value: Value) -> Int? {
        guard !ticks.isEmpty else {
            return nil
        }
        if step > 0 {
            let rawIndex = ((value - inRange.lowerBound) / step).rounded()
            let clamped = min(max(Int(rawIndex), 0), ticks.count - 1)
            return ticks[clamped].id
        }
        return nearestTickByScan(for: value)?.id
    }

    private func nearestTickByScan(for value: Value) -> Tick? {
        var best: Tick?
        var bestDistance = Double.greatestFiniteMagnitude

        for tick in ticks {
            let distance = abs(Double(tick.value - value))
            if distance < bestDistance {
                bestDistance = distance
                best = tick
            }
        }

        return best
    }

    private func steppedValue(_ rawValue: Value) -> Value {
        let lower = inRange.lowerBound
        let upper = inRange.upperBound
        guard step > 0 else {
            return min(max(rawValue, lower), upper)
        }
        let steps = (rawValue - lower) / step
        let rounded = steps.rounded()
        let stepped = lower + rounded * step
        return min(max(stepped, lower), upper)
    }

    private func isAnchorValue(_ value: Value) -> Bool {
        showsAnchorMarker && isApproximatelyEqual(value, .zero)
    }

    private func isApproximatelyEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        let diff = abs(Double(lhs - rhs))
        let tolerance = max(1e-8, Double(step) * 0.001)
        return diff <= tolerance
    }
    private struct Tick: Identifiable {
        let id: Int
        let value: Value
    }
}

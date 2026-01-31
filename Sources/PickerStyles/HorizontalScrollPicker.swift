import SwiftUI

public struct HorizontalScrollPicker<SelectionValue: Hashable, Content: View>: View {
    
    let content: Content
    
    @Binding
    var selection: SelectionValue
    
    @State
    private var leadingItemWidth: CGFloat = 0
    
    @State
    private var trailingItemWidth: CGFloat = 0
    
    public init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            scrollView(proxy: proxy)
        }
    }

    @ViewBuilder
    private func scrollView(proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal) {
            pickerContent
        }
        .frame(minHeight: 64)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center, for: .alignment)
        .mask(scrollMask)
        .onAppear {
            scrollToSelection(proxy, animated: false)
        }
        .onChange(of: selection) { _, _ in
            scrollToSelection(proxy, animated: true)
        }
    }

    private var pickerContent: some View {
        Group(subviews: content) { subviews in
            let leadingID = subviews.first?.id
            let trailingID = subviews.last?.id

            LazyHStack {
                edgeSpacer(itemWidth: leadingItemWidth)
                ForEach(subviews) { subview in
                    let isLeading = subview.id == leadingID
                    let isTrailing = subview.id == trailingID

                    if let tag = subview.containerValues.tag(for: SelectionValue.self) {
                        selectionButton(tag: tag, isSelected: selection == tag) {
                            subview
                        }
                        .id(tag)
                        .readEdgeItemWidth(isLeading: isLeading, isTrailing: isTrailing)
                    } else {
                        subview
                            .readEdgeItemWidth(isLeading: isLeading, isTrailing: isTrailing)
                    }
                }
                edgeSpacer(itemWidth: trailingItemWidth)
            }
            .scrollTargetLayout()
            .onPreferenceChange(EdgeItemWidthPreferenceKey.self) { values in
                updateEdgeItemWidths(values)
            }
        }
    }

    @ViewBuilder
    private func edgeSpacer(itemWidth: CGFloat) -> some View {
        Spacer()
            .containerRelativeFrame(.horizontal) { length, _ in
                max(0, (length - itemWidth) / 2.0)
            }
    }

    @ViewBuilder
    private func selectionButton<Label: View>(
        tag: SelectionValue,
        isSelected: Bool,
        @ViewBuilder label: () -> Label
    ) -> some View {
        Button {
            selection = tag
        } label: {
            label()
                .labelStyle(.titleOnly)
                .foregroundStyle(isSelected ? .black : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(isSelected ? .yellow : .clear)
                .mask(Capsule())
        }
        .foregroundStyle(Color.primary)
    }

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

    private func scrollToSelection(_ proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation {
                proxy.scrollTo(selection, anchor: .center)
            }
        } else {
            proxy.scrollTo(selection, anchor: .center)
        }
    }

    private func updateEdgeItemWidths(_ values: [Edge: CGFloat]) {
        if let leading = values[.leading] {
            leadingItemWidth = leading
        }
        if let trailing = values[.trailing] {
            trailingItemWidth = trailing
        }
    }
}

private struct EdgeItemWidthPreferenceKey: PreferenceKey {
    static var defaultValue: [Edge: CGFloat] { [:] }
    
    static func reduce(value: inout [Edge: CGFloat], nextValue: () -> [Edge: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct EdgeItemWidthReader: View {
    let isLeading: Bool
    let isTrailing: Bool
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: EdgeItemWidthPreferenceKey.self,
                value: preferenceValue(for: proxy.size.width)
            )
        }
    }
    
    private func preferenceValue(for width: CGFloat) -> [Edge: CGFloat] {
        var values: [Edge: CGFloat] = [:]
        if isLeading {
            values[.leading] = width
        }
        if isTrailing {
            values[.trailing] = width
        }
        return values
    }
}

private extension View {
    @ViewBuilder
    func readEdgeItemWidth(isLeading: Bool, isTrailing: Bool) -> some View {
        if isLeading || isTrailing {
            background(EdgeItemWidthReader(isLeading: isLeading, isTrailing: isTrailing))
        } else {
            self
        }
    }
}

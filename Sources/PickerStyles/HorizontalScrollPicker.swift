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
            ScrollView(.horizontal) {
                Group(subviews: content) { subviews in
                    let leadingID = subviews.first?.id
                    let trailingID = subviews.last?.id
                    
                    LazyHStack {
                        Spacer()
                            .containerRelativeFrame(.horizontal) { (length, _) in
                                max(0, (length - leadingItemWidth) / 2.0)
                            }
                        ForEach(subviews) { subview in
                            let isLeading = subview.id == leadingID
                            let isTrailing = subview.id == trailingID
                            
                            if let tag = subview.containerValues.tag(for: SelectionValue.self) {
                                Button {
                                    selection = tag
                                } label: {
                                    subview
                                        .labelStyle(.titleOnly)
                                        .foregroundStyle(selection == tag ? .black : .secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(selection == tag ? .yellow : .clear)
                                        .mask(Capsule())
                                }
                                .foregroundStyle(Color.primary)
                                .id(tag)
                                .readEdgeItemWidth(isLeading: isLeading, isTrailing: isTrailing)
                            } else {
                                subview
                                    .readEdgeItemWidth(isLeading: isLeading, isTrailing: isTrailing)
                            }
                        }
                        Spacer()
                            .containerRelativeFrame(.horizontal) { (length, _) in
                                max(0, (length - trailingItemWidth) / 2.0)
                            }
                    }
                    .scrollTargetLayout()
                    .onPreferenceChange(EdgeItemWidthPreferenceKey.self) { values in
                        if let leading = values[.leading] {
                            leadingItemWidth = leading
                        }
                        if let trailing = values[.trailing] {
                            trailingItemWidth = trailing
                        }
                    }
                }
            }
            .frame(minHeight: 64)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.center, for: .alignment)
            .mask {
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
            .onAppear {
                proxy.scrollTo(selection, anchor: .center)
            }
            .onChange(of: selection) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
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

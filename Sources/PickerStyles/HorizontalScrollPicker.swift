import SwiftUI

public struct HorizontalScrollPicker<SelectionValue: Hashable, Content: View>: View {
    
    let content: Content
    
    @Binding
    var selection: SelectionValue
    
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
                LazyHStack {
                    Spacer()
                        .containerRelativeFrame(.horizontal) { (length, _) in
                            length / 2.0
                        }
                    ForEach(subviews: content) { subview in
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
                        } else {
                            subview
                        }
                    }
                    Spacer()
                        .containerRelativeFrame(.horizontal) { (length, _) in
                            length / 2.0
                        }
                }
                .scrollTargetLayout()
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

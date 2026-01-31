import SwiftUI

struct HorizontalScrollPicker<SelectionValue: Hashable, Content: View>: View {
    
    let content: Content
    
    @Binding
    var selection: SelectionValue
    
    init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
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
                    } else {
                        subview
                    }
                }
            }
        }
        .frame(minHeight: 64)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
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
    }
}

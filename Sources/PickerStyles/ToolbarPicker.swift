import SwiftUI

public struct ToolbarPicker<SelectionValue: Hashable, Content: View>: View {
    
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
        HStack(spacing: 12) {
            ForEach(subviews: content) { subview in
                if let tag = subview.containerValues.tag(for: SelectionValue.self) {
                    Button {
                        selection = tag
                    } label: {
                        subview
                            .symbolVariant(selection == tag ? .fill : .none)
                            .labelStyle(ToolItemContentLabelStyle())
                            .foregroundStyle(selection == tag ? .primary : .secondary)
                            .frame(minWidth: 44)
                            .selectedIndicator(isEnabled: selection == tag)
                    }
                    .foregroundStyle(Color.primary)
                } else {
                    subview
                }
            }
        }
        .frame(minHeight: 64, alignment: .center)
        .padding(.horizontal, 24)
        .modifier {
            if #available(iOS 26.0, *) {
                $0.glassEffect(.regular.interactive())
            } else {
                $0.background(Material.regular).mask(Capsule())
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 12)
        .padding(.horizontal, 24)
    }
}

struct ToolItemContentLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            configuration.icon
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
            configuration.title
                .font(.caption2)
        }
    }
}

extension View {
    @ViewBuilder
    func selectedIndicator(isEnabled: Bool) -> some View {
        modifier(SelectedIndicatorViewModifier(isEnabled: isEnabled))
    }
}

struct SelectedIndicatorViewModifier: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                Image(systemName: "arrowtriangle.down")
                    .resizable()
                    .symbolVariant(.fill)
                    .frame(width: 5, height: 4)
                    .foregroundStyle(Color.accentColor)
                    .padding(1)
                    .alignmentGuide(.top) { $0[.bottom] }
                    .opacity(isEnabled ? 1 : 0)
            }
    }
}

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
        toolbarContent
    }

    private var toolbarContent: some View {
        Group(subviews: content) { subviews in
            HStack(spacing: 12) {
                ForEach(subviews) { subview in
                    if let tag = subview.containerValues.tag(for: SelectionValue.self) {
                        selectionButton(tag: tag, isSelected: selection == tag) {
                            subview
                        }
                    } else {
                        subview
                    }
                }
            }
        }
        .frame(minHeight: 64, alignment: .center)
        .padding(.horizontal, 24)
        .toolbarBackgroundStyle()
        .shadow(color: .black.opacity(0.2), radius: 12)
        .padding(.horizontal, 24)
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
                .symbolVariant(isSelected ? .fill : .none)
                .labelStyle(ToolItemContentLabelStyle())
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(minWidth: 44)
                .selectedIndicator(isEnabled: isSelected)
        }
        .foregroundStyle(Color.primary)
    }
}

private struct ToolItemContentLabelStyle: LabelStyle {
    @ViewBuilder
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

private extension View {
    @ViewBuilder
    func selectedIndicator(isEnabled: Bool) -> some View {
        modifier(SelectedIndicatorViewModifier(isEnabled: isEnabled))
    }
}

private struct SelectedIndicatorViewModifier: ViewModifier {
    let isEnabled: Bool
    
    @ViewBuilder
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

private extension View {
    @ViewBuilder
    func toolbarBackgroundStyle() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.interactive())
        } else {
            background(Material.regular).mask(Capsule())
        }
    }
}

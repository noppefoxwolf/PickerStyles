import SwiftUI

extension View {
    @ViewBuilder
    func modifier<Content: View>(
        @ViewBuilder _ content: (Self) -> Content
    ) -> some View {
        content(self)
    }
}

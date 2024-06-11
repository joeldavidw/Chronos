import SwiftUI

struct SheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct GetHeightModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geometry in
                Color.clear.preference(key: SheetHeightPreferenceKey.self, value: geometry.size.height)
            }
        }
    }
}

extension View {
    func getSheetHeight() -> some View {
        modifier(GetHeightModifier())
    }
}

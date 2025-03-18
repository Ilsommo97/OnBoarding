import SwiftUI

struct DelayedAppearModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.15), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}
extension View {
    func delayedAppear(index: Int) -> some View {
        self.modifier(DelayedAppearModifier(index: index))
    }
}

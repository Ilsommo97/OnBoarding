import SwiftUI
import SwiftUI

struct TextRevealModifier: ViewModifier {
    @State private var progress: CGFloat = 0
    let duration: Double

    func body(content: Content) -> some View {
        content
            .mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * progress, height: geometry.size.height)
                        .animation(.easeInOut(duration: duration), value: progress)
                }
            )
            .onAppear {
                progress = 1
            }
    }
}

// **Convenience Extension**
extension View {
    func textReveal(duration: Double = 2.0) -> some View {
        self.modifier(TextRevealModifier(duration: duration))
    }
}

struct TextAnimation: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .font(.largeTitle)
            .bold()
            .textReveal(duration: 0.5)
    }
}
#Preview {
    TextAnimation()
}

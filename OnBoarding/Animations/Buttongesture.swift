//
//  Buttongesture.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 07/03/25.
//

import SwiftUI

struct ScaleOnPressModifier: ViewModifier {
    // State to track if the view is being pressed
    @State private var isPressed = false
    
    // The action to perform when pressed
    var action: () -> Void
    
    // Scale factors for pressed and normal states
    var pressedScale: CGFloat = 0.9
    var normalScale: CGFloat = 1.0
    
    // Animation duration
    var animationDuration: Double = 0.35
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressedScale : normalScale)
            .animation(.easeInOut(duration: animationDuration), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

// Extension to make it easy to apply the modifier
extension View {
    func scaleOnPress(
        pressedScale: CGFloat = 0.9,
        normalScale: CGFloat = 1.0,
        animationDuration: Double = 0.1,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ScaleOnPressModifier(
                action: action,
                pressedScale: pressedScale,
                normalScale: normalScale,
                animationDuration: animationDuration
            )
        )
    }
}

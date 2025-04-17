//
//  ConditionalModifier.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 11/04/25.
//

import SwiftUI


import SwiftUI

extension View {
    /// Applies the given transform if the condition evaluates to true.
    ///
    /// - Parameters:
    ///   - condition: An autoclosure condition that determines if the transform should be applied.
    ///   - transform: A closure that takes the current view and returns the modified view.
    ///                Thanks to `@ViewBuilder`, you can use multiple modifiers inside this closure.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func when<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            // If the condition is true, apply the transform closure
            transform(self)
        } else {
            // Otherwise, return the original view unmodified
            self
        }
    }

    /// Applies the given transform if the optional value is non-nil.
    /// Often used for applying modifiers based on optional state.
    ///
    /// - Parameters:
    ///   - value: An optional value. The transform is applied if this is non-nil.
    ///   - transform: A closure that takes the current view and the unwrapped value,
    ///                returning the modified view.
    /// - Returns: Either the original `View` or the modified `View` if the value is non-nil.
    @ViewBuilder func whenLet<V, Content: View>(_ value: V?, transform: (Self, V) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Example Usage

struct ConditionalModifierExample: View {
    @State private var isHighlighted = false
    @State private var isDisabled = true
    @State private var borderColor: Color? = .blue
    let viewModel = BaseSwipeClass(cardQuee: [])
    var body: some View {
        VStack{
            Text("ao")
        }
        .when(viewModel is any ScoreAnimationProtocol, transform: { content in
            content
                .background(
                    .blue
                )
        })
        .padding()
    }
}


extension View {
    func expressionModifier<Content: View>(@ViewBuilder _ content: (Self) -> Content) -> some View {
        content(self)
    }
}
#Preview {
    ConditionalModifierExample()
}

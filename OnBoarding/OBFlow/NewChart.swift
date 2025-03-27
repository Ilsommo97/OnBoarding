//
//  NewChart.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 17/03/25.
//
import SwiftUI

struct CircularStorage: View {
    @State var usedStorage: Double = 77 // Example value in GB
    @State var totalStorage: Double = 100 // Example value in GB
    @State private var usedProgress: Double = 0
    @State private var availableProgress: Double = 0
    @State private var textOpacity: Double = 0
    @Binding var savedStorage: Double // Binding for saved storage
    var shouldAnimateAppear = true
    var dim = 120.0
    var linewidth = 12.0
    let angle: Angle = .degrees(270)
    
    var usedFraction: Double {
        (usedStorage - savedStorage) / totalStorage
    }
    var finishedCompletion: () -> Void = {}
    
    let initialColor: AngularGradient = .init(
        gradient: Gradient(colors: [.green, .orange, .red, .red]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(270 + 380)
    )
    
    let savedColor: AngularGradient = .init(
        gradient: Gradient(colors: [.green, .green, .yellow]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(270 + 380)
    )
    
    var body: some View {
        ZStack {
            // Used storage arc (the white filled part)
            Circle()
                .trim(from: usedFraction + 0.04, to: usedFraction + availableProgress * (1 - usedFraction) - 0.04)
                .stroke(.secondary, style: .init(lineWidth: linewidth, lineCap: .round))
                .rotationEffect(angle)
                .frame(width: dim, height: dim)
            
            Circle()
                .trim(from: 0, to: usedProgress * usedFraction)
                .stroke(savedStorage > 0 ? savedColor : initialColor, style: .init(lineWidth: linewidth, lineCap: .round))
                .rotationEffect(angle)
                .frame(width: dim, height: dim)
                .overlay {
                    Circle()
                        .trim(from: 0, to: usedProgress * usedFraction)
                        .stroke(savedStorage > 0 ? savedColor : initialColor, lineWidth: linewidth)
                        .rotationEffect(angle)
                        .frame(width: dim, height: dim)
                        .blur(radius: 8)
                }
            
        }
        .onAppear {
            // Initial animation when the view appears
            if shouldAnimateAppear {
                withAnimation(.spring(duration: 0.6), completionCriteria: .logicallyComplete) {
                    usedProgress = 1.0
                } completion: {
                    //
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.59) {
                    withAnimation(.linear(duration: 0.6)) {
                        availableProgress = 1.0
                        textOpacity = 1.0
                    }
                    finishedCompletion()
                }
            }
            else {
                usedProgress = 1
                availableProgress = 1.0
                textOpacity = 1.0
            }
        }
        .onChange(of: savedStorage) { newValue in
            if newValue > 0 {
                // Trigger animation when savedStorage changes
                withAnimation(.spring(duration: 0.6)) {
                    usedProgress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.59) {
                    withAnimation(.linear(duration: 0.6)) {
                        availableProgress = 1.0
                        textOpacity = 1.0
                    }
                }
            }
        }
    }
}
struct Test23 : View {
    @State var sto = 0.0
    var body: some View {
        CircularStorage(savedStorage: $sto)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.linear(duration: 1.5)) {
                        sto = 25.0

                    }
                }
            }

    }
}

#Preview {
    Test23()
        .preferredColorScheme(.dark)
}

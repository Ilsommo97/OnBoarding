//
//  pulse.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 08/03/25.
//

import SwiftUI

struct LoadingPulseOutline: View {
    @State private var isAnimating: Bool = false
    @State private var animationCompleted: Bool = false
    
    let timing: Double
    let maxCounter: Int = 3
    let frame: CGSize
    let primaryColor: Color
    let duration: Double
    let completion: () -> Void
    
    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5, duration: Double = 2.0, completion: @escaping () -> Void = {}) {
        self.timing = speed * 4
        self.frame = CGSize(width: size, height: size)
        self.primaryColor = color
        self.duration = duration
        self.completion = completion
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<maxCounter, id: \.self) { index in
                Circle()
                    .stroke(
                        primaryColor.opacity(isAnimating ? 0.0 : 1.0),
                        style: StrokeStyle(lineWidth: isAnimating ? 0.0 : 20.0)
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.0)
                    .animation(
                        Animation.easeOut(duration: timing)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * timing / Double(maxCounter))
                    )
            }
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        .onAppear {
            isAnimating.toggle()
            
            // Schedule the completion handler to be called after the specified duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                animationCompleted = true
                completion()
            }
        }
    }
}



struct AnimatingCircle : Identifiable {
    
    var id : UUID = UUID()
    
    var scale : Double = 0
    
    var opacity: Double = 1
}
struct ProgrammaticPulse: View {
    var color: Color = .white
    var nCircles = 4
    var animationDuration: Double = 2
    var delayBetweenCircles: Double = 0.5
    var completionHandler : (() -> Void)
    
    
    @State private var circles: [AnimatingCircle] = []
    
    var totalAnimationDuration: Double {
          // Time for the last circle to start + time for it to complete its animation
          return Double(nCircles - 1) * delayBetweenCircles + animationDuration
      }
    var body: some View {
        ZStack {
            ForEach(circles) { circle in
                Circle()
                    .stroke(color, style: .init(lineWidth: 5))
                    .frame(width: 200, height: 200)
                    .scaleEffect(circle.scale)
                    .opacity(circle.opacity)
            }
        }
        .onAppear {
            // Initialize circles
            circles = (0..<nCircles).map { _ in AnimatingCircle() }
            
            // Animate each circle with a delay
            for i in 0..<circles.count {
                let delay = Double(i) * delayBetweenCircles
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: animationDuration)) {
                        circles[i].opacity = 0
                        circles[i].scale = 1
                    }completion: {
                        if i == circles.count - 1 {
                            // completion handler!
                            completionHandler()
                        }
                    }
                    
                }
            }
        }
    }
}



#Preview {
    VStack{
        ProgrammaticPulse() {
            print("Here we are")
     
        }
        
    }
    .frame(maxHeight: .infinity)
    .frame(maxWidth: .infinity)
    .background(
        GeneralBackground(opacity: 0.2)
    )
    .preferredColorScheme(.dark)
}

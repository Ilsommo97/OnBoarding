//
//  Untitled.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 24/03/25.
//

import SwiftUI



import SwiftUI
import Charts

 func cubicBezier(t: Double, p0: Double, p1: Double, p2: Double, p3: Double) -> Double {
    let t2 = t * t
    let t3 = t2 * t
    let mt = 1 - t
    let mt2 = mt * mt
    let mt3 = mt2 * mt
    return mt3*p0 + 3*mt2*t*p1 + 3*mt*t2*p2 + t3*p3
}

struct DataPoint : Identifiable {
    let id = UUID()
    let time: String
    let value: Double
    
    static let dataPoints = {
        let realPoints = [
            (time: 0.0, label: "Start", value: 80.0),
            (time: 2.0, label: "Month", value: 50.0)
        ]
        
        // Generate interpolated points for smooth curve (ease-in-out)
        let interpolated = (1...3).map { i in
            let progress = Double(i) / 4.0 // 0.25, 0.5, 0.75
            let time = progress * 2.0
            let value = cubicBezier(t: progress, p0: 80, p1: 70, p2: 55, p3: 50)
            return (time: time, label: "", value: value)
        }
        
        return (realPoints + interpolated).sorted(by: { $0.time < $1.time })
    }()

}


struct EdgeToEdgeLineChart: View {
    // Original data points + interpolated points for smooth curve
   
    
    
    var body: some View {
 
            
            
            Chart(DataPoint.dataPoints, id: \.time) { point in
                // Only show points for real data
                if !point.label.isEmpty {
                    PointMark(
                        x: .value("Time", point.time),
                        y: .value("Percentage", point.value)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(100)
                    .annotation {
                        if point.label == "Month" {
                            Text("1 Month")
                                .font(.headline)
                            
                        }
                        else {
                            Text("Start")
                                .font(.headline)
                                .offset(x: 10)
                        }
                        
                    }
                }
                
                // Smooth line through all points
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Percentage", point.value)
                )
                .interpolationMethod(.cardinal(tension: 0.2))
                .foregroundStyle(.white)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                // Optional: Add gradient under the line
                AreaMark(
                    x: .value("Time", point.time),
                    y: .value("Percentage", point.value)
                )
                
                .interpolationMethod(.cardinal(tension: 0.2))
                .foregroundStyle(.linearGradient(
                    colors: [.green.opacity(0.2), .blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
             
            }
            .chartXScale(
                domain: [0, 2],
                range: .plotDimension(startPadding: 20, endPadding: 20)
            )
            .chartYAxis {
                AxisMarks(position: .leading, values: [50, 80]) { value in
                    AxisValueLabel {
                        if let percent = value.as(Int.self) {
                            Text("\(percent)%")
                                .font(.subheadline)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    Text("30 GB Saved")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 100) // Adjust position
                }
            )
            .frame(height: 300)

        }
    
    
    // Cubic Bézier easing function for smooth interpolation
  
}
struct SwipeChart: View {
    @Binding var page : Int
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Reclaim Your Storage")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
           Text("This chart shows your storage usage over time using SwAipe 5 minutes a day.")
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom)
            
//    
//            
//            Text("Device storage")
//                .font(.title2)
//                .fontWeight(.semibold)
//                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            EdgeToEdgeLineChart()
//                .padding()
//                .background {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.black.opacity(0.4))
//                }
                .padding(.vertical)
            
            Text("Spend just 5 minutes swiping each day, and you could reclaim around 20% of your storage in a month.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .font(.subheadline)
//            
//            AnimatedStorage(totalStorage: 256, initialUsedStorage: 240, clearedUsedStorage: 120, width: 300)
//                .padding(.vertical)
                Spacer()
      
            ContinueButtonOB() {
                withAnimation {
                    page += 1
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeneralBackground(opacity: 0.2))
    }
}


#Preview {
    SwipeChart(page: .constant(1))
        .preferredColorScheme(.dark)
}

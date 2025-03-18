//
//  StorageTest2.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 12/03/25.
//

import SwiftUI

struct StorageTest2: View {
    let color = LinearGradient(colors: [.orange, .red], startPoint: .leading
                               , endPoint: .trailing)
    
    let afterColor = LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing)
    var body: some View {
        VStack(spacing:12){
            
      
            Text("Your device is at risk")
                .font(.title)
                .fontWeight(.bold)
            
            
            StorageChart(dim: 180, linewidth: 18)
                .overlay {
                    VStack{
                        Text("98%")
                            .foregroundStyle(color)
                            .fontWeight(.bold)
                            .font(.title)
                        Text("Occupied")
                            .fontWeight(.bold)
                            .font(.title2)
                            .foregroundStyle(.secondary)

                    }
                }
                .overlay(alignment: .topTrailing, content: {
                    VStack(alignment: .leading){
                        HStack{
                            Circle()
                                .fill(color)
                                .frame(width: 10, height: 10)
                            Text("Used")
                                .fontWeight(.semibold)
                        }
                        HStack{
                            Circle()
                                .fill(.secondary)
                                .frame(width: 10, height: 10)
                            Text("Free")
                                .fontWeight(.semibold)
                        }
                    }
                    .offset(x: 100)

                        
                })
                .padding()
            Group{
                Text("You have 12 GB left out of 256 GB on your device. You're in the risk category.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                +
                Text(" Why?")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)


            Divider()
            Text("Similar items")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .delayedAppear(index: 0)

            
            HStack{
                
                VStack{
                    Label("Photos", systemImage: "photo.on.rectangle.angled")
           
                        .font(.headline)
                        .foregroundStyle(.secondary)
               
                    Text("2143")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.3))
                )
                
                //play.rectangle.on.rectangle.fill
                VStack{
                    Label("Videos", systemImage: "play.rectangle.on.rectangle.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("513")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.3))
                )
                
            }
            .delayedAppear(index: 1)
            Text("SwAipe will choose your best photos and videos among your similars based on its AI scoring system")
                .foregroundStyle(.secondary)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -3)
                .delayedAppear(index: 2)
            
            VStack(spacing: 8){
                AnimatedStorage(totalStorage: 256, initialUsedStorage: 250, clearedUsedStorage: 180, width: 370)
                Text("Save up to ")
                    .foregroundStyle(.secondary)
                + Text("24 GB")
                    .fontWeight(.bold)
            }
            .delayedAppear(index: 3)
            .padding(.vertical)
            


            Spacer()
            ContinueButtonOB()
        }
        .padding()
        .frame(maxWidth: .infinity
               , maxHeight: .infinity)
        .background(
            GeneralBackground(opacity: 0.2)
        )
        
    }
}



struct StorageTest3: View {
    let color = LinearGradient(colors: [.orange, .red], startPoint: .leading
                               , endPoint: .trailing)
    
    let afterColor = LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing)
    var body: some View {
        VStack(spacing:12){
            
      
            Text("Your device is at risk")
                .font(.title)
                .fontWeight(.bold)
            
            
            StorageChart(dim: 135, linewidth: 12)
                .overlay {
                    VStack{
                        Text("98%")
                            .foregroundStyle(color)
                            .fontWeight(.bold)
                            .font(.title)
                        Text("Occupied")
                            .fontWeight(.bold)
                            .font(.title2)
                            .foregroundStyle(.secondary)

                    }
                }
                .overlay(alignment: .topTrailing, content: {
                    VStack(alignment: .leading){
                        HStack{
                            Circle()
                                .fill(color)
                                .frame(width: 10, height: 10)
                            Text("Used")
                                .fontWeight(.semibold)
                        }
                        HStack{
                            Circle()
                                .fill(.secondary)
                                .frame(width: 10, height: 10)
                            Text("Free")
                                .fontWeight(.semibold)
                        }
                    }
                    .offset(x: 100)

                        
                })
                .padding()
            Group{
                Text("You have 12 GB left out of 256 GB on your device. You're in the risk category. ")
                    .font(.headline)
                    .foregroundStyle(.secondary)
             // or a specific number if you want to cap it
                +
                Text("Why?")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
                    
            }
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)

            Divider()
            Text("Similar photos (2134)")
                .font(.title2)
                .fontWeight(.semibold)
             //   .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal) {
                HStack{
                    ForEach(0..<5) { index in
                        Image(.canal)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 100)
                            .clipShape(.rect(cornerRadius: 8))
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: index == 0 ? "heart.fill" : "trash.fill")
                                    .font(.headline)
                                    .padding(2)
                                    .foregroundStyle( index == 0 ? .green : .red)
                                    
                            }
                    }
                }
            }
            
            Text("Similar Videos (1231)")
                .font(.title2)
                .fontWeight(.semibold)
             ///   .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal) {
                HStack{
                    ForEach(0..<5) { index in
                        Image(.canal)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 100)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: index == 0 ? "heart.fill" : "trash.fill")
                                    .font(.headline)
                                    .padding(2)
                                    .foregroundStyle( index == 0 ? .green : .red)
                                    
                            }
                            .overlay {
                                Image(systemName: "play.circle.fill")
                                    .font(.headline)
                            }
                            .clipShape(.rect(cornerRadius: 8))
                  
                    }
                }
            }
            
          
            
            VStack(spacing: 8){
                Text("SwAipe will choose your best photos and videos among your similars based on its AI scoring system")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, -3)
                    .delayedAppear(index: 2)
                AnimatedStorage(totalStorage: 256, initialUsedStorage: 250, clearedUsedStorage: 180, width: 370)
                Text("Save up to ")
                    .foregroundStyle(.secondary)
                + Text("24 GB")
                    .fontWeight(.bold)
            }
            .delayedAppear(index: 3)
            .padding(.vertical)

            ContinueButtonOB()
        }
        .padding()
        .frame(maxWidth: .infinity
               , maxHeight: .infinity)
        .background(
            GeneralBackground(opacity: 0.2)
        )
        
    }
}
#Preview {
    StorageTest3()
        .preferredColorScheme(.dark)
}




struct ScaledGauge <Style: GaugeStyle> : View {
    var tint : AnyShapeStyle
    var scaleEffect : CGFloat
    
    var currentValue : Float
    var maxValue : Float
    var gaugeStyle: Style
    
    @State private var scaledFrame : CGSize?
    
    private var clampedCurrentValue: Float {
        max(0, min(currentValue, maxValue))
    }
    
    var body: some View {
        ZStack {
            Gauge(value: clampedCurrentValue, in: 0...maxValue) {
                // Empty label
            } currentValueLabel: {
             
                Text("\(computePercentage())%")
                    .font(.subheadline)
            }
            .gaugeStyle( gaugeStyle )
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            scaledFrame = CGSize(width: geometry.size.width * scaleEffect, height: geometry.size.height * scaleEffect)
                        }
                }
            )
            .scaleEffect(scaleEffect)
            .tint(tint)
        }
        .frame(width: scaledFrame?.width, height: scaledFrame?.height)
    }
    
    private func computePercentage() -> Int {
        guard maxValue > 0 else { return 0 }
        return Int((clampedCurrentValue / maxValue * 100).rounded())
    }
}



struct AnimatedNumberTextView<Content>: View, Animatable where Content: View {
    private var value: Double
    @ViewBuilder private let content: (Double) -> Content
    
    init(_ value: Double, content: @escaping (Double) -> Content) {
        self.value = value
        self.content = content
    }
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        content(value)
    }
}



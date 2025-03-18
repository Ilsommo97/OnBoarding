//
//  HighStorage.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 10/03/25.
//

import SwiftUI


struct HighStorageView : View {
    let color: LinearGradient = .init(colors: [.orange, .red],
                                      startPoint: .leading, endPoint: .trailing)
    var body: some View {
        
        
        
        VStack{
            Text("Your device is at risk.")
                .font(.title)
                .fontWeight(.semibold)
             //   .foregroundStyle(color)
            TopBreakdown()
            Divider()
    
             
            
            Text("Let SwAipe handle it for you")
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
            
            similarView(false)
                .padding(.bottom, 8)
            similarView(true)
 
                
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            GeneralBackground(opacity: 0.2)
        }
    }
    
    private func similarView(_ video : Bool) -> some View {
        HStack{
            ZStack{
                Image(.canal)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 60)
                    .clipShape(.rect(cornerRadius: 4))
                    .rotationEffect(.degrees(12))
                
                Image(.canal)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 60)
                    .clipShape(.rect(cornerRadius: 4))
                    .rotationEffect(.degrees(-12))
                    .overlay {
                        if video {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                        }
                    }
            }
            VStack(alignment: .leading){
                Text("Up to 3211 similars \(!video ? "photos" : "videos")")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Save around 6.2 GB")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
        }
        .padding(.all, 16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.4)))
    }
}

struct TopBreakdown : View {
    
    let color: LinearGradient = .init(colors: [.orange, .red], startPoint: .bottom
                                      , endPoint: .top)
    var body: some View {

        VStack{
            // top row
            
            HStack{
                Text("Storage")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 2){
                    Image(systemName: "circle.fill")
                        .foregroundStyle(color)
                        .font(.subheadline)
                    Text("Used")
                        .font(.subheadline)
                    
                }
                HStack(spacing: 2){
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Text("Free")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                }
            }
            .padding(.bottom)
            HStack{
                StorageChart()
                    .padding(.trailing, 24)
//
                VStack(alignment: .leading, spacing: 12){
                    Label("Photos: 4223", systemImage: "photo")
                        .delayedAppear(index: 1)
                    Label("Live photos: 56211", systemImage: "livephoto")
                        .delayedAppear(index: 2)
                    Label("ScreenShots: 7623", systemImage: "livephoto")
                        .delayedAppear(index: 3)
                    Label("Videos: 123", systemImage: "video")
                        .delayedAppear(index: 4)
//             
//       
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.4))
        )
    }
}

struct AnimatedStorage: View {
    let initialGradient = LinearGradient(colors: [.orange, .red, .red], startPoint: .leading, endPoint: .trailing)
    let clearedGradient = LinearGradient(colors: [.green, .green, .yellow], startPoint: .leading, endPoint: .trailing)
    
    // Storage parameters
    var totalStorage: Double // in GB
    var initialUsedStorage: Double // in GB
    var clearedUsedStorage: Double // in GB after cleaning
    var containerWidth: CGFloat // Width of the outer container
    
    // Computed properties
    private var initialPercentage: Double {
        (initialUsedStorage / totalStorage) * 100
    }
    
    private var clearedPercentage: Double {
        (clearedUsedStorage / totalStorage) * 100
    }
    
    // Animation states
    @State private var isCleared = false
    @State private var storagePercentage: CGFloat = 1.0
    @State private var displayedUsedStorage: Double = 0
    @State private var displayedPercentage: Double = 0
    @State private var rectHeight: CGFloat = 34
    @State private var rectWidth: CGFloat = 0 // Will be set in init based on containerWidth
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    
    init(totalStorage: Double, initialUsedStorage: Double, clearedUsedStorage: Double, width: CGFloat) {
        self.totalStorage = totalStorage
        self.initialUsedStorage = initialUsedStorage
        self.clearedUsedStorage = clearedUsedStorage
        self.containerWidth = width
        
        self._rectWidth = State(initialValue: width)
        self._displayedUsedStorage = State(initialValue: initialUsedStorage)
        self._displayedPercentage = State(initialValue: (initialUsedStorage / totalStorage) * 100)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                // Background container
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .frame(width: containerWidth, height: 34)
                
                // Filled storage indicator
                RoundedRectangle(cornerRadius: 24)
                    .fill(isCleared ? clearedGradient : initialGradient)
                    .frame(
                        width: min(
                            containerWidth * (isCleared ?
                                CGFloat(clearedUsedStorage / totalStorage) :
                                CGFloat(initialUsedStorage / totalStorage)
                            ),
                            containerWidth
                        ),
                        height: rectHeight
                    )
                    .scaleEffect(x: scale, y: scale, anchor: .leading)
            }
            .overlay {
                AnimatedNumberTextView(displayedPercentage) { number in
                    Text("\(Int(number))%")
                        .fontWeight(.bold)
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        scale = 1.0
        displayedUsedStorage = initialUsedStorage
        displayedPercentage = initialPercentage
        
        // Slight delay before starting animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateStorageChanges()
        }
    }
    
    private func resetAnimation() {
        isCleared = false
        scale = 1.0
        rectHeight = 34
        displayedUsedStorage = initialUsedStorage
        displayedPercentage = initialPercentage
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            startAnimation()
        }
    }
    
    private func animateStorageChanges() {
        guard isAnimating else { return }
        
        // First animation: shrink height slightly and scale down
      
        
        // Second animation: toggle cleared state and update the displayed values
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                isCleared.toggle()
                rectHeight = 30
                scale = 0.95
                // Animate the displayed storage values
                displayedUsedStorage = clearedUsedStorage
                displayedPercentage = clearedPercentage
            }
            
            // Third animation: restore height and scale
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                
                // Fourth animation: reverse to initial state after a longer pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        isCleared.toggle()
                        displayedUsedStorage = initialUsedStorage
                        displayedPercentage = initialPercentage
                        rectHeight = 34
                        scale = 1.0
                    }
                    
                    // Start the sequence again after a pause
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        animateStorageChanges()
                    }
                }
            }
        }
    }
}
// Example usage:

#Preview {
    HighStorageView()
    
        .preferredColorScheme(.dark)
}


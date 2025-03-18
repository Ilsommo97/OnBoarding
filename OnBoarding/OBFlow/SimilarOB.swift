//
//  SimilarOB.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 13/03/25.
//

import SwiftUI

struct SimilarOB: View {

    var body: some View {
        VStack(spacing: 0){
            VStack(alignment: .leading){
                Text("Get rid of similars")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("SwAipe will choose your best photos and videos among your similars based on its AI scoring system")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            VStack(spacing: 4){
                
          
                AnimatedStorage(totalStorage: 256, initialUsedStorage: 250, clearedUsedStorage: 180, width: 370)
         
                Text("Save up to ")
                    .foregroundStyle(.secondary)
                    .font(.title2)
                + Text("24 GB")
                    .fontWeight(.bold)
                    .font(.title2)
            }
            .padding(.top, 16)
            .padding(.bottom, 6)
//
//            Text("Similar photos (3213)")
//                .font(.title2)
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, 12)
//                .padding(.bottom, 6)
//            
            
            ScrollView {
                ForEach(0..<5) { index in
                    similarStack(index + 2)
                }
                
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.4))
            )
            .scrollIndicators(.hidden)
            .overlay(alignment: .topTrailing, content: {
                //
                Label("Photos", systemImage: "photo.stack.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(8)
                
                
            })
            .padding(.bottom, 12)
            
            
//            Text("Similar videos (512)")
//                .font(.title2)
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, 6)
//                .padding(.bottom, 6)
            ScrollView {
                
                ForEach(0..<5) { index in
                    similarStack(index + 2, video: true)
                }
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.4))
            )
            .scrollIndicators(.hidden)
            .overlay(alignment: .topTrailing, content: {
                //
                Label("Videos", systemImage: "rectangle.stack.badge.play.fill")
                    .font(.title3)
                    
                    .padding(8)
                
            })
            .padding(.bottom, 12)
  


            ContinueButtonOB()
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(
            GeneralBackground(opacity: 0.2)
        )
     
    }
    
    
    func similarStack(_ n : Int, video: Bool = false) -> some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(0..<n) { index in
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
                        .overlay {
                            if video {
                                Image(systemName: "play.circle.fill")
                                    .font(.headline)

                            }
                        }
                    
                }
            }
        }
    }
}


struct SimilarOB2 : View {
    @Binding var page : Int
    let grayColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let softWarmRed = Color(red: 0.95, green: 0.3, blue: 0.3)   // Softer red
    let burntOrange = Color(red: 0.95, green: 0.6, blue: 0.2)  // Warmer orange
    let goldenYellow = Color(red: 0.98, green: 0.75, blue: 0.25) // Muted yellow
    let savedPercentage : Double = 25
    @State var expandPhotos = false
    @State var expandVideos = false
    
    @State var savedStorage : Double = 0
    @State var occupiedPercentage : Double = 85
    @Environment(OBViewModel2.self) var viewModel : OBViewModel2
    
    var body: some View {
        VStack{
            VStack(alignment:.leading){
                Text("Gallery breakdown")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Keep only your most important memories")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom)
             GalleryBreakdown(totalPhotos: 4531, similarPhotos: 2351, similarVideos: 540, screenshots: 222)
            
            
            HStack(spacing: 12){
                Circle()
                    .fill(grayColor)
                    .stroke(.black, style: .init(lineWidth: 1.5))
                    .frame(width: 25, height: 25)

                VStack(alignment:.leading){
                    Text("Media (1244)")
                        .font(.title2)
                        .fontWeight(.semibold)
                     //   .foregroundStyle(goldenYellow.opacity(0.8))
                    Text("All the other media in your device")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                Circle()
                    .fill(softWarmRed)
                    .stroke(.black, style: .init(lineWidth: 1.5))
                    .frame(width: 25, height: 25)

                VStack(alignment:.leading){
                    Text("Screenshots (1244)")
                        .font(.title2)
                        .fontWeight(.semibold)
                     //   .foregroundStyle(goldenYellow.opacity(0.8))
                    Text("32 GB")
                        .foregroundStyle(.secondary)
                        .font(.headline)
                }
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !expandVideos{
                VStack(spacing: 12){
                    HStack{
                        Circle()
                            .fill(burntOrange)
                            .stroke(.black, style: .init(lineWidth: 1.5))
                            .frame(width: 25, height: 25)
                        
                        VStack(alignment:.leading){
                            Text("Similar photos (1244)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            //   .foregroundStyle(goldenYellow.opacity(0.8))
                            Text("Save around 12 GB")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        Spacer()
                        Image(systemName: expandPhotos ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleOnPress {
                        withAnimation {
                            expandPhotos.toggle()
                            expandVideos = false
                        }
                    }
                    if expandPhotos {
                        SimilarStack(video: false)
                        //    .padding(.horizontal)
                    }
                }
                .padding()
            }
            if !expandPhotos {
                VStack(spacing: 12) {
                    HStack{
                        Circle()
                            .fill(goldenYellow)
                            .stroke(.black, style: .init(lineWidth: 1.5))
                            .frame(width: 25, height: 25)
                        
                        VStack(alignment:.leading){
                            Text("Similar videos (25)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            //   .foregroundStyle(goldenYellow.opacity(0.8))
                            Text("Save around 2.3 GB")                        .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        Spacer()
                        Image(systemName: expandVideos ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleOnPress {
                        withAnimation {
                            expandVideos.toggle()
                            expandPhotos = false
                        }
                    }
                    if expandVideos {
                        SimilarStack(video: true)
                        // .padding(.horizontal)
                    }
                }
                .padding()
            }
            Spacer()
            if !expandPhotos && !expandVideos{
//                VStack(spacing: 4) {
//                    Text("Free up 25% storage")
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .multilineTextAlignment(.center)
//                    Text("Let SwAipe optimize your Photos library.")
//                        .foregroundStyle(.secondary)
//                        .font(.headline)
//                        .multilineTextAlignment(.center)
//       
//                }
//                .padding(.vertical)
                StorageChart2(savedStorage: $savedStorage , shouldAnimateAppear: false, dim: 140)
                    .overlay {
                        VStack{
                            AnimatedNumberTextView(occupiedPercentage) { value in
                                Text(String(format: "%.0f%%", value))
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Text("Occupied")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                    }
                    .onAppear{
                        viewModel.setAnimation("similar") {
                            chartAnimation()
                        }
                    }
                    .padding(.vertical)
            }
            ContinueButtonOB()
            
        }
        .padding()
     
    }
    
    func chartAnimation() -> Void {
        withAnimation(Animation.spring(duration: 1.2)) {
            occupiedPercentage = occupiedPercentage - savedPercentage
            savedStorage = 24
        }
        
    }
    


}


struct GalleryBreakdown: View {
    
    @Environment(OBViewModel2.self) var viewModel : OBViewModel2
    
    let grayColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let softWarmRed = Color(red: 0.95, green: 0.3, blue: 0.3)   // Softer red
    let burntOrange = Color(red: 0.95, green: 0.6, blue: 0.2)  // Warmer orange
    let goldenYellow = Color(red: 0.98, green: 0.75, blue: 0.25) // Muted yellow
    let clearColor = Color.clear // Clear color for the background
    
    
    // Input values
    let totalPhotos: Int
    let similarPhotos: Int
    let similarVideos: Int
    let screenshots: Int
    
    // Animation state
    @State private var animate = false
    @State var formattedSavedGBs : Double = 0 // it should come in this form
    @State var opacity : Double = 0
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                Text("Save up to: ")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
                
                AnimatedNumberTextView(formattedSavedGBs) { number in
                    Text("\(String(format: "%.0f GB", number))")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .opacity(opacity)
                
            }
        
            
                
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let mediaCount = totalPhotos - similarPhotos - similarVideos - screenshots
                
                // Base widths (without animation)
                let mediaWidth = CGFloat(mediaCount) / CGFloat(totalPhotos) * totalWidth
                let similarPhotosWidth = CGFloat(similarPhotos) / CGFloat(totalPhotos) * totalWidth
                let similarVideosWidth = CGFloat(similarVideos) / CGFloat(totalPhotos) * totalWidth
                let screenshotsWidth = CGFloat(screenshots) / CGFloat(totalPhotos) * totalWidth
                
                // Animated widths
                let animatedSimilarPhotosWidth = animate ? similarPhotosWidth * 0.5 : similarPhotosWidth
                let animatedSimilarVideosWidth = animate ? similarVideosWidth * 0.5 : similarVideosWidth
                
                ZStack(alignment: .leading) {
                    // Clear background for the entire bar
                    Rectangle()
                        .fill(clearColor)
                        .frame(height: 34)
                    
                    // Media (remaining photos after subtracting similar photos, videos, and screenshots)
                    Rectangle()
                        .fill(grayColor)
                        .frame(width: mediaWidth, height: 34)
                    
                    // Similar Photos (animated)
                    Rectangle()
                        .fill(goldenYellow)
                        .frame(width: animatedSimilarPhotosWidth, height: 34)
                        .offset(x: mediaWidth)
                    
                    // Similar Videos (animated)
                    Rectangle()
                        .fill(burntOrange)
                        .frame(width: animatedSimilarVideosWidth, height: 34)
                        .offset(x: mediaWidth + animatedSimilarPhotosWidth)
                    
                    // Screenshots (red rectangle)
                    Rectangle()
                        .fill(softWarmRed)
                        .frame(width: screenshotsWidth, height: 34)
                        .offset(x: mediaWidth + animatedSimilarPhotosWidth + animatedSimilarVideosWidth)
                    
                    // Border around the entire bar
                    Rectangle()
                        .stroke(.black, style: .init(lineWidth: 1))
                        .frame(height: 34)
                }
            }
            .frame(height: 34) // Set a fixed height for the bar
        }

        .onAppear {
            // Start the animation loop
            viewModel.setAnimation("barAnimation", animation: onAppearAnimation)
        }
    }
    
    func onAppearAnimation() -> Void {
        withAnimation(Animation.spring(duration: 1.2)) {
            animate.toggle()
            formattedSavedGBs = 45.4
            opacity = 1
        }
    }
    
    
    
}


struct SimilarStack : View {
    var video : Bool = false
    var body: some View {
        ScrollView {
            VStack{
                ForEach(0..<10) { index in
                    Text("12 Genuary")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    similarStack(3, video: video)
                    
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.4))
        )
    }
    
    func similarStack(_ n : Int, video: Bool = false) -> some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(0..<n) { index in
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
                        .overlay {
                            if video {
                                Image(systemName: "play.circle.fill")
                                    .font(.headline)

                            }
                        }
                    
                }
            }
        }
    }

    
//    func similarStack(_ n : Int, video: Bool = false) -> some View {
//        ScrollView(.horizontal) {
//            HStack{
//                ForEach(0..<n) { index in
//                    Image(.canal)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 100, height: 150)
//                        .clipShape(.rect(cornerRadius: 8))
//                        .overlay(alignment: .bottomTrailing) {
//                            Image(systemName: index == 0 ? "heart.fill" : "trash.fill")
//                                .font(.headline)
//                                .padding(2)
//                                .foregroundStyle( index == 0 ? .green : .red)
//                                
//                        }
//                        .overlay {
//                            if video {
//                                Image(systemName: "play.circle.fill")
//                                    .font(.headline)
//
//                            }
//                        }
//                    
//                }
//            }
//        }
//    }

}



#Preview {
    SimilarOB2(page: .constant(1))
        .environment(OBViewModel2())
        .preferredColorScheme(.dark)
}

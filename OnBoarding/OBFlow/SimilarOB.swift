//
//  SimilarOB.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 13/03/25.
//

import SwiftUI

struct SimilarOB2: View {
    @Binding var page: Int
    let grayColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let burntOrange = Color(red: 0.95, green: 0.6, blue: 0.2)
    let goldenYellow = Color(red: 0.98, green: 0.75, blue: 0.25)
    let savedPercentage: Double = 25
    @State var expandPhotos = false
    @State var expandVideos = false
    
    @State var savedStorage: Double = 0
    @State var occupiedPercentage: Double = 85
    @Environment(OBViewModel2.self) var viewModel: OBViewModel2
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
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
            
            GalleryBreakdown(totalPhotos: 4121, similarPhotos: 1251, similarVideos: 540)
            
            if !expandVideos {
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(burntOrange)
                            .stroke(.black, style: .init(lineWidth: 1.5))
                            .frame(width: 25, height: 25)
                        
                        VStack(alignment: .leading) {
                            Text("Similar photos (1244)")
                                .font(.title2)
                                .fontWeight(.semibold)
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
                    }
                }
                .padding()
            }
            
            if !expandPhotos {
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(goldenYellow)
                            .stroke(.black, style: .init(lineWidth: 1.5))
                            .frame(width: 25, height: 25)
                        
                        VStack(alignment: .leading) {
                            Text("Similar videos (25)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Save around 2.3 GB")
                                .foregroundStyle(.secondary)
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
                    }
                }
                .padding()
            }
            if !expandPhotos && !expandVideos {
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(grayColor)
                            .stroke(.black, style: .init(lineWidth: 1.5))
                            .frame(width: 25, height: 25)
                        
                        VStack(alignment: .leading) {
                            Text("Media")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("All other media on the device")
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
               
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                   
                }
                .padding()
                Text("*These are estimates made by the system based on the media files found on your device.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .padding()
            }
            

          // Spacer()

            if !expandPhotos && !expandVideos {
                
                
                HStack(spacing: 24) {
                    CircularStorage(savedStorage: $savedStorage, shouldAnimateAppear: false, dim: 120, linewidth: 12)
                        .overlay {
                            VStack {
                                AnimatedNumberTextView(occupiedPercentage) { value in
                                    Text(String(format: "%.0f%%", value))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                Text("Occupied")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        }
                        .onAppear {
                            viewModel.setAnimation("similar") {
                                chartAnimation()
                            }
                        }
                    VStack(spacing: 4){
                        Text("Get rid of similars")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                     

                        Text("SwAipe will choose your best similars thanks to its AI scoring system. ")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                    }
                
                    
                }
                .fixedSize(horizontal: false, vertical: true)


//                .padding(.all, 24)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.black.opacity(0.3))
//                )
                .padding()
            }
            Spacer()
            ContinueButtonOB()
        }
        .padding()
    }
    
    func chartAnimation() {
        withAnimation(Animation.spring(duration: 1.2)) {
            occupiedPercentage -= savedPercentage
            savedStorage = 24
        }
    }
}

struct GalleryBreakdown: View {
    @Environment(OBViewModel2.self) var viewModel: OBViewModel2
    
    let burntOrange = Color(red: 0.95, green: 0.6, blue: 0.2)
    let goldenYellow = Color(red: 0.98, green: 0.75, blue: 0.25)
    let grayColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let clearColor = Color.clear
    
    let totalPhotos: Int
    let similarPhotos: Int
    let similarVideos: Int
    
    @State private var animate = false
    @State var formattedSavedGBs: Double = 0
    @State var opacity: Double = 0
    
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
                let mediaCount = totalPhotos - similarPhotos - similarVideos
                let mediaWidth = CGFloat(mediaCount) / CGFloat(totalPhotos) * totalWidth
                let similarPhotosWidth = CGFloat(similarPhotos) / CGFloat(totalPhotos) * totalWidth
                let similarVideosWidth = CGFloat(similarVideos) / CGFloat(totalPhotos) * totalWidth
                
                let animatedSimilarPhotosWidth = animate ? similarPhotosWidth * 0.5 : similarPhotosWidth
                let animatedSimilarVideosWidth = animate ? similarVideosWidth * 0.5 : similarVideosWidth
                
                ZStack(alignment: .leading) {
                    Rectangle().fill(clearColor).frame(height: 34)
                    Rectangle().fill(grayColor).frame(width: mediaWidth, height: 34)
                    Rectangle().fill(goldenYellow).frame(width: animatedSimilarPhotosWidth, height: 34).offset(x: mediaWidth)
                    Rectangle().fill(burntOrange).frame(width: animatedSimilarVideosWidth, height: 34).offset(x: mediaWidth + animatedSimilarPhotosWidth)
                    Rectangle().stroke(.black, style: .init(lineWidth: 1)).frame(height: 34)
                }
            }
            .frame(height: 34)
            .onAppear {
                viewModel.setAnimation("barAnimation", animation: onAppearAnimation)
            }
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
        .frame(maxWidth: .infinity, alignment: .leading)

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
    SimilarOB2(page: .constant(2))
        .environment(OBViewModel2())
        .background(
            GeneralBackground(opacity: 0.2)
        )
        .preferredColorScheme(.dark)
}



//MARK: -- The refactored swipe mechanism will address several critical issues that we had with the previous version:

// 1. Lack of video support

// 2. UI business and logic tangled together.

// 3. Weird way of updating each card image.

// 4. Lack of generalization. We could not re use that component.

// 5. Not previewable. Thats a whole another issue of the SwAipe project, but there was no way of previewing those swipable cards.

//MARK: -- We'll start with the generalization

/// In order to make the view as generalizable as possible, we need to move the UI business to a dedicated viewmodel, that adheres to some protocl we make.



import SwiftUI
import Photos

// we'll need the use the observable object. Generics dont interact well with the new observable macro

struct AssetWrapper {
    
    var phasset : PHAsset
    var isKept : Bool
    var isTrashed : Bool
    var score : Double
}

struct CardContent : Identifiable, Equatable {
    
    var id : UUID = UUID()
    
    var asset : PHAsset  // use this property to check if video
     
    var image: UIImage?
    
    var translation : CGSize = .zero
    
    var rotation : Double = 0
    
}




class SwipeViewModel : SwipeViewModelProtocol {
    
    var shouldLoadNewCardContent: Bool = true
    var cardSize: CGSize = .init(width: 200, height: 350)
    
    @Published var currentIndex: Int = 0
    @Published var currentCardOffset: CGSize = .zero
    @Published var currentCardRotation: Double = 0
    @Published var cardContentStack: [CardContent] = []
    @Published var cardCopies: [CardAnimationCopy] = []
    
    // the entire collectio of wrappers for the current month.
    var cardQuee: [AssetWrapper] = []

}

struct CardSwipeView<ViewModel: SwipeViewModelProtocol>: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @Namespace var scoreAnimation
    // Dynamic offset calculations based on card height
    private var baseOffset: CGFloat {
        (viewModel.cardSize.height / 550) * -100 // Original ratio: 550:100
    }
    private var offsetIncrement: CGFloat {
        (viewModel.cardSize.height / 550) * 50 // Original ratio: 550:50
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                // add the computation of the real height of the zstack, using a color clear to fill the real space of the view
                let progress = min(abs(viewModel.currentCardOffset.width) / viewModel.horizontalThreshold, 1.0)
                
                // Fourth card (currentIndex +3)
                if viewModel.currentIndex + 3 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 3].phasset,
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8)
                    .offset(y: baseOffset) // Dynamic base offset
                }
                
                // Third card (currentIndex +2)
                if viewModel.currentIndex + 2 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 2].phasset,
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8 + (0.1 * progress))
                    .offset(y: baseOffset + (offsetIncrement * progress)) // Scaled dynamic offset
                }
                
                // Second card (currentIndex +1)
                if viewModel.currentIndex + 1 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 1].phasset,
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.9 + (0.1 * progress))
                    .offset(y: (baseOffset / 2) + (offsetIncrement * progress)) // Half base + dynamic
                }
                
                // Top card with gesture
                if viewModel.currentIndex < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex].phasset,
                        size: viewModel.cardSize
                    )
                    .matchedGeometryEffect(id: "swipedCard", in: scoreAnimation, properties: .position, isSource: true)
                    .offset(viewModel.currentCardOffset)
                    .rotationEffect(.degrees(viewModel.currentCardRotation))
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged(viewModel.onDragChanged)
                        .onEnded(viewModel.onDragEnded)
                    )
                }
                
                // Card copies
                ForEach(viewModel.cardCopies) { copy in
                    Image(uiImage: copy.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: copy.shouldAnimate ? copy.toDimension.width : copy.fromDimension.width,
                               height: copy.shouldAnimate ? copy.toDimension.height : copy.fromDimension.height)
                        .clipShape(.rect(cornerRadius: copy.shouldAnimate ? 25 : 12))
                        .rotationEffect(.degrees(copy.rotation))
                        .matchedGeometryEffect(id: copy.shouldAnimate ? copy.matchedId : "swipedCard" ,
                                               in: scoreAnimation, properties: .position, isSource: false)
                        .allowsHitTesting(false)
                }
            }
            // Positions the placeholder for the card copy animation
            .overlay {
                Color.clear.frame(width: 1, height: 1)
                    .matchedGeometryEffect(id: "right", in: scoreAnimation, properties: .position, isSource: true)
                    .offset(x: 700)
                
                Color.clear.frame(width: 1, height: 1)
                    .matchedGeometryEffect(id: "left", in: scoreAnimation, properties: .position, isSource: true)
                    .offset(x: -700)
            }
            if let matchedViewModel = viewModel as? any MatchedGeometryProtocol {
                ZStack{
                    ScrollView(.horizontal) {
                        LazyHStack{
                            ForEach(matchedViewModel.littleCircledStack) { model in
                                
                                Image(uiImage: model.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    .matchedGeometryEffect(id: model.id.uuidString, in: scoreAnimation, properties: .position, isSource: true)
                            }
                        }
                    }
                    Color.clear.frame(height: 50)
                }
            }


        }
        .task {
            do {
                try await viewModel.cardContentStackFill()
            } catch {
                print("Error loading initial cards: \(error)")
            }
        }
    }
}
struct LoadingCardView< ViewModel : SwipeViewModelProtocol> : View {
    
    // the current index. It represents the last element of the card quee being taken into account
    @EnvironmentObject var viewModel : ViewModel
    var currentAsset : PHAsset
    let size : CGSize

    @State var cardContent : CardContent?
    
    var body: some View {
        Group {
            if let image = cardContent?.image  {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.black, lineWidth: 2)
                    })
                    .clipShape(.rect(cornerRadius: 12))
                
            }
            else{
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .onChange(of: viewModel.cardContentStack.first(where: {$0.asset.localIdentifier == currentAsset.localIdentifier})) { old, newValue in
            //
            if let newValue = newValue {
                cardContent = newValue
            }
        }
    
        
    }
}


struct InitialView : View {
    @State var finishedFetchingAssets : Bool = false
    @StateObject var viewModel : SwipeViewModel = .init()
    
    
    var body: some View {
        if !finishedFetchingAssets {
            Button("Fetch assets and switch view") {
                //
                let assets = AIPhotoManager.shared.fetchAllAssets().values
                
                var wrappers = assets.map({AssetWrapper(phasset: $0, isKept: false, isTrashed: false, score: Double.random(in: 0...1))})
                wrappers.sort(by: {$0.phasset.creationDate ?? .now > $1.phasset.creationDate ?? .now})
                viewModel.cardQuee = wrappers
                finishedFetchingAssets.toggle()
            }
        }
        else {
            CardSwipeView<SwipeViewModel>()
                .environmentObject(viewModel)
        }
        
    }
}

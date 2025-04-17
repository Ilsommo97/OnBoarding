

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



struct CardSwipeView<ViewModel: SwipeViewModelProtocol>: View {
    @EnvironmentObject var viewModel: ViewModel
    var finishedAnimation : Namespace.ID
    @Namespace var scoreAnimation

    // Dynamic offset calculations based on card height
    private var baseOffset: CGFloat {
        (viewModel.cardSize.height / 550) * -100 // Original ratio: 550:100
    }
    private var offsetIncrement: CGFloat {
        (viewModel.cardSize.height / 550) * 50 // Original ratio: 550:50
    }
    
    var body: some View {
        let scaledHeight = viewModel.cardSize.height * 0.8
        let heightDifferenceWhenScaled = (viewModel.cardSize.height - scaledHeight) / 2
        let heightToAccountFor = abs(baseOffset) - heightDifferenceWhenScaled
        let progress = min(abs(viewModel.currentCardOffset.width) / viewModel.horizontalThreshold, 1.0)

        VStack {
            ZStack(alignment: .bottom) {
                Color.clear.frame(height: self.viewModel.cardSize.height + heightToAccountFor)
                // Fourth card (currentIndex +3)
                if viewModel.currentIndex + 3 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 3],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8)
                    .offset(y: baseOffset) // Dynamic base offset
                }
                
                // Third card (currentIndex +2)
                if viewModel.currentIndex + 2 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 2],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8 + (0.1 * progress))
                    .offset(y: baseOffset + (offsetIncrement * progress)) // Scaled dynamic offset
                }
                
                // Second card (currentIndex +1)
                if viewModel.currentIndex + 1 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 1],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.9 + (0.1 * progress))
                    .offset(y: (baseOffset / 2) + (offsetIncrement * progress)) // Half base + dynamic
                }
                
                // Top card with gesture
                
                if viewModel.currentIndex < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex],
                        size: viewModel.cardSize,
                        isFirstCard: true
                    )
                    .matchedGeometryEffect(id: "swipedCard", in: scoreAnimation, properties: .position, isSource: true)
                    .offset(viewModel.currentCardOffset)
                    .rotationEffect(.degrees(viewModel.currentCardRotation))
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged(viewModel.onDragChanged)
                        .onEnded(viewModel.onDragEnded)
                    )
     
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
            if let matchedViewModel = viewModel as? (any ScoreAnimationProtocol) {
                // Now matchedViewModel conforms to both protocols
                // You can use your modifier directly
                ZStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(matchedViewModel.littleCircledStack) {  model in
                                
                                Image(uiImage: model.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: matchedViewModel.littleCircleStackDim, height: matchedViewModel.littleCircleStackDim)
                                    .clipShape(RoundedRectangle(cornerRadius: matchedViewModel.littleCircleStackDim / 2))
                                    .matchedGeometryEffect(id: model.id.uuidString, in: scoreAnimation, properties: .position, isSource: true)
                                    .expressionModifier({ view in
                                        if let coordinator = matchedViewModel as? any MatchedGeometryCoordinator {
//                                            view.modifier(
//                                                MatchedGeometryModifier(viewModel: coordinator, contentMode: .fill, cornerRadius: 2, fromId: "", toId: "", isFromView: true, namespace: finishedAnimation, image: model.image)
//                                            )
                                        }
                                        else {
                                            view
                                        }
                                    })
                                   
                                    .opacity(model.shouldHide ? 0 : 1)
                            }
                        }
                    }
                    Color.clear
                        .frame(width: 1, height: matchedViewModel.littleCircleStackDim)
                }
                .padding(.horizontal)
            }
        }
        //Animation placeholders and card copies
        .overlay(content: {
            // Card copies & Placeholders
            ZStack{
                ForEach(viewModel.cardCopies) { copy in
                    //MARK: -- The actual images being transitioned. You can recognize the ones that are moving since they have isSource set to false. All other view have isSource = true, meaning they act as position placeholders.
                    Image(uiImage: copy.image ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: copy.shouldAnimate ? copy.toContentMode : copy.fromContentMode)
                        .frame(width: copy.shouldAnimate ? copy.toDimension.width : copy.fromDimension.width,
                               height: copy.shouldAnimate ? copy.toDimension.height : copy.fromDimension.height)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thinMaterial)
                        )
                        .clipShape(.rect(cornerRadius: copy.shouldAnimate ? 25 : 12))
                      
                        .rotationEffect(.degrees(copy.shouldAnimate ? .zero : copy.rotation))
                        .matchedGeometryEffect(id: copy.shouldAnimate ? copy.matchedId : "swipedCard" ,
                                               in: scoreAnimation, properties: .position, isSource: false)
                        .allowsHitTesting(false)
                    
                    
                    Color.clear.frame(width: 1, height: 1)
                        .matchedGeometryEffect(id: "\(copy.assetWrapper.phasset.localIdentifier) right", in: scoreAnimation, properties: .position, isSource: true)
                        .offset(x: 700, y: copy.offsetY )
                    
                    Color.clear.frame(width: 1, height: 1)
                        .matchedGeometryEffect(id: "\(copy.assetWrapper.phasset.localIdentifier) left", in: scoreAnimation, properties: .position, isSource: true)
                        .offset(x: -700, y: copy.offsetY )
                    
                }
            }
        })
        .task {
            do {
                try await viewModel.cardContentStackFill()
            } catch {
                print("Error loading initial cards: \(error)")
            }
        }
    }
}


//MARK: -- Duplication of the card swipe view. This one has the view model conforming to the matched geometry coordinator, so that it can implement the custom matched geometry modifier for the final swipe view animation. I was not able to work my way around swift generics! Ive tried a lot
struct CardSwipeViewCoordinated<ViewModel: SwipeViewModelProtocol & MatchedGeometryCoordinator>: View {
    @EnvironmentObject var viewModel: ViewModel
    var finishedAnimation : Namespace.ID
    @Namespace var scoreAnimation

    // Dynamic offset calculations based on card height
    private var baseOffset: CGFloat {
        (viewModel.cardSize.height / 550) * -100 // Original ratio: 550:100
    }
    private var offsetIncrement: CGFloat {
        (viewModel.cardSize.height / 550) * 50 // Original ratio: 550:50
    }
    
    var body: some View {
        let scaledHeight = viewModel.cardSize.height * 0.8
        let heightDifferenceWhenScaled = (viewModel.cardSize.height - scaledHeight) / 2
        let heightToAccountFor = abs(baseOffset) - heightDifferenceWhenScaled
        let progress = min(abs(viewModel.currentCardOffset.width) / viewModel.horizontalThreshold, 1.0)

        VStack {
            ZStack(alignment: .bottom) {
                Color.clear.frame(height: self.viewModel.cardSize.height + heightToAccountFor)
                // Fourth card (currentIndex +3)
                if viewModel.currentIndex + 3 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 3],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8)
                    .offset(y: baseOffset) // Dynamic base offset
                }
                
                // Third card (currentIndex +2)
                if viewModel.currentIndex + 2 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 2],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.8 + (0.1 * progress))
                    .offset(y: baseOffset + (offsetIncrement * progress)) // Scaled dynamic offset
                }
                
                // Second card (currentIndex +1)
                if viewModel.currentIndex + 1 < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex + 1],
                        size: viewModel.cardSize
                    )
                    .scaleEffect(0.9 + (0.1 * progress))
                    .offset(y: (baseOffset / 2) + (offsetIncrement * progress)) // Half base + dynamic
                }
                
                // Top card with gesture
                
                if viewModel.currentIndex < viewModel.cardQuee.count {
                    LoadingCardView<ViewModel>(
                        currentAsset: viewModel.cardQuee[viewModel.currentIndex],
                        size: viewModel.cardSize,
                        isFirstCard: true
                    )
                    .matchedGeometryEffect(id: "swipedCard", in: scoreAnimation, properties: .position, isSource: true)
                    .offset(viewModel.currentCardOffset)
                    .rotationEffect(.degrees(viewModel.currentCardRotation))
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged(viewModel.onDragChanged)
                        .onEnded(viewModel.onDragEnded)
                    )
     
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
            if let matchedViewModel = viewModel as? (any ScoreAnimationProtocol) {
                // Now matchedViewModel conforms to both protocols
                // You can use your modifier directly
                ZStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(matchedViewModel.littleCircledStack) {  model in
                                VStack(spacing: 2){
                                    Image(uiImage: model.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: matchedViewModel.littleCircleStackDim, height: matchedViewModel.littleCircleStackDim)
                                        .clipShape(RoundedRectangle(cornerRadius: matchedViewModel.littleCircleStackDim / 2 ))
                                        .matchedGeometryEffect(id: model.id.uuidString, in: scoreAnimation, properties: .position, isSource: true)
                                        .expressionModifier({ view in
                                            if let index = matchedViewModel.littleCircledStack.firstIndex(where: {$0.id == model.id}) {
                                                view
                                                    .modifier(
                                                        MatchedGeometryModifier(viewModel: viewModel, width: matchedViewModel.littleCircleStackDim, height: matchedViewModel.littleCircleStackDim, contentMode: .fill, cornerRadius: matchedViewModel.littleCircleStackDim / 2,
                                                                                fromId: "finished\(model.id.uuidString)",
                                                                                toId: index > 0 ? "static" : "\(0)",
                                                                                isFromView: true,
                                                                                namespace: finishedAnimation,
                                                                                image: model.image)
                                                    )
                                            }
                                            else {
                                                view
                                            }
                                        })
                                        .opacity(model.shouldHide ? 0 : 1)

                       
                                    HStack(spacing: 4){
                                        Image(systemName: "sparkles")
                                            .font(.system(.caption, design: .default, weight: .regular))
                                        
                                        if true {
                                            Text("\(String(format: "%.1f%%", model.score > 0 ? (model.score * 100) : 0))")
                                                .font(.system(.caption, design: .default, weight: .regular))
                                        }
                                        else {
                                            Image(systemName: "lock.fill")
                                                .font(.system(.caption, design: .default, weight: .regular))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Color.clear
                        .frame(width: 1, height: matchedViewModel.littleCircleStackDim)
                }
                .padding(.horizontal)
            }
        }
        //Animation placeholders and card copies
        .overlay(content: {
            // Card copies & Placeholders
            ZStack{
                ForEach(viewModel.cardCopies) { copy in
                    //MARK: -- The actual images being transitioned. You can recognize the ones that are moving since they have isSource set to false. All other view have isSource = true, meaning they act as position placeholders.
                    Image(uiImage: copy.image ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: copy.shouldAnimate ? copy.toContentMode : copy.fromContentMode)
                        .frame(width: copy.shouldAnimate ? copy.toDimension.width : copy.fromDimension.width,
                               height: copy.shouldAnimate ? copy.toDimension.height : copy.fromDimension.height)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thinMaterial)
                        )
                        .clipShape(.rect(cornerRadius: copy.shouldAnimate ? 25 : 12))
                        .rotationEffect(.degrees(copy.shouldAnimate ? .zero : copy.rotation))
                        .matchedGeometryEffect(id: copy.shouldAnimate ? copy.matchedId : "swipedCard" ,
                                               in: scoreAnimation, properties: .position, isSource: false)
                        .allowsHitTesting(false)
                    
                    
                    Color.clear.frame(width: 1, height: 1)
                        .matchedGeometryEffect(id: "\(copy.assetWrapper.phasset.localIdentifier) right", in: scoreAnimation, properties: .position, isSource: true)
                        .offset(x: 700, y: copy.offsetY )
                    
                    Color.clear.frame(width: 1, height: 1)
                        .matchedGeometryEffect(id: "\(copy.assetWrapper.phasset.localIdentifier) left", in: scoreAnimation, properties: .position, isSource: true)
                        .offset(x: -700, y: copy.offsetY )
                    
                }
            }
        })
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
    
    @EnvironmentObject var viewModel : ViewModel
    var currentAsset : AssetWrapper
    let size : CGSize
    var isFirstCard : Bool = false
    @State var cardContent : CardContent?
    
    var body: some View {
        Group {
            if let image = cardContent?.image  {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: cardContent?.aspectRatio ?? .fill)
                    .frame(width: size.width, height: size.height)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.black, lineWidth: 2)
                    })
                    .modifier(CategorizedModifier(wrapper: currentAsset))
                    .clipShape(.rect(cornerRadius: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    )
                    
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
        
        .onChange(of: viewModel.cardContentStack.first(where: {$0.asset.localIdentifier == currentAsset.phasset.localIdentifier})) { old, newValue in
            //
            if let newValue = newValue {
                cardContent = newValue
            }
            else {
                cardContent = nil
            }
        }
    
        
    }
}




//
//  SwipeProtocol.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 29/03/25.
//

import SwiftUI
import Photos


struct RankedCircledImage : Identifiable {
    
    
    // We can use the string associated to the id for the matched Geo eff
    var id : UUID = UUID()
    
    var asset : PHAsset
    
    var score : Double
    
    var image : UIImage
    
    var shouldHide : Bool
        
}

struct CardAnimationCopy : Identifiable {
    
    //MARK: -- It uses matched geo eff to retrieve the start position. The card copy gets rendered on the screen as soon as we append to the its array the relative copy. The matched geo effect associates its position to the current swiped card. We then trigger its shouldAnimate parameter. The id changes, moving to either the circled image or one placeholder view offscreen. aspect ratio, frame and corner radius also depend on the should animate paramter
    
    var id : UUID = UUID()
    
    var assetWrapper : AssetWrapper
    
    var image : UIImage
    
    var shouldAnimate = false
    
    var matchedId : String
    
    var fromDimension : CGSize
    
    var rotation : Double
    
    var toDimension : CGSize
    
}


protocol SwipeViewModelProtocol : ObservableObject {
    // A new concept: these ones are all the wrappers of the associated month. In general, it represents all the wrappers that the user can swipe for the current swipe view.
    // Before, we were popping stuff from this array
        
    var cardQuee : [AssetWrapper] {get set }
    var shouldLoadNewCardContent : Bool { get set }
    var cardSize : CGSize { get set}
    
    // MARK: -- Published properties
    var cardContentStack : [CardContent] {get set}
    var cardCopies : [CardAnimationCopy] {get set}
    var currentIndex : Int {get set}
    var currentCardOffset: CGSize { get set }
    var currentCardRotation: Double { get set }
        
}


//MARK: -- Implements dragesture
extension SwipeViewModelProtocol {
    
    var horizontalThreshold: Double { 70.0 }
    
    // Default implementation
    func onEndedSwipe(_ trashed: Bool, assetWrapper: AssetWrapper) async throws { print("Remember to implement the swipe logic if neeeded!") }
    
    func onDragChanged(_ value: DragGesture.Value) {
        if shouldLoadNewCardContent {
            Task(priority: .userInitiated) {
                // it should already check whether or not we started already
                try await self.startLoadingNewCardContent()
            }
        }
        let translation = value.translation
        currentCardOffset = translation
        // Rotate proportionally to horizontal movement
        currentCardRotation = Double(translation.width / 20)
        shouldLoadNewCardContent = false
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        shouldLoadNewCardContent = true
        let translation = value.translation
        // Resetting the card parameters!
        if abs(translation.width) < horizontalThreshold {
            withAnimation {
                currentCardOffset = .zero
                currentCardRotation = 0
            }
        }
        else {
            // We trigger the swipe gesture.
            let currentAsset = self.cardQuee[self.currentIndex] // the asset being swiped
            let currentCardContent = self.cardContentStack.first(where: {$0.asset.localIdentifier == currentAsset.phasset.localIdentifier})
            let copy = CardAnimationCopy(assetWrapper: currentAsset,
                                         image: currentCardContent?.image ?? UIImage(),
                                         matchedId: currentAsset.phasset.localIdentifier,
                                         fromDimension: self.cardSize,
                                         rotation: currentCardRotation,
                                         toDimension: .init(width: 50, height: 50)
            )
            self.cardCopies.append(copy)
            
            if let matchinIndex = self.cardCopies.firstIndex(where: {$0.assetWrapper.phasset.localIdentifier == currentAsset.phasset.localIdentifier}) {
                if let self = self as? any MatchedGeometryProtocol {
                    
                    
                }
                else {
                    self.cardCopies[matchinIndex].matchedId = translation.width > 0 ? "right" : "left"
                    self.cardCopies[matchinIndex].toDimension = self.cardSize
                    withAnimation(.linear(duration: 0.4)) {
                        self.cardCopies[matchinIndex].shouldAnimate = true
                    }
                }
            }
            
            
            // we reset the UI parameters
            currentCardOffset = .zero
            currentCardRotation = 0
            self.currentIndex += 1
            
            // Implements the Business logic of the swipe
            Task(priority: .background) {
                try await self.onEndedSwipe(translation.width < 0, assetWrapper: currentAsset)
            }
            
        }
        
    }
    
//    private func swipeWithNoMatchedAnimation(_ translation : CGSize, copy: CardContent) {
//        if let matchinIndex = self.cardCopies.firstIndex(where: {$0.id == copy.id}) {
//            withAnimation{
//                self.cardCopies[matchinIndex].translation = translation.width > 0 ? CGSize(width: 700, height: translation.height) : CGSize(width: -700, height: translation.height)
//            } completion: {
//                // we flush useless data now
//                print("Are we entering this closure at all???")
//                self.cardCopies.removeAll(where: {$0.asset.localIdentifier == copy.asset.localIdentifier})
//                self.cardContentStack.removeAll(where: {$0.asset.localIdentifier == copy.asset.localIdentifier})
//            }
//        }
//    }
    
}

//MARK: -- implements default functions the the swipe view always needs:
// -- Initial loading of cards when the view appears.
// -- New loading of card when the user starts swiping
extension SwipeViewModelProtocol {
    
    func cardContentStackFill() async throws {
        
        if cardQuee.isEmpty {return}
        await MainActor.run
        {
            self.currentIndex = self.cardQuee.firstIndex(where: {!$0.isTrashed && !$0.isKept}) ?? 0
        }
        
        var assets : [AssetWrapper] = []
        if self.currentIndex < self.cardQuee.count {
            assets.append(self.cardQuee[self.currentIndex])
        }
        if self.currentIndex + 1 < self.cardQuee.count{
            assets.append(self.cardQuee[self.currentIndex + 1])
        }
        if self.currentIndex + 2 < self.cardQuee.count{
            assets.append(self.cardQuee[self.currentIndex + 2])
        }
        if self.currentIndex + 3 < self.cardQuee.count{
            assets.append(self.cardQuee[self.currentIndex + 3])
        }
        
        try await withThrowingTaskGroup(of: (PHAsset, UIImage).self) { group in
            for (index, asset) in assets.enumerated() {
                
                group.addTask(priority: index <= 1 ? .high : .medium) {
                    let image = try await AIPhotoManager.shared.getImageFromAssetAsync(asset: asset.phasset, targetSize: .init(width: 1080, height: 1080), deliveryMode: .highQualityFormat)
                    return (asset.phasset, image)
                }
            }
            for try await result in group
            {
                await MainActor.run {
                    print("Card content is being appended with image from asset \(result.1)")
                    self.cardContentStack.append(.init(asset: result.0, image: result.1))
                }
            }
        }
        
    }
    
    func startLoadingNewCardContent() async throws {
        // Why + 4? --> The first function that fills the card content stack, already accounts for 4 assets. In other words, we always want to load the fourth card, the one behind each shown card, for which we already should have a card content.
        
        let correctIndex = currentIndex + 4
        if correctIndex < self.cardQuee.count {
            // we can safely access the asset here
            let asset = self.cardQuee[correctIndex].phasset
            
            if let _ = self.cardContentStack.firstIndex(where: {$0.asset.localIdentifier == asset.localIdentifier}) {
                print("Skipping computation: the start new loading card content function has found that a card content is already present for the associated asset")
                return
            }
            await MainActor.run {
                self.cardContentStack.append(.init(asset: asset))
            }
            
            let lowResImage = try await AIPhotoManager.shared.getImageFromAssetAsync(asset: asset, targetSize: .init(width: 1080, height: 1080), deliveryMode: .highQualityFormat)
            
            await MainActor.run {
                if let matchingIndex = self.cardContentStack.firstIndex(where: {$0.asset.localIdentifier == asset.localIdentifier}) {
                    self.cardContentStack[matchingIndex].image = lowResImage
                }
            }
            
            let highResImage = try await AIPhotoManager.shared.getImageFromAssetAsync(asset: asset, targetSize: .init(width: 1080, height: 1080), deliveryMode: .highQualityFormat)
            
            await MainActor.run {
                if let matchingIndex = self.cardContentStack.firstIndex(where: {$0.asset.localIdentifier == asset.localIdentifier}) {
                    self.cardContentStack[matchingIndex].image = highResImage
                }
            }
        }
    }
}




protocol MatchedGeometryProtocol : SwipeViewModelProtocol {
    
    var littleCircledStack : [RankedCircledImage] {get set}
    
}



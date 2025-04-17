//
//  SwipeProtocol.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 29/03/25.
//

import SwiftUI
import Photos



// MARK: - Helper types
private enum SwipeDirection {
    case left
    case right
}

protocol SwipeViewModelProtocol : ObservableObject {
    // A new concept: these ones are all the wrappers of the associated month. In general, it represents all the wrappers that the user can swipe for the current swipe view.
    // Before, we were popping stuff from this array
        
    var cardQuee : [AssetWrapper] {get set }
    var categorizedCount : Int { get set }
    var shouldLoadNewCardContent : Bool { get set }
    var cardSize : CGSize { get set}

        
    // MARK: -- Published properties
    var cardContentStack : [CardContent] {get set}
    var cardCopies : [CardAnimationCopy] {get set}
    var currentIndex : Int {get set}
    var currentCardOffset: CGSize { get set }
    var currentCardRotation: Double { get set }
    var userCategorizedAll : Bool {get set}
    
    func onEndedSwipe(_ trashed: Bool, assetWrapper: AssetWrapper) async throws -> Void

}


//MARK: -- Implements dragesture
extension SwipeViewModelProtocol {
   
    
    var horizontalThreshold: Double { 70.0 }
    
    var generator : UIImpactFeedbackGenerator {
        UIImpactFeedbackGenerator(style: .medium)
    }

    var dateString: String {
        if self.currentIndex < self.cardQuee.count {
            let date = self.cardQuee[self.currentIndex].phasset.creationDate ?? .now
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"  // "21 Jan" format
            return dateFormatter.string(from: date)
        }
        else {
            return  "March"
        }
    }

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
        withAnimation(.linear(duration: 0)) {
            //MARK: -- HOT FIX: Wrapping these changes in a withAnimation block silence the red warning in the console. I don't understand why yet.
            currentCardOffset = translation
            currentCardRotation = Double(translation.width / 20)
        }
        shouldLoadNewCardContent = false
    }
    
    func onDragEnded(_ value: DragGesture.Value) {
        shouldLoadNewCardContent = true
        let translation = value.translation
        
        // Handle small swipe (below threshold)
        if abs(translation.width) < horizontalThreshold {
            withAnimation {
                currentCardOffset = .zero
                currentCardRotation = 0
            }

            return
        }
        
        // Process successful swipe
        processSuccessfulSwipe(translation)
    }

 

    private func processSuccessfulSwipe(_ translation: CGSize) {
        let hasAlreadyBeenSwiped = !self.cardQuee[currentIndex].isKept && !self.cardQuee[currentIndex].isTrashed
        let swipeDirection: SwipeDirection = translation.width > 0 ? .right : .left
        let currentAsset = self.cardQuee[currentIndex]
        
        // Update categorization state
        if hasAlreadyBeenSwiped {
            self.categorizedCount += 1
        }
        
        // Update card state based on swipe direction. We mark the wrapper in the card quee either as kept or trashed
        
        // Create and setup animation copy
        let copy = createAnimationCopy(for: currentAsset)
        self.cardCopies.append(copy)
        

        // Check if all cards categorized
        let userCategorizedAll = self.cardQuee.count == self.categorizedCount
        
        // Process animation with protocol check preserved
        processAnimationWithProtocolCheck(copy, translation, userCategorizedAll)
        
        // Reset current card UI parameters: From this moment on, we are ready to swipe another photo while the animation goes on
        
        currentCardOffset = .zero
        currentCardRotation = 0
 
        updateCardState(swipeDirection)

        // Update current index
        updateCurrentIndex(userCategorizedAll)
        
        // Update collection view if needed
        updateCollectionViewIfNeeded(swipeDirection, userCategorizedAll)
        
        // Execute business logic for the swipe
        executeSwipeBusinessLogic(swipeDirection == .left, currentAsset)
    }

    private func updateCardState(_ direction: SwipeDirection) {
        self.cardQuee[currentIndex].isKept = direction == .right
        self.cardQuee[currentIndex].isTrashed = direction == .left
    }

    private func createAnimationCopy(for asset: AssetWrapper) -> CardAnimationCopy {
        let currentCardContent = self.cardContentStack.first(where: {
            $0.asset.localIdentifier == asset.phasset.localIdentifier
        })
        var contentMode : ContentMode!
        if let image = currentCardContent?.image {
            contentMode = image.size.width > image.size.height ? .fit : .fill
        }
        else {
            contentMode = .fill
        }
        return CardAnimationCopy(
            assetWrapper: asset,
            image: currentCardContent?.image ?? UIImage(),
            matchedId: asset.phasset.localIdentifier,
            fromDimension: self.cardSize,
            rotation: currentCardRotation,
            toDimension: self.cardSize,
            fromContentMode: contentMode,
            toContentMode: contentMode
        )
    }

    private func processAnimationWithProtocolCheck(_ copy: CardAnimationCopy, _ translation: CGSize, _ userCategorizedAll: Bool) {
        guard let matchingIndex = self.cardCopies.firstIndex(where: {
            $0.assetWrapper.phasset.localIdentifier == copy.assetWrapper.phasset.localIdentifier
        }) else { return }
        
        // Preserve the protocol conformance check from the original code
        if let self = self as? any ScoreAnimationProtocol {
            if translation.width < 0 {
                // delete
                swipeWithNoMatchedAnimation(translation, matchinIndex: matchingIndex, copy: copy) {
                    
                    if userCategorizedAll {
                        // modification of the to matched string!
                        self.sortMatchedString()
                        self.userCategorizedAll.toggle()
                    }
                    
                }
            }
            else {
                // Keep - Check score against top scores
                let minScore = self.littleCircledStack.prefix(5).map({$0.score}).min() ?? 0
                let currentAsset = copy.assetWrapper
                let currentCardContent = self.cardContentStack.first(where: {
                    $0.asset.localIdentifier == currentAsset.phasset.localIdentifier
                })
                
                if currentAsset.score > minScore {
                    let duration = 0.35
                    // Add to top scores with animation
                    let newLittleRankedImage = RankedCircledImage(
                        asset: currentAsset.phasset,
                        score: currentAsset.score,
                        image: currentCardContent?.image ?? UIImage(),
                        shouldHide: true
                    )
                
                    withAnimation(.linear(duration: 0.15)) {
                        self.littleCircledStack.append(newLittleRankedImage)
                        self.littleCircledStack.sort(by: {$0.score > $1.score})
                    }
                    
                    
        
                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.1, blendDuration: 0.1),
                                   completionCriteria: userCategorizedAll ? .logicallyComplete :  .removed) {
                        self.cardCopies[matchingIndex].shouldAnimate = true
                        self.cardCopies[matchingIndex].matchedId = newLittleRankedImage.id.uuidString
                        self.cardCopies[matchingIndex].toContentMode = .fill // goes to a l
                        self.cardCopies[matchingIndex].toDimension = CGSize(
                            width: self.littleCircleStackDim,
                            height: self.littleCircleStackDim
                        )
                        
                    } completion: {
                        if let index = self.littleCircledStack.firstIndex(where: {$0.id == newLittleRankedImage.id}) {
                            self.littleCircledStack[index].shouldHide = false
                            if userCategorizedAll {
                                self.userCategorizedAll.toggle()
                            }
                        }
                    }
                    generator.impactOccurred()
                    flushDataAfterAnimations(animationDuration: duration + 1, copy: copy)
                }
                else {
                    // Standard keep animation without top scores
                    swipeWithNoMatchedAnimation(translation, matchinIndex: matchingIndex, copy: copy) {
                        
                        if userCategorizedAll {
                            self.sortMatchedString()
                            self.userCategorizedAll.toggle()
                        }
                        
                    }
                }
            }
        }
        else {
            // No matched geometry protocol - default animation
            swipeWithNoMatchedAnimation(translation, matchinIndex: matchingIndex, copy: copy) {
                withAnimation {
                    if userCategorizedAll {
                        self.userCategorizedAll.toggle()
                    }
                }
            }
        }
    }

    private func updateCurrentIndex(_ userCategorizedAll: Bool) {
        if self.cardQuee.count - 1 == self.currentIndex && !userCategorizedAll {
            self.currentIndex = self.cardQuee.firstIndex(where: { !$0.isKept && !$0.isTrashed }) ?? 0
        } else {
            self.currentIndex += 1
        }
    }

    private func updateCollectionViewIfNeeded(_ direction: SwipeDirection, _ userCategorizedAll: Bool) {
        if !userCategorizedAll {
            if let self = self as? any ScrollSwipeDelegate {
                self.matchCollectionViewIndex(isTrashed: direction == .left)
            }
        }
    }

    private func executeSwipeBusinessLogic(_ isTrashed: Bool, _ assetWrapper: AssetWrapper) {
        Task(priority: .background) {
            try await self.onEndedSwipe(isTrashed, assetWrapper: assetWrapper)
        }
    }
    
    private func sortMatchedString() {
        if let self = self as? any ScoreAnimationProtocol {
            
            for (index , _) in self.littleCircledStack.enumerated() {
                print("calling it, index : \(index)")

                if index == 0 {
                    // first image
                    self.littleCircledStack[index].toMatchedString = "big"
                }
                else if index == 1 {
                    self.littleCircledStack[index].toMatchedString = "first"
                }
                else if index == 2 {
                    self.littleCircledStack[index].toMatchedString = "second"
                }
                else if index == 3 {
                    self.littleCircledStack[index].toMatchedString = "third"
                }
                else if index == 4 {
                    self.littleCircledStack[index].toMatchedString = "fourth"
                }
                else if index == 5 {
                    self.littleCircledStack[index].toMatchedString = "fifth"
                }
                else {
                    self.littleCircledStack[index].toMatchedString = "other"
                }
            }
        }
    }


    private func swipeWithNoMatchedAnimation(_ translation : CGSize, matchinIndex: Int, copy: CardAnimationCopy, completion : @escaping () -> Void) {
        self.cardCopies[matchinIndex].matchedId = translation.width > 0
        ? "\(copy.assetWrapper.phasset.localIdentifier) right" :
          "\(copy.assetWrapper.phasset.localIdentifier) left"
        self.cardCopies[matchinIndex].offsetY = translation.height
         withAnimation(.linear(duration: 0.4)) {
            self.cardCopies[matchinIndex].shouldAnimate = true
         } completion: {
             completion()
         }
        flushDataAfterAnimations(animationDuration: 0.4, copy: copy)
        
    }
    
    //MARK: -- A note on this function. We encountered a lil bug when using the completion block of the animations. Even though the array were successfully popped, the memory continued to increase. Using dispatchquee fixes the problem!
    private func flushDataAfterAnimations(animationDuration : Double, copy: CardAnimationCopy) {
        let afterDuration = animationDuration + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + afterDuration) { [weak self] in
            guard let self = self else { return }
            if let cardCopyIndex = self.cardCopies.firstIndex(where: {$0.assetWrapper.phasset.localIdentifier == copy.assetWrapper.phasset.localIdentifier}) {
                print("Before : \(self.cardCopies.count)")
                self.cardCopies[cardCopyIndex].image = nil
                self.cardCopies.remove(at: cardCopyIndex)
                print("After : \(self.cardCopies.count)")
            }
            if let cardContentIndex = self.cardContentStack.firstIndex(where: {$0.asset.localIdentifier == copy.assetWrapper.phasset.localIdentifier}) {
                print("Before : \(self.cardContentStack.count)")
                self.cardContentStack[cardContentIndex].image = nil
                self.cardContentStack.remove(at: cardContentIndex)
                print("After : \(self.cardContentStack.count)")
            }
        }

    }

}

//MARK: -- implements default functions the the swipe view always needs:
// -- Initial loading of cards when the view appears.
// -- New loading of card when the user starts swiping
extension SwipeViewModelProtocol {
    
    func cardContentStackFill(_ skipFirstAssetLoading : Bool = false) async throws {
        
        if cardQuee.isEmpty {return}
       
        var assets : [AssetWrapper] = []
        if !skipFirstAssetLoading {
            if self.currentIndex < self.cardQuee.count {
                assets.append(self.cardQuee[self.currentIndex])
            }
        }
        let presentAssets = self.cardContentStack.map({$0.asset})
        if self.currentIndex + 1 < self.cardQuee.count{
            
            
            let asset = self.cardQuee[self.currentIndex + 1]
            if !presentAssets.contains(asset.phasset){
                assets.append(asset)
            }
        }
        if self.currentIndex + 2 < self.cardQuee.count{
            let asset = self.cardQuee[self.currentIndex + 2]
            if !presentAssets.contains(asset.phasset){
                assets.append(asset)
            }
        }
        if self.currentIndex + 3 < self.cardQuee.count{
            let asset = self.cardQuee[self.currentIndex + 3]
            if !presentAssets.contains(asset.phasset){
                assets.append(asset)
            }
        }
        
        if assets.isEmpty {return}
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




protocol ScoreAnimationProtocol : SwipeViewModelProtocol {
    
    var littleCircledStack : [RankedCircledImage] {get set}
    
}

extension ScoreAnimationProtocol {
    var littleCircleStackDim : Double { scaleHeight(40) }
}


protocol ScrollSwipeDelegate : SwipeViewModelProtocol {
    

    var imageRequestID : PHImageRequestID? { get set }
    var collectionView : UICollectionView? { get set }
    var savedSize : Double { get set }
}



extension ScrollSwipeDelegate {

    
    var redOpacity : Double { 0.15 }
    var greenOpacity : Double { 0.15 }
    var cellSize : CGSize { .init(width: 30 , height: 35)}
    var shouldDisableBackward : Bool
    {

        if let firstUncategorizedIndex = self.cardQuee.firstIndex(where: {!$0.isTrashed && !$0.isKept}) {
            return firstUncategorizedIndex >= self.currentIndex
        }
        else {
            return true
        }
    }
    
    // [X X X O O O X O X O O O X X X O ]
    var shouldDisableForward : Bool {
        
        if self.currentIndex < self.cardQuee.count {
            let isCategorized = self.cardQuee[self.currentIndex].isKept || self.cardQuee[self.currentIndex].isTrashed
            if !isCategorized {
                return true
            }
            if let _ = self.cardQuee.suffix(self.currentIndex).firstIndex(where: {!$0.isKept && !$0.isTrashed}) {
                return false // we will navigate to this exact index
            }
            else {
                return true
            }

        }
        else {
            return true
        }
    }
    
    func imageLoadingForScrollDetected(_ asset : PHAsset) {
        // we cancel any request!
        if let request = self.imageRequestID {
            PHImageManager.default().cancelImageRequest(request)
        }
        self.cardContentStack = []
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
       // options.resizeMode = .fast

        self.cardContentStack.append(.init(asset: asset))
        self.imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1080, height: 1080), contentMode: .aspectFill, options: options, resultHandler: { [weak self] image, dictError in
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                if let matchingIndex = self.cardContentStack.firstIndex(where: {$0.asset.localIdentifier == asset.localIdentifier}) {
                    self.cardContentStack[matchingIndex].image = image
                }
            }
        })
       // print(self.cardContentStack.count)
        
        
        
        
        
    }
    
    
    func scrollBackward() {
        self.cardContentStack.removeAll()

        if let firstIndex = self.cardQuee.firstIndex(where: {!$0.isKept && !$0.isTrashed}) {
            scrollAndScale(firstIndex)
        }
    }
    
    func scrollForward() {
        self.cardContentStack.removeAll()

        if let firstIndex = self.cardQuee[self.currentIndex...].firstIndex(where: {!$0.isKept && !$0.isTrashed}) {
            scrollAndScale(firstIndex)
        }
    }
    
    private func scrollAndScale(_ index : Int)
    {
        // Scroll to the cell first (if not already visible)
        self.currentIndex = index
        Task {
            try await self.cardContentStackFill()
        }
        // Disable system animation
        collectionView?.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )

        
    
    }
    
    
    
    func matchCollectionViewIndex(isTrashed : Bool) {
        guard let collectionView = self.collectionView else {return}
        collectionView.scrollToItem(at: .init(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        let animation = {
            collectionView.visibleCells.forEach { (cell) in
                if let cellIndexPath = collectionView.indexPath(for: cell) {
                    if cellIndexPath.item == self.currentIndex - 1 {
                        // updating last cell
                        if let cell = cell as? Cell {
                            cell.greenView.layer.opacity = Float(isTrashed ? 0 : self.greenOpacity)
                            cell.redView.layer.opacity = Float(isTrashed ? self.redOpacity : 0)
                        }
                    }
                    let scale = (cellIndexPath == IndexPath(item: self.currentIndex, section: 0)) ? 1.5 : 1.0
                    cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
        }
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction, .curveEaseOut],
                       animations: animation
        )
    }
}

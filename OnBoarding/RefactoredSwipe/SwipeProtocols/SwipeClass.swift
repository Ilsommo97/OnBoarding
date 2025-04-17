//
//  SwipeClass.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 05/04/25.
//

import SwiftUI
import Foundation
import Photos

class BaseSwipeClass : SwipeViewModelProtocol {
    
    //MARK: -- Implements only the base protocol
    
    var cardQuee: [AssetWrapper]
    
    var shouldLoadNewCardContent: Bool
    
    var cardSize: CGSize
    
    var categorizedCount: Int
    
    @Published var cardContentStack: [CardContent]
    
    @Published var cardCopies: [CardAnimationCopy]
    
    @Published var currentIndex: Int
    
    @Published var currentCardOffset: CGSize
    
    @Published var currentCardRotation: Double
    
    @Published var userCategorizedAll: Bool
    

    
    required init(cardQuee : [AssetWrapper]) {
        self.cardQuee = cardQuee
        self.currentIndex = self.cardQuee.firstIndex(where: {!$0.isKept && !$0.isTrashed}) ?? 0
        self.categorizedCount = self.cardQuee.filter({$0.isKept || $0.isTrashed}).count
        self.cardContentStack = []
        self.cardSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 550)
        self.cardCopies = []
        self.currentCardOffset = .zero
        self.currentCardRotation = 0
        self.shouldLoadNewCardContent = true
        self.userCategorizedAll = false
    }
}

class MatchedClass : BaseSwipeClass, ScoreAnimationProtocol {
    @Published var littleCircledStack: [RankedCircledImage] = []
}



class GeneralSwipeClass : BaseSwipeClass, ScoreAnimationProtocol, ScrollSwipeDelegate, MatchedGeometryCoordinator {
    
    //MARK: -- MatchedGeometryCoordinator
    var fromViews: Set<MatchedGeometryModel> = .init()
    var toViews: Set<MatchedGeometryModel> = .init()
    
    @Published var shouldDestroyFromView: Bool = false
    @Published var shouldHideFromViews: Bool = false
    @Published var shouldHideToViews: Bool = false
    @Published var animatedViews: [AnimationGeometryModel] = []
    @Published var shouldChangeView: Bool = false
    @Published var animationHasFinished: Bool = false
    //MARK: -- matched geo protocol
    @Published var littleCircledStack: [RankedCircledImage] = []
    
    
    
    var imageRequestID: PHImageRequestID? = nil
    var collectionView: UICollectionView? = nil
    var savedSize: Double
    
    // Designated initializer
    init(cardQuee: [AssetWrapper], savedSize: Double) {
        self.savedSize = savedSize
        super.init(cardQuee: cardQuee)
        
    }
    
    // Required initializer - provide default for savedSize
    required init(cardQuee: [AssetWrapper]) {
        fatalError("GeneralSwipeClass must be initialized with init(cardQuee:savedSize:)")
        // This will completely prevent accidental usage
    }
    
    
    // Set of properties for the finished swipe animation
    func optionalModificationAnimatedViews() {
        for index in self.animatedViews.indices {
            let fromString = self.animatedViews[index].fromMatchedString.replacingOccurrences(of: "finished", with: "")
            print("from string after filter is \(fromString)")
            if let matchingIndex = self.littleCircledStack.firstIndex(where: {$0.id.uuidString == fromString}) {
                if matchingIndex == 0 {
                    self.animatedViews[index].toMatchedString = "big"
                }
                else if matchingIndex == 1 {
                    self.animatedViews[index].toMatchedString = "first"

                }
                else if matchingIndex == 2 {
                    self.animatedViews[index].toMatchedString = "second"
                }
                else if matchingIndex == 3 {
                    self.animatedViews[index].toMatchedString = "third"
                }
                else if matchingIndex == 4 {
                    self.animatedViews[index].toMatchedString = "fourth"
                }
                else if matchingIndex == 5 {
                    self.animatedViews[index].toMatchedString = "fifth"
                }
                else {
                    self.animatedViews[index].toMatchedString = "placeholder"
                }
            }
        }
    }
    
    func startAnimatingOverlayCopies(completion: @escaping (Bool) -> Void) {
        // overriding the default animation.
        // We start animating the animation copies that match the order stack they originated from!
        print("We should have the same count! \(self.animatedViews.count) animation copies count and \(self.littleCircledStack.count) little circles count")
        
        for index in self.littleCircledStack.indices {
            
            let reversedIndex = max(self.animatedViews.count - index - 1, 0)
            let uiidString = self.littleCircledStack[reversedIndex].id.uuidString
            print("reversed index is \(reversedIndex)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                if let matchingIndex = self.animatedViews.firstIndex(where: {$0.fromMatchedString.replacingOccurrences(of: "finished", with: "") == uiidString }  ) {
                    withAnimation(.interactiveSpring(duration: 0.6, extraBounce: reversedIndex > 3 ? 0.01 : 0.15, blendDuration: 0.1)) {
                        self.animatedViews[matchingIndex].shouldAnimate = true
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(self.animatedViews.count) + 1) {
                completion(true)
            }
            
            
            
        }
    }
    
}



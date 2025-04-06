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

class MatchedClass : BaseSwipeClass, MatchedGeometryProtocol {
    @Published var littleCircledStack: [RankedCircledImage] = []
}



class GeneralSwipeClass : BaseSwipeClass, MatchedGeometryProtocol, ScrollSwipeDelegate {
    
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
    
    
}



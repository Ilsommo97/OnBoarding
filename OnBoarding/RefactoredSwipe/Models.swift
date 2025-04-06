//
//  Models.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 01/04/25.
//
import Photos
import SwiftUI

struct AssetWrapper : Identifiable{
    var id: UUID = .init()
    var phasset : PHAsset
    var isKept : Bool
    var isTrashed : Bool
    var score : Double
}

struct CardContent : Identifiable, Equatable {
    
    var id : UUID = UUID()
    
    var asset : PHAsset  // use this property to check if video
     
    var image: UIImage?
    
    var aspectRatio: ContentMode {
        guard let image else { return .fill }
        
        // Compare width to height to determine orientation
        return image.size.width > image.size.height ? .fit : .fill
    }
}

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
    
    var image : UIImage?
    
    var shouldAnimate = false
    
    var matchedId : String
    
    var fromDimension : CGSize
    
    var rotation : Double
    
    var toDimension : CGSize
    
    var offsetY : Double = 0
    
    var offsetX : Double = 0
    
}



//


import SwiftUI

struct MatchedGeometryModel : Identifiable, Hashable {
    var id : UUID = UUID()
    
    var width : CGFloat?
    
    var height : CGFloat?
    
    var image : UIImage
    
    var contentMode : ContentMode
    
    var cornerRadius : Double
    
    var fromMatchedString : String
    
    var toMatchedString : String
    
    var isAlredayInViewTree : Bool
    
}

struct AnimationGeometryModel : Identifiable {
    
    
    var id : UUID = UUID()
    
    var image : UIImage
    
    var fromWidth : CGFloat?
    
    var toWidth : CGFloat?
    
    var fromHeight : CGFloat?
    
    var toHeight : CGFloat?
    
    var fromContentMode : ContentMode
    
    var toContentMode : ContentMode
    
    var fromCornerRadius : Double
    
    var toCornerRadius : Double
    
    var fromMatchedString : String
    
    var toMatchedString : String
    
    var shouldAnimate : Bool = false
    
//    static func createFromModels(fromModel : MatchedGeometryModel, toModel : MatchedGeometryModel) -> AnimationGeometryModel {
//        
//        assert(fromModel.isAlredayInViewTree == true, " From model passed is not in view tree from its property ")
//        assert(toModel.isAlredayInViewTree == false, " To model passed is in view tree from its property ")
//        
//        return .init(image: fromModel.image,
//                     fromWidth: fromModel.width, toWidth: toModel.width,
//                     fromHeight: fromModel.height, toHeight: toModel.height,
//                     fromContentMode: fromModel.contentMode, toContentMode: toModel.contentMode,
//                     fromCornerRadius: fromModel.cornerRadius, toCornerRadius: toModel.cornerRadius,
//                     fromMatchedString: fromModel.mathedString, toMatchedString: toModel.mathedString)
//    }
    
}


//MARK: -- A utility function to match the models. Made by DeepSeek.

//func matchModels(
//    from fromViews: Set<MatchedGeometryModel>,
//    to toViews: Set<MatchedGeometryModel>
//) -> [(fromModel: MatchedGeometryModel, toModel: MatchedGeometryModel)] {
//    var matchedPairs = [(MatchedGeometryModel, MatchedGeometryModel)]()
//    
//    // Create a dictionary for quick lookup of toViews by their matchedString
//    let toViewsDict = Dictionary(uniqueKeysWithValues: toViews.map { ($0.mathedString, $0) })
//    print("from views count is \(fromViews.count) and to views count is \(toViews.count)")
//    for fromModel in fromViews {
//        // Convert fromModel's matchedString to what we expect in toViews
//        // This assumes the pattern is "fromX" -> "toX"
//        let toMatchedString = fromModel.mathedString.replacingOccurrences(of: "from", with: "to")
//        if let toModel = toViewsDict[toMatchedString] {
//            matchedPairs.append((fromModel, toModel))
//        }
//    }
//    
//    return matchedPairs
//}

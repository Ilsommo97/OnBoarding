//
//  MatchedGeoProtocol.swift
//  MatchedGeometryMadeEasy
//
//  Created by Simone De Angelis on 08/04/25.
//
import SwiftUI

public func scaleHeight(_ value: CGFloat, forDesignHeight designHeight: CGFloat = 852) -> CGFloat {
    let screenHeight = UIScreen.main.bounds.height
    return (value / designHeight) * screenHeight
}

//MARK: -- Implementation of the coordinator.

/// We can create a base class conforming to the coordinator. 

protocol MatchedGeometryCoordinator : ObservableObject {
    
    // When applying the custom matched geo modifier, the models will be inserted into this set. The implemented function in this protocol its going to create the matched animated models automatically
    var fromViews : Set<MatchedGeometryModel> { get set }
    var toViews : Set<MatchedGeometryModel> {get set}
    //MARK: -- The list of properties that need to be published!
    var shouldDestroyFromView : Bool { get set }
    var shouldHideFromViews : Bool { get set }
    var shouldHideToViews : Bool { get set }
    var animatedViews : [AnimationGeometryModel] {get set}
    var shouldChangeView : Bool {get set} // This one is animated by the coordinator function and it should be implemnted by the container view!
    var animationHasFinished : Bool { get set }
    func startAnimatingOverlayCopies(completion: @escaping (Bool) -> Void) // success value in bool
    
    func optionalModificationAnimatedViews() -> Void
    
}


extension MatchedGeometryCoordinator {
    
    //MARK: -- We need to change this method. As of now, the matched animated views are not created until the method is called.
    /// The modifiers on the on appear create the from and to models.
    
    // The issue with this approach is that the animated views dont have time to be rednered in the from positions, since they get destroyed when we change the views
    
    
    func startAnimating() {
        
        //MARK: -- The function that triggers the change in the view tree. Implemented in the container view
        startCreatingAnimatedViewsBeforeAnimationStarts()
        optionalModificationAnimatedViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {[self] in
            withAnimation(.linear(duration: 0.6)) {
                self.shouldChangeView.toggle()
            }
            shouldHideFromViews = true
            shouldHideToViews = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {[self] in
                // After the delay, we can start collecting infos propagated by the custom modifiers!
                // We need to match the from views and the to views. They will share the matchedString property, that is composed like: "from\(ID)" and "to\(ID)"
                
                //MARK: -- We now change animatedmodels, then we animate
                for (index,model) in self.animatedViews.enumerated() {
                    if shouldChangeView {
                        // from -> to
                        if let match = self.toViews.first(where: {$0.toMatchedString == model.toMatchedString}) {
                            // we have a match with the current model!
                            self.animatedViews[index].toCornerRadius = match.cornerRadius
                            self.animatedViews[index].toWidth = match.width
                            self.animatedViews[index].toHeight = match.height
                            self.animatedViews[index].toContentMode = match.contentMode
                            
                        }
                    }
                    else {
                        // to -> from
                        if let match = self.fromViews.first(where: {$0.toMatchedString == model.toMatchedString  }) {
                            self.animatedViews[index].fromCornerRadius = match.cornerRadius
                            self.animatedViews[index].fromWidth = match.width
                            self.animatedViews[index].fromHeight = match.height
                            self.animatedViews[index].fromContentMode = match.contentMode
                            
                        }
                    }
                }
                
                // We now collected the pairs. We can start animating them!
                startAnimatingOverlayCopies() {[weak self]  success in// Completion of the animation!
                    guard let self else {return}
                    self.shouldHideToViews = false
                    self.shouldHideFromViews = false
                    self.animatedViews.removeAll() // this should cleanup the ui
                    animationHasFinished = true
                    if self.shouldChangeView {
                        self.fromViews.removeAll()
                    }
                    else {
                        self.toViews.removeAll()
                    }
               
                    
                }
            }
        }
        
        
    }
    
    private func startCreatingAnimatedViewsBeforeAnimationStarts() {
        for view in shouldChangeView ? toViews : fromViews {
            if shouldChangeView {
                // When shouldChangeView is true, use toViews
                // Set "to" properties from the view and use placeholders for "from" properties
                animatedViews.append(.init(
                    image: view.image,
                    fromWidth: 0,  // Placeholder
                    fromHeight: 0, // Placeholder
                    fromContentMode: .fill, // Placeholder
                    toContentMode: view.contentMode,
                    fromCornerRadius: 0, // Placeholder
                    toCornerRadius: view.cornerRadius,
                    fromMatchedString: view.fromMatchedString,
                    toMatchedString: view.toMatchedString
                ))
            } else {
                // When shouldChangeView is false, use fromViews (your original implementation)
                animatedViews.append(.init(
                    image: view.image,
                    fromWidth: view.width,
                    fromHeight: view.height,
                    fromContentMode: view.contentMode,
                    toContentMode: .fill,
                    fromCornerRadius: view.cornerRadius,
                    toCornerRadius: 0,
                    fromMatchedString: view.fromMatchedString,
                    toMatchedString: view.toMatchedString

                ))
            }
        }
    }
    
    func startAnimatingOverlayCopies(completion : @escaping (Bool) -> Void) {
        // A default implementation.
        let duration = 5.0
        withAnimation(.linear(duration: duration)) {
            for index in self.animatedViews.indices {
                self.animatedViews[index].shouldAnimate.toggle()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2 ) {
            completion(true)
        }


    }
    
    func optionalModificationAnimatedViews() {
        // Implement if needed
    }
}


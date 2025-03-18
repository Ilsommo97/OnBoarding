//
//  OBModel.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 10/03/25.
//

import SwiftUI


struct OBModel : Identifiable {
    
    var id : UUID = UUID()
        
    var title: String?
    
    var subtitle: String?
    
    var index : Int
    
    var buttonContent : (() -> ContentView)? = nil
    
    var onAppearHandler : () -> Void = {}
    
    
    static let features : [Self] = [
        .init(title: "What's most important to you when managing your camera roll?", subtitle: "Help us tailor SwAipe to your needs", index: 0),
        .init(title: "How many photos and videos you take per month on average?", subtitle: "Help us tailor SwAipe to your needs", index: 1),
        .init(title: "Please grant access to your camera roll", subtitle: "SwAipe needs access to your camera roll to work", index: 2),
        .init(title: "Gallery Breakdown", subtitle: "Select your preferred option", index: 3),
    ]
}


@Observable
class OBViewModel {
    
    struct DelayedAnimation {
        var animation : () -> Void
        var shouldTrigger : Bool
        
    }
    
    var models = OBModel.features
    
    var title : String? = "What's most important to you when managing your camera roll?"
    
    var subtitle: String? = "How many photos and videos you take per month on average?"

    var animations : [String : DelayedAnimation] = [:]
    
    func registerAnimation(id: String, animation: @escaping () -> Void ) {
        
        self.animations[id] = .init(animation: animation, shouldTrigger: true)
        print("registered!")
    }
    
    func triggerAnimation(id:String) {
        if let animation = self.animations[id] {
            if animation.shouldTrigger{
                animation.animation()
            }
        }
        else {
            print("Animation not registered yet")
        }
    }
    
    
}


// First screen : Option screen

// Second screen: NPhotos screen

// Third screen: Gallery breakdown --> Challenges: We need to trigger the animation of this view in a separate completion handler. on appear is not working



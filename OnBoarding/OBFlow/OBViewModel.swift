//
//  OBViewModel.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 16/03/25.
//

import SwiftUI



struct AnimationTrigger : Identifiable {
    
    var id : UUID = UUID()
    
    var animation : () -> Void
    
    var alreadyTriggered : Bool = false
}

@Observable
class OBViewModel2 {
    
    var animations : [String : AnimationTrigger] = [:]
    
    func triggerAnimation(_ forKey: String) {

        // MARK: -- A function called after the scroll animation completes
            // The on appear cant be called, we fall back to this approach. When scroll is detected, we trigger the animation registered for the view having as a string the same scroll position triggering the scroll detection. On appear of each view that needs animaition theyll register it there
        if let animation = animations[forKey],
           animation.alreadyTriggered == false
        {
            animation.animation()
        }
        else {
            if let animation = animations[forKey] {
                print("Animation already triggered")
            }
            else {
                print("Register the animation before calling it!")
            }
        }
    }
    
    func setAnimation(_ forKey: String, animation : @escaping () -> Void) {
        if let x = animations[forKey] {
            // skip
            print("Animation already set for this key!")
        }else {
            animations[forKey] = .init(animation: animation)
        }
    }
    
    
}

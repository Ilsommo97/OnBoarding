//
//  Cards.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 05/03/25.
//
import SwiftUI



struct CardCopyPaywall : Identifiable{
    var id : UUID = UUID()
    var offset : Double
    var rotation : Angle
    var image : ImageResource
    var heroAnimation: Bool
    var keep : Bool
    var score: Double
    
    static let features : [CardCopyPaywall] = [
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: true, score: 0.78),
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: true, score: 0.65),
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: false, score: 0),
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: false, score: 0),
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: true, score: 0.76),
        .init(offset: 0, rotation: .degrees(0), image: .canal, heroAnimation: false, keep: true, score: 0.88),
    ]

}




struct AutomatedCardSwipeViewOB: View {
    @State var background : ImageResource?
    @State private var translationX: CGFloat = 0
    @State private var rotation: Angle = .degrees(0)
    @State var middleTranslationY : Double = -40
    @State var lastTranslationY : Double = -75
    @State var middleScale : Double = 0.9
    @State var lastScale : Double = 0.8
    @State var imageQuee : [CardCopyPaywall] = CardCopyPaywall.features
    @State var imageCopies : [CardCopyPaywall] = []
    @Namespace var cardAnimation
//    var sizeHeight : Double = 550
//    var sizeWidth : Double = UIScreen.main.bounds.width
    var sizeHeight : Double = 450
    var sizeWidth : Double = 350
    let middleTranslation : Double = -40
    let lastTranslation : Double = -75
    var size: CGSize = .zero
    @Binding var stopCardAnimation: Bool
    @State var destroy = false
    var body: some View {
        Group {
            if !destroy {
                ZStack(alignment: .bottom) {
                    let scaledHeight = sizeHeight * 0.8
                    let heightDifferenceWhenScaled = (sizeHeight - scaledHeight) / 2
                    let heightToAccountFor = abs(lastTranslation) - heightDifferenceWhenScaled
                    Color.clear.frame(height: heightToAccountFor + sizeHeight)
                    if imageQuee.indices.contains(3) {
                        Image(imageQuee[3].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: sizeWidth - 20, height: sizeHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black, lineWidth: 1)
                            }
                            .scaleEffect(0.8)
                            .offset(y: lastTranslation)
                    }
                    if imageQuee.indices.contains(2) {
                        Image(imageQuee[2].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: sizeWidth - 20, height: sizeHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black, lineWidth: 1)
                            }
                            .scaleEffect(lastScale)
                            .offset(y: lastTranslationY)
                    }
                    if imageQuee.indices.contains(1) {
                        
                        Image(imageQuee[1].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: sizeWidth - 20, height: sizeHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black, lineWidth: 1)
                            }
                            .scaleEffect(middleScale)
                            .offset(y: middleTranslationY)
                    }
                    if imageQuee.indices.contains(0) {
                        
                        Image(imageQuee[0].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: sizeWidth - 20, height: sizeHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black, lineWidth: 1)
                            }
                            .offset(x: translationX)
                            .rotationEffect(rotation)
                    }
                    
                    ForEach(imageCopies) { copy in
                        
                        Color.clear
                            .matchedGeometryEffect(id:  "cardPos \(copy.id.uuidString)", in: cardAnimation, isSource: true)
                            .frame(width: sizeWidth - 20, height: sizeHeight)
                            .offset(x: copy.offset)
                            .rotationEffect(copy.rotation)
                            .overlay {
                                Image(copy.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: copy.heroAnimation ? 40
                                           : sizeWidth - 20 ,
                                           height: copy.heroAnimation ? 40 : sizeHeight
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: copy.heroAnimation ? 40 / 2 : 12))
                                
                                    .overlay {
                                        RoundedRectangle(cornerRadius: copy.heroAnimation ? 40 / 2 : 12)
                                            .stroke(.black, lineWidth: 1.5)
                                    }
                                    .rotationEffect(copy.rotation)
                                    .matchedGeometryEffect(id: copy.heroAnimation ? "littlePos \(copy.id.uuidString)" : "cardPos \(copy.id.uuidString)",
                                                           in: cardAnimation,
                                                           properties: .frame,
                                                           isSource: false
                                    )
                            }
                        
                        
                    }
                    
                }
                
                .onAppear {
                    animateCard()
                }
            }
        }
        .onChange(of: stopCardAnimation) { oldValue, newValue in
            if newValue {
                print("destroying the view")
                destroy = true
            }
        }
        .onDisappear {
            // Ensure cleanup when view disappears
            destroy = true
            stopCardAnimation = true
        }
    }
    
    private func animateCard() {
        guard imageQuee.count > 0 else { return }  // Add this check
        
        self.animateParameters {
            let copy = imageQuee[0]
            let keep = copy.keep
            let cardCopy : CardCopyPaywall = .init(offset: self.translationX, rotation: self.rotation, image: copy.image, heroAnimation: false, keep: copy.keep, score: copy.score)
            resetParameters()

            self.imageCopies.append(cardCopy)
            
            withAnimation(.linear(duration: 0.4)) {
                imageCopies[0].offset =  keep ? 500 : -500
            } completion: {
                self.imageCopies = []
                if !stopCardAnimation && !destroy {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Double-check destroy state right before animating again
                        if !destroy {
                            animateCard()
                        }
                    }
                }
            }
            
            
         
                   
        }
    }
    
    private func animateParameters(completion : @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.5)) {
            translationX = self.imageQuee[0].keep ? 75 : -75
            rotation = self.imageQuee[0].keep ? Angle(degrees: 15) : Angle(degrees: -15)
            middleTranslationY = 0
            middleScale = 1
            lastScale = 0.9
            lastTranslationY = -40
        } completion: {
            completion()
        }
    
    }
    private func finishAnimateParameters(completion : @escaping () -> Void) {
        withAnimation(.linear(duration: 0.2), completionCriteria: .removed) {
            background = imageQuee[0].image
            translationX = 400
        } completion: {
            completion()
        }

    }
    private func resetParameters() {
        if !imageQuee.isEmpty{
            let removed = imageQuee.remove(at: 0)
            imageQuee.append(removed)

        }
        translationX = 0
        middleTranslationY = -40
        lastTranslationY = -75
        rotation = Angle(degrees: 0)
        middleScale = 0.9
        lastScale = 0.8
        
        
        print("finished")
    }
}

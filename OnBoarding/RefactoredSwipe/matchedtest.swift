//
//  matchedtest.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 29/03/25.
//

import SwiftUI

struct MatchedTest : View {
    @Namespace var animation
    @State private var isExpanded = true
    @State var hideDuringTransition = false
    var body: some View {
        
    
        VStack{
            if isExpanded{
                Image(.canal)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .matchedGeometryEffect(id: "big",
                                           in: animation,
                                           properties: .position,
                                           isSource: true
                    )
                    .frame(width: 300, height: 300)
                    .clipShape(.rect(cornerRadius: 12))

                    .opacity(hideDuringTransition ? 0 : 1)
            }
  
            Button("Start transition") {
                //
                hideDuringTransition = true
                withAnimation(completionCriteria: .removed, {
                    self.isExpanded.toggle()

                }, completion: {
                    hideDuringTransition = false
                })
            }
            Spacer()
            if !isExpanded{
                Image(.canal)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(.rect(cornerRadius: 4))
                    .matchedGeometryEffect(id: "small", in: animation,properties: .position, isSource: true)
                    .opacity(hideDuringTransition ? 0 : 1)
            }

        }
        .overlay {
            Image(.canal)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: isExpanded ? 300 : 50, height: isExpanded ? 300 : 50)
                .clipShape(.rect(cornerRadius: isExpanded ? 12 : 4))
                .opacity(hideDuringTransition ? 1 : 0)
                .matchedGeometryEffect(id: isExpanded ? "big" : "small", in: animation, properties: .position, isSource: false)


            
        }
    }
}

#Preview {
    MatchedTest()
}

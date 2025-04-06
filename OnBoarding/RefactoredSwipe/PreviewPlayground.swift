//
//  GaugeTest.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 03/04/25.
//

import SwiftUI


struct playground:  View {
    
    @Namespace var animation
    @State var triggerView = false
    var body: some View {
        Group {
            if triggerView {
                Text("Titke")
                Button("toggle") {
                    triggerView.toggle()
                }
                HStack{
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                }
                .frame(height: 120)
                
                HStack{
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                }
                .frame(height: 120)
                HStack{
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                }
                .frame(height: 120)
                HStack{
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 100)
                }
                .frame(height: 120)
                VStack{
                    HStack{
                        RoundedRectangle(cornerRadius: 12)
                            .frame(height: 100)
                        RoundedRectangle(cornerRadius: 12)
                            .frame(height: 100)
                    }
                    .frame(height: 150)
                    
                    
                    Spacer()
                    Image(.canal)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .matchedGeometryEffect(id: "little", in: animation, properties: .position, isSource: true)
                }
                
            }
            else {
                Text("Ao")
                Button("toggle") {
                    triggerView.toggle()
                }
                Spacer()
                Image(.canal)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .matchedGeometryEffect(id: "little", in: animation, properties: .position, isSource: true)
            }
            
        }
        .overlay {
            // Animations overlay
            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.5))
                .frame(width: 100, height: 100)
                .matchedGeometryEffect(id: "little", in: animation, properties: .position, isSource: false)
                .padding(.leading, 200 )
        }
    }
}


#Preview {
    playground()
}


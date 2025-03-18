//
//  AnimatedStorageView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 16/03/25.
//

import SwiftUI


struct AnimatedStorageView: View {
    @Binding var page : Int
    @State var isLoading: Bool = true
    var body: some View {
        
        Group {
            if isLoading {
                VStack{
                    Text("Analyzing device storage ...")
                        .font(.title)
                        .fontWeight(.semibold)
                    ProgrammaticPulse(nCircles: 3) {
                        isLoading.toggle()
                    }
                }
                .preferredColorScheme(.dark)
            }
            else {
                FirstStorageView(page: $page)
            }
        }
        
    }
        
}

#Preview {
    AnimatedStorageView(page: .constant(1))
        .preferredColorScheme(.dark)
}

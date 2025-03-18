//
//  ContentView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 05/03/25.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        MainOB()
    }
}


struct FirstViewOB : View {
    @Binding var showFirstView: Bool
    var body: some View {
        if showFirstView {
            VStack(spacing: 12){
                
                Text("Hello, SwAipe")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()
                AutomatedCardSwipeViewOB(sizeHeight: 480, stopCardAnimation: .constant(false))
                //.padding(.top, 12)
                Spacer()
                
                Text("Ready to discover your best photos and free up space? Let's start!")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center) // Align text in the center
                    .lineLimit(nil) // Allow unlimited lines
                    .fixedSize(horizontal: false, vertical: true) // Prevents truncation
                
                
                ContinueButtonOB(text: "Get started") {
                    withAnimation {
                        showFirstView = false
                    }
                }
                
                
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        }

    }
}

struct GeneralBackground : View {
    var opacity : Double = 0.5
    var body: some View {
        ZStack
        {
            Image(.canal)
                .resizable()
                .blur(radius: 24)
            Color.black.opacity(opacity)
        }
        .ignoresSafeArea()
    }
}

struct ContinueButtonOB : View {
    var evaluateDisabling : () -> Bool = { false }
    var text : String = "Continue"
    var action : () -> Void = {}
    var body: some View {
        Button {
            action()
            
        } label: {
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    evaluateDisabling() ? .gray : .white
                )
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            evaluateDisabling() ? .black.opacity(0.5) : .black
                        )
                )
            
        }
        
        .disabled(evaluateDisabling())
    }
}





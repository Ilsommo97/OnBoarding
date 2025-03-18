//
//  OBContainerView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 07/03/25.
//

import SwiftUI


struct OBContainerView<Content: View>: View {

    @State var buttonText : String = "Continue"
    @State var progress : Float = 0
    
    @State private var currentIndex = 0 // Tracks current view index
    @State var title : String? = "What’s most important to you when managing your camera roll?"
    @State var subtitle : String?  = "Help us tailor SwAipe to your needs"

    @State var disableLogic : () -> Bool = {false}
    @Environment(OBViewModel.self) var viewModel : OBViewModel
    @ViewBuilder
    var content: Content
    

    
    var body: some View {
        VStack {
            // Progress and back arrow
            HStack {
                    Button {
                        //
                        withAnimation {
                            progress -= 1
                        }
                        
                    } label: {
                        Image(systemName: "arrow.backward")
                            .font(.title3)
                            .padding(.all, 10)
                            .background(
                                Circle()
                                    .fill(.black.opacity(0.3))
                            )
                            .padding(.trailing)
                    }
                    .disabled(progress == 0)
                
                Gauge(value: progress, in: 0...5) {
                    //
                }
                .tint(.white)
            }
            .padding(.bottom, 4)
            
            // Title elements
            if let title = viewModel.title,
               let subtitle = viewModel.subtitle
            {
                VStack(spacing: 0){
                    
                    HStack {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.leading, 10)
                    
                    
                    HStack{
                        Text(subtitle)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.top, 6)
                    
                }
                .frame(minHeight: 100)
            }
            Spacer()
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    content
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .onChange(of: progress) { oldValue, newValue in
                    evaluateHeader(newValue)
                    updateScrollPosition(proxy, newValue)
                }
            }
            Spacer()
            ContinueButtonOB(evaluateDisabling: disableLogic, text: buttonText) {
                withAnimation {
                    progress += 1
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
    
    func evaluateHeader(_ progress: Float) {
        if progress == 0 {
            viewModel.title = "What’s most important to you when managing your camera roll?"
            viewModel.subtitle = "Help us tailor SwAipe to your needs"
            disableLogic = { false }
            buttonText = "Continue"
        }
        else if progress == 1 {
            viewModel.title = "How many photos and videos you take per month on average?"
            viewModel.subtitle = "Help us tailor SwAipe to your needs"
            disableLogic = { false }
            buttonText = "Continue"

        }
        else if progress == 2 {
            viewModel.title = "Privacy matters to us"
            viewModel.subtitle = "Your photos and videos always stay safe on your device"
            buttonText = "Grant access"
            disableLogic = { false }
        }
        else if progress == 3 {
            viewModel.title = "Scanning your gallery..."
            viewModel.subtitle = "Analyzing your camera roll, this operation may take a few seconds"
        }
    }
    
    /// Updates scroll position when progress changes
    func updateScrollPosition(_ proxy: ScrollViewProxy, _ newProgress: Float) {
        let newIndex = Int(newProgress) // Assuming progress corresponds to page index
        print("new index is \(newIndex)")
        if newIndex != currentIndex {
            currentIndex = newIndex
            withAnimation {
                print("trying to scroll")
                proxy.scrollTo(newIndex, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35){
                viewModel.triggerAnimation(id: "\(newIndex)")

            }
        }
    }
}

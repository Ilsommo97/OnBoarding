//
//  OBContainerView 2.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 10/03/25.
//
import SwiftUI

//struct OBContainerView<Content: View>: View {
//    @State var buttonText: String = "Continue"
//    @State var progress: Float = 1.0
//    
//    @State private var currentIndex = 0 // Tracks current view index
//    @State var disableLogic: () -> Bool
//    
//    @Environment(OBViewModel.self) var viewModel : OBViewModel
//    
//    @ViewBuilder
//    var content: Content
//    
//    var body: some View {
//        VStack {
//            // Progress and back arrow
//            HStack {
//                Button {
//                    withAnimation {
//                        progress -= 1
//                        updateCurrentIndex(Int(progress))
//                    }
//                } label: {
//                    Image(systemName: "arrow.backward")
//                        .font(.title3)
//                        .padding(.all, 10)
//                        .background(
//                            Circle()
//                                .fill(.black.opacity(0.3))
//                        )
//                        .padding(.trailing)
//                }
//                .disabled(progress <= 1)
//                
//                Gauge(value: progress, in: 0...Float(viewModel.models.count)) {
//                    //
//                }
//                .tint(.white)
//            }
//            .padding(.bottom, 4)
//            
//            // Title elements
//            if let currentModel = getCurrentModel() {
//                VStack(spacing: 0) {
//                    HStack {
//                        Text(currentModel.title ?? "")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                        Spacer()
//                    }
//                    .padding(.leading, 10)
//                    
//                    HStack {
//                        Text(currentModel.subtitle ?? "")
//                            .font(.title3)
//                            .foregroundStyle(.secondary)
//                        
//                        Spacer()
//                    }
//                    .padding(.leading, 10)
//                    .padding(.top, 6)
//                }
//                .frame(minHeight: 100)
//            }
//            
//            Spacer()
//            
//            ScrollViewReader { proxy in
//                ScrollView(.horizontal) {
//                    content
//                }
//                .scrollTargetBehavior(.viewAligned)
//                .scrollIndicators(.hidden)
//                .scrollDisabled(true)
//                .onChange(of: progress) { oldValue, newValue in
//                    updateCurrentIndex(Int(newValue))
//                    updateScrollPosition(proxy, Int(newValue))
//                }
//            }
//            
//            Spacer()
//            
//            if let currentModel = getCurrentModel(), let buttonContent = currentModel.buttonContent {
//                buttonContent()
//            }
//            
//            ContinueButtonOB(evaluateDisabling: disableLogic, text: buttonText) {
//                withAnimation {
//                    progress += 1
//                    updateCurrentIndex(Int(progress))
//                }
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .frame(maxHeight: .infinity)
//        .onAppear {
//            // Initialize with the first model
//            if let model = viewModel.models.first {
//                updateCurrentIndex(model.index)
//                setButtonTextForCurrentModel()
//            }
//        }
//    }
//    
//    private func getCurrentModel() -> OBModel? {
//        viewModel.models.first { $0.index == currentIndex }
//    }
//    
//    private func updateCurrentIndex(_ index: Int) {
//        currentIndex = index
//        setButtonTextForCurrentModel()
//    }
//    
//    private func setButtonTextForCurrentModel() {
//        if let currentModel = getCurrentModel() {
//            // Set button text based on the current model
//            switch currentModel.index {
//                case 0, 1:
//                    buttonText = "Continue"
//                case 2:
//                    buttonText = "Grant access"
//                default:
//                    buttonText = "Continue"
//            }
//        }
//    }
//    
//    /// Updates scroll position when progress changes
//    private func updateScrollPosition(_ proxy: ScrollViewProxy, _ newIndex: Int) {
//        withAnimation {
//            proxy.scrollTo(newIndex, anchor: .center)
//        } completion: {
//            if let currentModel = getCurrentModel() {
//                currentModel.onAppearHandler()
//            }
//        }
//    }
//}

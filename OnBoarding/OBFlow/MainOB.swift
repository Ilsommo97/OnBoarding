//
//  MainOB.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 16/03/25.
//

import SwiftUI


struct MainOB: View {
    @State var showFirstView: Bool = true
    let viewModel = OBViewModel2()
    @State private var currentPage: Int = 0 // Track the current page index

    var body: some View {
        Group {
            if showFirstView {
                FirstViewOB(showFirstView: $showFirstView)
                    .background(GeneralBackground(opacity: 0.2))
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        HStack{
                            
                            AnimatedStorageView(page: $currentPage)
                                .containerRelativeFrame(.horizontal)
                                .id(0)
                            
                            SwipeChart(page: $currentPage)                              .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .containerRelativeFrame(.horizontal)
                                .id(1)
                     
                            PermissionView(page: $currentPage)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .containerRelativeFrame(.horizontal)
                                .id(2)
                            SimilarOB2(page: $currentPage)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .containerRelativeFrame(.horizontal)
                                .id(3)
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .scrollDisabled(true)
                    .background(GeneralBackground(opacity: 0.2))
                    .onChange(of: currentPage) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue)
                        }
                        if currentPage == 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                // after the scrroll ...
                                if let animation = viewModel.animations["similar"] {
                                    if !animation.alreadyTriggered {
                                        animation.animation()
                                    }
                                }
                                
                                if let animation = viewModel.animations["barAnimation"] {
                                    if !animation.alreadyTriggered {
                                        animation.animation()
                                        
                                    }
                                }
                            }
                        }
                    }

                }
            }
                
        }
        .environment(viewModel)
    }
}

#Preview {
    MainOB()
        .preferredColorScheme(.dark)
}

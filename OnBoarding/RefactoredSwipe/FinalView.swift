//
//  matchedtest.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 29/03/25.
//

import SwiftUI

struct InitialView : View {
    @State var finishedFetchingAssets : Bool = false
    @State var viewModel : GeneralSwipeClass?
    var body: some View {
        if !finishedFetchingAssets {
            Button("Fetch assets and switch view") {
                //
                let assets = AIPhotoManager.shared.fetchAllAssets().values
                print(assets)
                var wrappers = assets
                    .map({AssetWrapper(phasset: $0, isKept: false, isTrashed: false, score: Double.random(in: 0...1))})
                
                wrappers.sort(by: {$0.phasset.creationDate ?? .now > $1.phasset.creationDate ?? .now})
//                wrappers += wrappers
//                wrappers += wrappers
//                wrappers += wrappers
//                wrappers += wrappers
//                wrappers += wrappers
//                wrappers += wrappers
                viewModel = .init(cardQuee: Array(wrappers.prefix(20)), savedSize: 0)
              //  viewModel.cardSize = .init(width: UIScreen.main.bounds.width - 20, height: 500)
                finishedFetchingAssets.toggle()
            }
        }
        else {
            NavigationView {
                SwipeMockup(viewModel: viewModel!)
            }
          //  .environmentObject(viewModel)
     

        }
        
    }
}


struct SwipeMockup : View {
    @StateObject var viewModel : GeneralSwipeClass

    @Namespace var finishedAnimation
    var body: some View {
        
        
        
        MatchedContainerView<GeneralSwipeClass>(animation: finishedAnimation) {
            VStack {
                ScrollControlView()
                CardSwipeViewCoordinated<GeneralSwipeClass>(finishedAnimation: finishedAnimation)
            }
        } toView: {
            FinishedSwipeView(finishedAnimation: finishedAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(viewModel)
        .navigationTitle(viewModel.dateString)
        .background(GeneralBackground(opacity: 0.2))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }

            }
        }
        .onChange(of: viewModel.userCategorizedAll) { oldValue, newValue in
            if newValue {
                viewModel.startAnimating()
            }
        }
    }
}


struct FinishedSwipeView : View {
    @EnvironmentObject var viewModel : GeneralSwipeClass
    var finishedAnimation : Namespace.ID
    @State var bestShotOpacity : CGFloat = 0
    var body: some View {
        
        VStack{
            Text("Top views")
                .font(.title)
            Text("Sub title and other stuff")
           
            BestPhotosStack(finishedAnimation: finishedAnimation)
           
            Image(uiImage: self.viewModel.littleCircledStack.first?.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: viewModel.cardSize.width, height: viewModel.cardSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .modifier(
                    MatchedGeometryModifier(viewModel: viewModel, width: viewModel.cardSize.width, height: viewModel.cardSize.height, contentMode: .fill, cornerRadius: 12, fromId: "big", toId: "big", isFromView: false, namespace: finishedAnimation, image: self.viewModel.littleCircledStack.first?.image ?? UIImage())
                )
                .overlay(alignment: .bottom) {
                    Text("Best shot: 54.2 %")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .opacity(bestShotOpacity)
                        .padding()
                }
            
            Spacer()

    
            
            
        }
        .onChange(of: viewModel.animationHasFinished) { oldValue, newValue in
            if newValue {
                withAnimation {
                    bestShotOpacity = 1
                }
            }
        }

        
    }
}

struct BestPhotosStack : View {
    @EnvironmentObject var viewModel : GeneralSwipeClass
    var finishedAnimation : Namespace.ID
    
    var body: some View {
        HStack(spacing: 0){
            VStack(alignment: .leading ,spacing: scaleHeight(8)){
                Text("Best photos")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .overlay {
                        Color.clear.frame(width: 1, height: 1)
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: 0, height: 0, contentMode: .fill, cornerRadius: 0, fromId: "placeholder", toId: "placeholder", isFromView: false, namespace: finishedAnimation, image: UIImage())
                            )
                    }
                    
                HStack(spacing: 0){
                    if viewModel.littleCircledStack.count > 1 {
                        Image(uiImage: viewModel.littleCircledStack[1].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim))
                            .clipShape(RoundedRectangle(cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2 ))
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim), contentMode: .fill, cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2, fromId: "first", toId: "first", isFromView: false, namespace: finishedAnimation, image: viewModel.littleCircledStack[1].image)
                            )
                        
                    }
                    if viewModel.littleCircledStack.count > 2 {
                        Image(uiImage: viewModel.littleCircledStack[2].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim))
                            .clipShape(RoundedRectangle(cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2 ))
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim), contentMode: .fill, cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2, fromId: "second", toId: "second", isFromView: false, namespace: finishedAnimation, image: viewModel.littleCircledStack[2].image)
                            )
                            .offset(x:-15)
                       
                    }
                    if viewModel.littleCircledStack.count > 3 {
                        Image(uiImage: viewModel.littleCircledStack[3].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim))
                            .clipShape(RoundedRectangle(cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2 ))
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim), contentMode: .fill, cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2, fromId: "third", toId: "third", isFromView: false, namespace: finishedAnimation, image: viewModel.littleCircledStack[3].image)
                            )
                            .offset(x:-30)
                          
                    }
                    if viewModel.littleCircledStack.count > 4 {
                        Image(uiImage: viewModel.littleCircledStack[4].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim))
                            .clipShape(RoundedRectangle(cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2 ))
                 
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim), contentMode: .fill, cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2, fromId: "fourth", toId: "fourth", isFromView: false, namespace: finishedAnimation, image: viewModel.littleCircledStack[4].image)
                            )
                            .offset(x:-45)
                    }
                    if viewModel.littleCircledStack.count > 5 {
                        Image(uiImage: viewModel.littleCircledStack[5].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim))
                            .clipShape(RoundedRectangle(cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2 ))
              
                            .modifier(
                                MatchedGeometryModifier(viewModel: viewModel, width: scaleHeight(viewModel.littleCircleStackDim), height: scaleHeight(viewModel.littleCircleStackDim), contentMode: .fill, cornerRadius: scaleHeight(viewModel.littleCircleStackDim) / 2, fromId: "fifth", toId: "fifth", isFromView: false, namespace: finishedAnimation, image: viewModel.littleCircledStack[5].image)
                            )
                            .offset(x:-60)
                        
                        
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.title2)
        }
        .padding()
    }
}

struct LittleRankedCircledView : View {
    @EnvironmentObject var viewModel : GeneralSwipeClass
    var finalAnimation : Namespace.ID
    @Binding var childViewAppears : Bool
    var body: some View {
        ZStack{
            ScrollView(.horizontal) {
                HStack{
                    ForEach(viewModel.littleCircledStack) { model in
                        Image(uiImage: model.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: viewModel.littleCircleStackDim, height: viewModel.littleCircleStackDim)
                            .clipShape(RoundedRectangle(cornerRadius: viewModel.littleCircleStackDim / 2))
                            .matchedGeometryEffect(id: model.id.uuidString, in: finalAnimation, properties: .position, isSource: true)
                         //   .opacity(model.shouldHide ? 0 : 1)
                    }
                }
            }
        Color.clear
                .frame(width: 1, height: viewModel.littleCircleStackDim)
        }
        .padding(.horizontal)
        .onAppear{
            childViewAppears = true
        }
        
        
    }
}



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
                viewModel = .init(cardQuee: Array(wrappers.prefix(5)), savedSize: 0)
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

    @Namespace var scoreAnimation
    var body: some View {
        
        
        ZStack{
            if !viewModel.userCategorizedAll {
                VStack {
                    ScrollControlView()
                    CardSwipeView<GeneralSwipeClass>()
                }
            }
            else {
                FinishedSwipeView()
            }
            
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
    }
}

struct FinishedSwipeView : View {
    @EnvironmentObject var viewModel : GeneralSwipeClass
    @Namespace var finalAnimation
    @State var matchedGeoAnimation : Bool = false
    @State var childViewAppears = false
    var body: some View {
        
        VStack{
            Text("Top views")
                .font(.title)
            Text("Sub title and other stuff")
            
            Image(uiImage: self.viewModel.littleCircledStack.first?.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: viewModel.cardSize.width, height: viewModel.cardSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .matchedGeometryEffect(id: "big", in: finalAnimation, properties: .position, isSource: true)
                
            
            Spacer()
            
            LittleRankedCircledView(finalAnimation: finalAnimation, childViewAppears: $childViewAppears)
    
            
            
        }
        .overlay {
            if childViewAppears {
                Image(uiImage: self.viewModel.littleCircledStack.first?.image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: matchedGeoAnimation ? viewModel.cardSize.width - 20 :  100, height: matchedGeoAnimation ? viewModel.cardSize.height : 100)
                    .clipShape(RoundedRectangle(cornerRadius: matchedGeoAnimation ? 12 : 25))
                    .matchedGeometryEffect(
                        id: matchedGeoAnimation ? "big" : self.viewModel.littleCircledStack.first?.id.uuidString ?? "" ,
                        in: finalAnimation,
                        properties: .position,
                        isSource: false
                        
                    )
            }
                
        }
        .onAppear{
            for (index, _ ) in self.viewModel.littleCircledStack.enumerated(){
                self.viewModel.littleCircledStack[index].shouldHide = true
            }
           
        }
        .onChange(of: childViewAppears) { oldValue, newValue in
            if newValue {
                withAnimation(.linear(duration: 7)) {
                    matchedGeoAnimation.toggle()
                }
            }
        }
        
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



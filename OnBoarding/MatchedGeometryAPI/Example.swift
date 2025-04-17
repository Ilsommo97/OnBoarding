//
//  Playground.swift
//  MatchedGeometryMadeEasy
//
//  Created by Simone De Angelis on 10/04/25.
//

import SwiftUI

class CoinCoordinator : MatchedGeometryCoordinator {
    
    
    
    var fromViews: Set<MatchedGeometryModel> = .init()
    
    var toViews: Set<MatchedGeometryModel> = .init()
    
    
    @Published var shouldDestroyFromView: Bool = false
    @Published var shouldHideFromViews: Bool = false
    @Published var shouldHideToViews: Bool = false
    @Published var animatedViews: [AnimationGeometryModel] = []
    @Published var shouldChangeView: Bool = false
    @Published var animationHasFinished: Bool = false
    
    func startAnimatingOverlayCopies(completion: @escaping (Bool) -> Void) {
        let delay = 0.09
        for (index, _) in self.animatedViews.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                withAnimation(.bouncy(duration: 0.35)) {
                    self.animatedViews[index].shouldAnimate.toggle()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.animatedViews.count - 1) * delay + 0.4 ) {
            completion(true)
        }
    }
}

struct CoinView: View {
    @Namespace var animation
    @StateObject var viewModel : CoinCoordinator = .init()
    var body: some View {
        MatchedContainerView<CoinCoordinator>(animation: animation) {
            ExampleFromView(animation: animation)
        } toView: {
            ExampleToView(animation: animation)
        }
        .environmentObject(viewModel)

    }
}

struct ExampleFromView : View {

    @EnvironmentObject var viewModel : CoinCoordinator
    var animation : Namespace.ID
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    let numberOfItems = 28

    var body: some View {

        VStack{
            Text("Your coins")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()
                .padding(.bottom)
            
            Spacer()
            Button {
                //
                viewModel.startAnimating()
         
            } label: {
                Text("Tap to collect!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.yellow.opacity(0.8))
                    )
                    .tint(.black)
            }
            
            Spacer()
            LazyVGrid(columns: columns, spacing: 20) {

                ForEach(0..<numberOfItems, id: \.self) { index in
                    Image(.coin)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .modifier(MatchedGeometryModifier(viewModel: viewModel, width: 30, height: 30, contentMode: .fill, cornerRadius: 0, fromId: "coin\(index)", toId: "counter", isFromView: true, namespace: animation, image: .coin))

                }
            }
            .padding()
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .blue.opacity(0.35)
        )
    }
}

struct ExampleToView : View {
    @EnvironmentObject var viewModel : CoinCoordinator
    var animation : Namespace.ID

    var body: some View {
        VStack{
            VStack(spacing: 0){
                Text("Counter: 28")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Image(.coin)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .modifier(
                        MatchedGeometryModifier(viewModel: viewModel, width: 100, height: 100, contentMode: .fill, cornerRadius: 0, fromId: "counter", toId: "counter", isFromView: false, namespace: animation, image: .coin)
                    )
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            .blue.opacity(0.35)
        )
    }
}




#Preview {
    CoinView()
}

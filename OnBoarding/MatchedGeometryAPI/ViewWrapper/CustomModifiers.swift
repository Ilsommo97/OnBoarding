//
//  CustomModifiers.swift
//  MatchedGeometryMadeEasy
//
//  Created by Simone De Angelis on 10/04/25.
//

import SwiftUI


struct MatchedGeometryModifier <coordinator : MatchedGeometryCoordinator >: ViewModifier {
    @ObservedObject var viewModel: coordinator

    var width: CGFloat?
    var height: CGFloat?
    var contentMode: ContentMode
    var cornerRadius: Double
    var fromId: String
    var toId: String
    var isFromView: Bool
    var namespace: Namespace.ID
    var image: UIImage

    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: isFromView ? fromId : toId, in: namespace, properties: .position, isSource: true)
            .expressionModifier({ view in
                if isFromView {
                    view.opacity(viewModel.shouldHideToViews ? 0 : 1)
                }
                else
                {
                    view.opacity(viewModel.shouldHideFromViews ? 0 : 1)
                }
            })
            .onAppear(perform: propagateInfos)
            
    }
    
    private func propagateInfos() {
        let model = MatchedGeometryModel(
            width: width,
            height: height,
            image: image,
            contentMode: contentMode,
            cornerRadius: cornerRadius,
            fromMatchedString: fromId,
            toMatchedString: toId,
            isAlredayInViewTree: isFromView
        )
        print("propagtin infos")
        if isFromView {
            self.viewModel.fromViews.insert(model)
        } else {
            self.viewModel.toViews.insert(model)
        }
    }
}




protocol ProtocolA : ObservableObject { var shouldHide : Bool { get set } }

protocol ProtocolB : ObservableObject { var someProperty : Bool { get set } }

class TestViewModel : ProtocolA  {
    @Published var shouldHide = false
}

struct TestView : View {
    @StateObject var viewModel = TestViewModel()
    var body: some View {
        VStack { // Added VStack for layout
            ChildView<TestViewModel>() // Specify concrete type here
                .environmentObject(viewModel) // Inject instance

            Button("toggle") {
                viewModel.shouldHide.toggle()
                print("Button Toggled - viewModel.shouldHide = \(viewModel.shouldHide)")
            }
            .padding()
        }
    }
}

// ChildView stays generic
struct ChildView <CoordinatorType : ProtocolA> : View { // Use descriptive generic name
    @EnvironmentObject var viewModel : CoordinatorType // Receives concrete type instance
    var body: some View {
        // let _ = print("ChildView body - viewModel.shouldHide = \(viewModel.shouldHide)")
        Text("ChildView")
            
        if let viewModelB = viewModel as? any (ProtocolB) {
            Text("Conforming to protocol B!")
               // .modifier(TestModifier(viewModel: viewModelB))
            
        }
    }
}

import SwiftUI
import Combine // Make sure Combine is imported for ObservableObject



// --- Make TestModifier Generic ---
struct TestModifier<T: ProtocolB & ObservableObject> : ViewModifier { // T conforms to Dummy (and ObservableObject)

    // Use @ObservedObject because T is now a concrete ObservableObject type
    @ObservedObject var viewModel : T

    // Init takes the concrete type
    init(viewModel: T) {
        self.viewModel = viewModel
    }

    func body(content: Content) -> some View {
        // let _ = print("TestModifier body - viewModel.shouldHide = \(viewModel.shouldHide)")
        content
            .opacity(viewModel.someProperty ? 0 : 1)
   
    }
}


#Preview {
    TestView()
}


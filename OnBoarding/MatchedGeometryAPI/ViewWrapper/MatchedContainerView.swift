//
import SwiftUI


//MARK: -- Implementing the container view handling the from view and the to view.

struct MatchedContainerView<Coordinator: MatchedGeometryCoordinator>: View {
    @EnvironmentObject var viewmodel: Coordinator
    var animation : Namespace.ID
    private let fromViewBuilder: () -> AnyView
    private let toViewBuilder: () -> AnyView

    init<FromView: View, ToView: View>(
        animation: Namespace.ID,
        @ViewBuilder fromView: @escaping () -> FromView,
        @ViewBuilder toView: @escaping () -> ToView
    ) {
        self.animation = animation
        self.fromViewBuilder = { AnyView(fromView()) }
        self.toViewBuilder = { AnyView(toView()) }
    }

    var body: some View {
        ZStack {
            if !viewmodel.shouldDestroyFromView {
                fromViewBuilder()
                    .opacity(viewmodel.shouldChangeView ? 0 : 1)
            }
            if viewmodel.shouldChangeView {
                toViewBuilder()
            }
        }
        .overlay {
            ZStack {
                ForEach(viewmodel.animatedViews) { model in
                    Image(uiImage: model.image)
                        .resizable()
                        .aspectRatio(contentMode: model.shouldAnimate ? model.toContentMode : model.fromContentMode)
                        .frame(width: model.shouldAnimate ? model.toWidth : model.fromWidth,
                               height: model.shouldAnimate ? model.toHeight : model.fromHeight)
                        .clipShape(.rect(cornerRadius: model.shouldAnimate ? model.toCornerRadius : model.fromCornerRadius))
                        .matchedGeometryEffect(id: model.shouldAnimate ? model.toMatchedString : model.fromMatchedString, in: animation , properties: .position, isSource: false)
                        .allowsHitTesting(false)
                        .onAppear{
                            print("model is \(model)")
                        }
                        

                }
            }
        }

    }
}

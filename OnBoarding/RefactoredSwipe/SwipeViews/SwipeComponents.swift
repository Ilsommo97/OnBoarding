//
//  SwipeComponents.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 04/04/25.
//

import SwiftUI

struct ScrollControlView: View {
    @EnvironmentObject var viewModel: GeneralSwipeClass
    
    @State private var indicatorSize: CGSize = .init(width: 1, height: 30)
    
    private var maskHeight: CGFloat {
        guard !viewModel.cardQuee.isEmpty else { return 0 }
        let progress = Double(viewModel.categorizedCount) / Double(viewModel.cardQuee.count)
        return indicatorSize.height * min(max(progress, 0), 1) // Now directly proportional
    }
    
    var body: some View {
        HStack {
            scrollControls
            statsPanel
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }
    
    // MARK: - Subviews
    
    private var scrollControls: some View {
        HStack(spacing: 0) {
            backwardButton
            ScrollPreviewUIKit<GeneralSwipeClass>()
                .frame(height: viewModel.cellSize.height * 1.5)
            forwardButton
        }
        .frame(maxHeight: .infinity)
        .padding(.trailing)
    }
    
    private var backwardButton: some View {
        Button {
            viewModel.scrollBackward()
        } label: {
            Image(systemName: "backward.frame")
                .font(.headline.bold())
        }
        .disabled(viewModel.shouldDisableBackward)
    }
    
    private var forwardButton: some View {
        Button {
            viewModel.scrollForward()
        } label: {
            Image(systemName: "forward.frame")
                .font(.headline.bold())
        }
        .disabled(viewModel.shouldDisableForward)
    }
    
    private var statsPanel: some View {
        HStack {
            countStack
            countIndicator
            savedDataStack
        }
        .fixedSize(horizontal: false, vertical: false)
    }
    
    private var countStack: some View {
        VStack(spacing: 1) {
//            AnimatedNumberTextView(Double(viewModel.categorizedCount), content: { val in
//                Text(String(format: "%.0f", val))
//                    .font(.caption)
//            })
            Text("\(viewModel.categorizedCount)")
                .font(.callout)
            divider
            Text("\(viewModel.cardQuee.count)")
                .font(.caption)
        }
        .fixedSize()
    }
    
    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.secondary)
    }
    private var savedDataStack: some View {
        VStack(spacing: 1) {
            Text("Saved")
                .font(.headline)
            Text(
                viewModel.savedSize > 1000 ? String(format: "%.1f GB", Double(viewModel.savedSize) / 1000) :
                    String(format: "%.1f MB", viewModel.savedSize)
            )
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
    private var countIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(.black, lineWidth: 0.5)
                .frame(width: 10)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.indicatorSize = proxy.size
                                }
                            }
                    }
                }

            RoundedRectangle(cornerRadius: 2)
                .stroke(.black, lineWidth: 0.5)
                .fill(.white)
                .frame(width: 9)
                .mask(memoryIndicatorMask)
        }
        .padding(.vertical, 4)
        .padding(.trailing, 4)
    }
    
    private var memoryIndicatorMask: some View {
        RoundedRectangle(cornerRadius: 2)
            .frame(width: 9, height: maskHeight)
            .frame(maxHeight: .infinity, alignment: .bottom) // Changed to .top to fill downward
    }
}





struct CategorizedModifier : ViewModifier {
    var wrapper : AssetWrapper
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if wrapper.isTrashed {
                    LinearGradient(colors:
                                    [
                                    .red.opacity(0.3),
                                    .red.opacity(0.05),
                                    .clear,
                                    .clear
                                    ],
                                   startPoint: .bottom, endPoint: .center)
                }
                else if wrapper.isKept {
                    LinearGradient(colors:
                                    [
                                        .green.opacity(0.3),
                                        .green.opacity(0.05),
                                        .clear,
                                        .clear
                                    ],
                                   startPoint: .bottom, endPoint: .center)
                }
            }
            .overlay(alignment: .bottomLeading, content: {
                if wrapper.isKept {
                    Image(systemName: "heart.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green )
                        .padding()
                }
                else if wrapper.isTrashed {
                    Image(systemName: "trash.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red )
                        .padding()
                }
              
            })
    }
}

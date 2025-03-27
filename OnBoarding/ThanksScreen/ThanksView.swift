//
//  ThanksView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 20/03/25.
//

import SwiftUI


struct ThanksView : View {
    let giftGradient = LinearGradient(
        gradient: Gradient(colors: [Color.red.opacity(0.5), Color.orange, Color.yellow]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        VStack{
            Text("Give us a rating!")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            stars()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeneralBackground(opacity: 0.2))
    }
    
    private func stars() -> some View {
        HStack{
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        }
    }
}


#Preview {
    ThanksView()
        .preferredColorScheme(.dark)
}


//
//  PermissionView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 08/03/25.
//

import SwiftUI

struct PermissionView: View {
    @Binding var page : Int
    var body: some View {
        VStack{
  
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 100))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            VStack(spacing: 8){
                Text("Grant access to your camera roll.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text("Our AI runs entirely on your phone, ensuring that no data is uploaded or shared with third parties.")
                    .font(.headline)
                    .foregroundStyle(.primary)
               
            }
            Spacer()
            ContinueButtonOB() {
                withAnimation {
                    page += 1
                }
            }
            
        }
        .padding()
       
        
    }
}


#Preview {
    PermissionView(page: .constant(1))
}

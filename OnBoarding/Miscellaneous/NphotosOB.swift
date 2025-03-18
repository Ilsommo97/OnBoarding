//
//  NphotosOB2.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 07/03/25.
//

import SwiftUI


struct NphotosOB2: View {
    @State var nPhotos: Double = 50
    
    // Calculate GBs based on photo count (assuming 5MB per photo)
    var storageGB: Double {
        let totalSizeMB = nPhotos * 5.0
        return totalSizeMB / 1000 // Convert MB to GB
    }
    
    // Tailor the message based on photo count
    var storageMessage: String {
        switch nPhotos {
        case ..<250:
            return "You'll use about \(String(format: "%.1f", storageGB))GB, organizing your gallery will be a breeze!"
        case 250..<750:
            return "You’ll use about \(String(format: "%.1f", storageGB))GB per month. Let's keep your memories tidy!"
        case 750..<1000:
            return "You’ll use around \(String(format: "%.1f", storageGB))GB per month. Don’t worry, we’ve got you covered!"
        case 1000:
            return "You’ll use more than 5GB per month. Let's start right away!"
        default:
            return "Smth went wrong"
        }

        
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 8){
                Text("Photos and videos taken per month")
                    .font(.title3)
                    .fontWeight(.semibold)
                HStack{
                    Image(systemName: "camera.fill")
                        .font(.title3)
                    Text(nPhotos == 1000 ? String(format: "%.0f +", nPhotos) : String(format: "%.0f", nPhotos) )
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            HStack{
                Text("Casual \nCollector")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .fontWeight(nPhotos < 250 ? .bold : .regular)
                    .foregroundStyle(nPhotos < 250 ? .primary : .secondary)
                
                Spacer()
                Text("Memory \nMaker")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(nPhotos < 750 && nPhotos >= 250 ? .primary : .secondary)
                    .fontWeight(nPhotos < 750 && nPhotos >= 250  ? .bold : .regular)

                
                Spacer()
                Text("Photo \nEnthusiast")  // Updated label
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fontWeight(nPhotos >= 750 ? .bold : .regular)
                    .foregroundStyle(nPhotos >= 750 ? .primary : .secondary)
                
            }
            Slider(value: $nPhotos, in: 50...1000, step: 50) {
                Text("Photos")
            }
            HStack {
                Text("50")
                    .fontWeight(.semibold)
                Spacer()
                Text("1000+")
                    .fontWeight(.semibold)
                
            }
            
            // Updated HStack with dynamic GB calculation and tailored message
            HStack {
                Image(systemName: "externaldrive.fill")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.trailing, 4)
                
                Text(storageMessage)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.vertical)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.black.opacity(0.4))
  
                )

            .padding(.top, 16)
        }
        .animation(.easeIn(duration: 0.2), value: nPhotos)
    }
}

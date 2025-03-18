//
//  FirstStorageView.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 12/03/25.
//

import SwiftUI

struct FirstStorageView: View {
    @Binding var page : Int
    var usedStorage : Double = 232.643
    
    var totalStorage : Double = 255.1231
    
    var body: some View {
        VStack {
            // device at risk
            HeaderView()
                
            // chart stack
            StorageChartView2()
                .padding()
            
//            Text("You have 12 GB of available storage out of 256 GB on your device. ")
//                .foregroundStyle(.secondary)
//                .font(.headline)
//                .textReveal(duration: 0.8)
            
          //  Divider()
            
            InfoCardView(iconName: "tortoise.fill", title: "Slower Performance", description: "File operations (like saving, copying, or downloading) take longer due to fragmented storage", index: 0)
                .padding(.vertical, 6)
            
          //  Divider()
            
            InfoCardView(iconName: "battery.25percent", title: "Battery degradation", description: "Frequent read/write operations strain storage, increasing CPU usage and draining battery faster over time", index: 1)
                .padding(.bottom, 6)

          //  Divider()
            
            InfoCardView(iconName: "xmark.octagon.fill", title: "App crashes & freezes", description: "Low storage limits space for app data, causing slowdowns, crashes, or failed updates.", index: 2)
                .padding(.bottom, 6)

            Spacer()
            
            ContinueButtonOB(action:  {
                // on tap gesture
                withAnimation {
                    page += 1
                }
            })
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
   
    }
}





struct InfoCardView: View {
    let iconName: String
    let title: String
    let description: String
    let index: Int
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title)
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title2)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.4))
        )
        .delayedAppear(index: index)
    }
}

struct StorageChartView: View {
    let color = LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
    let afterColor = LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing)
    @State var layoutSizeWidth : Double = 0
    var body: some View {
    
        HStack(alignment: .top, spacing: 0 ) {
          
//            Text("little")
//                .font(.subheadline)
//                .layoutPriority(1) // Ensures text gets laid out first

           
            VStack(alignment: .leading){
                circledInfo(anyColor: AnyShapeStyle(color), text: "200 GB")
                circledInfo(anyColor: .init(.gray), text: "56 GB")
                Spacer()
                HStack{
                    Spacer()
                    VStack(spacing: 4){
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                            .font(.title2)
                        VStack(spacing: 0) {
                            Text("Risk")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            Text("Category")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                 
                        
                    }
                    Spacer()
   
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .background {
                GeometryReader { proxy in
                    Color.clear.onAppear{
                        print("size is \(proxy.size.width)")
                        layoutSizeWidth = proxy.size.width
                    }
                }
            }
//            Text("34 / 256 GB ")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
            Spacer()
            StorageChart(usedStorage: 180,
                         totalStorage: 256,
                         dim: 150,
                         linewidth: 14)
                .overlay {
                    VStack {
                        Text("85%")
                            .fontWeight(.semibold)
                            .font(.title)
                        Text("Occupied")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            Spacer()// Ensures flexible spacing
            VStack(alignment: .leading){
                circledInfo(anyColor: AnyShapeStyle(color), text: "Used")
                circledInfo(anyColor: AnyShapeStyle(.gray), text: "Free")
            }
            .frame(maxWidth: layoutSizeWidth)
           // .frame(maxWidth: 60)


        }
        .fixedSize(horizontal: false, vertical: true)



//            .overlay(alignment: .topTrailing) {
               
//                .offset(x: 70)
//            }
        // embedded in a hastack with the storage chart
        //   Spacer()
        //            VStack(alignment: .leading) {
        //                // Used space
        //                HStack(alignment: .center) {
        //                    Circle()
        //                        .fill(color)
        //                        .frame(width: 15, height: 15)
        //                    Text("Used space: ")
        //                        .fontWeight(.light)
        //                        .foregroundStyle(.primary)
        //                    +
        //                    Text("243 GB")
        //                        .fontWeight(.semibold)
        //                }
        //                // Free space
        //                HStack(alignment: .center) {
        //                    Circle()
        //                        .fill(.secondary)
        //                        .frame(width: 15, height: 15)
        //                    Text("Free space: ")
        //                        .fontWeight(.light)
        //                        .foregroundStyle(.primary)
        //                    +
        //                    Text("12 GB")
        //                        .fontWeight(.semibold)
        //                }
        //                Spacer()
        //                Button {
        //                    // Action
        //                } label: {
        //                    Text("You are in the risk\n category. Learn more")
        //                        .font(.headline)
        //                        .fontWeight(.semibold)
        //                        .frame(maxWidth: .infinity, alignment: .center)
        //                }
        //                Spacer()
        //            }
        //            .fixedSize(horizontal: true, vertical: false)
        //            .textReveal(duration: 0.8)
        //
        //        .padding(.horizontal)
        //        .padding(.vertical, 16)
        // .fixedSize(horizontal: false, vertical: true)
    }
    
    
    private func circledInfo(anyColor: AnyShapeStyle, text : String) -> some View {
        
        HStack(spacing: 4){
            Circle()
                .fill(anyColor)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.headline)
                
        }
        
        
    }
}



struct StorageChartView2: View {
    let color = LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
    let afterColor = LinearGradient(colors: [.green, .yellow], startPoint: .leading, endPoint: .trailing)
    @State var layoutSizeWidth : Double = 0
    var body: some View {
    
        HStack(alignment: .top, spacing: 0 ) {
            StorageChart(usedStorage: 180,
                         totalStorage: 256,
                         dim: 160,
                         linewidth: 14)
                .overlay {
                    VStack(spacing: 4) {
                        Text("85%")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Occupied")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            Spacer()
            VStack(alignment: .center, spacing: 12){
                VStack(alignment: .leading, spacing: 12) {
                    circledInfo(anyColor: AnyShapeStyle(color), text: "220 GB")
                    circledInfo(anyColor: AnyShapeStyle(.gray), text: "36 GB", free: true)
                    
                 
                }
                Spacer()
                VStack(spacing: 4 ) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                    Text("Device at risk")
                        .font(.title3)
                        .fontWeight(.bold)
                        
                    Button {
                        //
                    } label: {
                        Text("Why?")
                            .fontWeight(.bold)
                    }

                    
                }
                    
        
                
                
         
                
            }
            .fixedSize()
           // .frame(maxWidth: .infinity)
       
         //   Spacer()


        }
        //.padding()

    }
    
    
    private func circledInfo(anyColor: AnyShapeStyle, text : String, free: Bool = false) -> some View {
        
        HStack(spacing: 12){
            Image(systemName: "circle.fill")
                .foregroundStyle(anyColor)
                .frame(width: 10, height: 10)
            Text( free ? "Free: " : "Used: ")
                .foregroundStyle(.secondary)
                .font(.title3)
            +
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                
        }
        
        
    }
}
struct HeaderView: View {
    var body: some View {
   
            Text("You're low on storage")
                .font(.title)
                .fontWeight(.bold)
                .textReveal(duration: 0.8)
    }
}


#Preview {
 
    FirstStorageView(page: .constant(1))
        .overlay {
            Rectangle()
                .fill(.red)
                .frame(width: 3, height: 800)
        }
        .preferredColorScheme(.dark)
}

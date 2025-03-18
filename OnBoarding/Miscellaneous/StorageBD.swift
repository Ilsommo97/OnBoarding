//
//  StorageBD.swift
//  OnBoarding
//
//  Created by Simone De Angelis on 08/03/25.
//

import SwiftUI

struct StorageBreakdown: View {
    @Environment(OBViewModel.self) var viewModel : OBViewModel
    @State private var textIndex = 0
    let generator = UIImpactFeedbackGenerator(style: .light)
    @State var finishedScanning = false
    @State var usedStorage : Double = 0
    @State var totalStorage : Double = 0
    let texts = [
        "Analyzing device storage...",
        "Scanning your photos...",
        "Processing your videos...",
        "Done."
    ]
    
    
    
    var body: some View {
        VStack {
            if finishedScanning
            {
                VStack{
                    StorageChart(usedStorage: usedStorage, totalStorage: totalStorage)
               
                }
                    .padding(.all, 32)
                Spacer()
            }
            else {
                Text(texts[textIndex])
                    .font(.title2)
                    .fontWeight(.semibold)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: textIndex)
                
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .onAppear{
            viewModel.registerAnimation(id: "3") {
                Task {
                    try await Task.sleep(for: .seconds(1.5))
                    await MainActor.run {
                        textIndex = 1
                        generator.impactOccurred()
                    }
                    try await Task.sleep(for: .seconds(1.5))
                    await MainActor.run {
                        textIndex = 2
                        generator.impactOccurred()
                        
                    }
                    try await Task.sleep(for: .seconds(1.5))
                    await MainActor.run {
                        textIndex = 3
                        generator.impactOccurred()
                        withAnimation {
                            finishedScanning = true
                        } completion: {
                            viewModel.title = nil
                            viewModel.subtitle = nil
                        }
                    }
                    
                    
                }
                let x = readStorage()
                usedStorage = x.usedDiskGB
                totalStorage = x.totalDiskGB
            }
        }
    }
    
 
}

struct Test : View {
    @State var startAnimating = false
    var body: some View {
        VStack{
            Text("Your device breakdown")
                .font(.title)
                .fontWeight(.semibold)
                
            HStack(spacing: 24){
                StorageChart(){
                    print("ao")
                    startAnimating = true
                }
                VStack(alignment: .leading, spacing: 12){
                    Label("Photos: 4223", systemImage: "livephoto")
                        .delayedAppear(index: 1)
                    Label("Live photos: 56211", systemImage: "livephoto")
                        .delayedAppear(index: 2)
                    Label("ScreenShots: 7623", systemImage: "livephoto")
                        .delayedAppear(index: 3)
                    Label("Videos: 123", systemImage: "livephoto")
                        .delayedAppear(index: 4)
             
       
                }
            }
                .padding()
            Divider()
            if startAnimating{
                Text("You have")
                ForEach(0..<5) { index in
                    HStack{
                        Image(systemName: "livephoto")
                            .font(.title)
                        VStack(alignment:.leading){
                            Text("Live photos")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("The amount of live photos in the device")
                                .foregroundStyle(.secondary)
                            
                        }
                        Spacer()
                        Text("1223")
                            .fontWeight(.bold)
                            .font(.title2)
                    }
                    .padding(.all, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.4))
                    )
                    .delayedAppear(index: index)
                }
                Spacer()
            }
            else {
                Spacer()
            }
        }
        .padding()

        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeneralBackground(opacity: 0.2))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    Test()
}




struct StorageChart: View {
    @State var usedStorage: Double = 77 // Example value in GB
    @State var totalStorage: Double = 100 // Example value in GB
    @State private var usedProgress: Double = 0
    @State private var availableProgress: Double = 0
    @State private var textOpacity: Double = 0
    
    var dim = 120.0
    var linewidth = 12.0
    let angle: Angle = .degrees(270)
    
    var usedFraction: Double {
        usedStorage / totalStorage
    }
    var finishedCompletion : () -> Void = {}
    
    let color: AngularGradient = .init(
        gradient: Gradient(colors: [.green, .orange, .red, .red]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(270 + 380)
    )
   // let color : Color = .white
    
    var body: some View {
        
        ZStack {
            // Used storage arc (the white filled part)
            Circle()
                .trim(from: usedFraction + 0.04, to: usedFraction + availableProgress * (1 - usedFraction) - 0.04)
                //.stroke(.secondary, style: .init(lineWidth: 10, lineCap: .round, miterLimit: 190, dash: [1, 20]))
                .stroke(.secondary, style: .init(lineWidth: linewidth, lineCap: .round))

                .rotationEffect(angle)
                .frame(width: dim, height: dim)
//            
            Circle()
                .trim(from: 0, to: usedProgress * usedFraction)
                .stroke(color, style: .init(lineWidth: linewidth, lineCap: .round))
                .rotationEffect(angle)
                .frame(width: dim, height: dim)
                .overlay {
                    Circle()
                        .trim(from: 0, to: usedProgress * usedFraction)
                        .stroke(color, lineWidth: linewidth)
                        .rotationEffect(angle)
                        .frame(width: dim, height: dim)
                        .blur(radius: 8)
                }
            
            // Available storage dashed arc

//            
//            VStack {
//                Text("\(Int(totalStorage - usedStorage)) GB")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .opacity(textOpacity)
//                    .foregroundStyle(.secondary)
//                Text("Available")
//                    .font(.body)
//                    .opacity(textOpacity)
//            }
        }
        .onAppear {
            // First animation: solid part
            withAnimation(.spring(duration: 0.6), completionCriteria: .logicallyComplete) {
                usedProgress = 1.0
            } completion: {
                //
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.59) {
                withAnimation(.linear(duration: 0.6)) {
                    availableProgress = 1.0
                    textOpacity = 1.0
                }
                finishedCompletion()
            }
            
            
          
        }
    }
}

func readStorage() -> (totalDiskGB: Double, usedDiskGB: Double) {
    let totalDiskInSpaceInGB = Double(UIDevice.current.totalDiskSpaceInBytes) / (1000 * 1000 * 1000)
    let usedDiskInGB = Double( UIDevice.current.usedDiskSpaceInBytes) / (1000 * 1000 * 1000)
    
    return (totalDiskInSpaceInGB, usedDiskInGB)
}

extension UIDevice {
    
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
       return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }

}

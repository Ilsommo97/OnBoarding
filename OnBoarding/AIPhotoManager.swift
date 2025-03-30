//
//  AIPhotoManager.swift
//  PhotoCleanerAI
//
//  Created by Salvatore De Angelis on 12/06/2024.
//

import Foundation
import Photos
import UIKit
import Vision
struct PhotoManagerPhoto {
    
    var wrapper : AssetWrapper
    
    var image : UIImage
    
}

class AIPhotoManager {
    
    static let shared = AIPhotoManager()
    let imageManager = PHImageManager.default()
    
    
    func fetchPhotoExcludingScreenshots(shouldExcludeScreenshots: Bool) -> [PHAsset] {
        var photoAssets = [PHAsset]()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
      // fetchOptions.predicate = NSPredicate(format: "mediaSubtype != %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        fetchOptions.includeHiddenAssets = false


        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects { (asset, _, _) in
            if shouldExcludeScreenshots {
                if !(asset.mediaSubtypes == .photoScreenshot) {
                    photoAssets.append(asset)
                }
            }
            else {
                photoAssets.append(asset)
            }
        }
 
                
        return photoAssets
    }
    
    func fetchAllVideoAssets() -> [PHAsset] {
        var videoAssets = [PHAsset]()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        
        fetchResult.enumerateObjects { (asset, _, _) in
            videoAssets.append(asset)
        }
        
        return videoAssets
    }
    
    
    func fetchScreenshots() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        
        let screenshots = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var screenshotAssets: [PHAsset] = []
        screenshots.enumerateObjects { (asset, _, _) in
            screenshotAssets.append(asset)
        }
        
        return screenshotAssets
    }
    
    func fetchAllAssets() -> [String: PHAsset] {
        let fetchOptions = PHFetchOptions()
        let allAssets = PHAsset.fetchAssets(with: fetchOptions)
        var assetDictionary : [String: PHAsset] = [:]
        allAssets.enumerateObjects { asset, _, _ in
        
            assetDictionary[asset.localIdentifier] = asset
        }
        return assetDictionary
    }
    
    func requestPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization({status in
            
            switch status {
            case .authorized:
                print("Authorized")
            default:
                print("Not authorized")
            }
            
        })
    }
    
    func getImages(assets: [AssetWrapper],
                   resolutions: [CGSize]? = nil,
                   deliveryModes: [PHImageRequestOptionsDeliveryMode]? = nil ) async throws -> [PhotoManagerPhoto] {
        var finalReturn: [PhotoManagerPhoto] = []
        return try await withThrowingTaskGroup(of: PhotoManagerPhoto?.self) { group in
            for (index,wrapper) in assets.enumerated() {
                group.addTask() {
                    do {
                        if let deliveryModes, let resolutions {
                            assert(deliveryModes.count == assets.count && assets.count == resolutions.count, "Input arrays must be of the same length")
                            let image = try await AIPhotoManager.shared.getImageFromAssetAsync(asset: wrapper.phasset,
                                                                                               targetSize: resolutions[index] ,
                                                                                               deliveryMode: deliveryModes[index])
                            print("index is \(index) and res is \(resolutions[index]) with deliv mode \(deliveryModes[index])")
                            return PhotoManagerPhoto(wrapper: wrapper, image: image)
                        }
                        
                        let image = try await AIPhotoManager.shared.getImageFromAssetAsync(asset: wrapper.phasset,
                                                                                           targetSize: CGSize(width: 200, height: 200),
                                                                                           deliveryMode: .fastFormat)
                        
                        return PhotoManagerPhoto(wrapper: wrapper, image: image)
                    } catch {
                        print("Error retrieving image for asset \(wrapper.phasset.localIdentifier): \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            
            // Collect results as they complete
            for try await result in group {
                if let photo = result {
                    finalReturn.append(photo)
                } else {
                    print("A task in the group returned nil.")
                }
            }
            
            return finalReturn
        }
    }
    
//    func fetchPHAssets(from localAssets: [LocalAsset]) -> [PHAsset?] {
//      
//        let identifiers = localAssets.compactMap { $0.localIdentifier }
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
//        
//        var assetDict = [String: PHAsset]()
//        fetchResult.enumerateObjects { (asset, _, _) in
//            assetDict[asset.localIdentifier] = asset
//        }
//        
//        return identifiers.compactMap { assetDict[$0] }
//    }
    
    func getImageFromAssetAsync(asset: PHAsset, targetSize: CGSize, deliveryMode: PHImageRequestOptionsDeliveryMode) async throws -> UIImage {

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = deliveryMode
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        return try await withCheckedThrowingContinuation { continuation in
            
            var hasResumed = false
            
            imageManager.requestImage(for: asset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFit,
                                      options: requestOptions) { (image, info) in
                guard !hasResumed else {
                    print("we're avoiding a crash due to the same continuation being called multiple times! ")
                    return
                }
                hasResumed = true
                
                if let image = image {
                    continuation.resume(returning: image)
                } else {
                    print("the continaution is resuming a error")
                    continuation.resume(throwing: FetchAssetError.imageNil)
                }
            }
        }
    }
    
}



enum AVAssetError : Error {
    case unk
    
    case assetNil
    
    case cancelled
}


import AVFoundation
extension AIPhotoManager {
    
    enum FetchAssetError : Error {
        case imageNil
    }
    
    
    //MARK: -- Video helper function
    func getAvAssetFromAssetAsync(asset: PHAsset) async throws -> AVAsset {
        try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.version = .current

            imageManager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
                // info is of type [AnyHashable : Any]?
                if let infoDictionary = info {
                    if let isFromICloud = infoDictionary[PHImageResultIsInCloudKey] as? Bool, isFromICloud {
                        print("Asset is from iCloud. Downloading...")
                    }
                    if let error = infoDictionary[PHImageErrorKey] as? Error {
                        print("Error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let isCancelled = infoDictionary[PHImageCancelledKey] as? Bool, isCancelled {
                        print("Request was cancelled")
                        continuation.resume(throwing: AVAssetError.cancelled)
                        return
                    }
                }
                
                if let avAsset = avAsset {
                    continuation.resume(returning: avAsset)
                    return
                } else {
                    print("are we throwing an error?")
                    continuation.resume(throwing: AVAssetError.assetNil)
                    return
                }
            }
        }
    }
    func getMultipleAVAssetAsync(assets : [PHAsset]) async throws -> [AVAsset] {
        
        try await withThrowingTaskGroup(of: (AVAsset?, Int).self) { group in
            
            for (index, asset) in assets.enumerated() {
                var avAsset : AVAsset? = nil
                group.addTask {
                    do {
                        avAsset = try await self.getAvAssetFromAssetAsync(asset: asset)
                    }
                    catch {
                        print("AVAsset could not be retrieved with error: \(error)")
                        throw error
                    }
                    return (avAsset, index)
                }
            }

            var resultArray : [(AVAsset, Int)] = []
            
            for try await result in group {
                //MARK: -- we now access the task group, awaiting for each result
                if result.0 != nil {
                    let newTuple = (result.0!, result.1)
                    resultArray.append(newTuple)
                }
            }
            
            return resultArray.sorted { $0.1 < $1.1 }.map{$0.0}
        }
        
    }

    func extractFirstAndLastFrame(from avAsset: AVAsset) async throws -> (firstFrame: CGImage, lastFrame: CGImage) {
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 150, height: 150)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        
        // Get duration safely
        let duration = try await avAsset.load(.duration)
        guard duration.isValid && duration > .zero else {
            throw NSError(domain: "InvalidDuration", code: -1, userInfo: nil)
        }
        
        // Fix last frame time (subtract 1 frame time)
        let firstFrameTime = CMTime.zero
        let lastFrameTime = duration - CMTime(value: 1, timescale: 1000) // Subtract 1ms
        
        @Sendable
        func generateImage(for time: CMTime) async throws -> CGImage {
            try await withCheckedThrowingContinuation { continuation in
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
                    _, cgImage, _, result, error in
                    
                    switch (result, error, cgImage) {
                    case (.cancelled, _, _):
                        continuation.resume(throwing: CancellationError())
                    case (_, let error?, _):
                        continuation.resume(throwing: error)
                    case (_, _, let cgImage?):
                        continuation.resume(returning: cgImage)
                    default:
                        continuation.resume(throwing: NSError(domain: "ImageError", code: -1))
                    }
                }
            }
        }
        
        async let firstFrame = generateImage(for: firstFrameTime)
        async let lastFrame = generateImage(for: lastFrameTime)
        
        return try await (firstFrame: firstFrame, lastFrame: lastFrame)
    }

    
    
}

@available(iOS 18.0, *)
extension AIPhotoManager {
    
    func calculateAesthicsScore(image: UIImage) async throws -> CGFloat? {
        // 1. Image to be processed
        guard let ciimage = CIImage(image: image) else { return nil }
        
        // 2. Set up the calculate image aesthetics scores request
        let request = CalculateImageAestheticsScoresRequest()
        
        // 3. Perform the request
        
        let observation = try await request.perform(on: ciimage)
        
        // 4. The resulting ImageAestheticsScoresObservation object
        if observation.isUtility {
            return nil
        }
        return CGFloat(observation.overallScore)
    }
}


// ph photo library stuff... deletion, ablums and more
extension AIPhotoManager {
    func performPhotoLibraryChanges(assets: [PHAsset], onSuccess: @escaping ([PHAsset]) -> Void, onError: @escaping (Error?) -> Void) {
            let assetIdentifiers = assets.map { $0.localIdentifier }
            let assetsToDelete = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assetsToDelete)
            } completionHandler: { success, completionError in
                DispatchQueue.main.async {
                    if success {
                        onSuccess(assets)
                    } else {
                        onError(completionError)
                    }
                }
            }
        }
    

    func createAlbumWithAssets(albumName: String, assets: [PHAsset], completion: @escaping (Bool, Error?) -> Void) {
        // Check if we already have the album
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Create album request
            let albumCreationRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            albumPlaceholder = albumCreationRequest.placeholderForCreatedAssetCollection
        }) { success, error in
            if success, let placeholder = albumPlaceholder {
                // Fetch the created album
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(false, NSError(domain: "AlbumCreation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch album"]))
                    return
                }
                // Add assets to the album
                PHPhotoLibrary.shared().performChanges({
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                        albumChangeRequest.addAssets(assets as NSFastEnumeration)
                    }
                }, completionHandler: completion)
            } else {
                completion(false, error)
            }
        }
    }

}

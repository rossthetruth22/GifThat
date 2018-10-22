//
//  PhotoService.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/4/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices
import FLAnimatedImage
import AVFoundation

class PhotoService {
    
    var assetCollection: PHAssetCollection!
    var cachingManager: PHCachingImageManager!
    var newImages = [FLAnimatedImage]()
    var videoURLString: String!
    var limages = [UIImage]()
    //var imageGenerator: AVAssetImageGenerator!
    //var fetchResult: PHFetchResult!
    
    //func getPhotos(size: CGSize), completionHandlerForData: @escaping (_ images: [FLAnimatedImage]? ) -> Void)

    
    
    func getPhotos(size: CGSize) -> [FLAnimatedImage]? {
    
        var images = [FLAnimatedImage]()
        
        guard let collectionAsset = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: nil).firstObject else{
            return nil
        }
        
        //let assetArray = imageAssets.objects(at: IndexSet(integersIn: 0..<imageAssets.count))
        
        let assetArray = PHAsset.fetchAssets(in: collectionAsset, options: nil)
        
        let assets = assetArray.objects(at: IndexSet(integersIn: 0..<assetArray.count))
        
        guard assets.count > 0 else {
            return nil
        }
        
        
        cachingManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFit, options: nil)
        
        //PHImageRequestOptions
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        for asset in assets{
            cachingManager.requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
                if let imageData = imageData{
                    
                    images.append(FLAnimatedImage(animatedGIFData: imageData))
                    
                }
            }
        }
        images.reverse()
        return images
    }
    
    
    func getVideos(size: CGSize) -> [[String:AnyObject]]?{
        
        var assetDictionaries = [[String:AnyObject]]()
        
        guard let collectionAsset = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil).firstObject else{
            return nil
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assetArray = PHAsset.fetchAssets(in: collectionAsset, options: nil)
        let assets = assetArray.objects(at: IndexSet(integersIn: 0..<assetArray.count))
        
        guard assets.count > 0 else {
            return nil
        }
        
        cachingManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFit, options: nil)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        
        
        for asset in assets{
            cachingManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, dictionary) in
                if let image = image{
                    
                    
                    let duration = asset.duration
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .positional
                    formatter.allowedUnits = [.minute, .second]
                    formatter.zeroFormattingBehavior = [.pad]
                    let formattedDuration = formatter.string(from: duration)
                    
                    let assetDictionary = ["Asset": asset, "Image": image, "Time": formattedDuration!] as [String : AnyObject]
                    
                    assetDictionaries.append(assetDictionary)
                }
            }
        }
        return assetDictionaries
    
    }
    
    func startCachingImages(assets: [PHAsset], size: CGSize){
        
        cachingManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFit, options: nil)
        
    }
    
    func getVideoPath(_ asset: PHAsset, completionHandlerForURL: @escaping (_ URL: URL?) -> Void){
        
        //var url = URL(string: "")
        
        cachingManager.requestAVAsset(forVideo: asset, options: nil) { (video, audioMix, dictionary) in
            if let video = video as? AVURLAsset{
                completionHandlerForURL(video.url)
                //url = video.url
                //print("Video link: \(video.url.absoluteString)")
            }else{
                completionHandlerForURL(nil)
            }
        }
    }
    
    func getVideoAsset(_ asset: PHAsset, completionHandlerForAsset: @escaping (_ AVAsset: AVURLAsset?) -> Void){
        cachingManager.requestAVAsset(forVideo: asset, options: nil) { (video, audioMix, dictionary) in
            guard let video = video as? AVURLAsset else{
                return
            }
            
            completionHandlerForAsset(video)
        
        }
    }
    
//    func getVideoFrames(_ asset: PHAsset ) -> [UIImage]{
//
//        var images = [UIImage]()
//        var vasset = AVURLAsset(url: URL(fileURLWithPath: ""))
//        getVideoAsset(asset) { (avasset) in
//            vasset = avasset!
//
//            self.getImages(vasset, completionHandler: { (image) in
//                images.append(image)
//                self.limages = images
//                print("image frame count: \(images.count)")
//            })
//
//            print("image frame count2: \(self.limages.count)")
//            //return images
//        }
//        print(images.count)
//        return images
//    }
    
//    private func getImages(_ asset: AVURLAsset, completionHandler: @escaping (_ image: UIImage) -> Void){
//
//        //var images = [UIImage]()
//        let times: [NSValue] = [CMTime(seconds: 0.0, preferredTimescale: 1) as NSValue, CMTime(seconds: 2, preferredTimescale: 1) as NSValue,
//                                CMTime(seconds: 3, preferredTimescale: 1) as NSValue]
//
//        let imageGenerator = AVAssetImageGenerator(asset: asset)
//        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (time1, image, time2, result, error) in
//            guard let image = image, error == nil else {return}
//            completionHandler(UIImage(cgImage: image))
//            //images.append(UIImage(cgImage: image))
//            //print("image frame count: \(images.count)")
//        }
//
//    }
    
    init() {
        
        assetCollection = PHAssetCollection()
        cachingManager = PHCachingImageManager()
        //imageGenerator = AVAssetImageGenerator()
        //newImages = FLAnimatedImage(
        
    }
    
    
}

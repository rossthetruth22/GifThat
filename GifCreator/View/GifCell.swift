//
//  GifCell.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/4/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Photos

class GifCell: UICollectionViewCell {
    
    
    @IBOutlet weak var gifImage: FLAnimatedImageView!
    var cachingImageManager = PHCachingImageManager()
    var asset: PHAsset!
    var animatedImage: FLAnimatedImage!
    //var cachingManager: PHCachingImageManager!
    var defaultImage: UIImage!
    

    
    func populateCell(with asset: PHAsset){
        cachingImageManager.startCachingImages(for: [asset], targetSize: self.intrinsicContentSize, contentMode: .aspectFit, options: nil)
        
        cachingImageManager.requestImage(for: asset, targetSize: self.intrinsicContentSize, contentMode: .aspectFit, options: nil) { (image, _) in
            if let image = image{
                self.defaultImage = image
                self.gifImage.image = self.defaultImage
            }
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        
        cachingImageManager.requestImageData(for: asset, options: options) { (imageData, _, _, _) in
            self.animatedImage = FLAnimatedImage(animatedGIFData: imageData)
        }
    }
    
}


extension FLAnimatedImageView{
    
    func fetchImage(asset: PHAsset){
        let cache = PHCachingImageManager()
        cache.startCachingImages(for: [asset], targetSize: self.intrinsicContentSize, contentMode: .aspectFit, options: nil)
        
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        
        cache.requestImage(for: asset, targetSize: self.intrinsicContentSize, contentMode: .aspectFit, options: options) { (image, _) in
            if let image = image{
                self.image = image

            }
        }

            PHCachingImageManager().requestImageData(for: asset, options: nil) { (imageData, _, _, _) in
                if let imageData = imageData{
                    //self.animatedImage.imageLazilyCached(at: 0)
                    self.animatedImage = FLAnimatedImage(animatedGIFData: imageData)
                    self.loopCompletionBlock = { (uint: UInt) -> Void in
                        self.stopAnimating()
                    }
                }
            }
    }
    
}

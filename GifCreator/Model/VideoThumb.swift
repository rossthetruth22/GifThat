//
//  VideoThumb.swift
//  GifCreator
//
//  Created by Royce Reynolds on 10/22/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import Foundation
import Photos

struct VideoThumb{
    
    var asset: PHAsset
    var image: UIImage
    var time: String
    
    init(asset: PHAsset, image: UIImage, time: String) {
        self.asset = asset
        self.image = image
        self.time = time
    }
}

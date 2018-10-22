//
//  TrimmedVideo.swift
//  GifCreator
//
//  Created by Royce Reynolds on 9/11/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import Foundation
import Photos

struct TrimmedVideo{
    var asset: AVAsset
    var startTime: CMTime
    var endTime: CMTime
    
    init(asset: AVAsset, startTime: CMTime, endTime: CMTime) {
        self.asset = asset
        self.startTime = startTime
        self.endTime = endTime
    }
}


